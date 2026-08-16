git fetch
git pull ( git fetch + get merge )
git clone

git checkout master

git reset
git revert
git reflog
tag
---------------
git reset --hard c45ab21
git reset HEAD~2	--> last 2 commits will be deleted

git reset --hard HEAD~1   = this command will delete the entire commit, stage and working file 

git reset --mixed HEAD~1 =  this is default [git reset HEAD~1] it will delete the commit and unstage file, working file will remains same

git reset --soft HEAD~1 = this will only delete the commit, the working files and stage files does not change

practicals
git commit -m "2nd commit"
git commit -m "wrong commit"
git commit -m "3rd  commit"

we need to delete wrong commit, but its not possible . so remove last 2 commits
git reset HEAD~2
---------------------
revert:

git commit -m "2nd commit"
git commit -m "wrong 1 commit"
git commit -m "wrong 2 commit"
git commit -m "3rd commit"

suppose we want the data which same as in the 2nd commit, so use below
git revert HEAD~3

----------------------
recover the deleted commit

git commit -m "2nd commit"
git branch X
git commit -m "3rd commit"
git commit -m "4th commit"
git checkout X
git commit -m "abc commit"
git commit -m "xyz commit"
git checkout master
git reset HEAD~1
git commit -m "fourth commit"
git commit -m "fifth commit"
git commit -m "sixth commit"
git checkout X
git checkout -b <new-branch-name> <deleted-commit-id>

recover deleted branch
git branch -d X
git checkout -b <deleted branch name> <last-commit-id of deleted branch>


----------------------
tag

git checkout <any-commit-id>
git tag <any-name>

so we are giving a specific name to git commit
--------------------
stash


in main.py , write somethings

git add .
git commit -m "aded a python file"

again do some changes to the file

git stash list
git stash pop

-------------------
