1. What is Git
2. Contents of a Git repo
3. How to push to a remote repo ?
4. Branch protection rules ?

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

## Commands

```bash
git branch <branch-name>
git branch -m main -> renames the current Git branch to main. It is commonly used when changing the default branch name from master to main.

git status
git status -s    # -s means short format

git init
git add <file-name>

git reset <file-name> -> unstage a file

git commit -m "first commit"
git commit -a -m "first commit"  # add and commit

git log
git log --oneline
```

---
