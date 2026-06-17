# 🔥 Git Troubleshooting Guide

[📖 README](README.md) | [🌳 Branching](git-branching.md) | [⚡ Commands](git-commands-cheatsheet.md) | [🔧 Internals](git-internals.md) | [🤝 Workflows](git-workflows.md) | [🚀 Advanced](git-advanced.md) | [🌐 GitHub/GitLab](github-gitlab-guide.md) | [🔥 Troubleshooting](git-troubleshooting.md) | [💼 Interview Prep](git-interview-questions.md) | [🔒 Security](git-security.md)

---

> Common Git problems organized as **Problem → Cause → Solution** with exact commands, expected output, and prevention tips.

<p align="center">
  <img src="images/conflict-resolution.svg" alt="Conflict Resolution" width="700"/>
</p>

---

## 1. Merge Conflicts

### Problem
When merging or rebasing, Git reports conflicts that prevent automatic completion.

```
Auto-merging src/app.js
CONFLICT (content): Merge conflict in src/app.js
Automatic merge failed; fix conflicts and then commit the result.
```

### Cause
Two branches modified the same lines in the same file, and Git cannot determine which version to keep.

### Solution

**Step 1: Identify conflicted files**
```bash
git status
```
Output:
```
Unmerged paths:
  (use "git add <file>..." to mark resolution)
        both modified:   src/app.js
```

**Step 2: Open the file and resolve**
The conflict markers look like:
```
<<<<<<< HEAD
const port = 3000;
=======
const port = 8080;
>>>>>>> feature-branch
```

Edit to keep the correct version:
```javascript
const port = 8080;
```

**Step 3: Mark as resolved and commit**
```bash
git add src/app.js
git commit -m "Resolve merge conflict in app.js"
```

**Using a merge tool:**
```bash
git mergetool
```

**Abort the merge entirely:**
```bash
git merge --abort
```

### Prevention
- Pull frequently to stay up-to-date
- Communicate with team about file ownership
- Keep commits small and focused

---

## 2. Detached HEAD State

### Problem
```
You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by switching back to a branch.
```

### Cause
You checked out a specific commit, tag, or remote branch directly instead of a local branch.

```bash
git checkout abc1234      # checking out a commit
git checkout v1.0.0       # checking out a tag
```

### Solution

**If you haven't made any commits in detached state:**
```bash
git checkout main
# or
git switch main
```

**If you made commits you want to keep:**
```bash
# Create a new branch from current position
git branch my-new-branch
git checkout my-new-branch
# Or in one command:
git checkout -b my-new-branch
```

**If you already switched away and lost the commit:**
```bash
git reflog
# Find the commit hash
git branch recover-branch abc1234
```

### Prevention
- Use `git switch` instead of `git checkout` (clearer semantics)
- Always check `git status` before making changes
- Use `git checkout -b <branch>` when exploring from a commit

---

## 3. Accidentally Committed to Wrong Branch

### Problem
You made commits on `main` that should have been on a feature branch.

### Cause
Forgot to create/switch to a feature branch before starting work.

### Solution

**Move last commit to a new branch:**
```bash
# Create new branch with your commits (stays at current position)
git branch feature-branch

# Reset main back (moves main pointer back 1 commit)
git reset --hard HEAD~1

# Switch to the feature branch
git checkout feature-branch
```

**Move last commit to an existing branch:**
```bash
# Note the commit hash
git log --oneline -1
# Output: abc1234 Your commit message

# Reset current branch
git reset --hard HEAD~1

# Switch and cherry-pick
git checkout feature-branch
git cherry-pick abc1234
```

### Expected Output
```
$ git reset --hard HEAD~1
HEAD is now at def5678 Previous commit message

$ git cherry-pick abc1234
[feature-branch xyz9999] Your commit message
 1 file changed, 10 insertions(+)
```

### Prevention
- Always run `git branch` or check your prompt before committing
- Use shell prompt integration to show current branch
- Set up branch protection on `main`

---

## 4. Undo Last Commit (Soft, Mixed, Hard Reset)

### Problem
You need to undo one or more recent commits.

### Cause
Wrong commit message, included wrong files, or committed prematurely.

### Solution

**`--soft`: Undo commit, keep changes staged**
```bash
git reset --soft HEAD~1
```
Result: Changes are in staging area, ready to re-commit.

**`--mixed` (default): Undo commit, keep changes unstaged**
```bash
git reset HEAD~1
# or
git reset --mixed HEAD~1
```
Result: Changes are in working directory but not staged.

**`--hard`: Undo commit, discard all changes**
```bash
git reset --hard HEAD~1
```
Result: Changes are completely gone (recoverable via reflog).

### Comparison Table

| Flag | Commit | Staging Area | Working Directory |
|------|--------|-------------|-------------------|
| `--soft` | ❌ Undone | ✅ Preserved | ✅ Preserved |
| `--mixed` | ❌ Undone | ❌ Cleared | ✅ Preserved |
| `--hard` | ❌ Undone | ❌ Cleared | ❌ Cleared |

### Expected Output
```
$ git reset --soft HEAD~1
$ git status
Changes to be committed:
  modified:   src/app.js

$ git reset --hard HEAD~1
HEAD is now at abc1234 Previous commit message
```

### Prevention
- Use `git stash` before risky operations
- Commit frequently with meaningful messages
- Use `--amend` for quick fixes to the last commit

---

## 5. Recover Deleted Branch

### Problem
A branch was deleted and you need it back.

```bash
git branch -D feature-branch
# Deleted branch feature-branch (was abc1234).
```

### Cause
Branch accidentally deleted with `-D` (force delete) or `-d`.

### Solution

**If you just deleted it (hash shown in output):**
```bash
git branch feature-branch abc1234
```

**If you don't remember the hash:**
```bash
git reflog
# Look for the last commit on that branch
# Example output:
# abc1234 HEAD@{2}: commit: Add feature X
# def5678 HEAD@{3}: checkout: moving from feature-branch to main

git branch feature-branch abc1234
```

**Recover a deleted remote branch:**
```bash
# Check if someone else has it
git fetch origin
git checkout -b feature-branch origin/feature-branch
```

### Expected Output
```
$ git reflog | grep feature
abc1234 HEAD@{5}: commit: Last commit on feature-branch

$ git branch feature-branch abc1234
$ git branch
  feature-branch
* main
```

### Prevention
- Use `git branch -d` (safe delete) instead of `-D`
- Push branches to remote as backup
- Think twice before force-deleting



---

## 6. Revert a Pushed Commit

### Problem
A commit has been pushed to a shared branch and needs to be undone without rewriting history.

### Cause
Bug introduced, wrong code pushed, or need to roll back a feature.

### Solution

**Revert a single commit:**
```bash
git revert abc1234
```

**Revert without auto-commit (to edit or combine):**
```bash
git revert --no-commit abc1234
git commit -m "Revert: remove broken feature"
```

**Revert a merge commit:**
```bash
# -m 1 means keep the first parent (usually main)
git revert -m 1 <merge-commit-hash>
```

**Push the revert:**
```bash
git push origin main
```

### Expected Output
```
$ git revert abc1234
[main def5678] Revert "Add broken feature"
 1 file changed, 0 insertions(+), 5 deletions(-)
```

### Prevention
- Use feature branches and PR reviews
- Run tests before merging to main
- Use CI/CD pipelines with automated checks

---

## 7. Remove File from Git Tracking but Keep Locally

### Problem
A file (e.g., config, IDE settings) is tracked by Git but should be ignored.

### Cause
File was committed before being added to `.gitignore`.

### Solution

**Remove from tracking, keep on disk:**
```bash
git rm --cached filename.txt
echo "filename.txt" >> .gitignore
git commit -m "Stop tracking filename.txt"
```

**For a directory:**
```bash
git rm -r --cached node_modules/
echo "node_modules/" >> .gitignore
git commit -m "Stop tracking node_modules"
```

### Expected Output
```
$ git rm --cached config.local.json
rm 'config.local.json'

$ git status
Changes to be committed:
  deleted:    config.local.json

Untracked files:
  config.local.json
```

Note: The file still exists on disk but Git no longer tracks it.

### Prevention
- Set up `.gitignore` before first commit
- Use templates: `github.com/github/gitignore`
- Review `git status` before committing

---

## 8. Fix Commit Message After Push

### Problem
A typo or incorrect commit message was pushed to remote.

### Cause
Commit message written hastily or with errors.

### Solution

**If it's the very last commit and nobody has pulled:**
```bash
git commit --amend -m "Corrected commit message"
git push --force-with-lease
```

**If it's an older commit:**
```bash
# Interactive rebase to the parent of the target commit
git rebase -i HEAD~3

# In the editor, change 'pick' to 'reword' for the target commit
# Save and close — a new editor opens for the message
# Then force push
git push --force-with-lease
```

### Expected Output
```
$ git commit --amend -m "Fix: correct validation logic"
[main abc1234] Fix: correct validation logic
 Date: Wed Jun 17 10:30:00 2026 +0530
 1 file changed, 3 insertions(+), 1 deletion(-)

$ git push --force-with-lease
+ def5678...abc1234 main -> main (forced update)
```

### Prevention
- Review commit messages before pushing
- Use commit message templates
- Use `git commit -v` to see diff while writing message

---

## 9. Squash Last N Commits

### Problem
Multiple small commits need to be combined into one clean commit before merging.

### Cause
Development involved many incremental commits that clutter history.

### Solution

**Interactive rebase (squash last 3 commits):**
```bash
git rebase -i HEAD~3
```

Editor opens:
```
pick abc1234 Add user model
pick def5678 Fix typo in user model
pick ghi9012 Add validation to user model
```

Change to:
```
pick abc1234 Add user model
squash def5678 Fix typo in user model
squash ghi9012 Add validation to user model
```

Save and close. A new editor opens for the combined commit message.

**Quick squash using reset (alternative):**
```bash
git reset --soft HEAD~3
git commit -m "Add user model with validation"
```

### Expected Output
```
$ git rebase -i HEAD~3
[detached HEAD xyz789] Add user model with validation
 Date: Wed Jun 17 09:00:00 2026 +0530
 3 files changed, 50 insertions(+)
Successfully rebased and updated refs/heads/feature-branch.

$ git log --oneline -3
xyz789 Add user model with validation
aaa111 Previous commit
bbb222 Even older commit
```

### Prevention
- Plan commits logically from the start
- Use `git commit --amend` for small fixes to last commit
- Squash when merging PRs (GitHub "Squash and merge")

---

## 10. Force Push Safely (--force-with-lease)

### Problem
You need to force push after rewriting history (rebase, amend) but don't want to overwrite teammates' work.

### Cause
Regular `--force` blindly overwrites the remote ref, potentially losing others' commits.

### Solution

**Safe force push:**
```bash
git push --force-with-lease
```

This fails if the remote has commits you haven't fetched:
```
! [rejected] main -> main (stale info)
error: failed to push some refs
```

**If you need to update your lease:**
```bash
git fetch origin
# Review what changed
git log origin/main --oneline -5
# If safe, force push
git push --force-with-lease
```

**Never use plain `--force` on shared branches:**
```bash
# DANGEROUS - avoid this
git push --force  # ❌

# SAFE alternative
git push --force-with-lease  # ✅
```

### Expected Output
```
$ git push --force-with-lease
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
+ abc1234...def5678 feature -> feature (forced update)
```

### Prevention
- Always use `--force-with-lease` instead of `--force`
- Set alias: `git config --global alias.pushf "push --force-with-lease"`
- Avoid rewriting history on shared branches
- Communicate with team before force pushing



---

## 11. Fix .gitignore Not Working

### Problem
Files listed in `.gitignore` are still being tracked by Git.

### Cause
The files were committed/tracked before the `.gitignore` rule was added. `.gitignore` only prevents **untracked** files from being added.

### Solution

**Remove all cached tracking and re-add:**
```bash
# Remove all files from index (not disk)
git rm -r --cached .

# Re-add everything (now .gitignore rules apply)
git add .

# Commit the changes
git commit -m "Fix: apply .gitignore rules"
```

**Remove specific files:**
```bash
git rm --cached path/to/file
git commit -m "Stop tracking ignored file"
```

### Expected Output
```
$ git rm -r --cached .
rm 'src/app.js'
rm 'config.local.json'
rm '.env'
...

$ git add .
$ git status
Changes to be committed:
  deleted:    .env
  deleted:    config.local.json
```

### Prevention
- Create `.gitignore` before the first commit
- Use `git check-ignore -v filename` to debug ignore rules
- Use global gitignore for editor/OS files:
  ```bash
  git config --global core.excludesFile ~/.gitignore_global
  ```

---

## 12. Large File Accidentally Committed

### Problem
A large binary file was committed, making the repository bloated.

```
remote: error: File big-data.zip is 150 MB; this exceeds the 100 MB limit.
```

### Cause
Large files (builds, data, binaries) committed without Git LFS.

### Solution

**If not yet pushed (remove from last commit):**
```bash
git rm --cached big-data.zip
echo "big-data.zip" >> .gitignore
git commit --amend --no-edit
```

**If committed several commits ago:**
```bash
# Using git filter-branch (older method)
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch big-data.zip' \
  --prune-empty --tag-name-filter cat -- --all

# Using BFG Repo Cleaner (faster, recommended)
# Download bfg.jar first
java -jar bfg.jar --delete-files big-data.zip
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push --force-with-lease
```

**Using git-filter-repo (modern approach):**
```bash
pip install git-filter-repo
git filter-repo --path big-data.zip --invert-paths
```

### Expected Output
```
$ git filter-repo --path big-data.zip --invert-paths
Parsed 150 commits
New history written in 0.5 seconds
Completely finished after 1.0 seconds.
```

### Prevention
- Set up `.gitignore` for binary/large files
- Use Git LFS for large files: `git lfs track "*.zip"`
- Add pre-commit hooks to check file size
- Use `git lfs install` at project start

---

## 13. Authentication Failures (SSH vs HTTPS)

### Problem
Push/pull/clone fails with authentication errors.

```
fatal: Authentication failed for 'https://github.com/user/repo.git'
```
or
```
git@github.com: Permission denied (publickey).
```

### Cause
- HTTPS: Invalid token/password, expired credentials
- SSH: Missing/incorrect SSH key, agent not running

### Solution

**For HTTPS issues:**
```bash
# Check current remote URL
git remote -v

# Update credentials (Windows)
# Open Credential Manager → Windows Credentials → Remove old git entries

# Use personal access token instead of password
git remote set-url origin https://<token>@github.com/user/repo.git

# Or use credential helper
git config --global credential.helper manager
```

**For SSH issues:**
```bash
# Test SSH connection
ssh -T git@github.com

# Check if key exists
ls ~/.ssh/id_ed25519.pub

# Generate new key if needed
ssh-keygen -t ed25519 -C "your_email@example.com"

# Add to SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key and add to GitHub/GitLab
cat ~/.ssh/id_ed25519.pub
```

**Switch between HTTPS and SSH:**
```bash
# HTTPS to SSH
git remote set-url origin git@github.com:user/repo.git

# SSH to HTTPS
git remote set-url origin https://github.com/user/repo.git
```

### Expected Output
```
$ ssh -T git@github.com
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

### Prevention
- Use SSH keys with passphrase for security
- Store credentials securely with credential helpers
- Use token-based auth for HTTPS (not passwords)
- Regularly rotate access tokens

---

## 14. Permission Denied (publickey)

### Problem
```
Permission denied (publickey).
fatal: Could not read from remote repository.
```

### Cause
- SSH key not added to SSH agent
- Wrong key associated with the account
- SSH config pointing to wrong key
- Key not added to Git hosting platform

### Solution

**Step 1: Verify SSH agent has key loaded**
```bash
ssh-add -l
```
If empty:
```bash
ssh-add ~/.ssh/id_ed25519
```

**Step 2: Verify key matches what's on GitHub/GitLab**
```bash
# Show your public key fingerprint
ssh-keygen -lf ~/.ssh/id_ed25519.pub

# Compare with keys on GitHub
# Settings → SSH and GPG keys
```

**Step 3: Test with verbose output**
```bash
ssh -vT git@github.com
```
Look for which key is being offered.

**Step 4: Configure SSH for multiple accounts**
Create/edit `~/.ssh/config`:
```
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519

Host github-work
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_work
```

Then use:
```bash
git remote set-url origin git@github-work:company/repo.git
```

### Expected Output
```
$ ssh-add -l
256 SHA256:abcdef123456 your_email@example.com (ED25519)

$ ssh -T git@github.com
Hi username! You've successfully authenticated...
```

### Prevention
- Add SSH key to system keychain for persistence
- Use `~/.ssh/config` for multiple accounts
- Ensure correct file permissions: `chmod 600 ~/.ssh/id_ed25519`

---

## 15. Repository Too Large / Slow Clone

### Problem
Clone takes too long or fails due to repository size.

```
Receiving objects: 15% (30000/200000), 1.5 GiB | 500 KiB/s
fatal: the remote end hung up unexpectedly
```

### Cause
- Large binary files in history
- Many years of accumulated commits
- Large number of branches/tags

### Solution

**Shallow clone (only recent history):**
```bash
# Last commit only
git clone --depth 1 https://github.com/user/repo.git

# Last 10 commits
git clone --depth 10 https://github.com/user/repo.git
```

**Single branch clone:**
```bash
git clone --single-branch --branch main https://github.com/user/repo.git
```

**Partial clone (blobless — fetch blobs on demand):**
```bash
git clone --filter=blob:none https://github.com/user/repo.git
```

**Partial clone (treeless — even less initial data):**
```bash
git clone --filter=tree:0 https://github.com/user/repo.git
```

**Increase buffer for large repos:**
```bash
git config --global http.postBuffer 524288000
```

**Convert shallow to full clone later:**
```bash
git fetch --unshallow
```

### Expected Output
```
$ git clone --depth 1 https://github.com/user/large-repo.git
Cloning into 'large-repo'...
Receiving objects: 100% (5000/5000), 50 MiB | 10 MiB/s, done.
```

### Prevention
- Use Git LFS for large binary files
- Regularly clean up old branches
- Keep repos focused (avoid monorepos without proper tooling)
- Use `.gitignore` for build artifacts



---

## 16. Submodule Issues

### Problem
Various submodule errors:
```
fatal: no submodule mapping found in .gitmodules for path 'lib/external'
```
or submodule directories are empty after clone.

### Cause
- Submodules not initialized after clone
- `.gitmodules` out of sync with actual submodule state
- Submodule URL changed

### Solution

**Empty submodule after clone:**
```bash
git submodule init
git submodule update
# Or combined:
git submodule update --init --recursive
```

**Clone with submodules from the start:**
```bash
git clone --recurse-submodules https://github.com/user/repo.git
```

**Submodule URL changed:**
```bash
# Edit .gitmodules with new URL, then:
git submodule sync
git submodule update --init --recursive
```

**Remove a submodule completely:**
```bash
# Remove from .gitmodules
git submodule deinit -f path/to/submodule
rm -rf .git/modules/path/to/submodule
git rm -f path/to/submodule
git commit -m "Remove submodule"
```

**Submodule stuck at wrong commit:**
```bash
cd path/to/submodule
git checkout main
git pull
cd ..
git add path/to/submodule
git commit -m "Update submodule to latest"
```

### Expected Output
```
$ git submodule update --init --recursive
Submodule 'lib/external' (git@github.com:user/lib.git) registered
Cloning into 'lib/external'...
Submodule path 'lib/external': checked out 'abc1234'
```

### Prevention
- Always clone with `--recurse-submodules`
- Consider `git subtree` as a simpler alternative
- Document submodule workflow in README
- Use `git config --global submodule.recurse true`

---

## 17. Line Ending Issues (CRLF vs LF)

### Problem
```
warning: LF will be replaced by CRLF in src/app.js
```
Or diffs show entire files changed when only line endings differ.

### Cause
- Windows uses CRLF (`\r\n`), Unix/Mac uses LF (`\n`)
- Team members on different OSes commit different line endings
- `core.autocrlf` not configured consistently

### Solution

**Configure for your OS:**
```bash
# Windows: convert to CRLF on checkout, LF on commit
git config --global core.autocrlf true

# Mac/Linux: convert CRLF to LF on commit, no change on checkout
git config --global core.autocrlf input
```

**Project-wide solution with `.gitattributes` (recommended):**
Create `.gitattributes` in repo root:
```
# Set default behavior
* text=auto

# Force LF for all text files
*.js text eol=lf
*.ts text eol=lf
*.json text eol=lf
*.md text eol=lf
*.yml text eol=lf
*.css text eol=lf
*.html text eol=lf

# Force CRLF for Windows-specific files
*.bat text eol=crlf
*.cmd text eol=crlf

# Binary files
*.png binary
*.jpg binary
*.ico binary
```

**Fix existing line endings in repo:**
```bash
# Remove all files from index
git rm -r --cached .
# Re-add (applies .gitattributes rules)
git add .
git commit -m "Normalize line endings"
```

### Expected Output
```
$ git diff --stat
 src/app.js | 0
 1 file changed, 0 insertions(+), 0 deletions(-)
(After normalization, no more phantom changes)
```

### Prevention
- Add `.gitattributes` to every repository
- Configure `core.autocrlf` on all developer machines
- Use EditorConfig for consistent editor settings

---

## 18. Corrupted Repository Recovery

### Problem
```
error: object file .git/objects/ab/cdef1234 is empty
fatal: loose object abcdef1234 is corrupt
```

### Cause
- Power failure during git operation
- Disk corruption
- File system errors

### Solution

**Step 1: Backup the repository first**
```bash
cp -r .git .git-backup
```

**Step 2: Check repository integrity**
```bash
git fsck --full
```

**Step 3: Try to recover from remote**
```bash
# Remove corrupted objects
find .git/objects/ -size 0 -delete

# Fetch fresh objects from remote
git fetch origin

# If HEAD is corrupted, reset it
git symbolic-ref HEAD refs/heads/main
```

**Step 4: If fetch doesn't help, re-clone and recover local work**
```bash
# In a new directory
git clone https://github.com/user/repo.git repo-fresh

# Copy any uncommitted work from old repo
cp -r old-repo/src/* repo-fresh/src/
```

**Step 5: Nuclear option — rebuild from remote**
```bash
mv .git .git-corrupt
git init
git remote add origin https://github.com/user/repo.git
git fetch origin
git reset --hard origin/main
```

### Expected Output
```
$ git fsck --full
Checking object directories: 100% done.
error: object file .git/objects/ab/cdef is empty
missing blob abcdef1234567890

$ find .git/objects/ -size 0 -delete
$ git fetch origin
From github.com:user/repo
   abc1234..def5678  main -> origin/main

$ git fsck --full
Checking object directories: 100% done.
(no errors)
```

### Prevention
- Push frequently to keep remote backup current
- Use reliable storage (SSD, avoid network drives for `.git`)
- Don't interrupt Git operations (especially during GC)
- Use `git maintenance start` for automatic maintenance

---

## 19. Diverged Branches

### Problem
```
Your branch and 'origin/main' have diverged,
and have 3 and 2 different commits each, respectively.
```

### Cause
- You committed locally while someone else pushed to the same branch
- A force push happened on the remote
- Rebasing a branch that was already pushed

### Solution

**Option 1: Merge (preserves all history):**
```bash
git pull origin main
# Resolves divergence with a merge commit
```

**Option 2: Rebase (linear history):**
```bash
git pull --rebase origin main
# Replays your commits on top of remote
```

**Option 3: If caused by force push on remote, reset to remote:**
```bash
git fetch origin
git reset --hard origin/main
# WARNING: loses local commits
```

**Option 4: Keep your version (if you're sure):**
```bash
git push --force-with-lease
```

### Expected Output
```
$ git pull --rebase origin main
First, rewinding head to replay your work on top of it...
Applying: Your local commit 1
Applying: Your local commit 2
Applying: Your local commit 3
```

### Prevention
- Pull before starting new work: `git pull --rebase`
- Set rebase as default pull strategy: `git config --global pull.rebase true`
- Avoid force-pushing shared branches
- Communicate with team about history rewrites

---

## 20. Accidentally Deleted Uncommitted Changes

### Problem
Local changes lost — file edits, `git checkout -- .`, or `git clean -fd` ran accidentally.

### Cause
- Ran `git checkout -- .` or `git restore .`
- Ran `git reset --hard`
- Ran `git clean -fd`
- Accidentally overwrote files

### Solution

**If changes were staged (added to index):**
```bash
# Find dangling blobs
git fsck --lost-found

# Look in .git/lost-found/other/
ls .git/lost-found/other/

# Examine recovered files
cat .git/lost-found/other/<hash>
```

**If changes were stashed:**
```bash
git stash list
git stash pop
```

**If using an IDE (IntelliJ, VS Code):**
- VS Code: File → Open Recent (local history)
- IntelliJ: Right-click → Local History → Show History
- Most IDEs keep local file history independently of Git

**If file was recently edited (OS-level recovery):**
```bash
# Check system backups, file history (Windows)
# Previous Versions → right-click file → Properties → Previous Versions
```

**If `git reset --hard` was used and changes WERE committed at some point:**
```bash
git reflog
# Find the commit before the reset
git reset --hard HEAD@{1}
```

### Expected Output
```
$ git fsck --lost-found
Checking object directories: 100% done.
dangling blob abc1234
dangling blob def5678

$ cat .git/lost-found/other/abc1234
// Your recovered file content here
```

### Prevention
- **Always `git stash` before destructive operations**
- Use `git clean -n` (dry run) before `git clean -f`
- Commit frequently, even WIP commits
- Use `git checkout -p` instead of `git checkout -- .` (interactive)
- Enable IDE local history features
- Consider `git worktree` for parallel workspaces

---

## Quick Reference: Emergency Commands

| Situation | Command |
|-----------|---------|
| Undo last commit (keep changes) | `git reset --soft HEAD~1` |
| Undo last commit (discard) | `git reset --hard HEAD~1` |
| Abort a merge | `git merge --abort` |
| Abort a rebase | `git rebase --abort` |
| Find lost commits | `git reflog` |
| Check repo health | `git fsck --full` |
| Safe force push | `git push --force-with-lease` |
| Undo a push | `git revert <hash>` |
| Save work temporarily | `git stash` |
| Recover stash | `git stash pop` |

---

*Navigate: [📖 README](README.md) | [🌳 Branching](git-branching.md) | [⚡ Commands](git-commands-cheatsheet.md) | [🔧 Internals](git-internals.md) | [🤝 Workflows](git-workflows.md) | [🚀 Advanced](git-advanced.md) | [🌐 GitHub/GitLab](github-gitlab-guide.md) | [🔥 Troubleshooting](git-troubleshooting.md) | [💼 Interview Prep](git-interview-questions.md)*
