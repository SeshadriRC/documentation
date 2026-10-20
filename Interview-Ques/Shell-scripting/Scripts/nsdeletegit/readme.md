# GitOps Namespace Deletion Automation (`nsdeletegit.sh`)

A production shell automation script to decommission namespaces by removing onboarding YAML manifests from a Git repository, creating a feature branch, and automating the Git lifecycle with signal-trap rollback protection.

---

## Table of Contents

- [Problem Statement](#problem-statement)
- [High-Level Workflow](#high-level-workflow)
- [Step-by-Step Script Walkthrough](#step-by-step-script-walkthrough)
- [Important Shell Concepts Used](#important-shell-concepts-used)
  - [1. Parameterized Paths & Variables](#1-parameterized-paths--variables)
  - [2. Tracking Failures via Arrays](#2-tracking-failures-via-arrays)
  - [3. File Validation (`-f`)](#3-file-validation--f)
  - [4. Directory Validation (`-d`)](#4-directory-validation--d)
  - [5. Safe Navigation & Error Handling (`||`)](#5-safe-navigation--error-handling-)
  - [6. Git Automation & Branch Isolation](#6-git-automation--branch-isolation)
  - [7. Reusable Cleanup Function](#7-reusable-cleanup-function)
  - [8. Signal Trap Handling (`trap ... INT TERM`)](#8-signal-trap-handling-trap--int-term)
  - [9. Dedicated File Descriptors (`exec 3<`)](#9-dedicated-file-descriptors-exec-3)
  - [10. CSV Parsing with `IFS=','`](#10-csv-parsing-with-ifs)
  - [11. Cross-Platform Sanitization (`tr -d '\r'`, `xargs`)](#11-cross-platform-sanitization-tr--d-r-xargs)
  - [12. Dynamic Directory Resolution](#12-dynamic-directory-resolution)
  - [13. Wildcard Searching (`*.yaml`)](#13-wildcard-searching-yaml)
  - [14. Safe Bulk File Removal (`rm -f *.yaml`)](#14-safe-bulk-file-removal-rm--f-yaml)
  - [15. Automated Staging, Commit & Push](#15-automated-staging-commit--push)
- [30-Second Interview Pitch](#30-second-interview-pitch)
- [Related Guides](#related-guides)

---

## Problem Statement

In enterprise GitOps environments (such as Red Hat ACM or ArgoCD), namespace onboarding configurations are maintained as YAML manifests inside Git repositories across nested directory structures (`base/cluster/namespace`).

When applications or namespaces are decommissioned:
- Engineers previously had to manually navigate multiple levels of directory trees.
- Locate and delete the correct YAML files.
- Manually create feature branches, commit changes, and push.
- This manual process was repetitive, error-prone, and risked accidental file deletions or inconsistent Git histories.

**Solution:** `nsdeletegit.sh` automates the bulk deletion of namespace onboarding files using CSV input, automates the complete Git workflow, and guarantees repository consistency with signal traps.

---

## High-Level Workflow

```text
Input CSV
   ↓
Step 1: Validate CSV Existence
   ↓
Step 2: Validate Git Repo Directory
   ↓
Step 3: Checkout Master & Pull Latest
   ↓
Step 4: Create Dedicated Feature Branch
   ↓
Step 5: Setup Signal Trap for Automated Rollback
   ↓
Step 6: Open CSV on File Descriptor 3 & Skip Header
   ↓
Step 7: Loop & Sanitize (base, cluster, namespace)
   ↓
Step 8: Navigate to Target Directory & Delete *.yaml
   ↓
Step 9: Git Add, Commit with Prompt, and Push Branch
```

---

## Step-by-Step Script Walkthrough

### 1. Parameterized Paths & Variables
```bash
csv_file="${1:-/c/Users/src00/Desktop/input.csv}"
repo_path="${2:-/c/Users/src00/Desktop/dfs-acm-application-onboarding-crs}"
```
- **Interview note:** *"I parameterized input paths with sensible defaults so the script can either run interactively or as part of a CI/CD pipeline."*

### 2. Tracking Failures via Arrays
```bash
Skipped_ns=()
# If a folder or yaml is missing:
Skipped_ns+=("$dir (no yaml)")
```
- **Interview note:** *"I used an in-memory Bash array to log skipped or missing directories so a post-execution report can be presented to the operator."*

### 3. File Validation (`-f`)
```bash
if [[ ! -f "$csv_file" ]]; then
    echo "CSV file not found: $csv_file"
    exit 1
fi
```
- **Interview note:** *"Fails fast before touching any Git state if the CSV input file is missing."*

### 4. Directory Validation (`-d`)
```bash
if [[ ! -d "$repo_path" ]]; then
    echo "GitHub path invalid: $repo_path"
    exit 1
fi
```
- **Interview note:** *"Validates that the local clone exists before attempting any `cd` or `git` commands."*

### 5. Safe Navigation & Error Handling (`||`)
```bash
cd "$repo_path" || {
    echo "Failed to change directory"
    exit 1
}
```
- **Interview note:** *"Always use `cd ... || exit` to prevent subsequent commands from executing in the wrong directory if navigation fails."*

### 6. Git Automation & Branch Isolation
```bash
git checkout master && git pull origin master
read -p "Enter new git branch name: " branch_name
git checkout -b "$branch_name"
```
- **Interview note:** *"Pulls the latest remote state and creates an isolated feature branch so modifications never happen directly on master."*

### 7. Reusable Cleanup Function
```bash
cleanup_branch() {
    echo "Error occurred. Cleanup started"
    git checkout master
    git branch -D "$branch_name"
    git reset --hard origin/master
    exit 1
}
```
- **Interview note:** *"Implements automated rollback: checks out master, deletes the temporary branch, and resets to clean remote state."*

### 8. Signal Trap Handling (`trap ... INT TERM`)
```bash
trap cleanup_branch INT TERM
```
- **Interview note:** *"Catches `SIGINT` (Ctrl+C) or `SIGTERM` (kill) signals and automatically invokes `cleanup_branch` to ensure the repository is never left in a dirty or broken state."*

### 9. Dedicated File Descriptors (`exec 3<`)
```bash
exec 3< "$csv_file"
read -r <&3     # Skips header
while IFS=',' read -r base cluster ns <&3; do
    ...
done
exec 3<&-      # Closes FD 3
```
- **Interview note:** *"Using File Descriptor 3 separates CSV streaming from `stdin`, preventing subcommands from eating lines meant for the loop."*

### 10. CSV Parsing with `IFS=','`
```bash
while IFS=',' read -r base cluster ns <&3
```
- **Interview note:** *"Configures comma as the delimiter and disables backslash escaping with `-r`."*

### 11. Cross-Platform Sanitization (`tr -d '\r'`, `xargs`)
```bash
base=$(echo "$base" | tr -d '\r' | xargs)
cluster=$(echo "$cluster" | tr -d '\r' | xargs)
ns=$(echo "$ns" | tr -d '\r' | xargs)
```
- **Interview note:** *"Removes Windows carriage returns (`\r`) and strips surrounding whitespace to avoid broken path lookups."*

### 12. Dynamic Directory Resolution
```bash
dir="$base/$cluster/$ns"
```
- **Interview note:** *"Builds directory paths dynamically based on metadata extracted from each CSV row."*

### 13. Wildcard Searching (`*.yaml`)
```bash
yaml_files=$(ls *.yaml 2>/dev/null || true)
```
- **Interview note:** *"Identifies whether manifests exist in the directory before attempting deletion."*

### 14. Safe Bulk File Removal (`rm -f *.yaml`)
```bash
rm -f *.yaml
```
- **Interview note:** *"Removes onboarding manifests while leaving any non-YAML files or parent directory trees intact."*

### 15. Automated Staging, Commit & Push
```bash
git add .
read -p "Enter commit message: " commit_comment
git commit -m "$commit_comment"
git push origin "$branch_name"
```
- **Interview note:** *"Automates the entire staging, commit, and remote push cycle, preparing the branch for Pull Request review."*

---

## 30-Second Interview Pitch

> *"I developed a Bash automation script to decommission namespaces from our GitOps onboarding repository. The script validates input parameters, pulls latest changes from master, branches off into a dedicated feature branch, and registers a signal `trap` to safely rollback git state if interrupted. It parses a CSV using a dedicated file descriptor (`FD 3`), dynamically traverses the directory tree to delete application YAML manifests, tracks skipped paths in a Bash array, and automates git staging, committing, and pushing for peer review."*

---

## Related Guides

- Master Overview & Cluster Script Guide: [Scripts/README.md](../README.md)
- Live Cluster Decommission Script: [nsdeletecluster.sh](../nsdeletecluster.sh)
- Complete Interview Q&A Reference: [Interview-Q&A.md](../../Interview-Q%26A.md)
