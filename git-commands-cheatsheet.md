[📖 README](README.md) | [🌳 Branching](git-branching.md) | [⚡ Commands](git-commands-cheatsheet.md) | [🔧 Internals](git-internals.md) | [🤝 Workflows](git-workflows.md) | [🚀 Advanced](git-advanced.md) | [🌐 GitHub/GitLab](github-gitlab-guide.md) | [🔥 Troubleshooting](git-troubleshooting.md) | [💼 Interview Prep](git-interview-questions.md)

---

# ⚡ Git Commands Cheatsheet

> A comprehensive reference for every essential Git command — organized by category with syntax, flags, and real-world examples.

---

## Table of Contents

1. [Setup & Config](#setup--config)
2. [Snapshotting](#snapshotting)
3. [Branching & Merging](#branching--merging)
4. [Sharing & Updating](#sharing--updating)
5. [Inspection & Comparison](#inspection--comparison)
6. [Patching](#patching)
7. [Debugging](#debugging)
8. [Administration](#administration)
9. [Subcommands](#subcommands)

---

## Setup & Config

### `git config`

Set configuration values for Git on a global or per-repository level.

**Syntax:**
```bash
git config [--global | --system | --local] <key> <value>
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `--global` | Set config for current user (all repos) |
| `--system` | Set config for all users on the system |
| `--local` | Set config for current repository only (default) |
| `--list` | List all config settings |
| `--unset` | Remove a config entry |
| `-e, --edit` | Open config file in editor |

**Examples:**

```bash
# Set your identity
$ git config --global user.name "John Doe"
$ git config --global user.email "john@example.com"

# List all configuration
$ git config --list
user.name=John Doe
user.email=john@example.com
core.editor=vim
core.autocrlf=input

# Set default branch name
$ git config --global init.defaultBranch main
```

**Pro Tips:**
- Use `git config --global core.editor "code --wait"` to set VS Code as your default editor.
- Store credentials with `git config --global credential.helper cache` (or `store` for permanent).
- Use conditional includes for work/personal configs: `[includeIf "gitdir:~/work/"]`.

---

### `git init`

Create a new Git repository or reinitialize an existing one.

**Syntax:**
```bash
git init [<directory>] [--bare] [--initial-branch=<name>]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `--bare` | Create a bare repo (no working directory) |
| `--initial-branch=<name>` | Set the initial branch name |
| `--template=<dir>` | Use a template directory |
| `--shared` | Set group permissions for sharing |

**Examples:**

```bash
# Initialize a new repo in current directory
$ git init
Initialized empty Git repository in /home/user/project/.git/

# Initialize with a specific branch name
$ git init --initial-branch=main my-project
Initialized empty Git repository in /home/user/my-project/.git/

# Create a bare repository (for servers)
$ git init --bare my-project.git
Initialized empty Git repository in /home/user/my-project.git/
```

**Pro Tips:**
- Bare repos are used as central/shared repositories — they have no working tree.
- Running `git init` in an existing repo is safe — it won't overwrite existing config.
- Always create a `.gitignore` immediately after `git init`.

---

### `git clone`

Clone a repository into a new directory.

**Syntax:**
```bash
git clone [options] <repository> [<directory>]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `--depth <n>` | Shallow clone with limited history |
| `--branch <name>` | Clone a specific branch |
| `--single-branch` | Clone only one branch |
| `--recurse-submodules` | Initialize submodules after cloning |
| `--bare` | Clone as a bare repository |
| `--mirror` | Mirror the repository (bare + all refs) |
| `--shallow-since=<date>` | Shallow clone since a date |

**Examples:**

```bash
# Clone a repository
$ git clone https://github.com/user/repo.git
Cloning into 'repo'...
remote: Enumerating objects: 1542, done.
remote: Total 1542 (delta 0), reused 0 (delta 0)
Receiving objects: 100% (1542/1542), 2.10 MiB | 5.20 MiB/s, done.

# Shallow clone (only last 5 commits)
$ git clone --depth 5 https://github.com/user/repo.git
Cloning into 'repo'...
remote: Enumerating objects: 45, done.
Receiving objects: 100% (45/45), 120.00 KiB | 2.40 MiB/s, done.

# Clone specific branch into custom directory
$ git clone --branch develop --single-branch https://github.com/user/repo.git my-dev-copy
Cloning into 'my-dev-copy'...
```

**Pro Tips:**
- Use `--depth 1` for CI/CD pipelines to speed up cloning.
- `--mirror` is best for backup purposes — it copies all refs including hidden ones.
- Clone via SSH (`git@github.com:user/repo.git`) for passwordless push access.

---


## Snapshotting

### `git add`

Add file contents to the staging area (index).

**Syntax:**
```bash
git add [options] [<pathspec>...]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `-A, --all` | Stage all changes (new, modified, deleted) |
| `-p, --patch` | Interactively stage chunks |
| `-u, --update` | Stage modified and deleted files only |
| `-n, --dry-run` | Show what would be staged |
| `-f, --force` | Add ignored files |
| `-i, --interactive` | Interactive staging mode |

**Examples:**

```bash
# Stage a specific file
$ git add index.html
# (no output on success)

# Stage all changes interactively (chunk by chunk)
$ git add -p
diff --git a/app.js b/app.js
@@ -1,3 +1,4 @@
+const express = require('express');
 const app = {};
Stage this hunk [y,n,q,a,d,/,e,?]? y

# Dry run to see what would be staged
$ git add -n .
add 'src/new-file.js'
add 'src/modified-file.js'
```

**Pro Tips:**
- Use `git add -p` for granular commits — stage only relevant changes per commit.
- `git add .` stages everything in the current directory and below; `git add -A` stages everything in the whole repo.
- Use `git add -N <file>` to mark intent to add a new file without staging its content.

---

### `git commit`

Record changes to the repository.

**Syntax:**
```bash
git commit [options]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `-m <msg>` | Commit message inline |
| `-a, --all` | Auto-stage modified/deleted tracked files |
| `--amend` | Modify the last commit |
| `--no-edit` | Amend without changing message |
| `-s, --signoff` | Add Signed-off-by line |
| `--allow-empty` | Allow commit with no changes |
| `-v, --verbose` | Show diff in commit editor |

**Examples:**

```bash
# Commit with a message
$ git commit -m "Add user authentication module"
[main 3a2b1c4] Add user authentication module
 3 files changed, 142 insertions(+), 5 deletions(-)

# Amend the last commit (add forgotten file)
$ git add forgotten-file.js
$ git commit --amend --no-edit
[main 7d4e5f6] Add user authentication module
 4 files changed, 158 insertions(+), 5 deletions(-)

# Commit all tracked changes with verbose diff
$ git commit -av
# (opens editor showing full diff for review)
```

**Pro Tips:**
- Follow conventional commits: `feat:`, `fix:`, `docs:`, `chore:`, etc.
- Never amend commits that have been pushed to shared branches.
- Use `git commit --fixup=<sha>` with `git rebase -i --autosquash` for clean history.

---

### `git status`

Show the working tree status.

**Syntax:**
```bash
git status [options]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `-s, --short` | Short format output |
| `-b, --branch` | Show branch info in short format |
| `--porcelain` | Machine-readable output |
| `-u, --untracked-files` | Show untracked files |
| `--ignored` | Show ignored files |

**Examples:**

```bash
# Full status
$ git status
On branch main
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   src/app.js

Changes not staged for commit:
        modified:   README.md

Untracked files:
        src/new-feature.js

# Short format
$ git status -s
M  src/app.js
 M README.md
?? src/new-feature.js

# Porcelain format (for scripts)
$ git status --porcelain
M  src/app.js
 M README.md
?? src/new-feature.js
```

**Pro Tips:**
- In short format: left column = staged, right column = working tree. `M` = modified, `A` = added, `?` = untracked.
- Use `--porcelain` in shell scripts for stable, parseable output.
- `git status -sb` gives you branch tracking info in one line.

---

### `git diff`

Show changes between commits, working tree, staging area, etc.

**Syntax:**
```bash
git diff [options] [<commit>] [--] [<path>...]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `--staged` (or `--cached`) | Diff between staging area and last commit |
| `--stat` | Show diffstat summary |
| `--name-only` | Show only file names |
| `--name-status` | Show file names with change type |
| `--word-diff` | Show word-level differences |
| `--color-words` | Colored word diff |
| `-w, --ignore-all-space` | Ignore whitespace |

**Examples:**

```bash
# Show unstaged changes
$ git diff
diff --git a/README.md b/README.md
index 1234567..abcdefg 100644
--- a/README.md
+++ b/README.md
@@ -1,3 +1,4 @@
 # My Project
+This is a new line
 Some content

# Show staged changes (ready to commit)
$ git diff --staged
diff --git a/src/app.js b/src/app.js
--- a/src/app.js
+++ b/src/app.js
@@ -5,0 +6,2 @@
+const router = require('./router');
+app.use(router);

# Compare two branches (stat view)
$ git diff main..feature --stat
 src/app.js      | 15 +++++++++------
 src/router.js   | 42 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 51 insertions(+), 6 deletions(-)
```

**Pro Tips:**
- `git diff` = working tree vs staging. `git diff --staged` = staging vs HEAD.
- Use `git diff HEAD` to see ALL uncommitted changes (staged + unstaged).
- `git diff branch1...branch2` shows changes since branches diverged (three dots!).

---

### `git stash`

Temporarily save uncommitted changes for later use.

**Syntax:**
```bash
git stash [push | pop | list | show | drop | apply | clear] [options]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `-u, --include-untracked` | Stash untracked files too |
| `-m, --message <msg>` | Add a description to the stash |
| `-p, --patch` | Interactively select hunks to stash |
| `--keep-index` | Keep staged changes in the index |
| `-a, --all` | Include ignored files |

**Examples:**

```bash
# Stash current changes with a message
$ git stash push -m "WIP: new login form"
Saved working directory and index state On main: WIP: new login form

# List all stashes
$ git stash list
stash@{0}: On main: WIP: new login form
stash@{1}: On main: WIP: refactoring utils
stash@{2}: On feature: quick experiment

# Apply and remove the latest stash
$ git stash pop
On branch main
Changes not staged for commit:
        modified:   src/login.js
Dropped refs/stash@{0} (a1b2c3d4e5f6...)
```

**Pro Tips:**
- Use `git stash push -m "description"` — always name your stashes.
- `git stash pop` applies AND removes; `git stash apply` applies but keeps the stash.
- `git stash branch <branchname>` creates a new branch from a stash — great for stashes with conflicts.

---

### `git reset`

Reset current HEAD to a specified state.

**Syntax:**
```bash
git reset [--soft | --mixed | --hard] [<commit>]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `--soft` | Reset HEAD only; keep staging and working tree |
| `--mixed` | Reset HEAD and staging; keep working tree (default) |
| `--hard` | Reset HEAD, staging, AND working tree (destructive!) |
| `-p, --patch` | Interactively unstage hunks |
| `--merge` | Reset for a failed merge |
| `--keep` | Reset but keep local modifications |

**Examples:**

```bash
# Unstage a file (mixed reset of specific file)
$ git reset HEAD src/app.js
Unstaged changes after reset:
M       src/app.js

# Undo last commit but keep changes staged
$ git reset --soft HEAD~1
# (no output; changes remain staged)

# Completely discard last 3 commits (DANGEROUS)
$ git reset --hard HEAD~3
HEAD is now at 9a8b7c6 Previous commit message
```

**Pro Tips:**
- `--soft` is great for "squashing" — undo commits then recommit as one.
- `--hard` is irreversible for uncommitted changes. Use `git reflog` as emergency recovery.
- Prefer `git restore --staged <file>` over `git reset HEAD <file>` for unstaging (modern Git).

---


## Branching & Merging

### `git branch`

List, create, or delete branches.

**Syntax:**
```bash
git branch [options] [<branchname>] [<start-point>]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `-a, --all` | List both local and remote branches |
| `-r, --remotes` | List remote-tracking branches |
| `-d, --delete` | Delete a merged branch |
| `-D` | Force-delete a branch (even if unmerged) |
| `-m, --move` | Rename a branch |
| `-v, --verbose` | Show last commit on each branch |
| `--merged` | List branches merged into current |
| `--no-merged` | List branches not yet merged |

**Examples:**

```bash
# List all branches (local + remote) with last commit
$ git branch -av
* main              3a2b1c4 Add authentication
  feature/login     7d4e5f6 WIP login page
  remotes/origin/main  3a2b1c4 Add authentication
  remotes/origin/develop  8e9f0a1 Merge PR #42

# Create and delete branches
$ git branch feature/signup
$ git branch -d feature/old-feature
Deleted branch feature/old-feature (was 1a2b3c4).

# Rename current branch
$ git branch -m old-name new-name
```

**Pro Tips:**
- Use `git branch --merged main` to find branches safe to delete.
- Set upstream with `git branch -u origin/main` to enable `git pull` without arguments.
- Use `git branch --sort=-committerdate` to see most recently active branches first.

---

### `git checkout`

Switch branches or restore working tree files (legacy command).

**Syntax:**
```bash
git checkout [options] <branch>
git checkout [options] [<commit>] -- <file>
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `-b <branch>` | Create and switch to new branch |
| `-B <branch>` | Create/reset and switch to branch |
| `--track` | Set up tracking for remote branch |
| `--orphan` | Create branch with no history |
| `-f, --force` | Force checkout, discard local changes |
| `-- <file>` | Restore a file from a commit |

**Examples:**

```bash
# Create and switch to a new branch
$ git checkout -b feature/payment
Switched to a new branch 'feature/payment'

# Restore a file from the last commit
$ git checkout -- src/broken-file.js
# (file restored, no output)

# Checkout a specific file from another branch
$ git checkout main -- src/config.js
Updated 1 path from branch 'main'
```

**Pro Tips:**
- In modern Git, prefer `git switch` for branches and `git restore` for files.
- `git checkout -` switches to the previous branch (like `cd -`).
- Use `git checkout --orphan gh-pages` to create GitHub Pages branches.

---

### `git switch`

Switch branches (modern replacement for `git checkout` for branch switching).

**Syntax:**
```bash
git switch [options] <branch>
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `-c, --create` | Create and switch to new branch |
| `-C` | Create/reset and switch |
| `--detach` | Switch to a commit in detached HEAD |
| `--track` | Set up remote tracking |
| `--discard-changes` | Discard local changes on switch |
| `-` | Switch to previous branch |

**Examples:**

```bash
# Switch to an existing branch
$ git switch develop
Switched to branch 'develop'
Your branch is up to date with 'origin/develop'.

# Create and switch to new branch
$ git switch -c feature/notifications
Switched to a new branch 'feature/notifications'

# Switch to previous branch
$ git switch -
Switched to branch 'main'
```

**Pro Tips:**
- `git switch` is safer than `git checkout` — it only handles branch operations.
- Use `git switch --detach v2.0.0` to inspect a tag without creating a branch.
- Introduced in Git 2.23 as part of the checkout split (`switch` + `restore`).

---

### `git merge`

Join two or more development histories together.

**Syntax:**
```bash
git merge [options] <branch>
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `--no-ff` | Always create a merge commit |
| `--ff-only` | Only allow fast-forward merges |
| `--squash` | Squash all commits into one (no merge commit) |
| `--abort` | Abort a conflicting merge |
| `--continue` | Continue after resolving conflicts |
| `-m <msg>` | Set merge commit message |
| `--no-commit` | Merge but don't auto-commit |

**Examples:**

```bash
# Merge feature into main with a merge commit
$ git switch main
$ git merge --no-ff feature/login
Merge made by the 'ort' strategy.
 src/login.js  | 85 ++++++++++++++++++++++
 src/auth.js   | 23 +++++++
 2 files changed, 108 insertions(+)

# Squash merge (combine all feature commits into one)
$ git merge --squash feature/cleanup
Squash commit -- not updating HEAD
Automatic merge went well; stopped before committing as requested.
$ git commit -m "chore: cleanup codebase"

# Abort a conflicted merge
$ git merge feature/conflicting
Auto-merging src/app.js
CONFLICT (content): Merge conflict in src/app.js
$ git merge --abort
```

**Pro Tips:**
- `--no-ff` keeps feature branch history visible in the graph — use it for release branches.
- `--squash` is great for keeping main history clean while preserving detailed branch commits.
- After resolving conflicts, use `git add <file>` then `git merge --continue`.

---

### `git rebase`

Reapply commits on top of another base tip.

**Syntax:**
```bash
git rebase [options] [<upstream>] [<branch>]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `-i, --interactive` | Interactive rebase (reorder, squash, edit) |
| `--onto <newbase>` | Rebase onto a specific commit |
| `--abort` | Abort rebase in progress |
| `--continue` | Continue after conflict resolution |
| `--skip` | Skip current patch |
| `--autosquash` | Auto-arrange fixup/squash commits |
| `--autostash` | Stash before rebase, apply after |

**Examples:**

```bash
# Rebase feature branch onto latest main
$ git switch feature/api
$ git rebase main
Successfully rebased and updated refs/heads/feature/api.

# Interactive rebase to squash last 4 commits
$ git rebase -i HEAD~4
# (editor opens with pick/squash/edit options)
pick 1a2b3c4 Add API endpoint
squash 5e6f7a8 Fix typo
squash 9b0c1d2 Add tests
squash 3e4f5a6 Update docs
Successfully rebased and updated refs/heads/feature/api.

# Rebase onto a specific branch point
$ git rebase --onto main feature/base feature/derived
```

**Pro Tips:**
- **Golden rule:** Never rebase commits that have been pushed to shared branches.
- Use `git rebase -i --autosquash` with fixup commits for a polished history.
- `--autostash` saves you from having to manually stash/pop around rebases.

---

### `git cherry-pick`

Apply specific commits from another branch.

**Syntax:**
```bash
git cherry-pick [options] <commit>...
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `-n, --no-commit` | Apply changes without committing |
| `-e, --edit` | Edit commit message |
| `-x` | Append "cherry picked from" to message |
| `--abort` | Abort cherry-pick in progress |
| `--continue` | Continue after conflict resolution |
| `-m <parent>` | Specify mainline parent for merge commits |

**Examples:**

```bash
# Cherry-pick a single commit
$ git cherry-pick 3a2b1c4
[main 9f8e7d6] Fix critical security bug
 1 file changed, 5 insertions(+), 2 deletions(-)

# Cherry-pick range of commits (exclusive start)
$ git cherry-pick main~3..main
[hotfix 1112131] Commit A
[hotfix 1415161] Commit B
[hotfix 1718192] Commit C

# Cherry-pick without committing (inspect first)
$ git cherry-pick -n abc1234
# (changes staged but not committed)
```

**Pro Tips:**
- Use `-x` to leave a trail — it records the source commit SHA in the message.
- Cherry-picking merge commits requires `-m 1` (first parent) or `-m 2` (second parent).
- Prefer `git rebase --onto` over multiple cherry-picks when moving a sequence of commits.

---


## Sharing & Updating

### `git remote`

Manage set of tracked repositories.

**Syntax:**
```bash
git remote [options] [add | remove | rename | show | set-url] [<name>] [<url>]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `-v, --verbose` | Show remote URLs |
| `add <name> <url>` | Add a new remote |
| `remove <name>` | Remove a remote |
| `rename <old> <new>` | Rename a remote |
| `set-url <name> <url>` | Change remote URL |
| `show <name>` | Display detailed remote info |

**Examples:**

```bash
# List remotes with URLs
$ git remote -v
origin  https://github.com/user/repo.git (fetch)
origin  https://github.com/user/repo.git (push)
upstream  https://github.com/original/repo.git (fetch)
upstream  https://github.com/original/repo.git (push)

# Add a new remote
$ git remote add upstream https://github.com/original/repo.git

# Show detailed remote info
$ git remote show origin
* remote origin
  Fetch URL: https://github.com/user/repo.git
  Push  URL: https://github.com/user/repo.git
  HEAD branch: main
  Remote branches:
    develop tracked
    main    tracked
  Local branches configured for 'git pull':
    main merges with remote main
```

**Pro Tips:**
- Use `upstream` as a conventional name for the original repo in forks.
- Switch from HTTPS to SSH: `git remote set-url origin git@github.com:user/repo.git`.
- You can have different push/fetch URLs: `git remote set-url --push origin <url>`.

---

### `git fetch`

Download objects and refs from another repository.

**Syntax:**
```bash
git fetch [options] [<remote>] [<refspec>]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `--all` | Fetch from all remotes |
| `--prune` | Remove stale remote-tracking refs |
| `--tags` | Fetch all tags |
| `--depth <n>` | Deepen shallow clone |
| `--dry-run` | Show what would be fetched |
| `-f, --force` | Force update of local refs |

**Examples:**

```bash
# Fetch from origin
$ git fetch origin
remote: Enumerating objects: 15, done.
remote: Counting objects: 100% (15/15), done.
From https://github.com/user/repo
   3a2b1c4..7d4e5f6  main       -> origin/main
 * [new branch]      feature/x  -> origin/feature/x

# Fetch and prune deleted remote branches
$ git fetch --prune
From https://github.com/user/repo
 - [deleted]         (none)     -> origin/old-feature
   3a2b1c4..7d4e5f6  main       -> origin/main

# Fetch a specific branch
$ git fetch origin feature/login
From https://github.com/user/repo
 * branch            feature/login -> FETCH_HEAD
```

**Pro Tips:**
- `git fetch` is always safe — it never modifies your working directory.
- Set auto-prune globally: `git config --global fetch.prune true`.
- Use `git fetch --all` before checking branch status across multiple remotes.

---

### `git pull`

Fetch and integrate changes from a remote repository.

**Syntax:**
```bash
git pull [options] [<remote>] [<branch>]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `--rebase` | Rebase instead of merge |
| `--ff-only` | Only fast-forward (fail otherwise) |
| `--no-rebase` | Force merge strategy |
| `--autostash` | Auto-stash before pull |
| `--all` | Fetch from all remotes |
| `--prune` | Prune stale tracking refs |

**Examples:**

```bash
# Pull with rebase (linear history)
$ git pull --rebase origin main
remote: Enumerating objects: 8, done.
From https://github.com/user/repo
 * branch            main     -> FETCH_HEAD
Successfully rebased and updated refs/heads/main.

# Pull with fast-forward only (safest)
$ git pull --ff-only
Updating 3a2b1c4..7d4e5f6
Fast-forward
 src/app.js | 5 +++++
 1 file changed, 5 insertions(+)

# Pull fails if not fast-forwardable
$ git pull --ff-only
fatal: Not possible to fast-forward, aborting.
```

**Pro Tips:**
- Set rebase as default: `git config --global pull.rebase true`.
- `--ff-only` prevents accidental merge commits — use it in CI.
- `git pull` = `git fetch` + `git merge` (or `git rebase` with `--rebase`).

---

### `git push`

Update remote refs along with associated objects.

**Syntax:**
```bash
git push [options] [<remote>] [<refspec>]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `-u, --set-upstream` | Set tracking reference |
| `--force` | Force push (overwrites remote) |
| `--force-with-lease` | Safe force push (fails if remote changed) |
| `--tags` | Push all tags |
| `--delete` | Delete a remote branch |
| `--dry-run` | Show what would be pushed |
| `--all` | Push all branches |

**Examples:**

```bash
# Push and set upstream tracking
$ git push -u origin feature/login
Enumerating objects: 12, done.
Counting objects: 100% (12/12), done.
To https://github.com/user/repo.git
 * [new branch]      feature/login -> feature/login
Branch 'feature/login' set up to track remote branch 'feature/login' from 'origin'.

# Safe force push (after rebase)
$ git push --force-with-lease origin feature/login
To https://github.com/user/repo.git
 + 3a2b1c4...7d4e5f6 feature/login -> feature/login (forced update)

# Delete a remote branch
$ git push origin --delete feature/old-branch
To https://github.com/user/repo.git
 - [deleted]         feature/old-branch
```

**Pro Tips:**
- **Always** use `--force-with-lease` instead of `--force` — it prevents overwriting others' work.
- Use `git push origin HEAD` to push current branch without typing its name.
- Push a tag: `git push origin v1.0.0`. Push all tags: `git push origin --tags`.

---


## Inspection & Comparison

### `git log`

Show commit logs.

**Syntax:**
```bash
git log [options] [<revision-range>] [-- <path>]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `--oneline` | Compact one-line format |
| `--graph` | Draw ASCII branch graph |
| `--all` | Show all branches |
| `-n <number>` | Limit to n commits |
| `--since=<date>` | Commits after date |
| `--author=<pattern>` | Filter by author |
| `--grep=<pattern>` | Filter by message content |
| `-p, --patch` | Show diffs |
| `--stat` | Show diffstat |
| `--pretty=format:` | Custom format |

**Examples:**

```bash
# Pretty graph log
$ git log --oneline --graph --all -10
* 7d4e5f6 (HEAD -> main, origin/main) Add payment gateway
| * 3a2b1c4 (feature/login) Add login validation
| * 9f8e7d6 Create login form
|/
* 1a2b3c4 Initial project setup
* 0a1b2c3 Add README

# Find commits by author in date range
$ git log --author="John" --since="2024-01-01" --oneline
7d4e5f6 Add payment gateway
5c6d7e8 Fix checkout flow
2b3c4d5 Update user model

# Custom format
$ git log --pretty=format:"%h %an %ar - %s" -5
7d4e5f6 John Doe 2 hours ago - Add payment gateway
3a2b1c4 Jane Smith 1 day ago - Add login validation
9f8e7d6 Jane Smith 2 days ago - Create login form
1a2b3c4 John Doe 1 week ago - Initial project setup
0a1b2c3 John Doe 1 week ago - Add README
```

**Pro Tips:**
- Create an alias: `git config --global alias.lg "log --oneline --graph --all --decorate"`
- Use `git log -S "function_name"` (pickaxe) to find when a string was added/removed.
- `git log --follow <file>` tracks file history even through renames.

---

### `git show`

Show various types of objects (commits, tags, trees, blobs).

**Syntax:**
```bash
git show [options] <object>
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `--stat` | Show diffstat only |
| `--name-only` | Show file names only |
| `--format=<fmt>` | Custom output format |
| `-s` | Suppress diff output |
| `--pretty` | Pretty-print format |

**Examples:**

```bash
# Show a specific commit
$ git show 3a2b1c4
commit 3a2b1c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b
Author: John Doe <john@example.com>
Date:   Mon Mar 15 10:30:00 2024 +0000

    Add user authentication module

diff --git a/src/auth.js b/src/auth.js
new file mode 100644
...

# Show a file at a specific commit
$ git show main:src/config.js
// config.js content at main branch
module.exports = { port: 3000, env: 'production' };

# Show tag info
$ git show v1.0.0
tag v1.0.0
Tagger: John Doe <john@example.com>
Date:   Fri Mar 20 14:00:00 2024 +0000

Release version 1.0.0
```

**Pro Tips:**
- `git show HEAD~3:path/to/file` shows a file 3 commits ago.
- Use `git show :<n>:<file>` during merge conflicts (stage 1=base, 2=ours, 3=theirs).
- `git show --stat HEAD` quickly shows which files the last commit touched.

---

### `git shortlog`

Summarize git log output by author.

**Syntax:**
```bash
git shortlog [options] [<revision-range>]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `-s, --summary` | Show commit count only |
| `-n, --numbered` | Sort by commit count |
| `-e, --email` | Show email addresses |
| `--group=<type>` | Group by author/committer/trailer |

**Examples:**

```bash
# Summary of contributors
$ git shortlog -sne
    142  John Doe <john@example.com>
     89  Jane Smith <jane@example.com>
     34  Bob Wilson <bob@example.com>

# Contributions in a range
$ git shortlog -sn v1.0.0..v2.0.0
     45  John Doe
     23  Jane Smith

# Detailed shortlog
$ git shortlog -5
John Doe (3):
      Add payment gateway
      Fix checkout flow
      Update user model

Jane Smith (2):
      Add login validation
      Create login form
```

**Pro Tips:**
- Perfect for generating changelogs and contributor lists.
- Use `git shortlog -sn --no-merges` to exclude merge commits from counts.
- Pipe to it: `git log --format="%aN" | sort -u` for a unique contributor list.

---

### `git describe`

Give a human-readable name to a commit based on tags.

**Syntax:**
```bash
git describe [options] [<commit>]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `--tags` | Use any tag, not just annotated |
| `--always` | Show abbreviated commit if no tag found |
| `--long` | Always use long format |
| `--abbrev=<n>` | Set abbreviated commit length |
| `--dirty` | Append "-dirty" if working tree modified |

**Examples:**

```bash
# Describe current commit relative to tags
$ git describe
v1.2.0-14-g3a2b1c4
# Meaning: 14 commits after tag v1.2.0, at commit 3a2b1c4

# Describe with dirty flag
$ git describe --tags --dirty
v1.2.0-14-g3a2b1c4-dirty

# Always show something (even without tags)
$ git describe --always
3a2b1c4
```

**Pro Tips:**
- Useful for automatic version numbering in build scripts.
- Format: `<tag>-<commits-since-tag>-g<abbreviated-hash>`.
- Use `git describe --dirty` in CI to detect uncommitted changes.

---


## Patching

### `git apply`

Apply a patch to files.

**Syntax:**
```bash
git apply [options] <patch-file>
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `--check` | Test if patch applies cleanly |
| `--stat` | Show diffstat of the patch |
| `--3way` | Attempt 3-way merge if patch fails |
| `-R, --reverse` | Apply patch in reverse |
| `--whitespace=<action>` | Handle whitespace errors |
| `-v, --verbose` | Report progress |

**Examples:**

```bash
# Check if a patch applies cleanly
$ git apply --check fix-bug.patch
# (no output = success)

# Apply a patch with stats
$ git apply --stat fix-bug.patch
 src/app.js |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)
$ git apply fix-bug.patch

# Apply with 3-way merge fallback
$ git apply --3way feature.patch
Applied patch to 'src/utils.js' with conflicts.
U src/utils.js
```

**Pro Tips:**
- `git apply` doesn't create commits — use `git am` for that.
- Always run `--check` first in scripts to avoid partial application.
- Use `--3way` for better conflict handling (creates merge markers).

---

### `git format-patch`

Prepare patches for email submission.

**Syntax:**
```bash
git format-patch [options] <since | revision-range>
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `-n` | Generate patches for last n commits |
| `-o <dir>` | Output directory |
| `--cover-letter` | Generate a cover letter |
| `--thread` | Make patches reply to each other |
| `-s, --signoff` | Add Signed-off-by line |
| `--stdout` | Output to stdout instead of files |

**Examples:**

```bash
# Create patches for last 3 commits
$ git format-patch -3
0001-Add-user-model.patch
0002-Add-user-controller.patch
0003-Add-user-routes.patch

# Create patches between two points
$ git format-patch main..feature/api -o patches/
patches/0001-Add-API-endpoints.patch
patches/0002-Add-API-tests.patch

# Single patch to stdout (for piping)
$ git format-patch -1 --stdout HEAD > latest.patch
```

**Pro Tips:**
- Used heavily in the Linux kernel development workflow (email-based).
- Patches include author info, commit message, and diffs — fully portable.
- Use with `--cover-letter` for patch series with an overview email.

---

### `git am`

Apply patches from mailbox format (created by `format-patch`).

**Syntax:**
```bash
git am [options] [<mbox-file>...]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `--3way` | Fall back to 3-way merge |
| `--abort` | Abort patch application |
| `--continue` | Continue after conflict resolution |
| `--skip` | Skip current patch |
| `-s, --signoff` | Add Signed-off-by line |
| `--directory=<dir>` | Apply patches relative to directory |

**Examples:**

```bash
# Apply a series of patches
$ git am patches/*.patch
Applying: Add user model
Applying: Add user controller
Applying: Add user routes

# Apply with 3-way merge for conflicts
$ git am --3way feature.patch
Applying: Add feature X
Using index info to reconstruct a base tree...
Falling back to patching base and 3-way merge...
Applied patch to 'src/feature.js' cleanly.

# Abort failed patch application
$ git am --abort
```

**Pro Tips:**
- `git am` creates commits (preserving author) — unlike `git apply`.
- Combine: `git format-patch` → email → `git am` for distributed workflows.
- Use `--3way` by default: `git config --global am.threeWay true`.

---

## Debugging

### `git bisect`

Use binary search to find the commit that introduced a bug.

**Syntax:**
```bash
git bisect <start | bad | good | reset | run>
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `start` | Begin bisect session |
| `bad [<rev>]` | Mark commit as bad |
| `good [<rev>]` | Mark commit as good |
| `reset` | End bisect session |
| `run <script>` | Automate with a test script |
| `skip` | Skip untestable commit |
| `log` | Show bisect log |

**Examples:**

```bash
# Manual bisect
$ git bisect start
$ git bisect bad HEAD
$ git bisect good v1.0.0
Bisecting: 25 revisions left to test after this (roughly 5 steps)
[abc1234] Some commit message

# (test the code, then mark)
$ git bisect bad
Bisecting: 12 revisions left to test after this (roughly 4 steps)

# ... repeat until found ...
$ git bisect good
abc1234def5678 is the first bad commit
commit abc1234def5678
Author: John Doe
Date: ...
    Introduce bug in parser

$ git bisect reset
Previous HEAD position was abc1234... Introduce bug in parser
Switched to branch 'main'

# Automated bisect with a test script
$ git bisect start HEAD v1.0.0
$ git bisect run npm test
running npm test
... (automated binary search) ...
abc1234 is the first bad commit
```

**Pro Tips:**
- Bisect checks ~log₂(n) commits — even 1000 commits only needs ~10 steps.
- The `run` script should return 0 for good, 1-124 for bad, 125 for skip.
- Use `git bisect visualize` to see remaining suspects in gitk.

---

### `git blame`

Show what revision and author last modified each line.

**Syntax:**
```bash
git blame [options] <file>
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `-L <start>,<end>` | Blame specific line range |
| `-w` | Ignore whitespace changes |
| `-M` | Detect moved lines within a file |
| `-C` | Detect lines moved from other files |
| `--since=<date>` | Ignore changes before date |
| `-e, --show-email` | Show author email |

**Examples:**

```bash
# Blame a specific file
$ git blame src/app.js
3a2b1c4d (John Doe  2024-03-15 10:30:00 +0000  1) const express = require('express');
7d4e5f6a (Jane Smith 2024-03-16 14:22:00 +0000  2) const helmet = require('helmet');
3a2b1c4d (John Doe  2024-03-15 10:30:00 +0000  3) const app = express();
9f8e7d6b (Bob Wilson 2024-03-17 09:15:00 +0000  4) app.use(helmet());

# Blame specific lines
$ git blame -L 10,20 src/app.js
9f8e7d6b (Bob Wilson 2024-03-17 09:15:00 +0000 10) app.get('/', (req, res) => {
9f8e7d6b (Bob Wilson 2024-03-17 09:15:00 +0000 11)   res.send('Hello World');
...

# Ignore whitespace and detect moves
$ git blame -w -M src/utils.js
```

**Pro Tips:**
- Use `git blame -w` to ignore blame from reformatting commits.
- Create a `.git-blame-ignore-revs` file and set `blame.ignoreRevsFile` for mass-formatting commits.
- `git log -p -S "line content"` can find the original author when blame shows a move.

---

### `git grep`

Search for patterns in tracked files.

**Syntax:**
```bash
git grep [options] <pattern> [<tree>] [-- <path>]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `-n, --line-number` | Show line numbers |
| `-c, --count` | Show match count per file |
| `-i, --ignore-case` | Case-insensitive search |
| `-l, --files-with-matches` | Show only filenames |
| `-w, --word-regexp` | Match whole words only |
| `-e <pattern>` | Specify pattern (for multiple) |
| `--and / --or` | Combine patterns |
| `-p, --show-function` | Show enclosing function |

**Examples:**

```bash
# Search for a function usage
$ git grep -n "fetchUserData"
src/api.js:15:async function fetchUserData(id) {
src/components/Profile.js:8:import { fetchUserData } from '../api';
src/components/Profile.js:22:  const data = await fetchUserData(userId);

# Search in a specific commit/branch
$ git grep "TODO" v1.0.0
v1.0.0:src/app.js:42:  // TODO: implement caching
v1.0.0:src/utils.js:18: // TODO: add error handling

# Count matches per file
$ git grep -c "console.log"
src/app.js:3
src/debug.js:12
tests/helper.js:7
```

**Pro Tips:**
- `git grep` is faster than regular `grep` — it only searches tracked files.
- Use `git grep -p` to see which function contains each match.
- Combine patterns: `git grep -e "pattern1" --and -e "pattern2"` for AND logic.

---


## Administration

### `git clean`

Remove untracked files from the working tree.

**Syntax:**
```bash
git clean [options]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `-f, --force` | Required to actually delete (safety) |
| `-d` | Remove untracked directories too |
| `-n, --dry-run` | Show what would be removed |
| `-x` | Remove ignored files too |
| `-X` | Remove ONLY ignored files |
| `-i, --interactive` | Interactive mode |

**Examples:**

```bash
# Preview what would be deleted
$ git clean -nd
Would remove build/
Would remove temp.log
Would remove untracked-file.js

# Remove untracked files and directories
$ git clean -fd
Removing build/
Removing temp.log
Removing untracked-file.js

# Remove only ignored files (like build artifacts)
$ git clean -fX
Removing node_modules/
Removing dist/
Removing .env.local
```

**Pro Tips:**
- Always run `-n` (dry run) first — `git clean` is irreversible.
- `git clean -fdx` gives you a pristine working tree (like a fresh clone).
- Use `-X` to clean build artifacts without removing new source files.

---

### `git gc`

Cleanup unnecessary files and optimize the repository.

**Syntax:**
```bash
git gc [options]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `--aggressive` | More thorough optimization (slow) |
| `--auto` | Only run if needed |
| `--prune=<date>` | Prune objects older than date |
| `--no-prune` | Don't prune loose objects |
| `--quiet` | Suppress output |

**Examples:**

```bash
# Standard garbage collection
$ git gc
Enumerating objects: 1542, done.
Counting objects: 100% (1542/1542), done.
Delta compression using up to 8 threads
Compressing objects: 100% (723/723), done.
Writing objects: 100% (1542/1542), done.
Total 1542 (delta 891), reused 1200 (delta 750)

# Aggressive optimization (for old/large repos)
$ git gc --aggressive
Enumerating objects: 15420, done.
Counting objects: 100% (15420/15420), done.
Delta compression using up to 8 threads
...

# Auto mode (Git decides if needed)
$ git gc --auto
# (may produce no output if optimization not needed)
```

**Pro Tips:**
- Git runs `gc --auto` automatically; you rarely need to run it manually.
- Use `--aggressive` after importing from another VCS or after major history rewrites.
- `git gc` packs loose objects, removes unreachable objects, and compresses pack files.

---

### `git archive`

Create an archive of files from a named tree.

**Syntax:**
```bash
git archive [options] <tree-ish> [<path>...]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `--format=<fmt>` | Archive format (tar, zip, tar.gz) |
| `--prefix=<prefix>` | Prepend prefix to each filename |
| `-o, --output=<file>` | Write to file instead of stdout |
| `--remote=<repo>` | Archive from remote repo |

**Examples:**

```bash
# Create a zip archive of HEAD
$ git archive --format=zip --output=release.zip HEAD
# (creates release.zip)

# Create tarball of a specific tag with prefix
$ git archive --format=tar.gz --prefix=myproject-v1.0/ -o myproject-v1.0.tar.gz v1.0.0
# (creates myproject-v1.0.tar.gz with directory prefix)

# Archive only a subdirectory
$ git archive --format=zip -o docs.zip HEAD docs/
# (creates docs.zip containing only the docs/ directory)
```

**Pro Tips:**
- Perfect for creating release tarballs without `.git` directory.
- Use `.gitattributes` with `export-ignore` to exclude files from archives.
- `--remote` lets you archive directly from a remote without cloning.

---

### `git bundle`

Move objects and refs by archive (offline transfer).

**Syntax:**
```bash
git bundle create <file> <git-rev-list-args>
git bundle verify <file>
git bundle unbundle <file>
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `create` | Create a bundle file |
| `verify` | Verify bundle is valid |
| `list-heads` | List refs in the bundle |
| `unbundle` | Unpack objects from bundle |

**Examples:**

```bash
# Bundle entire repository
$ git bundle create repo.bundle --all
Enumerating objects: 1542, done.
Counting objects: 100% (1542/1542), done.
Writing objects: 100% (1542/1542), 2.10 MiB | 10.50 MiB/s, done.
Total 1542 (delta 891), reused 1542 (delta 891)

# Bundle only recent commits
$ git bundle create update.bundle main~5..main
Enumerating objects: 25, done.
Writing objects: 100% (25/25), 15.30 KiB, done.

# Clone from a bundle
$ git clone repo.bundle my-project
Cloning into 'my-project'...
Receiving objects: 100% (1542/1542), done.
```

**Pro Tips:**
- Bundles are for sneakernet — transfer repos via USB when there's no network.
- Incremental bundles (`since..until`) keep transfers small.
- Verify before using: `git bundle verify repo.bundle`.

---

## Subcommands

### `git stash` (extended)

*(See also: [Snapshotting > git stash](#git-stash))*

**Additional Operations:**

```bash
# Show stash contents as diff
$ git stash show -p stash@{0}
diff --git a/src/login.js b/src/login.js
--- a/src/login.js
+++ b/src/login.js
@@ -1,3 +1,8 @@
+import { validate } from './utils';
...

# Create branch from stash
$ git stash branch feature/from-stash stash@{1}
Switched to a new branch 'feature/from-stash'
Dropped stash@{1}

# Stash specific files only
$ git stash push -m "only config" src/config.js src/env.js
Saved working directory and index state On main: only config
```

---

### `git tag`

Create, list, delete, or verify tags.

**Syntax:**
```bash
git tag [options] [<tagname>] [<commit>]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `-a` | Create annotated tag |
| `-m <msg>` | Tag message |
| `-d` | Delete a tag |
| `-l <pattern>` | List tags matching pattern |
| `-f` | Force (replace existing tag) |
| `-s` | Create signed tag (GPG) |
| `-v` | Verify signed tag |
| `--sort=<key>` | Sort tags |

**Examples:**

```bash
# Create annotated tag
$ git tag -a v1.0.0 -m "Release version 1.0.0"
# (no output)

# List tags with pattern
$ git tag -l "v1.*"
v1.0.0
v1.1.0
v1.2.0

# Delete local and remote tag
$ git tag -d v1.0.0-beta
Deleted tag 'v1.0.0-beta' (was 3a2b1c4)
$ git push origin --delete v1.0.0-beta
To https://github.com/user/repo.git
 - [deleted]         v1.0.0-beta
```

**Pro Tips:**
- Use annotated tags (`-a`) for releases — they store tagger, date, and message.
- Lightweight tags (no `-a`) are just pointers — use for personal/temporary marks.
- Tags don't push by default. Use `git push --tags` or `git push origin <tagname>`.

---

### `git worktree`

Manage multiple working trees from one repository.

**Syntax:**
```bash
git worktree <add | list | remove | prune> [options]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `add <path> [<branch>]` | Create a new worktree |
| `list` | List all worktrees |
| `remove <worktree>` | Remove a worktree |
| `prune` | Clean up stale worktree info |
| `-b <branch>` | Create new branch in worktree |
| `--detach` | Detach HEAD in new worktree |

**Examples:**

```bash
# Add a worktree for a hotfix
$ git worktree add ../hotfix-branch hotfix/critical-fix
Preparing worktree (checking out 'hotfix/critical-fix')
HEAD is now at 3a2b1c4 Previous commit

# List all worktrees
$ git worktree list
/home/user/project          3a2b1c4 [main]
/home/user/hotfix-branch    7d4e5f6 [hotfix/critical-fix]
/home/user/review-pr-42     9f8e7d6 [pr-42]

# Remove a worktree
$ git worktree remove ../hotfix-branch
```

**Pro Tips:**
- Worktrees let you work on multiple branches simultaneously without stashing.
- Great for: reviewing PRs, running tests on another branch, hotfixes during development.
- Each worktree shares the same `.git` objects — very space-efficient.

---

### `git submodule`

Manage repositories nested inside another repository.

**Syntax:**
```bash
git submodule [add | init | update | status | foreach | sync | deinit]
```

**Common Flags:**

| Flag | Description |
|------|-------------|
| `add <url> [<path>]` | Add a submodule |
| `init` | Initialize submodule config |
| `update --init` | Clone and checkout submodules |
| `update --recursive` | Update nested submodules |
| `update --remote` | Update to latest remote commit |
| `foreach <cmd>` | Run command in each submodule |
| `deinit <path>` | Unregister a submodule |
| `status` | Show submodule status |

**Examples:**

```bash
# Add a submodule
$ git submodule add https://github.com/lib/awesome-lib.git vendor/awesome-lib
Cloning into 'vendor/awesome-lib'...
done.

# Clone a repo and initialize all submodules
$ git clone --recurse-submodules https://github.com/user/project.git
Cloning into 'project'...
Submodule 'vendor/awesome-lib' registered for path 'vendor/awesome-lib'
Cloning into 'vendor/awesome-lib'...

# Update all submodules to latest
$ git submodule update --remote --merge
Submodule path 'vendor/awesome-lib': merged in 'abc1234'

# Run command in all submodules
$ git submodule foreach 'git checkout main && git pull'
Entering 'vendor/awesome-lib'
Already on 'main'
Already up to date.
```

**Pro Tips:**
- Always use `--recurse-submodules` when cloning repos with submodules.
- Consider `git subtree` as a simpler alternative for most use cases.
- `.gitmodules` tracks submodule URLs — commit it to share with the team.
- Use `git config --global submodule.recurse true` to auto-update submodules.

---

## Quick Reference Card

| Task | Command |
|------|---------|
| Undo last commit (keep changes) | `git reset --soft HEAD~1` |
| Discard all local changes | `git checkout -- .` or `git restore .` |
| See what changed | `git diff --stat` |
| Find who changed a line | `git blame <file>` |
| Search code | `git grep "pattern"` |
| Undo a pushed commit | `git revert <sha>` |
| Sync fork with upstream | `git fetch upstream && git rebase upstream/main` |
| Clean up merged branches | `git branch --merged main \| grep -v main \| xargs git branch -d` |
| Emergency save | `git stash -u -m "emergency"` |
| Find bug introduction | `git bisect start && git bisect bad && git bisect good <sha>` |

---

*Last updated: June 2026*
