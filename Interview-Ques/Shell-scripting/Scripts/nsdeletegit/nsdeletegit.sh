#!/bin/bash
# ==============================================================================
# Script Name   : nsdeletegit.sh
# Purpose       : Automate decommission of namespace onboarding YAML manifests
#                 from a GitOps repository, create a dedicated branch, commit
#                 the deletions, and push to origin with rollback safety.
# Author / Owner: Seshadri RC
#
# INTERVIEW TALKING POINTS & STEP-BY-STEP SUMMARY:
# ------------------------------------------------------------------------------
# 1. Why this script exists:
#    In a GitOps/ACM/ArgoCD architecture, cluster state is driven by Git. If an
#    engineer manually deletes files across dozens of nested directories, it is
#    time-consuming and error-prone. This script automates bulk manifest removal
#    from the Git repository based on a CSV input file, while maintaining Git
#    integrity and auditing via branch creation and commit tracking.
#
# 2. How it works (9 Sequential Steps):
#    Step 1: Input CSV File Validation (`[[ -f "$csv_file" ]]`).
#    Step 2: Git Repository Path Validation & Directory Change (`[[ -d ]]` + `|| exit`).
#    Step 3: Synchronize with Master (`git checkout master && git pull origin master`).
#    Step 4: Create a Dedicated Feature/Decommission Branch (`git checkout -b`).
#    Step 5: Rollback Handling via Trap (`trap cleanup_branch INT TERM`).
#    Step 6: Safe CSV Parsing Using File Descriptor 3 (`exec 3< "$csv_file"`).
#    Step 7: Dynamic Directory Resolution & Validation (`$base/$cluster/$ns`).
#    Step 8: YAML Manifest Search, Deletion (`rm *.yaml`), & Skipped Tracking.
#    Step 9: Git Operations: Status, Staging (`git add`), Commit, & Push (`git push`).
# ==============================================================================

# ------------------------------------------------------------------------------
# Configuration Variables
# ------------------------------------------------------------------------------
csv_file="${1:-/c/Users/src00/Desktop/input.csv}"
repo_path="${2:-/c/Users/src00/Desktop/dfs-acm-application-onboarding-crs}"

# Array to track namespaces skipped during processing (for post-execution reporting)
Skipped_ns=()

echo "=========================================================="
echo " Starting GitOps Namespace Deletion Automation"
echo "=========================================================="

# ------------------------------------------------------------------------------
# STEP 1: Validate CSV File Existence
# Interview note: We validate input before initiating any Git operations to fail fast.
# ------------------------------------------------------------------------------
echo "[+] Step 1: Validating CSV file..."
if [[ ! -f "$csv_file" ]]; then
    echo "[-] ERROR: CSV file not found: $csv_file"
    exit 1
fi
echo "[✓] CSV file validated."

# ------------------------------------------------------------------------------
# STEP 2: Validate Git Repository Path
# Interview note: Ensures the target repo exists and navigates into it safely using ||.
# ------------------------------------------------------------------------------
echo "[+] Step 2: Validating Git repository path..."
if [[ ! -d "$repo_path" ]]; then
    echo "[-] ERROR: Git repository directory not found: $repo_path"
    exit 1
fi

cd "$repo_path" || {
    echo "[-] ERROR: Failed to enter repository directory: $repo_path"
    exit 1
}
echo "[✓] Inside repository: $(pwd)"

# ------------------------------------------------------------------------------
# STEP 3: Switch to Master & Pull Latest Remote Changes
# Interview note: Always sync with remote origin/master to avoid branch conflicts.
# ------------------------------------------------------------------------------
echo "[+] Step 3: Checking out master and pulling latest changes..."
git checkout master && git pull origin master || {
    echo "[-] ERROR: Failed to pull latest changes from origin/master"
    exit 1
}
echo "[✓] Repository is up-to-date with origin/master."

# ------------------------------------------------------------------------------
# STEP 4: Create a New Dedicated Feature Branch
# Interview note: We never commit directly to master. A separate branch allows PR review.
# ------------------------------------------------------------------------------
echo "[+] Step 4: Creating new git branch..."
read -p "Enter new git branch name (e.g., decommission-batch-01): " branch_name

if [[ -z "$branch_name" ]]; then
    echo "[-] ERROR: Branch name cannot be empty."
    exit 1
fi

git checkout -b "$branch_name" || {
    echo "[-] ERROR: Failed to create and checkout branch: $branch_name"
    exit 1
}
echo "[✓] Switched to new branch: $branch_name"

# ------------------------------------------------------------------------------
# STEP 5: Rollback Function & Signal Trap Registration
# Interview note: If an engineer presses Ctrl+C (INT) or the process is killed (TERM),
# the trap triggers cleanup_branch to delete the uncommitted branch and reset to master.
# ------------------------------------------------------------------------------
cleanup_branch() {
    echo ""
    echo "[!] INTERRUPT OR ERROR DETECTED: Executing automated rollback..."
    git checkout master 2>/dev/null || true
    git branch -D "$branch_name" 2>/dev/null || true
    git reset --hard origin/master 2>/dev/null || true
    echo "[✓] Rollback complete. Repository restored to clean origin/master state."
    exit 1
}

# Trap SIGINT (Ctrl+C) and SIGTERM (kill)
trap cleanup_branch INT TERM

# ------------------------------------------------------------------------------
# STEP 6: Process CSV File Using Dedicated File Descriptor 3
# Interview note: Using `exec 3< "$csv_file"` separates CSV reading from stdin (FD 0),
# preventing subcommands or prompts from accidentally consuming CSV rows.
# ------------------------------------------------------------------------------
echo "[+] Step 6: Processing CSV entries..."

exec 3< "$csv_file"
# Skip the CSV header row (base,cluster,namespace)
read -r <&3

while IFS=',' read -r base cluster ns <&3; do
    # Sanitize inputs: remove carriage returns (\r from Windows CSVs) and trim spaces
    base=$(echo "${base:-}" | tr -d '\r' | xargs)
    cluster=$(echo "${cluster:-}" | tr -d '\r' | xargs)
    ns=$(echo "${ns:-}" | tr -d '\r' | xargs)

    if [[ -z "$base" || -z "$cluster" || -z "$ns" ]]; then
        echo "[!] WARN: Skipping row with empty values."
        continue
    fi

    dir="$base/$cluster/$ns"
    echo "----------------------------------------------------------"
    echo "[*] Checking target directory: $dir"

    # --------------------------------------------------------------------------
    # STEP 7: Validate Target Directory Existence
    # --------------------------------------------------------------------------
    if [[ -d "$dir" ]]; then
        cd "$dir" || {
            echo "[-] ERROR: Failed to enter directory: $dir"
            Skipped_ns+=("$dir (failed cd)")
            cd "$repo_path"
            continue
        }

        # ----------------------------------------------------------------------
        # STEP 8: Search and Delete YAML Manifest Files
        # ----------------------------------------------------------------------
        yaml_files=$(ls *.yaml 2>/dev/null || true)

        if [[ -z "$yaml_files" ]]; then
            echo "[!] No YAML files found in: $dir. Skipping."
            Skipped_ns+=("$dir (no yaml)")
        else
            echo "[+] Found YAML manifest(s):"
            echo "$yaml_files"
            echo "[+] Deleting YAML manifest files..."
            rm -f *.yaml
            echo "[✓] YAML files removed from $dir."
        fi

        # Always return to repo root
        cd "$repo_path" || cleanup_branch
    else
        echo "[!] Directory does not exist: $dir. Skipping."
        Skipped_ns+=("$dir (directory not found)")
    fi

done

# Close File Descriptor 3
exec 3<&-

# ------------------------------------------------------------------------------
# STEP 9: Git Operations: Status, Stage, Commit, and Push
# ------------------------------------------------------------------------------
echo "=========================================================="
echo "[+] Step 9: Finalizing Git Operations..."
echo "=========================================================="

cd "$repo_path" || cleanup_branch

echo "[+] Current Git Status:"
git status

echo "[+] Staging all changes..."
git add .
echo "[✓] Staging complete."

read -p "Enter commit message: " commit_comment
if [[ -z "$commit_comment" ]]; then
    commit_comment="decommission: remove onboarding manifests via automation"
fi

git commit -m "$commit_comment" || {
    echo "[-] ERROR: Commit failed or no changes to commit."
    cleanup_branch
}

echo "[+] Pushing branch '$branch_name' to origin..."
git push origin "$branch_name" || {
    echo "[-] ERROR: Failed to push branch to remote origin."
    cleanup_branch
}

echo "=========================================================="
echo "[✓] SUCCESS: All changes successfully committed and pushed!"
echo "    Branch: origin/$branch_name"
echo "=========================================================="

# Report any skipped namespaces
if [[ ${#Skipped_ns[@]} -gt 0 ]]; then
    echo ""
    echo "[!] Summary of Skipped Namespaces (${#Skipped_ns[@]} total):"
    for item in "${Skipped_ns[@]}"; do
        echo "    - $item"
    done
fi
