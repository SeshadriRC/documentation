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

git reset <file-name>   # unstage a file
git reset --hard c45ab21
git reset HEAD~2	   # last 2 commits will be deleted

git rebase main
git rebase --continue
git rebase --abort

git remote set-url private-repo https://ghp_token@github.com/SeshadriRC/sonar-private-repo.git		
```
