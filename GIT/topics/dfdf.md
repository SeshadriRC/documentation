These five Git commands are very important for DevOps interviews. The easiest way to understand them is by knowing **what problem each one solves**.

---

# 1. `git reset` 🔄

`git reset` is used to **move the current branch pointer to another commit**.

Suppose:

```text
A---B---C---D  main
```

You want to go back to `B`:

```bash
git reset --hard B
```

Now:

```text
A---B  main
```

### Three important reset modes

#### `--soft`

```bash
git reset --soft B
```

Moves `HEAD`, but keeps your changes **staged**.

#### `--mixed` — default

```bash
git reset B
```

Moves `HEAD` and unstages changes, but keeps the changes in your working directory.

#### `--hard`

```bash
git reset --hard B
```

Moves `HEAD` and **discards changes** after `B`.

⚠️ Be careful with `--hard`.

### Interview answer

> "`git reset` moves the branch pointer to another commit. Depending on the mode, it can keep changes staged, unstaged, or discard them."

---

# 2. `git revert` ↩️

`git revert` is used to **undo a commit by creating a new commit**.

Suppose:

```text
A---B---C---D  main
```

`D` introduced a bug.

Run:

```bash
git revert D
```

Git creates a new commit:

```text
A---B---C---D---R  main
```

`R` reverses the changes introduced by `D`.

### Why is this useful?

Because it **doesn't rewrite history**.

That's why `revert` is generally safer for shared branches such as `main` or `master`.

### Interview answer

> "`git revert` creates a new commit that reverses the changes introduced by an earlier commit. I prefer it for shared branches because it preserves Git history."

---

# 3. `git reflog` 🔍

This one is **extremely useful**.

`git reflog` records movements of `HEAD` and branch references in your **local repository**.

For example, you accidentally do:

```bash
git reset --hard HEAD~3
```

and think:

> 😨 "I lost my commits!"

Check:

```bash
git reflog
```

You might see:

```text
a1b2c3d HEAD@{0}: reset: moving to HEAD~3
e4f5g6h HEAD@{1}: commit: Important changes
```

You can recover the previous state:

```bash
git reset --hard e4f5g6h
```

### Important

`reflog` is like a **local recovery history**.

```text
git log     → Shows commit history
git reflog  → Shows movements of HEAD / references
```

### Interview answer

> "`git reflog` helps me recover commits or previous branch states that may no longer be reachable through the normal branch history, especially after operations such as reset or rebase."

---

# 4. `git tag` 🏷️



---

# 5. `git stash` 📦

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

# 🧠 All 5 together

| Command  | Purpose                                   | Rewrites history?                |
| -------- | ----------------------------------------- | -------------------------------- |
| `reset`  | Move branch/HEAD to another commit        | ✅ Usually                        |
| `revert` | Undo a commit with a new commit           | ❌                                |
| `reflog` | Recover previous HEAD/reference states    | Doesn't modify history by itself |
| `tag`    | Mark a specific commit, usually a release | ❌                                |
| `stash`  | Temporarily save uncommitted changes      | ❌                                |

### Easy memory trick

```text
RESET   → Move backward
REVERT  → Undo with a new commit
REFLOG  → Recover lost work
TAG     → Mark a release
STASH   → Temporarily hide my changes
```

### 🔥 Very common interview scenario

**Interviewer:** "You accidentally did `git reset --hard` and lost your commit. What will you do?"

Answer:

> **"First I'll check `git reflog` to find the previous commit or HEAD position. Once I identify the commit, I can recover it using `git reset --hard <commit-hash>` or create a branch from that commit."**

For example:

```bash
git reflog
git branch recovery <commit-hash>
```

That's a **very strong practical Git answer** for an interview.
