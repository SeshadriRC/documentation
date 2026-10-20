# Git Commands for DevOps Engineers

A comprehensive reference for version control, branch management, history manipulation, GitOps workflows, SSH authentication, and repository troubleshooting.

---

## Table of Contents

- [1. Setup & Configuration](#1-setup--configuration)
- [2. SSH Authentication & GitHub Setup Walkthrough](#2-ssh-authentication--github-setup-walkthrough)
  - [Step 1: Check for Existing SSH Keys](#step-1-check-for-existing-ssh-keys)
  - [Step 2: Generate a New SSH Key Pair](#step-2-generate-a-new-ssh-key-pair)
  - [Step 3: View and Copy Public SSH Key](#step-3-view-and-copy-public-ssh-key)
  - [Step 4: Add Public Key to GitHub Web UI](#step-4-add-public-key-to-github-web-ui)
  - [Step 5: Switch Existing Repository Remote from HTTPS to SSH](#step-5-switch-existing-repository-remote-from-https-to-ssh)
  - [Step 6: Test SSH Connection & Accept Host Fingerprint](#step-6-test-ssh-connection--accept-host-fingerprint)
  - [Step 7: Configure Git User Identity (Fix "Author identity unknown")](#step-7-configure-git-user-identity-fix-author-identity-unknown)
  - [Step 8: Stage, Commit, and Push over SSH](#step-8-stage-commit-and-push-over-ssh)
  - [Step 9: (Optional) Start SSH Agent & Add Private Key](#step-9-optional-start-ssh-agent--add-private-key)
  - [Step 10: (Optional) Configure `~/.ssh/config` for Multiple Accounts (Work vs Personal)](#step-10-optional-configure-sshconfig-for-multiple-accounts-work-vs-personal)
- [3. Basic Staging, Committing & Status](#3-basic-staging-committing--status)
- [4. Branching & Switching](#4-branching--switching)
- [5. Stashing Uncommitted Work](#5-stashing-uncommitted-work)
- [6. History, Inspection & Diffs](#6-history-inspection--diffs)
- [7. Undoing Changes & History Rewriting](#7-undoing-changes--history-rewriting)
- [8. Reflog & Disaster Recovery](#8-reflog--disaster-recovery)
- [9. Rebasing, Merging & Cherry-Picking](#9-rebasing-merging--cherry-picking)
- [10. Remotes & Synchronization](#10-remotes--synchronization)
- [11. Tags & Releases](#11-tags--releases)
- [12. Maintenance, Cleanups & Submodules](#12-maintenance-cleanups--submodules)

---

## 1. Setup & Configuration

```bash
# Set global identity
git config --global user.name "DevOps Engineer"
git config --global user.email "devops@example.com"

# Set default branch name to main
git config --global init.defaultBranch main

# Configure pull behavior (rebase by default to avoid merge commits)
git config --global pull.rebase true

# List all global and local configurations
git config --list --show-origin
```

[Back to Top ↑](#table-of-contents)

---

## 2. SSH Authentication & GitHub Setup Walkthrough

### Step 1: Check for Existing SSH Keys

```bash
# Check if public SSH keys already exist on your system
ls -la ~/.ssh

# Look for default public key filenames:
# id_rsa.pub, id_ed25519.pub, id_ecdsa.pub
```

### Step 2: Generate a New SSH Key Pair

```bash
# Standard RSA key pair (widely compatible)
ssh-keygen -t rsa

# Modern recommended alternative: Ed25519 (faster, compact)
ssh-keygen -t ed25519 -C "devops@example.com"
```

**Interactive Prompts Walkthrough:**
1. `Enter file in which to save the key (/home/<user>/.ssh/id_rsa):`  
   → Press **`Enter`** to accept default file location (`~/.ssh/id_rsa`).
2. `Enter passphrase (empty for no passphrase):`  
   → Press **`Enter`** for no passphrase (or type a secure passphrase).
3. `Enter same passphrase again:`  
   → Press **`Enter`** again.

Your private key is saved in `~/.ssh/id_rsa` and public key in `~/.ssh/id_rsa.pub`.

### Step 3: View and Copy Public SSH Key

```bash
# Display the public SSH key to copy:
cat ~/.ssh/id_rsa.pub

# Or if using Ed25519:
cat ~/.ssh/id_ed25519.pub

# Or copy directly to clipboard using xclip (Linux):
xclip -selection clipboard < ~/.ssh/id_rsa.pub
```

> [!TIP]
> Copy the entire printed line starting with `ssh-rsa AAAA...` through your username/hostname.

### Step 4: Add Public Key to GitHub Web UI

1. Open [GitHub](https://github.com) and log in.
2. Click your **Profile photo** (top-right corner) → **Settings**.
3. In the left navigation menu under **Access**, select **SSH and GPG keys**.
4. Click the green **New SSH key** button.
5. In **Title**, enter a friendly label for your machine (e.g., `Workstation-Ubuntu` or `Sesha-PC`).
6. Set **Key type** to `Authentication Key`.
7. Paste your public key into the **Key** textarea.
8. Click **Add SSH key** (confirm password/2FA if prompted).

*(Other Git Providers & CLI:)*
* **GitHub CLI shortcut:** `gh ssh-key add ~/.ssh/id_rsa.pub --title "DevOps Machine"`
* **GitLab:** Profile Settings → SSH Keys → Add an SSH key
* **Bitbucket:** Personal settings → SSH keys → Add key

### Step 5: Switch Existing Repository Remote from HTTPS to SSH

If your local repository was originally cloned via HTTPS, switch it to SSH:

```bash
# 1. Inspect current remote URLs
git remote -v
# Output:
# origin  https://github.com/<username>/<repo>.git (fetch)
# origin  https://github.com/<username>/<repo>.git (push)

# 2. Update origin URL to use SSH syntax
git remote set-url origin git@github.com:<username>/<repo>.git

# 3. Verify the updated remote URL
git remote -v
# Output:
# origin  git@github.com:<username>/<repo>.git (fetch)
# origin  git@github.com:<username>/<repo>.git (push)
```

### Step 6: Test SSH Connection & Accept Host Fingerprint

Test SSH authentication with GitHub:

```bash
ssh -T git@github.com
```

**First-Time Connection Prompt:**
```text
The authenticity of host 'github.com (20.207.73.82)' can't be established.
ED25519 key fingerprint is SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'github.com' (ED25519) to the list of known hosts.
Hi <username>! You've successfully authenticated, but GitHub does not provide shell access.
```

> [!NOTE]
> Type **`yes`** and press `Enter` to permanently add GitHub to your `~/.ssh/known_hosts`. When you see `Hi <username>! You've successfully authenticated...`, your SSH key is working.

```bash
# Test connection to other providers:
ssh -T git@gitlab.com
ssh -T git@bitbucket.org

# Verbose debugging if authentication fails:
ssh -vT git@github.com
```

### Step 7: Configure Git User Identity (Fix "Author identity unknown")

If `git commit` fails with:
> `Author identity unknown`  
> `*** Please tell me who you are.`  
> `fatal: empty ident name not allowed`

Configure your global user identity:

```bash
# Configure your global Git username and email
git config --global user.name "Your Name or Username"
git config --global user.email "your-email@example.com"

# Verify configured settings
git config user.name
git config user.email
```

### Step 8: Stage, Commit, and Push over SSH

With SSH authentication and author identity configured, you can stage and push your commits:

```bash
# 1. Check working tree status
git status

# 2. Stage all changes
git add .

# 3. Commit staged changes
git commit -m "first push"

# 4. Push to remote main branch via SSH
git push origin main
```

### Step 9: (Optional) Start SSH Agent & Add Private Key

```bash
# Start ssh-agent in the background
eval "$(ssh-agent -s)"

# Add your private key to the ssh-agent
ssh-add ~/.ssh/id_rsa
# Or if using Ed25519:
ssh-add ~/.ssh/id_ed25519

# Verify that the key is loaded in ssh-agent
ssh-add -l
```

### Step 10: (Optional) Configure `~/.ssh/config` for Multiple Accounts (Work vs Personal)

```ssh
# Edit ~/.ssh/config:
# Personal GitHub Account
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa
    IdentitiesOnly yes

# Work GitHub Account
Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes
```

```bash
# Clone using custom host alias:
git clone git@github-work:my-company/infra-repo.git
```

[Back to Top ↑](#table-of-contents)

---

## 3. Basic Staging, Committing & Status

```bash
# Initialize a new repository
git init

# View working directory status in short format (-s)
git status
git status -s

# Stage specific file, directory, or all changes
git add <file-name>
git add .
git add -A

# Interactive staging: review and stage specific hunks/lines of code
git add -p

# Commit staged changes with message
git commit -m "feat(infra): add terraform module for vpc"

# Stage and commit tracked modified files in one command
git commit -a -m "fix: update helm chart replica count"

# Amend the previous commit (modify commit message or include newly staged files)
git commit --amend --no-edit
git commit --amend -m "feat: updated commit message"
```

[Back to Top ↑](#table-of-contents)

---

## 4. Branching & Switching

```bash
# List local branches
git branch

# List all local and remote-tracking branches
git branch -a

# Create a new branch
git branch <branch-name>

# Switch branches (modern Git)
git switch <branch-name>
git switch -c feature/new-pipeline      # Create and switch in one command

# Switch branches (classic Git)
git checkout <branch-name>
git checkout -b feature/new-pipeline

# Rename current branch to main
git branch -m main

# Delete a merged branch
git branch -d feature/old-feature

# Force delete an unmerged branch
git branch -D feature/abandoned-work
```

[Back to Top ↑](#table-of-contents)

---

## 5. Stashing Uncommitted Work

```bash
# Stash tracked working directory changes with a descriptive label
git stash push -m "wip: halfway through docker compose config"

# Stash including untracked files (-u)
git stash -u

# List all saved stashes
git stash list

# Apply and remove the latest stash from the list
git stash pop

# Apply a specific stash without removing it from the stash list
git stash apply stash@{1}

# View diff of a stash
git stash show -p stash@{0}

# Drop a specific stash or clear all stashes
git stash drop stash@{0}
git stash clear
```

[Back to Top ↑](#table-of-contents)

---

## 6. History, Inspection & Diffs

```bash
# Compact one-line commit log
git log --oneline

# Visual graph of branching and merge history
git log --graph --oneline --decorate --all

# View commits with diffs of changes introduced
git log -p -2

# Show commit statistics (files changed, insertions, deletions)
git log --stat -n 5

# Inspect specific commit details and diff
git show <commit-sha>

# View line-by-line authorship of a file
git blame <file-name>

# Diff working directory vs staging area
git diff

# Diff staging area vs latest commit (what will be committed)
git diff --staged

# Diff between two branches
git diff main..feature/api-gateway
```

[Back to Top ↑](#table-of-contents)

---

## 7. Undoing Changes & History Rewriting

```bash
# Discard uncommitted changes in a specific file
git restore <file-name>

# Unstage a file while keeping changes in working directory
git restore --staged <file-name>
git reset <file-name>

# Undo the last commit but keep changes in the working directory (Soft Reset)
git reset --soft HEAD~1

# Undo the last commit and unstage changes (Mixed Reset - Default)
git reset HEAD~1

# Discard all commits and working directory changes back to a specific commit (Hard Reset - Destructive)
git reset --hard <commit-sha>
git reset --hard HEAD~2    # Last 2 commits completely wiped

# Revert a published commit by generating a new inverse commit (Safe for shared branches)
git revert <commit-sha>
git revert -m 1 <merge-commit-sha>    # Revert a merge commit specifying parent 1
```

[Back to Top ↑](#table-of-contents)

---

## 8. Reflog & Disaster Recovery

```bash
# View reference log of all HEAD movements (recovers "lost" commits, reset commits, deleted branches)
git reflog

# Recover from an accidental git reset --hard
# 1. Locate the commit SHA from before the reset in reflog:
git reflog
# 2. Reset back to that commit or branch from it:
git reset --hard HEAD@{2}
# or:
git branch recovery-branch HEAD@{2}
```

[Back to Top ↑](#table-of-contents)

---

## 9. Rebasing, Merging & Cherry-Picking

```bash
# Merge a branch into current branch with explicit merge commit
git merge feature-branch --no-ff -m "merge: integrate feature-branch"

# Rebase current branch on top of main (creates linear commit history)
git rebase main

# Continue rebase after resolving merge conflicts
git add <resolved-files>
git rebase --continue

# Abort an in-progress rebase and return to original state
git rebase --abort

# Interactive rebase: squash, edit, or reword the last 4 commits
git rebase -i HEAD~4

# Cherry-pick a specific commit from another branch into current branch
git cherry-pick <commit-sha>
git cherry-pick --continue
git cherry-pick --abort
```

[Back to Top ↑](#table-of-contents)

---

## 10. Remotes & Synchronization

```bash
# List configured remote repositories with URLs
git remote -v

# Add a new remote repository
git remote add origin https://github.com/org/repo.git

# Update remote repository URL (e.g. switching to SSH or personal access token)
git remote set-url origin git@github.com:org/repo.git
git remote set-url origin https://<token>@github.com/org/repo.git

# Fetch all remote branches and tags without merging, pruning deleted branches
git fetch --all --prune

# Pull remote changes with rebase
git pull --rebase origin main

# Push branch to remote and set upstream tracking (-u)
git push -u origin feature/new-pipeline

# Force push safely (only succeeds if no one else has pushed to the branch in the meantime)
git push --force-with-lease origin feature/new-pipeline

# Delete a remote branch
git push origin --delete feature/old-branch
```

[Back to Top ↑](#table-of-contents)

---

## 11. Tags & Releases

```bash
# List all tags
git tag
git tag -l "v1.*"

# Create an annotated release tag
git tag -a v1.2.0 -m "Release v1.2.0: EKS migration and auto-scaling"

# Push a specific tag to remote
git push origin v1.2.0

# Push all local tags to remote
git push origin --tags

# Delete a tag locally and remotely
git tag -d v1.2.0
git push origin --delete v1.2.0
```

[Back to Top ↑](#table-of-contents)

---

## 12. Maintenance, Cleanups & Submodules

```bash
# Preview which untracked files and directories would be removed (Dry-Run)
git clean -nd

# Delete all untracked files and directories
git clean -fd

# Clean up unnecessary files and optimize local repository storage
git gc --prune=now

# Initialize and update Git submodules recursively
git submodule update --init --recursive

# Run a command across all submodules
git submodule foreach git pull origin main
```

[Back to Top ↑](#table-of-contents)
