[📖 README](README.md) | [🌳 Branching](git-branching.md) | [⚡ Commands](git-commands-cheatsheet.md) | [🔧 Internals](git-internals.md) | [🤝 Workflows](git-workflows.md) | [🚀 Advanced](git-advanced.md) | [🌐 GitHub/GitLab](github-gitlab-guide.md) | [🔥 Troubleshooting](git-troubleshooting.md) | [💼 Interview Prep](git-interview-questions.md)

---

# 🚀 Git Advanced Techniques

Master-level Git operations for power users and team leads.

---

## Table of Contents

1. [Interactive Rebase](#interactive-rebase)
2. [Reflog](#reflog)
3. [Git Bisect](#git-bisect)
4. [Git Worktrees](#git-worktrees)
5. [Git Hooks](#git-hooks)
6. [Git Submodules](#git-submodules)
7. [Git Subtree](#git-subtree)
8. [Rewriting History](#rewriting-history)
9. [Signed Commits (GPG)](#signed-commits-gpg)
10. [Git LFS](#git-lfs)
11. [Sparse Checkout](#sparse-checkout)
12. [Shallow Clones](#shallow-clones)
13. [Git Aliases](#git-aliases)
14. [.gitattributes](#gitattributes)
15. [Monorepo Strategies](#monorepo-strategies)
16. [Performance Optimization](#performance-optimization)

---

## Interactive Rebase

Interactive rebase lets you rewrite commit history — squash, reorder, edit, or drop commits.

### Starting an Interactive Rebase

```bash
# Rebase last 5 commits
git rebase -i HEAD~5

# Rebase onto a branch
git rebase -i main
```

### The Rebase Editor

When you run `git rebase -i HEAD~5`, Git opens an editor:

```
pick a1b2c3d Add user authentication
pick e4f5g6h Fix typo in login page
pick i7j8k9l Add password reset feature
pick m0n1o2p Fix edge case in reset flow
pick q3r4s5t Update documentation
```

### Available Commands

| Command | Short | Description |
|---------|-------|-------------|
| `pick` | `p` | Use commit as-is |
| `reword` | `r` | Use commit but edit the message |
| `edit` | `e` | Pause to amend the commit |
| `squash` | `s` | Meld into previous commit (keep message) |
| `fixup` | `f` | Meld into previous commit (discard message) |
| `drop` | `d` | Remove commit entirely |
| `exec` | `x` | Run a shell command |

### Example: Squash Commits

```
pick a1b2c3d Add user authentication
squash e4f5g6h Fix typo in login page
squash i7j8k9l Add password reset feature
fixup m0n1o2p Fix edge case in reset flow
pick q3r4s5t Update documentation
```

Result: First three commits merge into one (you edit the combined message). The fixup merges silently.

### Example: Reword a Commit

```
pick a1b2c3d Add user authentication
reword e4f5g6h Fix typo in login page
pick i7j8k9l Add password reset feature
```

Git pauses at `e4f5g6h` and opens editor to change the message.

### Example: Edit a Commit

```
edit e4f5g6h Fix typo in login page
pick i7j8k9l Add password reset feature
```

```bash
# Git pauses. Make changes, then:
git add .
git commit --amend
git rebase --continue
```

### Example: Drop a Commit

```
pick a1b2c3d Add user authentication
drop e4f5g6h Fix typo in login page
pick i7j8k9l Add password reset feature
```

### Autosquash

```bash
git commit --fixup=a1b2c3d
git rebase -i --autosquash HEAD~5
```

### Abort a Rebase

```bash
git rebase --abort
```

---

## Reflog

The reflog records every HEAD movement — your safety net for recovering lost work.

### Viewing the Reflog

```bash
git reflog
# a1b2c3d HEAD@{0}: commit: Add feature X
# e4f5g6h HEAD@{1}: checkout: moving from main to feature
# i7j8k9l HEAD@{2}: reset: moving to HEAD~3

git reflog show feature-branch
git reflog --date=relative
```

### Recovering Lost Commits After Reset

```bash
# Oops! Hard reset
git reset --hard HEAD~3

# Find the lost commits
git reflog
# m0n1o2p HEAD@{1}: commit: Important work

# Recover
git branch recovered-work m0n1o2p
# Or: git reset --hard m0n1o2p
```

### Recovering After a Bad Rebase

```bash
git reflog
# Find: HEAD@{5}: rebase (start): checkout main
git reset --hard HEAD@{6}
```

### Recovering Deleted Branches

```bash
git branch -D feature-x   # Oops!
git reflog | grep feature-x
git branch feature-x abc1234
```

---

## Git Bisect

Binary search through commits to find which one introduced a bug.

### Full Walkthrough

```bash
git bisect start
git bisect bad              # Current commit has the bug
git bisect good v1.0.0      # This version was fine

# Git checks out a middle commit. Test it:
git bisect good   # No bug here
# or
git bisect bad    # Bug exists here

# Repeat until Git finds the first bad commit
git bisect reset  # End session
```

### Automated Bisect

```bash
git bisect start HEAD v1.0.0
git bisect run ./test-bug.sh
```

Example `test-bug.sh`:

```bash
#!/bin/bash
npm test -- --grep "user login" 2>/dev/null
exit $?
```

### Bisect Skip and Log

```bash
git bisect skip           # Can't test this commit
git bisect log            # View bisect history
git bisect replay log.txt # Replay a session
```


---

## Git Worktrees

Work on multiple branches simultaneously without stashing or switching.

### Creating a Worktree

```bash
git worktree add ../hotfix-branch hotfix/critical-bug
git worktree add -b feature/new-ui ../new-ui-work
```

### Listing and Removing

```bash
git worktree list
# /home/user/project       abc1234 [main]
# /home/user/hotfix-branch def5678 [hotfix/critical-bug]

git worktree remove ../hotfix-branch
git worktree prune
```

### Use Cases

- Review a PR while continuing your own work
- Run tests on one branch while developing on another
- Compare behavior between branches side by side

---

## Git Hooks

Scripts that run automatically at specific points in the Git workflow.

### Hook Location

```bash
.git/hooks/          # Local (not shared)
.githooks/           # Shared (with config below)
git config core.hooksPath .githooks
```

### pre-commit Hook

```bash
#!/bin/bash
# .githooks/pre-commit - Lint and format check

echo "Running pre-commit checks..."

# Check for console.log statements
if git diff --cached --name-only | grep -E '\.(js|ts|tsx)$' | xargs grep -l 'console.log' 2>/dev/null; then
    echo "❌ ERROR: Remove console.log statements before committing"
    exit 1
fi

# Run linter on staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(js|ts|tsx)$')
if [ -n "$STAGED_FILES" ]; then
    npx eslint $STAGED_FILES
    if [ $? -ne 0 ]; then
        echo "❌ ESLint failed. Fix errors before committing."
        exit 1
    fi
fi

echo "✅ Pre-commit checks passed"
exit 0
```

### commit-msg Hook

```bash
#!/bin/bash
# .githooks/commit-msg - Enforce conventional commits

COMMIT_MSG=$(cat "$1")
PATTERN="^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?: .{1,72}"

if ! echo "$COMMIT_MSG" | grep -qE "$PATTERN"; then
    echo "❌ Invalid commit message format!"
    echo "Expected: <type>(<scope>): <description>"
    echo "Types: feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert"
    echo "Example: feat(auth): add OAuth2 login"
    exit 1
fi
exit 0
```

### pre-push Hook

```bash
#!/bin/bash
# .githooks/pre-push - Run tests before push

echo "Running tests before push..."
npm test
if [ $? -ne 0 ]; then
    echo "❌ Tests failed! Push aborted."
    exit 1
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
    echo "❌ Direct push to $BRANCH not allowed. Use a Pull Request."
    exit 1
fi

echo "✅ All checks passed. Pushing..."
exit 0
```

---

## Git Submodules

Include external repositories inside your repository.

### Adding a Submodule

```bash
git submodule add https://github.com/user/library.git libs/library
git commit -m "Add library submodule"
```

### Cloning with Submodules

```bash
git clone --recurse-submodules https://github.com/user/project.git

# If already cloned:
git submodule update --init --recursive
```

### Updating Submodules

```bash
git submodule update --remote
git add libs/library
git commit -m "Update library submodule"
```

### Removing a Submodule

```bash
git submodule deinit -f libs/library
rm -rf .git/modules/libs/library
git rm -f libs/library
git commit -m "Remove library submodule"
```

---

## Git Subtree

An alternative to submodules — merges external repo into your tree.

### Adding, Updating, Pushing

```bash
# Add
git subtree add --prefix=libs/library https://github.com/user/library.git main --squash

# Update
git subtree pull --prefix=libs/library https://github.com/user/library.git main --squash

# Push changes back
git subtree push --prefix=libs/library https://github.com/user/library.git main
```

### Subtree vs Submodules

| Feature | Submodules | Subtree |
|---------|-----------|---------|
| External repo reference | Pointer (.gitmodules) | Full copy in tree |
| Clone complexity | Requires `--recurse-submodules` | Just clone |
| Update flow | `submodule update` | `subtree pull` |
| History | Separate | Merged into parent |


---

## Rewriting History

### git filter-repo (Recommended)

```bash
pip install git-filter-repo

# Remove a file from entire history
git filter-repo --path secrets.env --invert-paths

# Remove a directory
git filter-repo --path build/ --invert-paths

# Replace text in all files
git filter-repo --replace-text expressions.txt
# expressions.txt: literal:OLD_SECRET==>***REMOVED***

# Move files into subdirectory (monorepo migration)
git filter-repo --to-subdirectory-filter my-project/
```

### git filter-branch (Legacy — Avoid)

```bash
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch secrets.env' \
  --prune-empty --tag-name-filter cat -- --all
```

### BFG Repo-Cleaner

```bash
java -jar bfg.jar --strip-blobs-bigger-than 100M
java -jar bfg.jar --replace-text passwords.txt
```

---

## Signed Commits (GPG)

### Setup

```bash
gpg --full-generate-key
gpg --list-secret-keys --keyid-format=long
# sec   rsa4096/ABC123DEF456 2024-01-01

git config --global user.signingkey ABC123DEF456
git config --global commit.gpgsign true

# Export public key (add to GitHub/GitLab)
gpg --armor --export ABC123DEF456
```

### Usage

```bash
git commit -S -m "Signed commit"
git log --show-signature
git verify-commit HEAD
git verify-tag v1.0.0
```

---

## Git LFS

Store large files (binaries, media) efficiently.

### Setup and Usage

```bash
git lfs install
git lfs track "*.psd"
git lfs track "*.zip"
git lfs track "assets/videos/*"
git add .gitattributes
git commit -m "Configure Git LFS"

# Use normally
git add design.psd
git commit -m "Add design file"
git push

# Check status
git lfs ls-files
git lfs pull

# Migrate existing files to LFS
git lfs migrate import --include="*.psd" --everything
```

---

## Sparse Checkout

Clone only specific directories from a large repo.

```bash
git clone --no-checkout https://github.com/org/monorepo.git
cd monorepo

git sparse-checkout init --cone
git sparse-checkout set services/api packages/shared
git sparse-checkout add docs/
git sparse-checkout list

# Disable (get everything back)
git sparse-checkout disable
```

---

## Shallow Clones

Clone with limited history for faster operations.

```bash
git clone --depth 1 https://github.com/org/repo.git
git clone --depth 10 https://github.com/org/repo.git

# Fetch more history later
git fetch --deepen=50
git fetch --unshallow   # Convert to full clone

# Shallow clone specific branch
git clone --depth 1 --branch release/v2 https://github.com/org/repo.git

# Shallow since a date
git clone --shallow-since="2024-01-01" https://github.com/org/repo.git
```


---

## Git Aliases

Add to `~/.gitconfig`:

```ini
[alias]
    # Status & Log
    st = status -sb
    lg = log --oneline --graph --decorate --all
    ll = log --pretty=format:'%C(yellow)%h%Creset %s %C(blue)(%cr)%Creset %C(red)<%an>%Creset' --abbrev-commit
    last = log -1 HEAD --stat

    # Branching
    co = checkout
    br = branch -vv
    sw = switch
    newbr = checkout -b

    # Staging & Commits
    aa = add --all
    cm = commit -m
    ca = commit --amend --no-edit
    unstage = reset HEAD --
    undo = reset --soft HEAD~1

    # Diff
    df = diff --stat
    dfc = diff --cached
    dfw = diff --word-diff

    # Stash
    sl = stash list
    sp = stash pop
    ss = stash save

    # Remote
    pl = pull --rebase
    ps = push
    pf = push --force-with-lease

    # Cleanup
    cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master\\|develop' | xargs -n 1 git branch -d"
    prune-remote = fetch --prune

    # Utilities
    find = "!git log --all --oneline | grep"
    who = shortlog -sne
    fixup = "!f() { git commit --fixup=$1; }; f"
    ri = "!f() { git rebase -i HEAD~$1; }; f"
```

---

## .gitattributes

Control how Git handles files (line endings, merge strategies, diff).

```gitattributes
# Auto detect and normalize line endings
* text=auto

# Force LF for scripts
*.sh text eol=lf
*.bash text eol=lf

# Force CRLF for Windows files
*.bat text eol=crlf
*.cmd text eol=crlf

# Binary files
*.png binary
*.jpg binary
*.pdf binary
*.zip binary

# Git LFS
*.psd filter=lfs diff=lfs merge=lfs -text
*.mp4 filter=lfs diff=lfs merge=lfs -text

# Merge strategy for lock files
package-lock.json merge=union
yarn.lock merge=union

# Linguist overrides (GitHub language stats)
docs/* linguist-documentation
vendor/* linguist-vendored
*.generated.ts linguist-generated
```

---

## Monorepo Strategies

### Structure

```
monorepo/
├── packages/
│   ├── shared/
│   ├── frontend/
│   └── backend/
├── services/
│   ├── auth/
│   ├── api/
│   └── worker/
├── tools/
└── package.json
```

### Tools Comparison

| Tool | Use Case |
|------|----------|
| **Nx** | Full-featured, caching, affected detection |
| **Turborepo** | Fast builds with remote caching |
| **Lerna** | Package versioning and publishing |
| **Bazel** | Large-scale builds (Google-style) |
| **Rush** | Microsoft's monorepo manager |

### Git Practices for Monorepos

- Use path-based CODEOWNERS
- Sparse checkout for dev speed
- Shallow clone + filter in CI
- Per-package tags: `@frontend/v1.2.0`
- `nx affected --target=test` to run only impacted tests

---

## Performance Optimization

### For Large Repositories

```bash
# Filesystem monitor (Git 2.36+)
git config core.fsmonitor true
git config core.untrackedcache true

# Commit graph for faster log/merge-base
git commit-graph write --reachable
git config fetch.writeCommitGraph true

# Partial clone (fetch blobs on demand)
git clone --filter=blob:none https://github.com/org/repo.git

# Treeless clone
git clone --filter=tree:0 https://github.com/org/repo.git

# Speed up status for many files
git config feature.manyFiles true

# Scheduled maintenance (Git 2.30+)
git maintenance start
```

### Diagnosing Slowness

```bash
GIT_TRACE2_PERF=1 git status
git count-objects -vH
git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | sort -rnk3 | head -20
```

### Tips

- Aggressive `.gitignore` (node_modules, build output)
- Run `git gc` periodically
- Use `git-sizer` to analyze repo bloat
- Git LFS for binaries
- Partial/sparse checkout in CI

---

## Quick Reference

| Task | Command |
|------|---------|
| Interactive rebase last N | `git rebase -i HEAD~N` |
| Recover lost commit | `git reflog` → `git cherry-pick <hash>` |
| Find bug commit | `git bisect start` → good/bad loop |
| New worktree | `git worktree add <path> <branch>` |
| Sign commit | `git commit -S -m "msg"` |
| Track LFS file | `git lfs track "*.ext"` |
| Sparse checkout | `git sparse-checkout set <paths>` |
| Shallow clone | `git clone --depth 1 <url>` |

---

> 💡 **Pro Tip:** Combine these techniques! Use sparse checkout + shallow clone in CI for fast pipelines. Use worktrees + aliases for efficient code review. Use hooks + signed commits for secure team workflows.
