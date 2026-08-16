1. What is Git
2. Contents of a Git repo
3. How to push to a remote repo ?
4. Branch protection rules ?
5. Git merge, fast forward merge, rebase and merge conflict, git pull.
6. Git reset, revert, reflog, tag, stash

- [Commands](#Commands)
---

### 1. What is Git

Git is a Distributed Version Control System (DVCS)


---

### 2. Contents of a Git repo

```bash
.git/
├── HEAD
├── config
├── description
├── hooks/
├── info/
├── objects/
├── refs/
```

---

### 3. How to push to a remote repo ?

1. Create a repo in github
2. ```git init``` in local ( assume folder is gityoutube )
3. ```git remote add origin https://github.com/seshadri/gityoutube.git```

While pushing to remote, it will ask username and password. username we can provide same "seshadri" but for password we need to follow the below steps

```myprofile --> settings --> developer setttings --> personal access token --> generate classic token```

4. git config is used to configure Git user information such as username and email. The --global option applies settings to all repositories, while without --global the settings apply only to the current repository.

```bash
git config -- global user.name "seshadri"
git config -- global user.email "seshaec1999@gmail.com"


git config user.name "seshadri"
git config user.email "seshaec1999@gmail.com"
```

---

### 4. Branch protection rule ?

Repository --> Settings --> Rulesets --> New ruleset --> New branch ruleset

---

### 5. Git merge, rebase and merge conflict

**Git merge**

 - git merge is used to integrate changes from one branch into another.

**Git fast forward merge**

- A fast-forward merge occurs when the target branch has no new commits since the feature branch was created.
- `main` hasn't changed after `feature` was created.

**Git rebase**
- `git rebase` moves my branch commits on top of the latest commit of another branch. It replays those commits with new hashes and creates a linear history.

**Git merge/rebase difference**
[merge-and-rebase-difference](https://github.com/SeshadriRC/documentation/blob/main/GIT/topics/merge-rebase-difference.md)

**Git pull**
- git pull is used to get changes from a remote repository and integrate them into your current local branch.

**Git merge conflict**
[merge-and-rebase-difference](https://github.com/SeshadriRC/documentation/blob/main/GIT/topics/merge-rebase-difference.md)

---

### 6. Git reset, revert, reflog, tag, stash

- `git reset` moves the branch pointer to another commit. Depending on the mode, it can keep changes staged, unstaged, or discard them.
- `git revert` is used to undo a commit by creating a new commit. I prefer it for shared branches because it preserves Git history.
- `git reflog` records movements of HEAD and branch references in your local repository. git reflog helps me recover commits or previous branch states that may no longer be reachable through the normal branch history

   For example, you accidentally do and think: 😨 "I lost my commits!"

    `git reset --hard HEAD~3`

  So check

  ` git reflog`

  you might see

  ```
  a1b2c3d HEAD@{0}: reset: moving to HEAD~3
  e4f5g6h HEAD@{1}: commit: Important changes
  ```

- A Git tag is a **named reference to a specific commit**, commonly used to mark releases.

Suppose:

```text
A---B---C---D
        ↑
       v1.0
```

Create a tag:

```bash
git tag v1.0
```

See tags:

```bash
git tag
```

Push it:

```bash
git push origin v1.0
```

Or push all tags:

```bash
git push origin --tags
```

### Why use tags?

For releases:

```text
v1.0.0
v1.1.0
v2.0.0
```

For example:

```text
v1.5.0 → Production release
```

Your CI/CD pipeline could detect the tag and deploy that version.

### Annotated tag

For production releases, you may use:

```bash
git tag -a v1.0 -m "Production release v1.0"
```

### Interview answer

> "A Git tag is a reference to a specific commit, commonly used to mark important points such as application releases or production versions."

---

`git stash` temporarily stores your **uncommitted changes** so you can get a clean working directory.

Suppose you're working:

```text
Modified:
app.py
config.yaml
```

But suddenly you need to switch branches.

Instead of committing unfinished work:

```bash
git stash
```

Now:

```text
Working directory → Clean
```

You can switch branches:

```bash
git checkout main
```

Later, come back:

```bash
git checkout feature
```

Restore your changes:

```bash
git stash pop
```

Your changes come back.

### Useful commands

List stashes:

```bash
git stash list
```

Apply without removing from stash:

```bash
git stash apply
```

Apply and remove from stash:

```bash
git stash pop
```

Delete a stash:

```bash
git stash drop
```

### Interview answer

> "`git stash` temporarily saves uncommitted changes so I can switch branches or perform another Git operation without committing incomplete work."



---
## Commands

```bash
git init
git add <file-name>

git branch <branch-name>
git branch -m main -> renames the current Git branch to main. It is commonly used when changing the default branch name from master to main.

git commit -m "first commit"
git commit -a -m "first commit"  # add and commit

git log
git log --oneline

git merge feature

git status
git status -s    # -s means short format

git reset <file-name> -> unstage a file

git rebase main
git rebase --continue
git rebase --abort
```

---
