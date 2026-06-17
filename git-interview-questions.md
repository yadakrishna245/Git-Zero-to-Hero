# 💼 Git Interview Questions & Answers

[📖 README](README.md) | [🌳 Branching](git-branching.md) | [⚡ Commands](git-commands-cheatsheet.md) | [🔧 Internals](git-internals.md) | [🤝 Workflows](git-workflows.md) | [🚀 Advanced](git-advanced.md) | [🌐 GitHub/GitLab](github-gitlab-guide.md) | [🔥 Troubleshooting](git-troubleshooting.md) | [💼 Interview Prep](git-interview-questions.md) | [🔒 Security](git-security.md)

---

> 60+ Git interview questions organized by difficulty with clear answers and code examples.

---

## Beginner Level (20 Questions)

### 1. What is Git? What are the types of Version Control Systems?

**Answer:** Git is a distributed version control system (DVCS) that tracks changes in source code during software development.

**Types of VCS:**
| Type | Description | Examples |
|------|-------------|----------|
| Local VCS | Database on local machine | RCS |
| Centralized (CVCS) | Single central server | SVN, Perforce |
| Distributed (DVCS) | Full repo on every machine | Git, Mercurial |

Git's key advantage: every developer has a complete copy of the repository, enabling offline work and redundancy.

---

### 2. What is the difference between `git init` and `git clone`?

**Answer:**

- `git init` creates a **new** empty repository in the current directory
- `git clone` creates a **copy** of an existing remote repository

```bash
# Create new repo
git init my-project
# Result: empty repo with .git/ directory

# Clone existing repo
git clone https://github.com/user/repo.git
# Result: full copy with all history and remote configured
```

Key difference: `git clone` automatically sets up `origin` remote and tracks the default branch.

---

### 3. What is the staging area (index) and why does it exist?

**Answer:** The staging area is an intermediate zone between your working directory and the repository. It lets you craft commits precisely.

```
Working Directory → Staging Area → Repository
     (edit)          (git add)     (git commit)
```

**Why it exists:**
- Selectively commit parts of your changes
- Review what will be committed before committing
- Build logical commits from unrelated changes

```bash
# Stage specific files
git add src/feature.js

# Stage specific lines within a file
git add -p src/app.js

# See what's staged
git diff --cached
```

---

### 4. What is the difference between `git pull` and `git fetch`?

**Answer:**

| Command | Action |
|---------|--------|
| `git fetch` | Downloads changes but does NOT merge |
| `git pull` | Downloads changes AND merges (fetch + merge) |

```bash
# Fetch only — safe, non-destructive
git fetch origin
git log origin/main --oneline  # inspect changes
git merge origin/main          # manually merge

# Pull — fetch + merge in one step
git pull origin main

# Pull with rebase (cleaner history)
git pull --rebase origin main
```

**Best practice:** Use `git fetch` + inspect + merge for more control.

---

### 5. What is `.gitignore` and how does it work?

**Answer:** `.gitignore` tells Git which files/directories to ignore (not track).

```gitignore
# Dependencies
node_modules/
vendor/

# Build output
dist/
build/

# Environment files
.env
.env.local

# OS files
.DS_Store
Thumbs.db

# IDE
.idea/
.vscode/
*.swp

# Patterns
*.log
*.tmp
!important.log    # Negate: DO track this file
docs/**/*.pdf     # Ignore PDFs in docs subdirectories
```

**Key rules:**
- Only affects **untracked** files (files already tracked aren't affected)
- Use `git rm --cached file` to untrack a file already committed
- Patterns are matched relative to `.gitignore` location
- `#` for comments, `!` to negate, `*` wildcard, `**` directory wildcard

---

### 6. What is HEAD in Git?

**Answer:** HEAD is a pointer to the current commit/branch you're working on. It represents "where you are right now."

```bash
# HEAD usually points to a branch
$ cat .git/HEAD
ref: refs/heads/main

# Which points to a commit
$ git rev-parse HEAD
abc1234def5678...

# Move HEAD by switching branches
git checkout feature  # HEAD → feature branch
git checkout abc1234  # HEAD → specific commit (detached HEAD)
```

**Special references:**
- `HEAD~1` — parent of current commit
- `HEAD~3` — 3 commits back
- `HEAD^1` — first parent (useful for merge commits)

---

### 7. What does `git status` show and how do you interpret it?

**Answer:** `git status` shows the state of your working directory and staging area.

```bash
$ git status
On branch main
Your branch is ahead of 'origin/main' by 2 commits.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   src/new-feature.js
        modified:   src/app.js

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
        modified:   README.md

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        temp.txt
```

**Three sections:**
1. **Staged** (green) — will be included in next commit
2. **Modified but unstaged** (red) — changed but not yet staged
3. **Untracked** — new files Git doesn't know about

Short format: `git status -s` (M=modified, A=added, ?=untracked)

---

### 8. How do you create and switch branches?

**Answer:**

```bash
# Create a branch
git branch feature-login

# Switch to it
git checkout feature-login
# or (modern)
git switch feature-login

# Create and switch in one command
git checkout -b feature-login
# or (modern)
git switch -c feature-login

# List branches
git branch          # local
git branch -r       # remote
git branch -a       # all

# Delete a branch
git branch -d feature-login      # safe (only if merged)
git branch -D feature-login      # force delete
```

---

### 9. What is a commit in Git?

**Answer:** A commit is a snapshot of your project at a point in time. It contains:

- A unique SHA-1 hash (40 characters)
- Author name and email
- Timestamp
- Commit message
- Pointer to parent commit(s)
- Pointer to a tree object (snapshot of file structure)

```bash
# Make a commit
git commit -m "Add login feature"

# View commit details
git show abc1234

# View commit history
git log --oneline
# abc1234 Add login feature
# def5678 Initial commit
```

Commits are **immutable** — you can't change a commit, only create new ones (amend creates a new commit with a new hash).

---

### 10. What is the difference between `git add .` and `git add -A`?

**Answer:**

| Command | New Files | Modified Files | Deleted Files | Scope |
|---------|-----------|---------------|---------------|-------|
| `git add .` | ✅ | ✅ | ✅ | Current directory and below |
| `git add -A` | ✅ | ✅ | ✅ | Entire working tree |
| `git add -u` | ❌ | ✅ | ✅ | Entire working tree (tracked only) |

```bash
# From repo root, these are equivalent:
git add .
git add -A

# From a subdirectory, they differ:
cd src/
git add .    # only stages changes in src/
git add -A   # stages changes everywhere
```



---

### 11. How do you view commit history?

**Answer:**

```bash
# Basic log
git log

# One line per commit
git log --oneline

# Graph view
git log --oneline --graph --all

# Last 5 commits
git log -5

# By author
git log --author="John"

# By date range
git log --after="2026-01-01" --before="2026-06-01"

# By file
git log -- src/app.js

# Search commit messages
git log --grep="fix bug"
```

---

### 12. What is `git diff` and how is it used?

**Answer:** `git diff` shows differences between various states.

```bash
# Working directory vs staging area
git diff

# Staging area vs last commit
git diff --cached
# or
git diff --staged

# Between two commits
git diff abc1234 def5678

# Between branches
git diff main..feature

# Specific file
git diff -- src/app.js

# Summary only (stats)
git diff --stat
```

---

### 13. What is a remote in Git?

**Answer:** A remote is a reference to a repository hosted elsewhere (GitHub, GitLab, etc.).

```bash
# View remotes
git remote -v
# origin  https://github.com/user/repo.git (fetch)
# origin  https://github.com/user/repo.git (push)

# Add a remote
git remote add upstream https://github.com/original/repo.git

# Remove a remote
git remote remove upstream

# Rename a remote
git remote rename origin old-origin
```

`origin` is the conventional name for your primary remote. `upstream` is typically used for the original repo in fork workflows.

---

### 14. How do you undo changes in Git?

**Answer:** Depends on the state of the changes:

```bash
# Discard unstaged changes in working directory
git checkout -- file.txt
# or (modern)
git restore file.txt

# Unstage a file (keep changes in working directory)
git reset HEAD file.txt
# or (modern)
git restore --staged file.txt

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Undo a pushed commit (safe, creates new commit)
git revert <commit-hash>
```

---

### 15. What is a merge conflict and how do you resolve it?

**Answer:** A merge conflict occurs when Git can't automatically merge changes because two branches modified the same lines.

```bash
# Attempt merge
git merge feature
# CONFLICT (content): Merge conflict in file.txt

# View conflicts
git status

# Edit file — conflict markers:
<<<<<<< HEAD
current branch code
=======
incoming branch code
>>>>>>> feature

# After manual resolution:
git add file.txt
git commit -m "Resolve merge conflict"
```

---

### 16. What is `git stash`?

**Answer:** `git stash` temporarily saves uncommitted changes so you can work on something else.

```bash
# Save changes
git stash
# or with message
git stash save "WIP: login feature"

# List stashes
git stash list
# stash@{0}: On main: WIP: login feature
# stash@{1}: WIP on main: abc1234 Previous work

# Apply most recent stash (keep in stash list)
git stash apply

# Apply and remove from stash list
git stash pop

# Apply specific stash
git stash apply stash@{1}

# Drop a stash
git stash drop stash@{0}

# Clear all stashes
git stash clear
```

---

### 17. What is the purpose of `git tag`?

**Answer:** Tags mark specific points in history, typically for releases.

```bash
# Lightweight tag (just a pointer)
git tag v1.0.0

# Annotated tag (recommended — includes metadata)
git tag -a v1.0.0 -m "Release version 1.0.0"

# Tag a specific commit
git tag -a v1.0.0 abc1234

# List tags
git tag -l "v1.*"

# Push tags to remote
git push origin v1.0.0
git push origin --tags    # push all tags

# Delete a tag
git tag -d v1.0.0                    # local
git push origin --delete v1.0.0      # remote
```

---

### 18. What is `git log --oneline --graph` and why is it useful?

**Answer:** It shows a compact, visual representation of branch history.

```bash
$ git log --oneline --graph --all
* e5f6g7h (HEAD -> main) Merge feature into main
|\
| * c3d4e5f (feature) Add new feature
| * a1b2c3d Start feature work
|/
* 9z8y7x6 Initial commit
```

Useful for:
- Visualizing branch topology
- Seeing merge points
- Understanding parallel development
- Identifying which commits are on which branch

Alias: `git config --global alias.lg "log --oneline --graph --all --decorate"`

---

### 19. How do you rename and delete files in Git?

**Answer:**

```bash
# Rename (Git tracks this as delete + add)
git mv old-name.js new-name.js
# Equivalent to:
mv old-name.js new-name.js
git add new-name.js
git rm old-name.js

# Delete a file
git rm file.txt              # remove from disk and staging
git rm --cached file.txt     # remove from tracking only (keep on disk)

# Commit the change
git commit -m "Rename/delete file"
```

Git detects renames by content similarity (even without `git mv`).

---

### 20. What is a bare repository?

**Answer:** A bare repository has no working directory — it only contains the `.git` contents. It's used as a shared/central repository.

```bash
# Create bare repo
git init --bare project.git

# Contents (no working files, only git objects)
$ ls project.git/
HEAD  config  description  hooks/  info/  objects/  refs/

# Clone from bare repo
git clone /path/to/project.git

# Convert existing repo to bare
git clone --bare my-project my-project.git
```

**Use cases:** Servers (GitHub/GitLab host bare repos), CI/CD pipelines, shared network repos.



---

## Intermediate Level (20 Questions)

### 21. What is the difference between merge and rebase?

**Answer:**

| Aspect | Merge | Rebase |
|--------|-------|--------|
| History | Non-linear (preserves branches) | Linear (straight line) |
| Creates merge commit | Yes | No |
| Safe for shared branches | Yes | No (rewrites history) |
| Conflict resolution | Once | Per commit replayed |

```bash
# Merge: creates a merge commit
git checkout main
git merge feature
#   *   Merge commit
#   |\
#   | * Feature commit
#   |/
#   * Main commit

# Rebase: replays commits on top
git checkout feature
git rebase main
#   * Feature commit (replayed, new hash)
#   * Main commit
```

**Golden rule:** Never rebase commits that have been pushed to a shared branch.

---

### 22. What is a fast-forward merge?

**Answer:** A fast-forward merge occurs when the target branch has no new commits since the source branch diverged. Git simply moves the pointer forward.

```bash
# main hasn't changed since feature branched off
#   main
#   |
#   * -- * -- * feature
#
git checkout main
git merge feature
# Fast-forward (no merge commit created)

# Force a merge commit even in fast-forward situations:
git merge --no-ff feature
```

**When it happens:** Only when there's a direct linear path from the current branch to the branch being merged.

---

### 23. What is `git cherry-pick`?

**Answer:** Cherry-pick applies a specific commit from one branch to another without merging the entire branch.

```bash
# Apply a single commit
git cherry-pick abc1234

# Apply multiple commits
git cherry-pick abc1234 def5678

# Apply without committing (stage only)
git cherry-pick --no-commit abc1234

# If conflict occurs:
git cherry-pick --continue   # after resolving
git cherry-pick --abort      # cancel
```

**Use cases:**
- Hotfix: apply a bug fix from develop to main
- Selective features from a long-running branch
- Recovering a commit from a deleted branch

---

### 24. What is `git stash` and how does it work internally?

**Answer:** `git stash` saves dirty working directory and staged changes onto a stack, then reverts to a clean state.

Internally, stash creates two (or three) commit objects:
1. One for the index (staged changes)
2. One for the working directory
3. Optionally one for untracked files (`--include-untracked`)

```bash
# Stash including untracked files
git stash --include-untracked
# or
git stash -u

# Stash specific files
git stash push -m "message" -- src/file.js

# Create a branch from stash
git stash branch new-feature stash@{0}

# Show stash contents without applying
git stash show -p stash@{0}
```

---

### 25. What is the difference between `git reset` and `git revert`?

**Answer:**

| Aspect | `git reset` | `git revert` |
|--------|-------------|--------------|
| Modifies history | Yes | No |
| Safe for pushed commits | No | Yes |
| Direction | Moves backward | Creates forward commit |
| Team impact | Dangerous on shared branches | Safe always |

```bash
# Reset: moves branch pointer backward (REWRITES HISTORY)
git reset --hard HEAD~1  # commit is gone from history

# Revert: creates a NEW commit that undoes changes
git revert abc1234       # original commit stays in history
# Result: new commit "Revert 'original message'"
```

**Rule:** Use `reset` for local unpushed commits, `revert` for pushed commits.

---

### 26. What are common Git branching strategies?

**Answer:**

**Git Flow:**
- `main` — production-ready code
- `develop` — integration branch
- `feature/*` — new features
- `release/*` — release preparation
- `hotfix/*` — production bug fixes

**GitHub Flow (simpler):**
- `main` — always deployable
- Feature branches → Pull Request → Merge to main

**Trunk-Based Development:**
- Single `main` branch
- Short-lived feature branches (< 1 day)
- Feature flags for incomplete work

**GitLab Flow:**
- `main` + environment branches (`staging`, `production`)
- Merge upstream → downstream

```bash
# Git Flow example
git checkout -b feature/login develop
# ... work ...
git checkout develop
git merge --no-ff feature/login
git branch -d feature/login
```

---

### 27. What are Git hooks?

**Answer:** Hooks are scripts that run automatically at specific Git events.

**Client-side hooks** (in `.git/hooks/`):
| Hook | Trigger |
|------|---------|
| `pre-commit` | Before commit is created |
| `prepare-commit-msg` | After default message generated |
| `commit-msg` | After user enters message |
| `pre-push` | Before push to remote |
| `post-merge` | After a merge completes |

**Server-side hooks:**
| Hook | Trigger |
|------|---------|
| `pre-receive` | Before accepting a push |
| `post-receive` | After push is accepted |
| `update` | Per branch, before update |

```bash
# Example: pre-commit hook that runs linting
#!/bin/sh
# .git/hooks/pre-commit
npm run lint
if [ $? -ne 0 ]; then
  echo "Lint failed. Commit aborted."
  exit 1
fi
```

**Tools for managing hooks:** Husky (Node.js), pre-commit (Python), lefthook (Go).

---

### 28. What is the difference between annotated and lightweight tags?

**Answer:**

```bash
# Lightweight: just a pointer (like a branch that doesn't move)
git tag v1.0.0

# Annotated: full object with metadata (recommended)
git tag -a v1.0.0 -m "Release 1.0.0"
```

| Aspect | Lightweight | Annotated |
|--------|-------------|-----------|
| Metadata | None | Tagger, date, message |
| Git object | No (just a ref) | Yes (tag object) |
| GPG signing | No | Yes (`-s` flag) |
| Best for | Temporary/local | Releases, public marks |

```bash
# Show tag info
git show v1.0.0
# Annotated shows: tagger, date, message, then commit info
# Lightweight shows: just the commit info
```

---

### 29. What is `git bisect`?

**Answer:** Binary search through commits to find which commit introduced a bug.

```bash
# Start bisect
git bisect start

# Mark current commit as bad
git bisect bad

# Mark a known good commit
git bisect good abc1234

# Git checks out a middle commit — test it, then:
git bisect good   # if the bug is NOT present
git bisect bad    # if the bug IS present

# Repeat until Git identifies the culprit:
# abc1234 is the first bad commit

# End bisect
git bisect reset
```

**Automated bisect with a test script:**
```bash
git bisect start HEAD abc1234
git bisect run npm test
# Git automatically finds the failing commit
```

---

### 30. How do you configure Git for a project vs globally?

**Answer:**

Three levels of configuration (higher specificity wins):
```bash
# System-wide (all users)
git config --system user.name "Name"     # /etc/gitconfig

# Global (current user)
git config --global user.name "Name"     # ~/.gitconfig

# Local (current repository)
git config --local user.name "Name"      # .git/config
```

```bash
# View all config with origin
git config --list --show-origin

# Common configurations
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global core.editor "code --wait"
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.st status
```



---

### 31. What is `git reflog`?

**Answer:** Reflog records every change to HEAD and branch tips, even operations that don't appear in `git log` (like resets and rebases).

```bash
$ git reflog
abc1234 HEAD@{0}: commit: Add feature
def5678 HEAD@{1}: reset: moving to HEAD~1
ghi9012 HEAD@{2}: commit: Old commit (now "lost")

# Recover "lost" commit
git checkout ghi9012
# or
git branch recovery-branch ghi9012
```

Reflog entries expire after 90 days (30 days for unreachable commits). It is **local only** — not shared with remote.

---

### 32. How do you squash commits?

**Answer:**

```bash
# Interactive rebase — squash last 3 commits
git rebase -i HEAD~3
```

In the editor:
```
pick abc1234 First commit
squash def5678 Fix typo
squash ghi9012 Add test
```

Alternative (soft reset method):
```bash
git reset --soft HEAD~3
git commit -m "Combined: Add feature with tests"
```

**Squash during merge (GitHub-style):**
```bash
git merge --squash feature
git commit -m "Add feature (squashed)"
```

---

### 33. What are tracking branches?

**Answer:** Tracking branches are local branches that have a direct relationship with a remote branch.

```bash
# Set up tracking
git checkout -b feature --track origin/feature
# or
git branch --set-upstream-to=origin/main main

# Check tracking
git branch -vv
# * main    abc1234 [origin/main] Latest commit
#   feature def5678 [origin/feature: ahead 2] My work

# Push with tracking setup
git push -u origin feature
```

Tracking enables:
- `git pull` / `git push` without specifying remote/branch
- `git status` showing ahead/behind counts

---

### 34. What is `git blame`?

**Answer:** Shows who last modified each line of a file and when.

```bash
# Basic blame
git blame src/app.js

# Output:
# abc1234 (John 2026-01-15 10:30:00 +0530  1) const express = require('express');
# def5678 (Jane 2026-02-20 14:15:00 +0530  2) const app = express();

# Blame specific lines
git blame -L 10,20 src/app.js

# Ignore whitespace changes
git blame -w src/app.js

# Show original commit (before move/copy)
git blame -C src/app.js
```

---

### 35. What is `git worktree`?

**Answer:** Worktrees let you check out multiple branches simultaneously in separate directories.

```bash
# Create a worktree for a different branch
git worktree add ../hotfix hotfix-branch

# List worktrees
git worktree list
# /home/user/project       abc1234 [main]
# /home/user/hotfix        def5678 [hotfix-branch]

# Remove a worktree
git worktree remove ../hotfix
```

**Use cases:**
- Work on hotfix without stashing current feature work
- Run tests on one branch while developing on another
- Compare branches side-by-side

---

### 36. How does `git rebase --onto` work?

**Answer:** Allows rebasing a subset of commits onto a different base.

```bash
# Syntax: git rebase --onto <newbase> <oldbase> <branch>

# Scenario: Move feature commits from develop to main
# Before:
#   main: A - B
#   develop: A - B - C - D
#   feature: A - B - C - D - E - F (branched from develop at D)

git rebase --onto main develop feature
# After: feature is now A - B - E - F (only E and F moved to main)
```

---

### 37. What is `git clean`?

**Answer:** Removes untracked files from the working directory.

```bash
# Dry run (show what would be deleted)
git clean -n

# Remove untracked files
git clean -f

# Remove untracked files and directories
git clean -fd

# Remove ignored files too
git clean -fdx

# Interactive mode
git clean -i
```

**Warning:** `git clean -f` is irreversible — files are permanently deleted.

---

### 38. How do you resolve a merge conflict in a binary file?

**Answer:** Git cannot merge binary files automatically. You must choose one version.

```bash
# Keep our version (current branch)
git checkout --ours path/to/image.png
git add path/to/image.png

# Keep their version (incoming branch)
git checkout --theirs path/to/image.png
git add path/to/image.png

# Complete the merge
git commit
```

**For better binary handling:** Use Git LFS and avoid binary files in the repo when possible.

---

### 39. What is `git shortlog`?

**Answer:** Summarizes `git log` output grouped by author.

```bash
# Commits by author
git shortlog
# Jane (5):
#       Add feature X
#       Fix bug Y
# John (3):
#       Update docs

# Count only
git shortlog -sn
#      5  Jane
#      3  John

# Include all branches
git shortlog -sn --all

# Since a tag
git shortlog v1.0.0..HEAD
```

Useful for release notes and contribution statistics.

---

### 40. How do you set up a Git alias?

**Answer:**

```bash
# Common aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage "reset HEAD --"
git config --global alias.last "log -1 HEAD"
git config --global alias.lg "log --oneline --graph --all --decorate"
git config --global alias.amend "commit --amend --no-edit"

# Usage
git co feature-branch   # same as: git checkout feature-branch
git lg                   # pretty log graph

# Shell commands in aliases (prefix with !)
git config --global alias.cleanup '!git branch --merged | grep -v main | xargs git branch -d'
```



---

## Advanced Level (20+ Questions)

### 41. Explain Git internals — what are blobs, trees, commits, and tags?

**Answer:** Git stores everything as objects identified by SHA-1 hashes.

| Object | Purpose |
|--------|---------|
| **Blob** | Stores file content (no filename) |
| **Tree** | Stores directory listing (filenames → blob/tree refs) |
| **Commit** | Points to a tree + metadata (author, message, parent) |
| **Tag** | Points to a commit + annotation metadata |

```bash
# View object type
git cat-file -t abc1234

# View object content
git cat-file -p abc1234

# Example: inspecting a commit
$ git cat-file -p HEAD
tree 4b825dc642cb6eb9a060e54bf899d69f7e6053b7
parent abc1234def5678901234567890abcdef12345678
author John <john@example.com> 1718600000 +0530
committer John <john@example.com> 1718600000 +0530

Commit message here
```

**Object storage:** `.git/objects/` — first 2 chars of SHA as directory, rest as filename. Objects are compressed with zlib.

---

### 42. How does Git compute SHA-1 hashes?

**Answer:** Git hashes the object header + content:

```
SHA-1("<type> <size>\0<content>")
```

```bash
# Manually compute a blob hash
echo -n "Hello World" | git hash-object --stdin
# 557db03de997c86a4a028e1ebd3a1ceb225be238

# Verify:
printf "blob 11\0Hello World" | sha1sum
# 557db03de997c86a4a028e1ebd3a1ceb225be238
```

**Key property:** Same content always produces the same hash. This enables:
- Deduplication (same file = same blob regardless of location)
- Integrity checking
- Content-addressable storage

---

### 43. How does `git reflog` help in recovery scenarios?

**Answer:** Reflog records every HEAD movement, making almost any operation recoverable.

```bash
# After accidental reset --hard
$ git reflog
abc1234 HEAD@{0}: reset: moving to HEAD~3
def5678 HEAD@{1}: commit: Important work
ghi9012 HEAD@{2}: commit: More important work
jkl3456 HEAD@{3}: commit: Critical feature

# Recover all lost commits
git reset --hard jkl3456

# After accidental branch delete
$ git reflog | grep feature
mno7890 HEAD@{5}: checkout: moving from feature to main
git branch feature mno7890

# After bad rebase
git reflog
# Find pre-rebase state
git reset --hard HEAD@{4}
```

**Reflog expiry:**
- Reachable commits: 90 days
- Unreachable commits: 30 days
- Configure: `git config gc.reflogExpire 180.days`

---

### 44. Explain interactive rebase in detail.

**Answer:** Interactive rebase lets you rewrite history by editing, reordering, squashing, or dropping commits.

```bash
git rebase -i HEAD~5
```

Editor opens:
```
pick abc1234 Add feature
pick def5678 Fix typo
pick ghi9012 Add tests
pick jkl3456 Refactor
pick mno7890 Update docs
```

**Available commands:**
| Command | Action |
|---------|--------|
| `pick` (p) | Keep commit as-is |
| `reword` (r) | Keep commit, edit message |
| `edit` (e) | Pause to amend the commit |
| `squash` (s) | Merge with previous commit (combine messages) |
| `fixup` (f) | Merge with previous commit (discard this message) |
| `drop` (d) | Delete the commit entirely |
| `exec` (x) | Run a shell command |

**Example: reorder and squash:**
```
pick abc1234 Add feature
fixup def5678 Fix typo
pick ghi9012 Add tests
drop jkl3456 Refactor (removing this)
reword mno7890 Update docs
```

---

### 45. What is `git bisect` and how do you automate it?

**Answer:** Binary search for the commit that introduced a bug.

**Manual bisect:**
```bash
git bisect start
git bisect bad HEAD              # current is broken
git bisect good v1.0.0           # this version worked
# Git checks out midpoint — test and mark:
git bisect good  # or  git bisect bad
# Repeat until found
git bisect reset
```

**Automated bisect:**
```bash
# With a test script that exits 0 (good) or 1 (bad)
git bisect start HEAD v1.0.0
git bisect run npm test

# With a custom script
git bisect run ./test-for-bug.sh

# Skip commits that can't be tested
git bisect skip
```

For N commits, bisect finds the bug in ~log₂(N) steps. 1000 commits → ~10 steps.

---

### 46. Explain Git submodules vs subtrees.

**Answer:**

| Aspect | Submodule | Subtree |
|--------|-----------|---------|
| Storage | Separate repo, linked by hash | Merged into parent repo |
| Clone | Requires `--recurse-submodules` | Automatic (it's all one repo) |
| Updates | Explicit `submodule update` | `git subtree pull` |
| Complexity | Higher | Lower |
| Offline access | Need to fetch submodule separately | Full code available |

**Submodule:**
```bash
git submodule add https://github.com/lib/tools.git lib/tools
git submodule update --init --recursive
# .gitmodules tracks the relationship
```

**Subtree:**
```bash
# Add
git subtree add --prefix=lib/tools https://github.com/lib/tools.git main --squash

# Pull updates
git subtree pull --prefix=lib/tools https://github.com/lib/tools.git main --squash

# Push changes back
git subtree push --prefix=lib/tools https://github.com/lib/tools.git main
```

**When to use:**
- Submodules: external dependencies you don't modify
- Subtrees: libraries you actively develop alongside main project

---

### 47. What are monorepo strategies with Git?

**Answer:** A monorepo stores multiple projects in a single repository.

**Challenges at scale:**
- Clone/fetch time grows
- `git status` and `git log` become slow
- CI runs all tests for every change

**Solutions:**

```bash
# Sparse checkout (only clone specific directories)
git clone --filter=blob:none --sparse https://github.com/org/monorepo.git
cd monorepo
git sparse-checkout set packages/my-app packages/shared-lib

# Partial clone
git clone --filter=blob:none https://github.com/org/monorepo.git

# Shallow clone for CI
git clone --depth 1 --single-branch https://github.com/org/monorepo.git
```

**Tools for monorepos:**
- **Nx** / **Turborepo** — JS/TS monorepo build tools
- **Bazel** — language-agnostic build system
- **git sparse-checkout** — only checkout needed paths
- **CODEOWNERS** — define per-directory ownership
- **Path-based CI** — only run tests for changed paths

---

### 48. Explain Git LFS (Large File Storage).

**Answer:** Git LFS replaces large files with pointer files in Git, storing actual content on a separate server.

```bash
# Install and set up
git lfs install

# Track file types
git lfs track "*.psd"
git lfs track "*.zip"
git lfs track "assets/**"

# .gitattributes is created/updated:
# *.psd filter=lfs diff=lfs merge=lfs -text

# Commit as normal
git add .gitattributes
git add design.psd
git commit -m "Add design file with LFS"
git push
```

**How it works:**
1. On `git add`, large file is stored in `.git/lfs/objects/`
2. A pointer file (tiny text) is committed to Git
3. On `git push`, LFS uploads the actual file to LFS server
4. On `git clone`/`pull`, LFS downloads files on demand

```bash
# View tracked patterns
git lfs track

# View LFS files
git lfs ls-files

# Migrate existing files to LFS
git lfs migrate import --include="*.psd" --everything
```

---

### 49. How do you optimize Git performance at scale?

**Answer:**

```bash
# Enable filesystem monitor (faster git status)
git config core.fsmonitor true
git config core.untrackedCache true

# Commit graph (faster log, merge-base operations)
git commit-graph write --reachable

# Multi-pack index
git multi-pack-index write

# Scheduled maintenance
git maintenance start
# Registers: prefetch, loose-objects, incremental-repack, commit-graph

# Sparse index (for sparse checkouts)
git sparse-checkout init --cone
git config index.sparse true

# Partial clone for CI
git clone --filter=blob:none <url>
```

**Configuration for large repos:**
```bash
git config pack.threads 4
git config pack.windowMemory 256m
git config core.preloadIndex true
git config gc.auto 256
```

---

### 50. What is `git rerere`?

**Answer:** "Reuse Recorded Resolution" — Git remembers how you resolved a conflict and applies the same resolution automatically next time.

```bash
# Enable
git config --global rerere.enabled true

# How it works:
# 1. You resolve a merge conflict
# 2. Git records the resolution
# 3. Next time the same conflict appears, Git resolves it automatically

# View recorded resolutions
ls .git/rr-cache/

# Forget a specific resolution
git rerere forget path/to/file

# Useful for:
# - Long-lived branches that are rebased repeatedly
# - Repeated merges during release process
# - "What-if" merges: merge, resolve, reset, merge later (auto-resolved)
```



---

### 51. What is the Git pack file format?

**Answer:** Git compresses objects into pack files for efficient storage and transfer.

**Loose objects:** Individual compressed files in `.git/objects/`
**Pack files:** Multiple objects compressed together in `.git/objects/pack/`

```bash
# Trigger packing manually
git gc

# View pack contents
git verify-pack -v .git/objects/pack/pack-abc123.idx

# Repack with aggressive optimization
git repack -a -d --depth=250 --window=250
```

**How packing works:**
1. Git identifies similar objects
2. Stores the most recent version in full
3. Stores older versions as deltas (differences)
4. Creates `.pack` (objects) + `.idx` (index for fast lookup)

---

### 52. Explain the three-way merge algorithm.

**Answer:** Git uses three inputs for merge: the two branch tips + their common ancestor (merge base).

```
        Common Ancestor (Base)
       /                      \
  Branch A (ours)          Branch B (theirs)
```

**Logic for each region:**
- If only A changed from Base → take A's version
- If only B changed from Base → take B's version
- If neither changed → keep Base
- If both changed the same way → take either (same result)
- If both changed differently → **CONFLICT**

```bash
# Find merge base
git merge-base main feature
# abc1234

# View three-way diff
git diff abc1234...feature
```

---

### 53. What is `git filter-repo` and when do you use it?

**Answer:** Modern tool for rewriting Git history (replacement for `filter-branch`).

```bash
# Install
pip install git-filter-repo

# Remove a file from all history
git filter-repo --path secrets.env --invert-paths

# Remove a directory from history
git filter-repo --path node_modules/ --invert-paths

# Rename a directory throughout history
git filter-repo --path-rename old-dir/:new-dir/

# Remove files larger than 10MB
git filter-repo --strip-blobs-bigger-than 10M

# Change author email throughout history
git filter-repo --email-callback '
  return email.replace(b"old@email.com", b"new@email.com")
'
```

**Advantages over `filter-branch`:** 10-100x faster, safer (refuses to run in dirty repos), simpler API.

---

### 54. How do signed commits and tags work?

**Answer:** GPG/SSH signing proves that a commit/tag was actually made by the claimed author.

```bash
# Setup GPG signing
git config --global user.signingkey <GPG-KEY-ID>
git config --global commit.gpgsign true

# Sign a commit
git commit -S -m "Signed commit"

# Sign a tag
git tag -s v1.0.0 -m "Signed release"

# Verify
git verify-commit abc1234
git verify-tag v1.0.0

# SSH signing (Git 2.34+)
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
```

GitHub/GitLab show "Verified" badge on signed commits.

---

### 55. What is `git notes`?

**Answer:** Attach additional information to commits without changing them.

```bash
# Add a note to a commit
git notes add -m "Reviewed by Jane, approved for release" abc1234

# View notes
git log --show-notes

# Push notes to remote
git push origin refs/notes/commits

# Fetch notes
git fetch origin refs/notes/commits:refs/notes/commits

# Remove a note
git notes remove abc1234
```

**Use cases:** Code review annotations, CI build links, deployment tracking — all without modifying commit hashes.

---

### 56. Explain Git's garbage collection.

**Answer:** `git gc` cleans up unnecessary files and optimizes the local repository.

```bash
# Manual GC
git gc

# Aggressive GC (slower but more thorough)
git gc --aggressive

# See what would be pruned
git prune --dry-run

# GC runs automatically after:
# - ~6700 loose objects (gc.auto default: 6700)
# - ~50 pack files (gc.autoPackLimit default: 50)
```

**What GC does:**
1. Packs loose objects into pack files
2. Prunes unreachable objects (after expiry period)
3. Removes stale remote tracking branches
4. Compresses file revisions
5. Updates commit-graph

---

### 57. How does `git sparse-checkout` work?

**Answer:** Only materializes specific directories in the working tree (useful for monorepos).

```bash
# Initialize sparse checkout (cone mode — faster)
git sparse-checkout init --cone

# Set directories to include
git sparse-checkout set packages/my-app packages/shared-lib

# Add more directories
git sparse-checkout add packages/another-package

# List current patterns
git sparse-checkout list

# Disable (get full working tree back)
git sparse-checkout disable
```

**Cone mode vs non-cone:** Cone mode only allows directory-based patterns (faster), non-cone allows gitignore-style patterns.

---

### 58. What is `git replace`?

**Answer:** Creates replacement objects — Git uses the replacement transparently wherever the original is referenced.

```bash
# Replace a commit (e.g., graft history from two repos)
git replace <original-hash> <replacement-hash>

# List replacements
git replace -l

# Remove a replacement
git replace -d <original-hash>

# Push replacements
git push origin 'refs/replace/*'
```

**Use cases:** Grafting repository histories together, fixing metadata in published commits without rewriting history.

---

### 59. What are Git's merge strategies?

**Answer:**

```bash
# Recursive (default for 2 branches) — handles renames, criss-cross merges
git merge -s recursive feature

# Ort (default since Git 2.33, replacement for recursive) — faster
git merge -s ort feature

# Ours (keep our version for everything — used to record a merge without taking changes)
git merge -s ours old-branch

# Octopus (default for 3+ branches)
git merge feature1 feature2 feature3

# Subtree (merge another project as a subdirectory)
git merge -s subtree --allow-unrelated-histories other-project/main
```

**Strategy options (fine-tuning):**
```bash
# Prefer our changes on conflicts
git merge -X ours feature

# Prefer their changes on conflicts
git merge -X theirs feature

# Detect renames with more sensitivity
git merge -X rename-threshold=50 feature
```

---

### 60. How does Git handle symlinks and file permissions?

**Answer:**

**File permissions:** Git only tracks executable bit (755 vs 644), not full Unix permissions.

```bash
# Mark a file as executable
git update-index --chmod=+x script.sh
git commit -m "Make script executable"

# Check permissions
git ls-files -s
# 100755 abc1234 0    script.sh  (executable)
# 100644 def5678 0    readme.md  (regular file)

# Disable permission tracking (useful on Windows)
git config core.fileMode false
```

**Symlinks:** Git stores symlinks as a file containing the target path.
```bash
# Symlinks on Windows require developer mode or admin
git config core.symlinks true

# If symlinks aren't supported, Git stores as plain text file
cat link-file  # contains: ../target/path
```



---

## Scenario-Based Questions (10 Questions)

### S1. You accidentally pushed sensitive data (API keys) to a public repo. What do you do?

**Answer:**

**Immediate steps:**
1. **Revoke the exposed credentials immediately** (most critical step)
2. Remove from history using `git filter-repo`:
```bash
git filter-repo --path .env --invert-paths
# or for specific content:
git filter-repo --blob-callback '
  if b"API_KEY" in blob.data:
    blob.skip()
'
```
3. Force push the cleaned history:
```bash
git push --force --all
git push --force --tags
```
4. Contact GitHub support to clear cached views
5. Notify team members to re-clone
6. Add file to `.gitignore` and set up pre-commit hooks to prevent recurrence

**Prevention:** Use `.env.example` with placeholder values, pre-commit hooks with tools like `detect-secrets` or `gitleaks`.

---

### S2. Two developers are working on the same file and both push. Developer B gets rejected. How should they resolve it?

**Answer:**

Developer B sees:
```
! [rejected] main -> main (non-fast-forward)
```

**Solution:**
```bash
# Option 1: Rebase (preferred for clean history)
git fetch origin
git rebase origin/main
# Resolve any conflicts
git add .
git rebase --continue
git push

# Option 2: Merge
git pull origin main
# Resolve conflicts
git add .
git commit -m "Merge remote changes"
git push
```

**Best practice:** Use feature branches + PRs to avoid this entirely.

---

### S3. Your production server is broken after a deployment from the latest commit. How do you rollback?

**Answer:**

```bash
# Option 1: Revert the bad commit (safest — preserves history)
git revert HEAD
git push origin main
# Trigger redeployment

# Option 2: If multiple commits are bad
git revert --no-commit HEAD~3..HEAD
git commit -m "Revert: rollback last 3 commits due to production issue"
git push origin main

# Option 3: Deploy a specific known-good tag
git checkout v1.2.3
# Deploy this version

# Option 4: Emergency — point main to last known good (team coordination required)
git reset --hard <last-good-commit>
git push --force-with-lease origin main
```

**Post-mortem:** Identify root cause, add tests, improve CI pipeline.

---

### S4. You need to move a subdirectory from one repository to another while preserving its Git history.

**Answer:**

```bash
# In the source repo: extract subdirectory history
cd source-repo
git filter-repo --subdirectory-filter path/to/subdir/
# Now the repo root IS the subdirectory with only its history

# In the target repo: add as remote and merge
cd target-repo
git remote add source ../source-repo
git fetch source
git merge source/main --allow-unrelated-histories
# or place it in a subdirectory:
git read-tree --prefix=new-subdir/ -u source/main
git commit -m "Import subdir from source repo with history"
git remote remove source
```

---

### S5. A team member force-pushed to a shared branch and you've lost your local commits. How do you recover?

**Answer:**

```bash
# Step 1: Find your lost commits in reflog
git reflog
# abc1234 HEAD@{1}: commit: My important work
# def5678 HEAD@{2}: commit: Another commit

# Step 2: Create a recovery branch from your last commit
git branch my-recovery abc1234

# Step 3: Rebase your work onto the new remote state
git fetch origin
git checkout my-recovery
git rebase origin/main

# Step 4: Push your work
git push origin my-recovery
# Create a PR to merge back

# Prevention: Protect shared branches from force push in repo settings
```

---

### S6. You need to maintain two versions of a project (v1 and v2) simultaneously. How do you structure this?

**Answer:**

```bash
# Option 1: Long-lived release branches
git branch release/v1 v1.0.0    # branch from last v1 release tag
git branch release/v2 v2.0.0

# Hotfix for v1:
git checkout release/v1
git checkout -b hotfix/v1-security-fix
# ... fix ...
git checkout release/v1
git merge hotfix/v1-security-fix
git tag v1.0.1

# Cherry-pick fix to v2 if applicable:
git checkout release/v2
git cherry-pick <fix-commit-hash>
git tag v2.0.1

# Option 2: Use tags for releases, branches for active development
# Tag every release, create branch only when maintenance is needed
git tag v1.0.0
git tag v2.0.0
# When v1 needs a fix:
git checkout -b release/v1 v1.0.0
```

---

### S7. Your CI pipeline takes 30 minutes and you need to find which of 100 commits broke the build. What's the fastest approach?

**Answer:**

```bash
# Use git bisect with automated test
git bisect start
git bisect bad HEAD           # current is broken
git bisect good HEAD~100      # 100 commits ago was good

# Automated: run the specific failing test
git bisect run ./run-failing-test.sh

# This finds the culprit in ~7 steps (log₂(100) ≈ 7)
# Each step runs only the relevant test, not full CI

# If some commits can't be tested (won't compile):
# In your test script, exit 125 to skip:
#!/bin/bash
make || exit 125    # can't build = skip
./run-test || exit 1  # test fails = bad
exit 0               # test passes = good
```

Total time: ~7 × test-run-time instead of 100 × test-run-time.

---

### S8. You started working on a feature, then realize you're on the wrong branch. You have unstaged changes. What do you do?

**Answer:**

```bash
# Option 1: Stash and move (simplest)
git stash
git checkout correct-branch
git stash pop

# Option 2: If changes don't conflict with target branch
git checkout correct-branch
# Git carries uncommitted changes to the new branch (if no conflicts)

# Option 3: If you already committed on wrong branch
git log --oneline -1   # note commit hash: abc1234
git reset --soft HEAD~1  # undo commit, keep changes staged
git stash
git checkout correct-branch
git stash pop
git commit -m "Feature work"

# Option 4: cherry-pick if already committed
git checkout correct-branch
git cherry-pick abc1234
git checkout wrong-branch
git reset --hard HEAD~1
```

---

### S9. Your team wants to adopt a new branching strategy. How would you migrate from Git Flow to trunk-based development?

**Answer:**

**Migration steps:**
```bash
# 1. Merge all active feature branches to develop
git checkout develop
git merge --no-ff feature/pending-1
git merge --no-ff feature/pending-2

# 2. Merge develop into main (final sync)
git checkout main
git merge develop

# 3. Delete old branches
git branch -d develop
git push origin --delete develop
git branch -d release/1.0
git branch -d hotfix/fix-1

# 4. Protect main branch (in GitHub/GitLab settings)
# - Require PR reviews
# - Require CI to pass
# - No direct pushes
```

**New workflow:**
```bash
# Short-lived feature branches (max 1-2 days)
git checkout -b feature/quick-change main
# ... make changes ...
git push -u origin feature/quick-change
# Create PR → review → squash merge → delete branch

# Use feature flags for incomplete features
# Deploy from main continuously
```

**Team communication:**
- Document new process in CONTRIBUTING.md
- Set up branch protection rules
- Configure CI for trunk-based flow
- Train team on feature flags

---

### S10. A repository has grown to 5GB and clones take 20+ minutes. How do you diagnose and fix this?

**Answer:**

**Diagnosis:**
```bash
# Check repo size breakdown
git count-objects -vH
# size-pack: 4.8 GiB

# Find largest files in history
git rev-list --objects --all |
  git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' |
  sed -n 's/^blob //p' |
  sort -rnk2 |
  head -20

# Or use git-sizer tool
git-sizer --verbose
```

**Solutions:**
```bash
# 1. Remove large files from history
git filter-repo --strip-blobs-bigger-than 50M

# 2. Move large files to LFS
git lfs migrate import --include="*.zip,*.tar.gz,*.bin" --everything

# 3. For users: use partial/shallow clone
git clone --filter=blob:none <url>    # download blobs on demand
git clone --depth 1 <url>             # shallow clone

# 4. Enable server-side optimizations
# - Enable reachability bitmaps
# - Enable commit-graph
git repack -a -d --write-bitmap-index
git commit-graph write --reachable

# 5. Clean up
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push --force --all
git push --force --tags
```

**Prevention:**
- Use Git LFS from project start for binaries
- Add comprehensive `.gitignore`
- Regularly audit with `git-sizer`
- Set up pre-receive hooks to reject large pushes

---

## Tips for Git Interviews

1. **Practice hands-on** — create test repos and try every command
2. **Understand internals** — knowing blobs/trees/commits shows deep understanding
3. **Know the difference between safe and dangerous operations**
4. **Be ready for scenario questions** — interviewers love "what would you do if..."
5. **Mention tools** — knowing GitHub Actions, Husky, git-filter-repo shows practical experience
6. **Draw diagrams** — for branching strategies, explain with visual commit graphs
7. **Discuss tradeoffs** — merge vs rebase, submodule vs subtree — explain WHY you'd choose one

---

*Navigate: [📖 README](README.md) | [🌳 Branching](git-branching.md) | [⚡ Commands](git-commands-cheatsheet.md) | [🔧 Internals](git-internals.md) | [🤝 Workflows](git-workflows.md) | [🚀 Advanced](git-advanced.md) | [🌐 GitHub/GitLab](github-gitlab-guide.md) | [🔥 Troubleshooting](git-troubleshooting.md) | [💼 Interview Prep](git-interview-questions.md) | [🔒 Security](git-security.md)*
