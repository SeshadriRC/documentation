# Git Commands for DevOps Engineers

A comprehensive reference for version control, branch management, history manipulation, GitOps workflows, SSH authentication, and repository troubleshooting.

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

---

## 2. SSH Authentication & Key Setup

### Step 1: Check for Existing SSH Keys

```bash
# Check if public SSH keys already exist on your system
ls -la ~/.ssh

# Look for default public key filenames:
# id_ed25519.pub, id_rsa.pub, id_ecdsa.pub
```

### Step 2: Generate a New SSH Key Pair

```bash
# Recommended modern standard: Ed25519 (faster, more secure)
ssh-keygen -t ed25519 -C "devops@example.com"

# Legacy fallback: RSA 4096-bit (for older systems/servers)
ssh-keygen -t rsa -b 4096 -C "devops@example.com"

# Press Enter to accept default location (~/.ssh/id_ed25519)
# Optionally set a secure passphrase for key protection
```

### Step 3: Start SSH Agent & Add Private Key

```bash
# Start ssh-agent in the background
eval "$(ssh-agent -s)"

# Add your private key to the ssh-agent
ssh-add ~/.ssh/id_ed25519

# Verify that the key is loaded in ssh-agent
ssh-add -l
```

### Step 4: Add Public Key to Git Hosting Provider (GitHub / GitLab / Bitbucket)

```bash
# Display the public key to copy to clipboard
cat ~/.ssh/id_ed25519.pub

# Or copy directly to clipboard using xclip (Linux):
xclip -selection clipboard < ~/.ssh/id_ed25519.pub

# Alternatively, add SSH key to GitHub directly via GitHub CLI:
gh ssh-key add ~/.ssh/id_ed25519.pub --title "DevOps Workstation $(date +%F)"
```

*In the Web UI:*
* **GitHub:** Settings -> SSH and GPG keys -> New SSH key -> Paste key
* **GitLab:** User Settings -> SSH Keys -> Add an SSH key
* **Bitbucket:** Personal settings -> SSH keys -> Add key

### Step 5: Test the SSH Connection

```bash
# Test connection to GitHub
ssh -T git@github.com
# Expected output: "Hi <username>! You've successfully authenticated..."

# Test connection to GitLab
ssh -T git@gitlab.com

# Test connection to Bitbucket
ssh -T git@bitbucket.org

# Verbose debugging if authentication fails
ssh -vT git@github.com
```

### Step 6: Configure `~/.ssh/config` for Multiple Accounts (Work vs Personal)

```ssh
# Edit ~/.ssh/config:
# Personal GitHub Account
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
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

### Step 7: Switch Existing Repo from HTTPS to SSH

```bash
# Check current remote URL
git remote -v

# Switch remote URL to SSH
git remote set-url origin git@github.com:my-org/my-repo.git

# Verify updated URL
git remote -v
```

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
