<p align="center">
  <img src="images/git-workflow.svg" alt="Git Workflow Animation" width="700"/>
</p>

<h1 align="center">Git Zero to Hero</h1>

<p align="center">
  <strong>A complete guide to mastering Git from the ground up</strong>
</p>

<p align="center">
  <a href="https://github.com/krishna-yada/Git-Zero-to-Hero/stargazers"><img src="https://img.shields.io/github/stars/krishna-yada/Git-Zero-to-Hero?style=flat-square&color=f97316" alt="Stars"/></a>
  <a href="https://github.com/krishna-yada/Git-Zero-to-Hero/network/members"><img src="https://img.shields.io/github/forks/krishna-yada/Git-Zero-to-Hero?style=flat-square&color=3b82f6" alt="Forks"/></a>
  <a href="https://github.com/krishna-yada/Git-Zero-to-Hero/pulls"><img src="https://img.shields.io/badge/PRs-welcome-10b981?style=flat-square" alt="PRs Welcome"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-8b5cf6?style=flat-square" alt="License MIT"/></a>
  <img src="https://komarev.com/ghpvc/?username=krishna-yada&label=visitors&color=f97316&style=flat-square" alt="Visitors"/>
</p>

---

## 📑 Table of Contents

- [What is Git](#what-is-git)
- [Why Git](#why-git)
- [Installation](#installation)
- [First-time Setup](#first-time-setup)
- [Core Concepts](#core-concepts)
- [Basic Commands](#basic-commands)
- [Branching Basics](#branching-basics)
- [Remote Repositories](#remote-repositories)
- [Deep Dive Guides](#-deep-dive-guides)

---

## What is Git

Git is a **distributed version control system** that tracks changes in your files and coordinates work among multiple people. Created by Linus Torvalds in 2005 for Linux kernel development, it has become the standard for source code management.

Key characteristics:
- **Distributed** — Every developer has a full copy of the repository history
- **Fast** — Most operations are local, no network needed
- **Integrity** — Every file and commit is checksummed with SHA-1
- **Branching** — Lightweight branches enable parallel workflows

[⬆ Back to top](#-table-of-contents)

---

## Why Git

| Without Version Control | With Git |
|---|---|
| `report_final_v2_FINAL(1).docx` | Clean commit history |
| Emailing zip files | Push/pull in seconds |
| "Who changed this?" | `git blame` tells you |
| No undo | Revert any commit |
| One person at a time | Entire teams in parallel |

Git gives you:
- Complete history of every change
- Safe experimentation through branches
- Effortless collaboration via remotes
- Industry-standard workflow (GitHub, GitLab, Bitbucket)

[⬆ Back to top](#-table-of-contents)

---

## Installation

### Windows

```bash
# Download installer from https://git-scm.com/download/win
# Or use winget:
winget install --id Git.Git -e --source winget
```

### macOS

```bash
# With Homebrew:
brew install git

# Or install Xcode Command Line Tools:
xcode-select --install
```

### Linux

```bash
# Debian/Ubuntu
sudo apt update && sudo apt install git

# Fedora
sudo dnf install git

# Arch
sudo pacman -S git
```

Verify installation:

```bash
git --version
```

[⬆ Back to top](#-table-of-contents)

---

## First-time Setup

Configure your identity (used in every commit):

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Recommended settings:

```bash
# Set default branch name
git config --global init.defaultBranch main

# Set default editor
git config --global core.editor "code --wait"

# Enable colored output
git config --global color.ui auto

# View all settings
git config --list
```

[⬆ Back to top](#-table-of-contents)

---

## Core Concepts

<p align="center">
  <img src="images/git-internals.svg" alt="Git Internals" width="700"/>
</p>

### Working Directory

Your project folder — the files you see and edit. Git watches this directory for changes.

### Staging Area (Index)

A preparation zone between your working directory and the repository. You selectively choose which changes to include in the next commit.

```bash
# Stage a file
git add filename.txt

# Stage all changes
git add .

# See what's staged
git status
```

### Commits

A commit is a **permanent snapshot** of your staged changes. Each commit has:
- A unique SHA-1 hash
- Author and timestamp
- A message describing the change
- A pointer to its parent commit(s)

```bash
git commit -m "Add user authentication module"
```

### How They Connect

```
Working Directory  →  Staging Area  →  Repository
   (edit files)       (git add)       (git commit)
```

[⬆ Back to top](#-table-of-contents)

---

## Basic Commands

### Initialize a Repository

```bash
# Create a new repo
git init

# Clone an existing repo
git clone https://github.com/user/repo.git
```

### Track Changes

```bash
# Check status
git status

# View changes (unstaged)
git diff

# View changes (staged)
git diff --staged
```

### Stage and Commit

```bash
# Stage specific files
git add file1.txt file2.txt

# Stage all modified files
git add .

# Commit with message
git commit -m "Describe what changed"

# Stage + commit in one step (tracked files only)
git commit -am "Quick commit"
```

### View History

```bash
# Full log
git log

# Compact one-line log
git log --oneline

# Graphical branch view
git log --oneline --graph --all
```

### Undo Changes

```bash
# Discard changes in working directory
git checkout -- filename.txt

# Unstage a file
git reset HEAD filename.txt

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1
```

[⬆ Back to top](#-table-of-contents)

---

## Branching Basics

<p align="center">
  <img src="images/git-branching.svg" alt="Git Branching" width="700"/>
</p>

Branches let you work on features in isolation without affecting the main codebase.

```bash
# List branches
git branch

# Create a new branch
git branch feature-login

# Switch to a branch
git checkout feature-login
# Or (Git 2.23+):
git switch feature-login

# Create and switch in one step
git checkout -b feature-login
# Or:
git switch -c feature-login
```

### Merging

```bash
# Switch to main branch
git checkout main

# Merge feature branch into main
git merge feature-login

# Delete merged branch
git branch -d feature-login
```

<p align="center">
  <img src="images/merge-vs-rebase.svg" alt="Merge vs Rebase" width="700"/>
</p>

[⬆ Back to top](#-table-of-contents)

---

## Remote Repositories

Remotes are versions of your repository hosted on a server (GitHub, GitLab, etc.).

```bash
# Add a remote
git remote add origin https://github.com/user/repo.git

# View remotes
git remote -v

# Push to remote
git push -u origin main

# Pull changes from remote
git pull origin main

# Fetch without merging
git fetch origin
```

### Common Workflow

```bash
# 1. Create feature branch
git switch -c feature-x

# 2. Make changes and commit
git add .
git commit -m "Implement feature X"

# 3. Push branch to remote
git push -u origin feature-x

# 4. Create Pull Request on GitHub
# 5. After review, merge PR
# 6. Update local main
git switch main
git pull origin main
```

[⬆ Back to top](#-table-of-contents)

---

## 📚 Deep Dive Guides

| Guide | Description |
|---|---|
| [Branching Strategies](docs/branching-strategies.md) | Git Flow, GitHub Flow, Trunk-based |
| [Merge vs Rebase](docs/merge-vs-rebase.md) | When to use each approach |
| [Git Internals](docs/git-internals.md) | Blobs, trees, commits, and refs |
| [Undoing Changes](docs/undoing-changes.md) | Reset, revert, checkout, and restore |
| [Git Hooks](docs/git-hooks.md) | Automate workflows with hooks |
| [Collaboration](docs/collaboration.md) | PRs, code review, conflict resolution |
| [Advanced Commands](docs/advanced-commands.md) | Stash, cherry-pick, bisect, reflog |
| [Git Aliases](docs/git-aliases.md) | Productivity shortcuts |
| [Cheat Sheet](docs/cheatsheet.md) | Quick reference card |

---

<p align="center">
  Made with ❤️ for the Git community<br/>
  <a href="#-table-of-contents">⬆ Back to top</a>
</p>
