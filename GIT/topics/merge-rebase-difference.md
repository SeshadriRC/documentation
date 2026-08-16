Absolutely. Let's practice **both `git merge` and `git rebase` hands-on**. You can do everything locally without GitHub/GitLab.

## Part 1 — Create a practice repository

```bash
mkdir git-merge-rebase-practice
cd git-merge-rebase-practice

git init
git branch -M main
```

Configure Git if needed:

```bash
git config user.name "Your Name"
git config user.email "your@email.com"
```

---

# Part 2 — Practice `git merge`

### Step 1: Create the first commit

```bash
echo "Initial application" > app.txt
git add .
git commit -m "Initial commit"
```

Check:

```bash
git log --oneline
```

You should have:

```text
A Initial commit
```

---

### Step 2: Create a feature branch

```bash
git checkout -b feature
```

Now you're on:

```text
feature
```

Make a change:

```bash
echo "Feature 1" >> app.txt
git add .
git commit -m "Add feature 1"
```

Make another change:

```bash
echo "Feature 2" >> app.txt
git add .
git commit -m "Add feature 2"
```

Your history:

```text
A---B---C
        ↑
     feature
```

Actually, conceptually:

```text
A = Initial
B = Feature 1
C = Feature 2
```

---

### Step 3: Go back to main

```bash
git checkout main
```

Create a change on `main`:

```bash
echo "Main change" >> app.txt
git add .
git commit -m "Main branch change"
```

Now:

```text
      B---C  feature
     /
A---D  main
```

---

### Step 4: Merge feature into main

```bash
git merge feature
```

You'll get something like:

```text
      B---C
     /     \
A---D-------M  main
```

`M` is the **merge commit**.

Check:

```bash
git log --oneline --graph --all
```

<img width="1366" height="764" alt="image" src="https://github.com/user-attachments/assets/776e0e9b-1503-4c56-9b48-0fc4f3944987" />


This command is very useful for understanding Git history.

---

# Part 3 — Practice `git rebase`

Now let's create a **fresh practice scenario** so the history is easier to understand.

### Step 1: Create another feature branch

First make sure you're on main:

```bash
git checkout main
```

Create:

```bash
git checkout -b feature-rebase
```

Make two commits:

```bash
echo "Rebase feature 1" >> app.txt
git add .
git commit -m "Rebase feature 1"
```

Then:

```bash
echo "Rebase feature 2" >> app.txt
git add .
git commit -m "Rebase feature 2"
```

---

### Step 2: Make a change on main

Go to main:

```bash
git checkout main
```

Create another commit:

```bash
echo "New main change" >> app.txt
git add .
git commit -m "New main change"
```

Now you have:

```text
      B---C  feature-rebase
     /
A---D  main
```

Where:

```text
A = Initial
B = Rebase feature 1
C = Rebase feature 2
D = New main change
```

---

### Step 3: Rebase your feature branch

Switch back:

```bash
git checkout feature-rebase
```

Run:

```bash
git rebase main
```

Git takes your feature commits and **replays them on top of the latest main**.

Before:

```text
      B---C  feature
     /
A---D  main
```

After:

```text
A---D---B'---C'  feature-rebase
```

Notice:

```text
B → B'
C → C'
```

The commits get **new commit hashes** because rebase rewrites history.

---

# Part 4 — See the difference clearly

Run:

```bash
git log --oneline --graph --all
```

### Merge

You get a history like:

```text
*   Merge branch 'feature'
|\
| * Feature 2
| * Feature 1
* | Main change
|/
* Initial
```

### Rebase

You get:

```text
* Feature 2
* Feature 1
* Main change
* Initial
```

<img width="1039" height="713" alt="image" src="https://github.com/user-attachments/assets/2979920f-4e78-4a9d-b0a2-9d91f4d18d49" />


That's why people say:

> **Merge preserves branching history, while rebase creates a linear history.**

---

# Part 5 — Practice a real conflict 🔥

This is very important for interviews.

Create another branch:

```bash
git checkout main
git checkout -b conflict-test
```

Change the same line:

```bash
echo "Feature version" > conflict.txt
git add .
git commit -m "Feature change"
```

Go to main:

```bash
git checkout main
```

Create the same file with a different value:

```bash
echo "Main version" > conflict.txt
git add .
git commit -m "Main change"
```

Now try:

```bash
git merge conflict-test
```

You'll get a conflict.

Check:

```bash
git status
```

Open `conflict.txt`. You'll see something similar to:

```text
<<<<<<< HEAD
Main version
=======
Feature version
>>>>>>> conflict-test
```

Choose the version you want, for example:

```text
Feature version
```

Then:

```bash
git add conflict.txt
git commit -m "Resolve merge conflict"
```

---

# Part 6 — Practice rebase conflict

You can repeat the same scenario but use:

```bash
git rebase main
```

When you get a conflict:

```bash
git status
```

Fix the file manually, then:

```bash
git add conflict.txt
git rebase --continue
```

If you decide to cancel the rebase:

```bash
git rebase --abort
```

This is **very important to remember**:

```text
Merge conflict:
    Fix → git add → git commit

Rebase conflict:
    Fix → git add → git rebase --continue

Cancel rebase:
    git rebase --abort
```

---

## 🧠 Your practice exercise

Do this without looking at the answer:

```text
1. Create main
2. Create feature branch
3. Make 2 commits on feature
4. Make 1 commit on main
5. Merge feature into main
6. Look at git log --graph
7. Create another feature branch
8. Make 2 commits
9. Make 1 commit on main
10. Rebase feature onto main
11. Look at git log --graph
12. Create a merge conflict
13. Resolve it
14. Create a rebase conflict
15. Resolve it
```

The **most important commands to memorize** are:

```bash
git merge feature
git rebase main

git merge --abort
git rebase --abort

git rebase --continue

git log --oneline --graph --all
```

If you're practicing for a **DevOps interview**, I'd especially recommend doing the conflict exercise—you'll very likely get a question such as **"What happens when you get a merge conflict during rebase, and how do you resolve it?"**
