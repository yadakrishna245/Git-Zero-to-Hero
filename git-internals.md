[📖 README](README.md) | [🌳 Branching](git-branching.md) | [⚡ Commands](git-commands-cheatsheet.md) | [🔧 Internals](git-internals.md) | [🤝 Workflows](git-workflows.md) | [🚀 Advanced](git-advanced.md) | [🌐 GitHub/GitLab](github-gitlab-guide.md) | [🔥 Troubleshooting](git-troubleshooting.md) | [💼 Interview Prep](git-interview-questions.md)

---

# 🔧 Git Internals — How Git Works Under the Hood

> Understanding Git's internal architecture transforms you from a user into a power user. This guide demystifies the plumbing behind the porcelain.

---

## Table of Contents

1. [Git is a Content-Addressable Filesystem](#git-is-a-content-addressable-filesystem)
2. [The .git Directory Structure](#the-git-directory-structure)
3. [Git Objects](#git-objects)
4. [How SHA-1 Hashing Works](#how-sha-1-hashing-works)
5. [Refs: Branches, HEAD, and Tags](#refs-branches-head-and-tags)
6. [The Reflog](#the-reflog)
7. [Packfiles and Garbage Collection](#packfiles-and-garbage-collection)
8. [How Merge Works Internally](#how-merge-works-internally)
9. [How Rebase Works Internally](#how-rebase-works-internally)
10. [Transfer Protocols](#transfer-protocols)
11. [Commands to Inspect Internals](#commands-to-inspect-internals)

---

## Git is a Content-Addressable Filesystem

At its core, Git is **not** a version control system — it's a content-addressable filesystem with a VCS built on top.

### What does "content-addressable" mean?

Every piece of data stored in Git is addressed by a **SHA-1 hash** of its content. This means:

- The **same content** always produces the **same hash** (deterministic).
- Any change in content (even 1 bit) produces a **completely different hash**.
- You can retrieve any object if you know its hash.

```bash
# Store arbitrary content and get its hash
$ echo "Hello, Git!" | git hash-object --stdin
f5c87dc3c3a93e0f3c7a8e0f7d2c8e4a1b5f9d23

# Store it in the database
$ echo "Hello, Git!" | git hash-object -w --stdin
f5c87dc3c3a93e0f3c7a8e0f7d2c8e4a1b5f9d23

# Retrieve it back
$ git cat-file -p f5c87dc3c3a93e0f3c7a8e0f7d2c8e4a1b5f9d23
Hello, Git!
```

### The Two Layers of Git

| Layer | Description | Examples |
|-------|-------------|----------|
| **Porcelain** | User-friendly commands | `git add`, `git commit`, `git push` |
| **Plumbing** | Low-level internal commands | `git hash-object`, `git cat-file`, `git update-index` |

Porcelain commands are wrappers around plumbing commands. Understanding plumbing gives you complete control.

---

## The .git Directory Structure

When you run `git init`, Git creates the `.git` directory — the **entire repository** lives here.

```
.git/
├── HEAD                 # Points to current branch ref
├── config               # Repository-specific configuration
├── description          # Used by GitWeb (usually ignored)
├── index                # The staging area (binary file)
├── packed-refs          # Packed references for efficiency
├── hooks/               # Client/server-side hook scripts
│   ├── pre-commit.sample
│   ├── pre-push.sample
│   └── ...
├── info/
│   └── exclude          # Local ignore rules (not shared)
├── logs/                # Reflog data
│   ├── HEAD             # History of HEAD movements
│   └── refs/
│       └── heads/
│           └── main     # History of main branch movements
├── objects/             # All content (blobs, trees, commits, tags)
│   ├── info/
│   ├── pack/            # Packfiles (compressed objects)
│   ├── 3a/              # Object directories (first 2 chars of SHA)
│   │   └── 2b1c4d...   # Object file (remaining 38 chars of SHA)
│   └── ...
└── refs/                # Branch and tag pointers
    ├── heads/           # Local branches
    │   └── main         # File containing SHA of latest commit
    ├── remotes/         # Remote-tracking branches
    │   └── origin/
    │       └── main
    └── tags/            # Tag references
        └── v1.0.0
```

### Key Files Explained

| File/Directory | Purpose |
|---------------|---------|
| `HEAD` | Text file containing `ref: refs/heads/<branch>` or a raw SHA (detached HEAD) |
| `index` | Binary file representing the staging area — what will be in the next commit |
| `config` | INI-format config specific to this repo (`[core]`, `[remote]`, `[branch]`) |
| `objects/` | The object database — every version of every file ever committed |
| `refs/heads/` | Each file is a branch — contains the SHA of the branch's tip commit |
| `refs/tags/` | Lightweight tags point directly to commits |
| `packed-refs` | Optimization: many refs packed into one file instead of individual files |
| `logs/` | Reflog entries recording every ref update |
| `hooks/` | Executable scripts triggered by Git events |

```bash
# Inspect HEAD
$ cat .git/HEAD
ref: refs/heads/main

# See what main points to
$ cat .git/refs/heads/main
3a2b1c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b

# View the index (staging area)
$ git ls-files --stage
100644 f5c87dc3c3a93e0f3c7a8e0f7d2c8e4a1b5f9d23 0	README.md
100644 a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0 0	src/app.js
```

---

## Git Objects

Git has exactly **four** types of objects. Everything in Git is built from these primitives.

### 1. Blob (Binary Large Object)

A blob stores **file content** — just the raw data, no filename, no permissions.

```bash
# Create a blob
$ echo "Hello World" | git hash-object -w --stdin
557db03de997c86a4a028e1ebd3a1ceb225be238

# Inspect it
$ git cat-file -t 557db03
blob
$ git cat-file -p 557db03
Hello World
$ git cat-file -s 557db03
12
```

**Key facts:**
- Two files with identical content share the **same blob** (deduplication!).
- Blobs don't know their filename — that's stored in the tree object.
- Internal format: `blob <size>\0<content>`

### 2. Tree

A tree represents a **directory listing**. It maps filenames to blobs (files) or other trees (subdirectories).

```bash
# View a tree object
$ git cat-file -p main^{tree}
100644 blob 557db03de997c86a4a028e1ebd3a1ceb225be238    README.md
100644 blob a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0    package.json
040000 tree 9f8e7d6c5b4a3d2e1f0a9b8c7d6e5f4a3b2c1d0e    src
```

**Structure of a tree entry:**

```
<mode> <type> <SHA-1>    <filename>
100644  blob  557db03...  README.md      # Regular file
100755  blob  a1b2c3d...  setup.sh       # Executable file
040000  tree  9f8e7d6...  src            # Subdirectory
120000  blob  e1f2a3b...  link           # Symbolic link
160000 commit 4c5d6e7...  submodule      # Submodule reference
```

**File modes:**
| Mode | Meaning |
|------|---------|
| `100644` | Regular file |
| `100755` | Executable file |
| `040000` | Directory (tree) |
| `120000` | Symbolic link |
| `160000` | Submodule (gitlink) |

### 3. Commit

A commit object ties everything together. It points to a tree (snapshot) and contains metadata.

```bash
$ git cat-file -p HEAD
tree 9f8e7d6c5b4a3d2e1f0a9b8c7d6e5f4a3b2c1d0e
parent 1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b
author John Doe <john@example.com> 1710500000 +0000
committer John Doe <john@example.com> 1710500000 +0000

Add user authentication module
```

**Commit structure:**
| Field | Description |
|-------|-------------|
| `tree` | SHA-1 of the root tree (complete snapshot) |
| `parent` | SHA-1 of parent commit(s) — 0 for initial, 2+ for merges |
| `author` | Who wrote the code + timestamp |
| `committer` | Who committed + timestamp |
| message | Free-form text after blank line |

**Important:** A commit is a **full snapshot**, not a diff. Git stores the complete tree state at each commit. Diffs are computed on-the-fly.

### 4. Tag (Annotated)

An annotated tag is a full object pointing to a commit with metadata.

```bash
$ git cat-file -p v1.0.0
object 3a2b1c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b
type commit
tag v1.0.0
tagger John Doe <john@example.com> 1710600000 +0000

Release version 1.0.0 - stable API
```

**Note:** Lightweight tags are NOT objects — they're just refs (pointers) stored in `refs/tags/`.

### Object Relationships Diagram

```
                    ┌─────────────────────────────────────┐
                    │          COMMIT (3a2b1c4)           │
                    │  tree: 9f8e7d6                      │
                    │  parent: 1a2b3c4                    │
                    │  author: John Doe                   │
                    │  message: "Add auth module"         │
                    └──────────────┬──────────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────────────┐
                    │          TREE (9f8e7d6)             │
                    │  blob 557db03  README.md            │
                    │  blob a1b2c3d  package.json         │
                    │  tree 4e5f6a7  src/                 │
                    └────────┬──────────┬────────────────┘
                             │          │
                    ┌────────┘          └────────┐
                    ▼                             ▼
         ┌──────────────────┐         ┌──────────────────┐
         │  BLOB (557db03)  │         │  TREE (4e5f6a7)  │
         │  "# My Project"  │         │  blob e8f9a0b app.js
         └──────────────────┘         │  blob b1c2d3e auth.js
                                      └──────────────────┘
```

---

## How SHA-1 Hashing Works

Git uses SHA-1 to generate 40-character hexadecimal identifiers for all objects.

### Hash Computation

Git doesn't hash just the content — it prepends a header:

```
SHA-1( "<type> <content-length>\0<content>" )
```

**Example:**

```bash
# Manual hash computation
$ echo -n "Hello World" | wc -c
11

# Git computes: SHA-1("blob 11\0Hello World")
$ echo -n "blob 11\0Hello World" | sha1sum
557db03de997c86a4a028e1ebd3a1ceb225be238

# Verify with Git
$ echo -n "Hello World" | git hash-object --stdin
557db03de997c86a4a028e1ebd3a1ceb225be238
```

### Properties of SHA-1 in Git

| Property | Implication |
|----------|-------------|
| Deterministic | Same content → same hash, always |
| Collision-resistant | Different content → different hash (practically) |
| Fixed-length | Always 40 hex characters (160 bits) |
| Avalanche effect | 1-bit change → ~50% of hash bits flip |
| One-way | Cannot recover content from hash |

### SHA-1 vs SHA-256

Git is transitioning to SHA-256 (available experimentally since Git 2.29):

```bash
# Initialize repo with SHA-256 (experimental)
$ git init --object-format=sha256
```

SHA-1 collisions have been demonstrated (SHAttered, 2017), but Git has mitigations:
- Hardened SHA-1 detects known collision patterns.
- SHA-256 transition is underway for future-proofing.

### Object Storage on Disk

Objects are stored in `.git/objects/` using the first 2 characters as directory name:

```
SHA: 3a2b1c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b
Path: .git/objects/3a/2b1c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b
```

Objects are zlib-compressed on disk:

```bash
# Decompress a raw object
$ python -c "import zlib,sys; sys.stdout.buffer.write(zlib.decompress(open('.git/objects/3a/2b1c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b','rb').read()))"
commit 234\0tree 9f8e7d6...
```

---


## Refs: Branches, HEAD, and Tags

Refs are human-readable names that point to SHA-1 hashes. They're stored as simple text files.

### Branches

A branch is just a file in `.git/refs/heads/` containing a commit SHA.

```bash
# A branch is literally a 41-byte file (40 chars + newline)
$ cat .git/refs/heads/main
3a2b1c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b

# Creating a branch = creating a file
$ echo "3a2b1c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b" > .git/refs/heads/my-branch
# (This is literally what `git branch my-branch` does internally)

# List all refs
$ git for-each-ref --format='%(refname) %(objectname:short)' refs/heads/
refs/heads/develop 7d4e5f6
refs/heads/feature/login 9f8e7d6
refs/heads/main 3a2b1c4
```

### HEAD

HEAD is a **symbolic reference** — it points to a branch ref, not directly to a commit.

```bash
# Normal state: HEAD points to a branch
$ cat .git/HEAD
ref: refs/heads/main

# Detached HEAD: points directly to a commit
$ git checkout 3a2b1c4
$ cat .git/HEAD
3a2b1c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b
```

**How HEAD moves:**
- `git commit` → advances the branch HEAD points to
- `git checkout <branch>` → changes which branch HEAD points to
- `git checkout <sha>` → detaches HEAD (points directly to commit)

### Symbolic Refs

```bash
# Read symbolic ref
$ git symbolic-ref HEAD
refs/heads/main

# Set symbolic ref (switch branch at plumbing level)
$ git symbolic-ref HEAD refs/heads/develop
```

### Tags as Refs

```bash
# Lightweight tag = file in refs/tags/ pointing to a commit
$ cat .git/refs/tags/v1.0.0
3a2b1c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b

# Annotated tag = file pointing to a tag OBJECT (which then points to a commit)
$ cat .git/refs/tags/v2.0.0
e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0

$ git cat-file -t e1f2a3b4
tag
$ git cat-file -p e1f2a3b4
object 3a2b1c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b
type commit
tag v2.0.0
...
```

### Packed Refs

For performance, Git packs many refs into a single file:

```bash
$ cat .git/packed-refs
# pack-refs with: peeled fully-peeled sorted
3a2b1c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b refs/heads/main
7d4e5f6a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e refs/remotes/origin/main
e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0 refs/tags/v1.0.0
^3a2b1c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b
```

The `^` line is the "peeled" value — the commit an annotated tag points to.

---

## The Reflog

The reflog is your **safety net** — it records every movement of every ref locally.

### How it Works

Every time HEAD or a branch ref changes, Git logs the old and new values:

```bash
# View HEAD reflog
$ git reflog
3a2b1c4 (HEAD -> main) HEAD@{0}: commit: Add payment gateway
7d4e5f6 HEAD@{1}: pull --rebase: Fast-forward
9f8e7d6 HEAD@{2}: checkout: moving from feature/login to main
1a2b3c4 HEAD@{3}: commit: Add login validation
0a1b2c3 HEAD@{4}: checkout: moving from main to feature/login

# View reflog for a specific branch
$ git reflog show develop
7d4e5f6 develop@{0}: merge feature/api: Fast-forward
3a2b1c4 develop@{1}: commit: Update config
9f8e7d6 develop@{2}: branch: Created from main
```

### Reflog File Format

```bash
$ cat .git/logs/HEAD
0000000000000000000000000000000000000000 3a2b1c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b John Doe <john@example.com> 1710500000 +0000	commit (initial): Initial commit
3a2b1c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b 7d4e5f6a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e John Doe <john@example.com> 1710600000 +0000	commit: Add feature
```

Each entry: `<old-sha> <new-sha> <identity> <timestamp>\t<action>`

### Recovering Lost Commits

The reflog is your recovery tool when things go wrong:

```bash
# "I accidentally ran git reset --hard!"
$ git reflog
3a2b1c4 HEAD@{0}: reset: moving to HEAD~3
7d4e5f6 HEAD@{1}: commit: Important work I thought I lost!

# Recover!
$ git reset --hard 7d4e5f6
HEAD is now at 7d4e5f6 Important work I thought I lost!

# "I deleted a branch!"
$ git reflog | grep "feature/important"
1a2b3c4 HEAD@{5}: checkout: moving from feature/important to main
$ git branch feature/important 1a2b3c4
```

### Reflog Expiry

Reflogs are local-only and expire:
- Reachable entries: 90 days (default)
- Unreachable entries: 30 days (default)

```bash
# Configure expiry
$ git config gc.reflogExpire 180.days
$ git config gc.reflogExpireUnreachable 60.days

# Manually expire
$ git reflog expire --expire=now --all
```

---

## Packfiles and Garbage Collection

### Loose Objects vs Packfiles

Initially, every object is stored as a separate zlib-compressed file (**loose object**). As the repo grows, Git packs objects into **packfiles** for efficiency.

```bash
# Count loose objects
$ git count-objects
48 objects, 192 kilobytes

# Count packed objects
$ git count-objects -v
count: 48              # Loose objects
size: 192              # Loose object size (KB)
in-pack: 1542          # Packed objects
packs: 1               # Number of packfiles
size-pack: 2048        # Packfile size (KB)
prune-packable: 0      # Loose objects that could be pruned
garbage: 0
size-garbage: 0
```

### How Packfiles Work

Packfiles use **delta compression** — storing only the differences between similar objects.

```
.git/objects/pack/
├── pack-abc123.idx    # Index file (offsets for fast lookup)
└── pack-abc123.pack   # Packed objects (compressed with deltas)
```

```bash
# View packfile contents
$ git verify-pack -v .git/objects/pack/pack-abc123.idx
3a2b1c4d... commit  234  155  12
7d4e5f6a... commit  189  132  167
557db03d... blob    2048 1024 299
a1b2c3d4... blob    45   38   1323  1 557db03d...  # Delta of 557db03!
```

The last entry is a **deltified object** — stored as a delta against `557db03d`.

### Manual Packing

```bash
# Pack loose objects
$ git repack -a -d
Enumerating objects: 1590, done.
Counting objects: 100% (1590/1590), done.
Delta compression using up to 8 threads
Compressing objects: 100% (723/723), done.
Writing objects: 100% (1590/1590), done.
Total 1590 (delta 891), reused 1542 (delta 866)
Removing duplicate objects: 100% (48/48), done.

# More aggressive packing
$ git repack -a -d --depth=250 --window=250
```

### Garbage Collection Process

`git gc` performs these steps:

1. **Pack loose objects** into packfiles
2. **Remove redundant packs** (consolidate into one)
3. **Prune unreachable objects** older than `gc.pruneExpire` (default: 2 weeks)
4. **Pack refs** into `packed-refs`
5. **Expire reflog** entries past their configured lifetime
6. **Repack** with delta compression

```bash
# What triggers auto-gc:
# - More than 6700 loose objects (gc.auto)
# - More than 50 packfiles (gc.autoPackLimit)

# Force full GC
$ git gc --aggressive --prune=now

# See what's unreachable
$ git fsck --unreachable
unreachable blob 557db03de997c86a4a028e1ebd3a1ceb225be238
unreachable commit 1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b
```

---


## How Merge Works Internally

### The Three-Way Merge Algorithm

Git merges use a **three-way merge** algorithm with three inputs:

```
         BASE (common ancestor)
        /                      \
    OURS (current branch)    THEIRS (branch being merged)
```

**Step-by-step process:**

1. **Find the merge base:** Git finds the best common ancestor using `git merge-base`.
2. **Compare trees:** Git diffs BASE→OURS and BASE→THEIRS.
3. **Apply non-conflicting changes:** Changes in only one side are applied automatically.
4. **Flag conflicts:** Changes to the same region in both sides create conflicts.
5. **Create merge commit:** If successful, creates a commit with two parents.

```bash
# Find the merge base
$ git merge-base main feature/login
1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b

# See what merge would do (without doing it)
$ git merge-tree $(git merge-base main feature) main feature
```

### Merge Strategies

| Strategy | When Used | Description |
|----------|-----------|-------------|
| `ort` (default) | Two branches | Optimized recursive three-way merge (Git 2.33+) |
| `recursive` | Two branches | Previous default — handles criss-cross merges |
| `resolve` | Two branches | Simple three-way (doesn't handle criss-cross) |
| `octopus` | 3+ branches | Merges multiple branches (no conflicts allowed) |
| `ours` | Special | Keeps our tree, discards theirs entirely |
| `subtree` | Subtree merges | Adjusts tree to match subdirectory |

```bash
# Use a specific strategy
$ git merge -s ort feature/login

# Use strategy options
$ git merge -X theirs feature/login    # Prefer theirs on conflict
$ git merge -X ours feature/login      # Prefer ours on conflict
```

### What Happens During a Conflict

When merge conflicts occur, Git writes **three versions** to the index (staging area):

```bash
# During a conflict:
$ git ls-files -u
100644 aaa1111... 1	src/app.js    # Stage 1: BASE (common ancestor)
100644 bbb2222... 2	src/app.js    # Stage 2: OURS (current branch)
100644 ccc3333... 3	src/app.js    # Stage 3: THEIRS (incoming branch)
```

The working tree file contains conflict markers:

```
<<<<<<< HEAD (ours)
const port = 3000;
=======
const port = process.env.PORT || 8080;
>>>>>>> feature/login (theirs)
```

```bash
# View each stage
$ git show :1:src/app.js    # Base version
$ git show :2:src/app.js    # Our version
$ git show :3:src/app.js    # Their version
```

### Fast-Forward Merge

When one branch is directly ahead of another, Git doesn't create a merge commit:

```
Before:  A → B → C (main)
                   \
                    D → E (feature)

After fast-forward:  A → B → C → D → E (main, feature)
```

```bash
# This is a fast-forward (no merge commit needed)
$ git merge feature
Updating 3a2b1c4..7d4e5f6
Fast-forward
 src/app.js | 5 +++++
```

---

## How Rebase Works Internally

### The Rebase Process

Rebase **replays** commits onto a new base, creating **new commit objects** (new SHAs).

```
Before rebase:
    A → B → C (main)
         \
          D → E → F (feature)

After `git rebase main` on feature:
    A → B → C (main)
              \
               D' → E' → F' (feature)
```

**Internal steps:**

1. Find the common ancestor of current branch and target (`git merge-base`).
2. Generate patches for each commit: BASE→D, D→E, E→F.
3. Reset current branch to target (`main`'s tip).
4. Apply each patch sequentially, creating new commits.

```bash
# What rebase does internally (simplified):
$ git merge-base feature main
# → commit B

$ git format-patch B..feature --stdout > /tmp/patches
$ git reset --hard main
$ git am /tmp/patches
# Creates D', E', F' with new SHAs but same diffs
```

### Interactive Rebase Internals

`git rebase -i` uses a **todo file** to script operations:

```bash
$ git rebase -i HEAD~4
# Opens .git/rebase-merge/git-rebase-todo:

pick 1a2b3c4 Add user model
pick 5e6f7a8 Fix typo in model
pick 9b0c1d2 Add user tests
pick 3e4f5a6 Update documentation
```

**Available operations:**
| Command | Effect |
|---------|--------|
| `pick` | Use the commit as-is |
| `reword` | Use commit but edit message |
| `edit` | Pause to amend the commit |
| `squash` | Meld into previous commit (keep message) |
| `fixup` | Meld into previous commit (discard message) |
| `drop` | Remove the commit entirely |
| `exec` | Run a shell command |
| `break` | Pause rebase here |

### Rebase Conflict Resolution

During rebase, conflicts are resolved one commit at a time:

```bash
$ git rebase main
Applying: Add feature X
Using index info to reconstruct a base tree...
Falling back to patching base and 3-way merge...
CONFLICT (content): Merge conflict in src/app.js
error: could not apply 1a2b3c4... Add feature X

# State files during rebase:
$ ls .git/rebase-merge/
done            # Commits already applied
git-rebase-todo # Commits remaining
head-name       # Original branch name
orig-head       # Original HEAD SHA
onto            # The new base commit

# After resolving:
$ git add src/app.js
$ git rebase --continue
Applying: Add feature X
Applying: Add feature Y
Successfully rebased.
```

### Why Rebase Creates New Commits

Since the parent changes, the commit hash **must** change:

```
Original commit D:
  tree: <same>
  parent: B          ← Different!
  author: same
  message: same

Rebased commit D':
  tree: <same or merged>
  parent: C          ← Different!
  author: same
  message: same
```

Even with identical content, a different parent means a different SHA-1.

---

## Transfer Protocols

Git supports multiple protocols for communicating between repositories.

### Smart HTTP Protocol

The most common protocol for hosted services (GitHub, GitLab, etc.).

**Discovery:**
```
GET /repo.git/info/refs?service=git-upload-pack HTTP/1.1

Response:
001e# service=git-upload-pack
00000155 3a2b1c4d... HEAD\0multi_ack thin-pack side-band...
003f 7d4e5f6a... refs/heads/main
003f 9f8e7d6b... refs/heads/develop
0000
```

**Upload (fetch):**
```
POST /repo.git/git-upload-pack HTTP/1.1
Content-Type: application/x-git-upload-pack-request

0054 want 3a2b1c4d... multi_ack_detailed side-band-64k
0032 have 1a2b3c4d...
0000
0009 done

Response: packfile stream
```

**Receive (push):**
```
POST /repo.git/git-receive-pack HTTP/1.1
Content-Type: application/x-git-receive-pack-request

00820000000... 3a2b1c4d... refs/heads/main\0report-status
0000
<packfile data>
```

### Dumb HTTP Protocol

Simple HTTP serving — client does all the work. No server-side Git process.

```bash
# Client fetches info/refs
GET /repo.git/info/refs
# Client fetches objects individually
GET /repo.git/objects/3a/2b1c4d5e6f...
# Client fetches pack index
GET /repo.git/objects/info/packs
GET /repo.git/objects/pack/pack-abc123.idx
GET /repo.git/objects/pack/pack-abc123.pack
```

**Limitations:**
- No negotiation (fetches more data than needed)
- No server-side compression
- Requires `git update-server-info` after each push

### SSH Protocol

Most efficient for private repos — launches `git-upload-pack` or `git-receive-pack` directly.

```bash
# What happens when you run:
$ git push git@github.com:user/repo.git main

# 1. SSH connects and runs:
ssh git@github.com "git-receive-pack 'user/repo.git'"

# 2. Server sends its refs
# 3. Client sends packfile of new objects
# 4. Server updates refs
```

**Protocol comparison:**

| Feature | Smart HTTP | Dumb HTTP | SSH | Git (daemon) |
|---------|-----------|-----------|-----|-------------|
| Authentication | Flexible | Basic/None | Keys | None |
| Firewall-friendly | ✅ (port 443) | ✅ | ⚠️ (port 22) | ❌ (port 9418) |
| Negotiation | ✅ | ❌ | ✅ | ✅ |
| Encryption | TLS | Optional | ✅ | ❌ |
| Performance | Good | Poor | Best | Good |

### Pack Negotiation

During fetch, client and server negotiate what to transfer:

```
Client: "I want commit X"
Client: "I already have commits A, B, C"
Server: "ACK B" (I can compute a delta from B)
Server: <sends minimal packfile with only missing objects>
```

This is why fetching from a repo you already have most of is fast.

---

## Commands to Inspect Internals

### Essential Plumbing Commands

```bash
# ═══════════════════════════════════════════
# git cat-file — Inspect any object
# ═══════════════════════════════════════════

# Show object type
$ git cat-file -t HEAD
commit

# Show object content (pretty-printed)
$ git cat-file -p HEAD
tree 9f8e7d6c5b4a3d2e1f0a9b8c7d6e5f4a3b2c1d0e
parent 1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b
author John Doe <john@example.com> 1710500000 +0000
committer John Doe <john@example.com> 1710500000 +0000

Add user authentication module

# Show object size
$ git cat-file -s HEAD
234

# ═══════════════════════════════════════════
# git ls-tree — Inspect tree objects
# ═══════════════════════════════════════════

# List files at HEAD
$ git ls-tree HEAD
100644 blob 557db03de997c86a4a028e1ebd3a1ceb225be238	README.md
040000 tree 4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f	src
100644 blob a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0	package.json

# Recursive listing
$ git ls-tree -r HEAD --name-only
README.md
package.json
src/app.js
src/auth.js
src/utils.js

# List with sizes
$ git ls-tree -r -l HEAD
100644 blob 557db03... 1234	README.md
100644 blob a1b2c3d...  567	package.json
100644 blob e8f9a0b... 2048	src/app.js

# ═══════════════════════════════════════════
# git ls-files — Inspect the index (staging area)
# ═══════════════════════════════════════════

# Show staged files
$ git ls-files --stage
100644 557db03de997c86a4a028e1ebd3a1ceb225be238 0	README.md
100644 a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0 0	package.json

# Show unmerged (conflicted) files
$ git ls-files -u
100644 aaa... 1	src/app.js
100644 bbb... 2	src/app.js
100644 ccc... 3	src/app.js

# ═══════════════════════════════════════════
# git hash-object — Compute object hash
# ═══════════════════════════════════════════

# Hash content without storing
$ echo "test content" | git hash-object --stdin
d670460b4b4aece5915caf5c68d12f560a9fe3e4

# Hash and write to object database
$ echo "test content" | git hash-object -w --stdin
d670460b4b4aece5915caf5c68d12f560a9fe3e4

# Hash a file
$ git hash-object README.md
557db03de997c86a4a028e1ebd3a1ceb225be238

# ═══════════════════════════════════════════
# git rev-parse — Translate names to SHAs
# ═══════════════════════════════════════════

$ git rev-parse HEAD
3a2b1c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b

$ git rev-parse main~3
9f8e7d6c5b4a3d2e1f0a9b8c7d6e5f4a3b2c1d0e

$ git rev-parse --short HEAD
3a2b1c4

# ═══════════════════════════════════════════
# git for-each-ref — Iterate over refs
# ═══════════════════════════════════════════

$ git for-each-ref --format='%(objectname:short) %(refname:short) %(authordate:relative)' refs/heads/
3a2b1c4 main 2 hours ago
7d4e5f6 develop 1 day ago
9f8e7d6 feature/login 3 days ago

# ═══════════════════════════════════════════
# git fsck — Verify object database integrity
# ═══════════════════════════════════════════

$ git fsck --full
Checking object directories: 100% (256/256), done.
Checking objects: 100% (1542/1542), done.
dangling commit 1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b
dangling blob 557db03de997c86a4a028e1ebd3a1ceb225be238

# ═══════════════════════════════════════════
# git update-ref — Safely update refs
# ═══════════════════════════════════════════

# Move a branch pointer (with safety check)
$ git update-ref refs/heads/main 7d4e5f6a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e

# Delete a ref
$ git update-ref -d refs/heads/old-branch

# ═══════════════════════════════════════════
# git diff-tree — Compare two tree objects
# ═══════════════════════════════════════════

$ git diff-tree --stat HEAD~1 HEAD
 src/app.js   | 5 +++--
 src/auth.js  | 12 ++++++++++++
 2 files changed, 15 insertions(+), 2 deletions(-)
```

### Practical Investigation Workflows

```bash
# "What exactly is in this commit?"
$ git cat-file -p abc1234              # See commit metadata
$ git ls-tree -r abc1234^{tree}       # See full file listing at that commit
$ git diff-tree -p abc1234            # See the diff introduced

# "How big is my repo really?"
$ git count-objects -vH
count: 48
size: 192.00 KiB
in-pack: 1542
packs: 1
size-pack: 2.00 MiB

# "What's dangling/unreachable?"
$ git fsck --unreachable --no-reflogs
unreachable commit abc1234...    # Can be recovered!
unreachable blob def5678...      # Orphaned content

# "Trace the ancestry of a commit"
$ git rev-list --ancestry-path main..feature
7d4e5f6a...
3a2b1c4d...
9f8e7d6c...

# "Show the merge base between two branches"
$ git merge-base --all main feature
1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b
```

---

## Summary: The Big Picture

```
┌─────────────────────────────────────────────────────────────────┐
│                        WORKING DIRECTORY                         │
│  (Your actual files on disk)                                    │
└──────────────────────────────┬──────────────────────────────────┘
                               │ git add
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                    INDEX / STAGING AREA                          │
│  (.git/index — binary file mapping paths to blob SHAs)          │
└──────────────────────────────┬──────────────────────────────────┘
                               │ git commit
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                     OBJECT DATABASE                              │
│  (.git/objects/ — blobs, trees, commits, tags)                  │
│                                                                 │
│  commit → tree → blobs (content)                                │
│    ↓                                                            │
│  parent commit → tree → blobs                                   │
└──────────────────────────────┬──────────────────────────────────┘
                               │ git push / git fetch
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                        REMOTE                                    │
│  (Same object database structure on another machine)            │
└─────────────────────────────────────────────────────────────────┘
```

### Key Takeaways

1. **Git stores snapshots, not diffs** — each commit points to a complete tree.
2. **Branches are cheap** — just 41-byte files containing a SHA.
3. **Everything is an object** — addressable by its SHA-1 hash.
4. **The reflog saves you** — it records every ref movement for ~90 days.
5. **Packfiles optimize storage** — delta compression between similar objects.
6. **The index is the "next commit"** — it sits between working tree and objects.
7. **Git never deletes immediately** — unreachable objects survive for 2 weeks (gc.pruneExpire).

---

*Last updated: June 2026*
