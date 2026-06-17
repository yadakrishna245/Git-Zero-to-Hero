[📖 README](README.md) | [🌳 Branching](git-branching.md) | [⚡ Commands](git-commands-cheatsheet.md) | [🔧 Internals](git-internals.md) | [🤝 Workflows](git-workflows.md) | [🚀 Advanced](git-advanced.md) | [🌐 GitHub/GitLab](github-gitlab-guide.md) | [🔥 Troubleshooting](git-troubleshooting.md) | [💼 Interview Prep](git-interview-questions.md) | [🔒 Security](git-security.md)

---

# 🌳 Git Branching — The Complete Guide

<p align="center">
  <img src="images/git-branching.svg" alt="Git Branching" width="700"/>
</p>

## Table of Contents

1. [What Are Branches?](#what-are-branches)
2. [Creating, Switching, Listing, Deleting Branches](#branch-operations)
3. [Branch Naming Conventions](#branch-naming-conventions)
4. [Merging: Fast-Forward vs 3-Way Merge](#merging)
5. [Merge Conflicts](#merge-conflicts)
6. [Rebasing](#rebasing)
7. [Cherry-Pick](#cherry-pick)
8. [Branch Strategies](#branch-strategies)
9. [Best Practices](#best-practices)

---

## What Are Branches? <a name="what-are-branches"></a>

### The Analogy: A Book with Parallel Storylines

Imagine you're writing a novel. The `main` branch is your published manuscript. Now you want to experiment with an alternate ending — you photocopy the manuscript, write on the copy, and only replace the original if the new ending is better. **That photocopy is a branch.**

In Git, a branch is simply a lightweight, movable pointer to a specific commit. Unlike other VCS tools that copy entire directories, Git branches are just 41-byte files containing a commit hash.

### How Branches Work Internally

```
main        → commit C3
feature/login → commit C5 (which has C3 as ancestor)
```

```
C1 ← C2 ← C3 (main)
              ↖
               C4 ← C5 (feature/login)
```

- **HEAD** is a special pointer that tells Git which branch you're currently on.
- Creating a branch = creating a new pointer. It's instant and costs almost nothing.

---

## Branch Operations <a name="branch-operations"></a>

### Creating a Branch

```bash
# Create a new branch (does NOT switch to it)
$ git branch feature/login

# Create AND switch to the new branch
$ git checkout -b feature/login
Switched to a new branch 'feature/login'

# Modern way (Git 2.23+): create and switch
$ git switch -c feature/login
Switched to a new branch 'feature/login'

# Create a branch from a specific commit
$ git branch hotfix/bug-123 abc1234

# Create a branch from a tag
$ git branch release/v2.0 v2.0.0
```

### Switching Branches

```bash
# Classic way
$ git checkout main
Switched to branch 'main'

# Modern way (Git 2.23+)
$ git switch main
Switched to branch 'main'

# Switch to previous branch (like cd -)
$ git switch -
Switched to branch 'feature/login'
```

### Listing Branches

```bash
# List local branches (* = current)
$ git branch
* feature/login
  main
  develop

# List remote branches
$ git branch -r
  origin/main
  origin/develop
  origin/feature/auth

# List all branches (local + remote)
$ git branch -a
* feature/login
  main
  develop
  remotes/origin/main
  remotes/origin/develop

# List branches with last commit info
$ git branch -v
* feature/login  a1b2c3d Add login form
  main           e4f5g6h Initial commit
  develop        i7j8k9l Add API routes

# List merged/unmerged branches
$ git branch --merged main
  feature/old-feature
  bugfix/typo

$ git branch --no-merged main
* feature/login
  feature/dashboard
```

### Deleting Branches

```bash
# Delete a fully merged branch
$ git branch -d feature/old-feature
Deleted branch feature/old-feature (was a1b2c3d).

# Force delete (even if not merged)
$ git branch -D feature/experimental
Deleted branch feature/experimental (was x9y8z7w).

# Delete a remote branch
$ git push origin --delete feature/old-feature
To https://github.com/user/repo.git
 - [deleted]         feature/old-feature

# Prune stale remote-tracking branches
$ git fetch --prune
```

### Renaming Branches

```bash
# Rename the current branch
$ git branch -m new-name

# Rename a specific branch
$ git branch -m old-name new-name

# Rename and update remote
$ git push origin -u new-name
$ git push origin --delete old-name
```

---

## Branch Naming Conventions <a name="branch-naming-conventions"></a>

### Recommended Prefixes

| Prefix | Purpose | Example |
|--------|---------|---------|
| `feature/` | New feature development | `feature/user-authentication` |
| `bugfix/` | Bug fix in development | `bugfix/login-redirect` |
| `hotfix/` | Critical production fix | `hotfix/security-patch` |
| `release/` | Release preparation | `release/v2.1.0` |
| `docs/` | Documentation only | `docs/api-reference` |
| `refactor/` | Code refactoring | `refactor/database-layer` |
| `test/` | Adding/fixing tests | `test/payment-integration` |
| `chore/` | Maintenance tasks | `chore/update-dependencies` |

### Rules

- Use lowercase and hyphens: `feature/user-login` ✅ not `Feature/User_Login` ❌
- Include ticket number when available: `feature/JIRA-123-add-oauth`
- Keep names short but descriptive
- No spaces (use hyphens or slashes)
- Avoid special characters: `~`, `^`, `:`, `?`, `*`, `[`, `\`

---

## Merging <a name="merging"></a>

### Fast-Forward Merge

A fast-forward merge happens when the target branch has no new commits since the source branch diverged. Git simply moves the pointer forward.

```
Before:
main:    C1 ← C2 ← C3
                      ↖
feature:               C4 ← C5

After (fast-forward):
main:    C1 ← C2 ← C3 ← C4 ← C5
```

```bash
$ git checkout main
Switched to branch 'main'

$ git merge feature/login
Updating a1b2c3d..e4f5g6h
Fast-forward
 src/login.js | 45 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)
 create mode 100644 src/login.js
```

#### Force a Merge Commit (No Fast-Forward)

```bash
$ git merge --no-ff feature/login
Merge made by the 'ort' strategy.
 src/login.js | 45 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)
```

This creates a merge commit even when fast-forward is possible — useful for preserving branch history.

### 3-Way Merge (Recursive/Ort Merge)

A 3-way merge happens when both branches have diverged (both have new commits since the common ancestor).

```
Before:
main:    C1 ← C2 ← C3 ← C6
                      ↖
feature:               C4 ← C5

After (3-way merge):
main:    C1 ← C2 ← C3 ← C6 ← M (merge commit)
                      ↖         ↗
feature:               C4 ← C5
```

```bash
$ git checkout main
$ git merge feature/dashboard
Merge made by the 'ort' strategy.
 src/dashboard.js | 120 +++++++++++++++++++++
 src/widgets.js   |  35 ++++++
 2 files changed, 155 insertions(+)
```

### Comparison Table

| Aspect | Fast-Forward | 3-Way Merge |
|--------|-------------|-------------|
| When | Linear history, no divergence | Both branches have new commits |
| Merge commit | No (unless `--no-ff`) | Yes, always |
| History | Linear | Shows branch topology |
| Revert | Must revert individual commits | Revert single merge commit |



---

## Merge Conflicts <a name="merge-conflicts"></a>

### How Conflicts Happen

Conflicts occur when:
1. Two branches modify the **same line** in the same file
2. One branch deletes a file that the other modified
3. Both branches add a file with the same name but different content

### Example: Creating a Conflict

```bash
# On main branch
$ echo "Hello World" > greeting.txt
$ git add greeting.txt && git commit -m "Add greeting"

# Create and switch to feature branch
$ git switch -c feature/update-greeting
$ echo "Hello Universe" > greeting.txt
$ git commit -am "Change to Universe"

# Switch back to main
$ git switch main
$ echo "Hello Earth" > greeting.txt
$ git commit -am "Change to Earth"

# Try to merge — CONFLICT!
$ git merge feature/update-greeting
Auto-merging greeting.txt
CONFLICT (content): Merge conflict in greeting.txt
Automatic merge failed; fix conflicts and then commit the result.
```

### Understanding Conflict Markers

```
<<<<<<< HEAD
Hello Earth
=======
Hello Universe
>>>>>>> feature/update-greeting
```

- `<<<<<<< HEAD` — your current branch's version
- `=======` — separator
- `>>>>>>> feature/update-greeting` — incoming branch's version

### Step-by-Step Resolution

**Step 1: Identify conflicted files**
```bash
$ git status
On branch main
You have unmerged paths.
  (fix conflicts and run "git commit")

Unmerged paths:
  (use "git add <file>..." to mark resolution)
        both modified:   greeting.txt
```

**Step 2: Open and edit the conflicted file**

Choose one of:
- Keep your version (HEAD)
- Keep their version (incoming)
- Combine both
- Write something entirely new

Edit `greeting.txt`:
```
Hello Earth and Universe
```

**Step 3: Mark as resolved**
```bash
$ git add greeting.txt
```

**Step 4: Complete the merge**
```bash
$ git commit
# Editor opens with default merge message
[main 1a2b3c4] Merge branch 'feature/update-greeting'
```

### Using Merge Tools

```bash
# Configure a merge tool
$ git config --global merge.tool vscode
$ git config --global mergetool.vscode.cmd 'code --wait $MERGED'

# Launch merge tool
$ git mergetool
Merging:
greeting.txt

Normal merge conflict for 'greeting.txt':
  {local}: modified file
  {remote}: modified file
```

### Aborting a Merge

```bash
# Cancel the merge and go back to pre-merge state
$ git merge --abort
```

---

## Rebasing <a name="rebasing"></a>

### What Is Rebasing?

Rebasing means moving (replaying) your branch's commits on top of another branch's latest commit. It rewrites commit history to create a linear timeline.

```
Before rebase:
main:    C1 ← C2 ← C3 ← C6
                      ↖
feature:               C4 ← C5

After rebase:
main:    C1 ← C2 ← C3 ← C6
                            ↖
feature:                     C4' ← C5'
```

Note: C4' and C5' are **new commits** (different hashes) with the same changes.

### Basic Rebase

```bash
# On feature branch, rebase onto main
$ git checkout feature/login
$ git rebase main
Successfully rebased and updated refs/heads/feature/login.

# Now merge is a fast-forward
$ git checkout main
$ git merge feature/login
Fast-forward
```

### When to Use Rebase

✅ **Use rebase when:**
- You want a clean, linear history
- Updating your feature branch with latest main
- Before merging your feature branch (to avoid merge commits)
- Working on a local branch not yet pushed

❌ **Never rebase when:**
- The branch is shared/public (others have based work on it)
- You've already pushed the commits (unless you're the only one using the branch)

### The Golden Rule of Rebasing

> **Never rebase commits that have been pushed to a public repository that others may have pulled.**

### Handling Rebase Conflicts

```bash
$ git rebase main
CONFLICT (content): Merge conflict in app.js
error: could not apply a1b2c3d... Add feature
hint: Resolve all conflicts manually, mark them as resolved with
hint: "git add/rm <conflicted_files>", then run "git rebase --continue".

# Fix the conflict in the file, then:
$ git add app.js
$ git rebase --continue

# Or abort the entire rebase:
$ git rebase --abort

# Or skip this commit:
$ git rebase --skip
```

### Interactive Rebase

Interactive rebase lets you edit, squash, reorder, or drop commits before they're applied.

```bash
# Rebase last 4 commits interactively
$ git rebase -i HEAD~4
```

This opens your editor with:

```
pick a1b2c3d Add login form
pick e4f5g6h Fix typo in login
pick i7j8k9l Add validation
pick m0n1o2p Update styles

# Commands:
# p, pick = use commit
# r, reword = use commit, but edit the commit message
# e, edit = use commit, but stop for amending
# s, squash = use commit, but meld into previous commit
# f, fixup = like "squash", but discard this commit's message
# d, drop = remove commit
```

#### Squash Example: Combine 4 commits into 1

Change to:
```
pick a1b2c3d Add login form
squash e4f5g6h Fix typo in login
squash i7j8k9l Add validation
squash m0n1o2p Update styles
```

Result:
```bash
[detached HEAD x9y8z7w] Add login form with validation and styles
 Date: Wed Jun 17 10:00:00 2026 +0530
 4 files changed, 200 insertions(+)
```

#### Reword Example: Change a commit message

```
pick a1b2c3d Add login form
reword e4f5g6h Fix typo in login
pick i7j8k9l Add validation
```

Git will pause and open your editor to edit the message for `e4f5g6h`.

### Rebase onto a Specific Commit

```bash
# Rebase feature branch onto a specific commit
$ git rebase --onto main feature-base feature/login
```



---

## Cherry-Pick <a name="cherry-pick"></a>

### What Is Cherry-Pick?

Cherry-pick applies a specific commit from one branch to another — copying just that one commit without merging the entire branch.

### Syntax and Examples

```bash
# Apply a single commit to current branch
$ git cherry-pick abc1234
[main 9f8e7d6] Fix critical bug in payment
 Date: Wed Jun 17 10:30:00 2026 +0530
 1 file changed, 3 insertions(+), 1 deletion(-)

# Cherry-pick multiple commits
$ git cherry-pick abc1234 def5678

# Cherry-pick a range of commits
$ git cherry-pick abc1234..xyz9876

# Cherry-pick without committing (stage changes only)
$ git cherry-pick --no-commit abc1234

# Cherry-pick and edit the commit message
$ git cherry-pick --edit abc1234
```

### Use Cases

1. **Hotfix backporting** — Apply a bug fix from `develop` to `release/v1.0`
2. **Selective feature porting** — Pick specific features from a long-lived branch
3. **Recovering lost commits** — Retrieve commits from a deleted branch via reflog
4. **Undoing a revert** — Re-apply a previously reverted commit

### Cherry-Pick Conflict Resolution

```bash
$ git cherry-pick abc1234
error: could not apply abc1234... Fix bug
hint: After resolving the conflicts, mark them with "git add"
hint: and run "git cherry-pick --continue"

# Fix conflicts, then:
$ git add .
$ git cherry-pick --continue

# Or abort:
$ git cherry-pick --abort
```

---

## Branch Strategies <a name="branch-strategies"></a>

### 1. GitFlow

GitFlow is a structured branching model designed for projects with scheduled releases.

#### Branch Structure (Diagram)

```
main ──────●────────────────────●──────────────●──── (production)
           │                    ↑              ↑
           │               tag v1.0       tag v1.1
           │                    │              │
           ▼                    │              │
develop ──────●───●───●────●───┤────●───●─────┤──── (integration)
              │       ↑    │   │    │       ↑  │
              ▼       │    ▼   │    ▼       │  │
feature/A ────●───●───┘    │   │ feature/C ─┘  │
                           │   │               │
                     release/1.0               │
                           │                   │
                      hotfix/bug ──────────────┘
```

#### Key Branches

| Branch | Purpose | Created From | Merges Into |
|--------|---------|-------------|-------------|
| `main` | Production code | — | — |
| `develop` | Integration branch | `main` | — |
| `feature/*` | New features | `develop` | `develop` |
| `release/*` | Release preparation | `develop` | `main` + `develop` |
| `hotfix/*` | Emergency fixes | `main` | `main` + `develop` |

#### GitFlow Commands

```bash
# Initialize GitFlow
$ git flow init

# Start a feature
$ git flow feature start user-auth
Switched to a new branch 'feature/user-auth'

# Finish a feature (merges to develop)
$ git flow feature finish user-auth
Switched to branch 'develop'
Merge made by the 'ort' strategy.
Deleted branch feature/user-auth.

# Start a release
$ git flow release start v1.2.0
Switched to a new branch 'release/v1.2.0'

# Finish a release (merges to main + develop, tags)
$ git flow release finish v1.2.0

# Start a hotfix
$ git flow hotfix start critical-bug
Switched to a new branch 'hotfix/critical-bug'

# Finish a hotfix (merges to main + develop)
$ git flow hotfix finish critical-bug
```

#### When to Use GitFlow

✅ Products with scheduled releases (mobile apps, desktop software)
✅ Multiple versions in production simultaneously
✅ Teams that need clear separation between development and production
❌ NOT for continuous deployment / web apps with frequent releases

---

### 2. GitHub Flow

A simpler model: just `main` + short-lived feature branches.

```
main (always deployable)
 │
 ├── feature/add-search ──→ PR → Review → Merge → Deploy
 ├── fix/broken-link ──→ PR → Review → Merge → Deploy
 └── update/readme ──→ PR → Review → Merge → Deploy
```

#### Workflow

```bash
# 1. Create a branch from main
$ git checkout -b feature/add-search main

# 2. Make commits
$ git add . && git commit -m "Add search functionality"

# 3. Push branch
$ git push -u origin feature/add-search

# 4. Open Pull Request
$ gh pr create --title "Add search" --body "Implements full-text search"

# 5. Code review + CI passes

# 6. Merge PR (squash merge recommended)

# 7. Deploy from main (automatic via CI/CD)

# 8. Delete branch
$ git branch -d feature/add-search
$ git push origin --delete feature/add-search
```

#### When to Use GitHub Flow

✅ Web applications with continuous deployment
✅ Small to medium teams
✅ Projects that deploy frequently (daily/weekly)
❌ NOT for projects needing multiple release versions

---

### 3. Trunk-Based Development

Everyone commits to `main` (trunk) directly or via very short-lived branches (< 1 day).

```
main (trunk) ──●──●──●──●──●──●──●──●──●── (always releasable)
                   │           ↑
                   └── quick ──┘  (lives < 1 day)
```

#### Workflow

```bash
# Option A: Direct commit to main
$ git checkout main
$ git pull
$ git commit -am "Add feature behind flag"
$ git push

# Option B: Short-lived branch (< 1 day)
$ git checkout -b quick-fix
$ git commit -am "Fix button alignment"
$ git push -u origin quick-fix
# Create PR, get quick review, merge within hours
$ git checkout main && git pull
$ git branch -d quick-fix
```

#### Key Practices

- Feature flags to hide incomplete work
- Commits must be small and self-contained
- Strong CI pipeline (must pass before merge)
- Pair programming reduces need for async review

#### When to Use Trunk-Based Development

✅ Mature teams with strong CI/CD
✅ Projects needing fastest delivery speed
✅ Teams practicing pair/mob programming
❌ NOT for junior teams without strong testing culture
❌ NOT for open-source with many external contributors

---

### Comparison: When to Use Which?

| Factor | GitFlow | GitHub Flow | Trunk-Based |
|--------|---------|-------------|-------------|
| Release frequency | Scheduled | Continuous | Continuous |
| Team size | Large (10+) | Small-Medium (2-10) | Any (mature) |
| Complexity | High | Low | Low |
| Parallel releases | Yes | No | No |
| Best for | Mobile/Desktop | Web apps/SaaS | High-velocity |
| Feature flags | No | Optional | Essential |
| Code review | Formal async | PR-based | Pair/PR |

---

## Best Practices <a name="best-practices"></a>

### Branch Hygiene

1. **Delete branches after merging** — Don't accumulate stale branches
   ```bash
   $ git branch --merged main | grep -v main | xargs git branch -d
   ```

2. **Keep branches short-lived** — Merge within days, not weeks

3. **Update frequently** — Rebase/merge from main regularly
   ```bash
   $ git fetch origin
   $ git rebase origin/main
   ```

4. **One branch = one purpose** — Don't mix unrelated changes

### Commit Discipline on Branches

5. **Make atomic commits** — Each commit should be a single logical change
6. **Write meaningful commit messages** — Future you will thank present you
7. **Squash WIP commits before merging** — Clean history for reviewers

### Protection and Safety

8. **Never force-push to shared branches** — Use `--force-with-lease` if you must
   ```bash
   $ git push --force-with-lease origin feature/login
   ```

9. **Protect main/develop branches** — Require PRs and CI checks
10. **Tag releases** — Always tag production deployments
    ```bash
    $ git tag -a v1.2.0 -m "Release version 1.2.0"
    $ git push origin v1.2.0
    ```

### Team Conventions

11. **Agree on a branching strategy** — Document it in CONTRIBUTING.md
12. **Use consistent naming** — Enforce with Git hooks or CI checks
13. **Automate cleanup** — Set up branch deletion after PR merge

---

*Next: [🤝 Workflows](git-workflows.md) — Learn team collaboration patterns →*
