[📖 README](README.md) | [🌳 Branching](git-branching.md) | [⚡ Commands](git-commands-cheatsheet.md) | [🔧 Internals](git-internals.md) | [🤝 Workflows](git-workflows.md) | [🚀 Advanced](git-advanced.md) | [🌐 GitHub/GitLab](github-gitlab-guide.md) | [🔥 Troubleshooting](git-troubleshooting.md) | [💼 Interview Prep](git-interview-questions.md) | [🔒 Security](git-security.md)

---

# 🔒 Git Security Guide

> A production-grade guide to securing your Git workflow — from SSH keys to secret scanning to branch protection.

---

## Table of Contents

1. [SSH Key Setup](#1-ssh-key-setup)
2. [GPG Signed Commits](#2-gpg-signed-commits)
3. [Credential Management](#3-credential-management)
4. [Secret Scanning](#4-secret-scanning)
5. [Removing Secrets from History](#5-removing-secrets-from-history)
6. [Branch Protection](#6-branch-protection)
7. [GitHub Security Features](#7-github-security-features)
8. [.gitignore for Security](#8-gitignore-for-security)
9. [Secure Collaboration](#9-secure-collaboration)
10. [Security Checklist](#10-security-checklist)

---

## 1. SSH Key Setup

SSH keys provide passwordless, encrypted authentication to remote Git hosts.

### Generate an Ed25519 Key

Ed25519 is the modern standard — faster and more secure than RSA.

```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
```

**Expected output:**
```
Generating public/private ed25519 key pair.
Enter file in which to save the key (/c/Users/you/.ssh/id_ed25519):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /c/Users/you/.ssh/id_ed25519
Your public key has been saved in /c/Users/you/.ssh/id_ed25519.pub
The key fingerprint is:
SHA256:AbCdEfGhIjKlMnOpQrStUvWxYz your.email@example.com
```

> ⚠️ **Always set a passphrase** — it protects your key if someone gains access to your filesystem.

### Add Key to SSH Agent

**Linux/macOS:**
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

**Windows (PowerShell as Admin):**
```powershell
# Start the ssh-agent service
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent

# Add your key
ssh-add $env:USERPROFILE\.ssh\id_ed25519
```

### Add Public Key to GitHub/GitLab

```bash
# Copy your public key
cat ~/.ssh/id_ed25519.pub
# Windows: type %USERPROFILE%\.ssh\id_ed25519.pub
```

- **GitHub:** Settings → SSH and GPG keys → New SSH key → Paste
- **GitLab:** Preferences → SSH Keys → Add key → Paste

### Test the Connection

```bash
ssh -T git@github.com
```

**Expected output:**
```
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

```bash
ssh -T git@gitlab.com
```

**Expected output:**
```
Welcome to GitLab, @username!
```

### Multiple Keys Configuration

When you have separate keys for GitHub, GitLab, and work servers, configure `~/.ssh/config`:

```ssh-config
# Personal GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes

# Work GitHub Enterprise
Host github-work
    HostName github.company.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes

# GitLab
Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519_gitlab
    IdentitiesOnly yes
```

**Usage with work host:**
```bash
git clone git@github-work:org/repo.git
```

### Real-World Example: Rotating an SSH Key

```bash
# Generate new key
ssh-keygen -t ed25519 -C "new-key-2026@example.com" -f ~/.ssh/id_ed25519_new

# Add new public key to GitHub (keep old one temporarily)
cat ~/.ssh/id_ed25519_new.pub
# Add via GitHub UI

# Update SSH config to use new key
# Test connection
ssh -T git@github.com

# Remove old key from GitHub UI
# Delete old key locally
rm ~/.ssh/id_ed25519_old ~/.ssh/id_ed25519_old.pub
```

---

## 2. GPG Signed Commits

Signed commits prove that a commit was actually made by you, not someone impersonating your email.

### Generate a GPG Key

```bash
gpg --full-generate-key
```

**Selections:**
- Kind: `(1) RSA and RSA`
- Size: `4096`
- Expiry: `1y` (recommended — rotate annually)
- Real name: Your Name
- Email: your.email@example.com (must match your Git email)

### List Your Keys

```bash
gpg --list-secret-keys --keyid-format=long
```

**Expected output:**
```
/home/user/.gnupg/pubring.kbx
-----------------------------
sec   rsa4096/3AA5C34371567BD2 2026-06-17 [SC] [expires: 2027-06-17]
      1234567890ABCDEF1234567890ABCDEF12345678
uid                 [ultimate] Your Name <your.email@example.com>
ssb   rsa4096/42B317FD4BA89E7A 2026-06-17 [E] [expires: 2027-06-17]
```

The key ID is `3AA5C34371567BD2` (the part after `rsa4096/`).

### Configure Git to Use Your GPG Key

```bash
git config --global user.signingkey 3AA5C34371567BD2
git config --global commit.gpgsign true    # Auto-sign all commits
git config --global tag.gpgSign true       # Auto-sign all tags
```

**Windows — specify GPG path:**
```bash
git config --global gpg.program "C:/Program Files (x86)/GnuPG/bin/gpg.exe"
```

### Sign a Commit

```bash
git commit -S -m "feat: add authentication module"
```

### Verify Signed Commits

```bash
git log --show-signature -1
```

**Expected output:**
```
commit abc123def456...
gpg: Signature made Wed Jun 17 13:00:00 2026
gpg:                using RSA key 1234567890ABCDEF1234567890ABCDEF12345678
gpg: Good signature from "Your Name <your.email@example.com>" [ultimate]
Author: Your Name <your.email@example.com>
Date:   Wed Jun 17 13:00:00 2026

    feat: add authentication module
```

### Add GPG Key to GitHub

```bash
# Export your public key
gpg --armor --export 3AA5C34371567BD2
```

Paste the output (including `-----BEGIN PGP PUBLIC KEY BLOCK-----`) into:
GitHub → Settings → SSH and GPG keys → New GPG key

### Enable Vigilant Mode (GitHub)

Settings → SSH and GPG keys → Enable **"Flag unsigned commits as unverified"**

This marks all unsigned commits with a yellow "Unverified" badge.

---

## 3. Credential Management

### credential.helper Options

| Helper | Storage | Security | Platform |
|--------|---------|----------|----------|
| `cache` | Memory (timeout) | Good | Linux/macOS |
| `store` | Plain text file | ⚠️ Poor | Any |
| `manager` | OS keychain | ✅ Best | Windows/macOS |

**Configure credential caching (Linux):**
```bash
# Cache for 1 hour (3600 seconds)
git config --global credential.helper 'cache --timeout=3600'
```

**Configure Git Credential Manager (Windows/macOS):**
```bash
git config --global credential.helper manager
```

**Never use `store` in production:**
```bash
# ⚠️ This saves passwords in PLAIN TEXT at ~/.git-credentials
git config --global credential.helper store
# Only acceptable for local-only development VMs
```

### Personal Access Tokens (PATs) vs SSH

| Aspect | PAT | SSH |
|--------|-----|-----|
| Protocol | HTTPS | SSH |
| Scope control | ✅ Fine-grained | ❌ Full access |
| Expiry | ✅ Configurable | ❌ Manual rotation |
| Multiple services | Separate tokens | Separate keys |
| CI/CD | ✅ Preferred | Possible |
| Firewall-friendly | ✅ Port 443 | Port 22 may be blocked |

### Creating a Fine-Grained PAT (GitHub)

Settings → Developer settings → Personal access tokens → Fine-grained tokens → Generate

**Recommended scopes for daily work:**
- `repo` — Full repository access
- `read:org` — Read org membership

**For CI/CD, use minimal scopes:**
- `contents: read` — Clone only
- `contents: write` — Push access

### Token Rotation Best Practice

```bash
# Check current credential
git credential-manager get <<EOF
protocol=https
host=github.com
EOF

# Remove stored credential
git credential-manager erase <<EOF
protocol=https
host=github.com
EOF

# Next git operation will prompt for new token
git fetch origin
```

**Rotation schedule:**
- PATs: Every 90 days (set expiry at creation)
- SSH keys: Annually
- Deploy keys: Per release cycle



---

## 4. Secret Scanning

### What Happens When You Commit Secrets

```
Developer commits AWS key → Pushes to GitHub → Bot scrapes public repos within seconds
                                              → Key is compromised in < 5 minutes
                                              → Attacker spins up crypto miners
                                              → $50,000 AWS bill arrives
```

**This is not hypothetical.** GitHub reports that over 100,000 secrets are leaked in public repos every year.

Even in private repos, secrets in Git history are:
- Visible to all collaborators (current and future)
- Included in every clone
- Persistent even after the file is deleted (still in history)

### Tool 1: git-secrets (AWS Labs)

Prevents committing AWS credentials and configurable patterns.

**Installation:**
```bash
# Windows (via installer or chocolatey)
choco install git-secrets

# macOS
brew install git-secrets

# Linux (from source)
git clone https://github.com/awslabs/git-secrets.git
cd git-secrets && make install
```

**Setup in a repo:**
```bash
cd your-repo
git secrets --install
git secrets --register-aws
```

**Add custom patterns:**
```bash
# Block any string starting with "sk-" (OpenAI keys)
git secrets --add 'sk-[a-zA-Z0-9]{48}'

# Block generic private keys
git secrets --add '-----BEGIN.*PRIVATE KEY-----'

# Block connection strings
git secrets --add 'mongodb\+srv://[^@]+@'
```

**Test before committing:**
```bash
git secrets --scan
```

**Expected output (violation found):**
```
src/config.js:3:  const API_KEY = "AKIAIOSFODNN7EXAMPLE"

[ERROR] Matched one or more prohibited patterns
```

### Tool 2: TruffleHog

Deep scanning of entire Git history for high-entropy strings and known patterns.

```bash
# Install
pip install trufflehog

# Scan entire repo history
trufflehog git file://. --since-commit HEAD~50

# Scan a remote repo
trufflehog git https://github.com/org/repo.git --only-verified
```

**Expected output:**
```
Found verified result 🐷🔑
Detector Type: AWS
Raw result: AKIAIOSFODNN7EXAMPLE
File: src/config/aws.js
Commit: a1b2c3d
Email: developer@company.com
```

### Tool 3: Gitleaks

Fast, configurable secret scanner with CI/CD integration.

```bash
# Install
# Windows
choco install gitleaks

# macOS
brew install gitleaks

# Scan current state
gitleaks detect --source .

# Scan entire history
gitleaks detect --source . --log-opts="--all"

# Generate report
gitleaks detect --source . --report-format json --report-path gitleaks-report.json
```

**Expected output:**
```
Finding:     AKIAIOSFODNN7EXAMPLE
Secret:      AKIAIOSFODNN7EXAMPLE
RuleID:      aws-access-key-id
Entropy:     3.52
File:        config/settings.py
Line:        14
Commit:      abc123def
Author:      Dev Name
Date:        2026-06-15
```

### Pre-commit Hook Prevention

**Using pre-commit framework:**

Create `.pre-commit-config.yaml`:
```yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks

  - repo: https://github.com/awslabs/git-secrets
    rev: master
    hooks:
      - id: git-secrets
```

```bash
pip install pre-commit
pre-commit install
```

**Manual pre-commit hook (`.git/hooks/pre-commit`):**
```bash
#!/bin/bash
# Scan staged files for secrets before allowing commit

if gitleaks protect --staged --no-banner 2>/dev/null; then
    exit 0
else
    echo "❌ SECRET DETECTED! Commit blocked."
    echo "Run 'gitleaks protect --staged' for details."
    echo "If false positive, use: git commit --no-verify"
    exit 1
fi
```

```bash
chmod +x .git/hooks/pre-commit
```

---

## 5. Removing Secrets from History

> ⚠️ **WARNING:** Rewriting history is destructive. All collaborators must re-clone after this operation.

### Option 1: git filter-repo (Recommended)

The modern replacement for `git filter-branch`. Faster and safer.

```bash
# Install
pip install git-filter-repo

# Remove a specific file from ALL history
git filter-repo --invert-paths --path config/secrets.yml

# Remove a specific string from all files in history
git filter-repo --replace-text <(echo 'AKIAIOSFODNN7EXAMPLE==>REMOVED')
```

**Using an expressions file for multiple secrets:**

Create `replacements.txt`:
```
AKIAIOSFODNN7EXAMPLE==>***REMOVED_AWS_KEY***
sk-abc123def456ghi789==>***REMOVED_OPENAI_KEY***
mongodb+srv://admin:password123@cluster.mongodb.net==>***REMOVED_CONNECTION_STRING***
```

```bash
git filter-repo --replace-text replacements.txt
```

**Expected output:**
```
Parsed 847 commits
New history written in 2.31 seconds; now repacking/cleaning...
Repacking your repo and cleaning out old unneeded objects
Enumerating objects: 2341, done.
Completely finished after 4.12 seconds.
```

### Option 2: BFG Repo-Cleaner

Simpler interface, specifically designed for removing secrets.

```bash
# Download BFG
# https://rtyley.github.io/bfg-repo-cleaner/

# Remove a file by name from history (keeps current version)
java -jar bfg.jar --delete-files secrets.yml

# Replace text in all history
java -jar bfg.jar --replace-text passwords.txt

# Remove files larger than 100M
java -jar bfg.jar --strip-blobs-bigger-than 100M
```

**After BFG/filter-repo, clean up:**
```bash
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

### Force Push Considerations

After rewriting history, you must force push:

```bash
git push origin --force --all
git push origin --force --tags
```

**⚠️ Critical steps after force push:**

1. **Notify all collaborators immediately**
2. All collaborators must:
   ```bash
   # Option A: Fresh clone (safest)
   rm -rf repo && git clone <url>

   # Option B: Reset to remote
   git fetch origin
   git reset --hard origin/main
   ```
3. **Invalidate the exposed credential** — rewriting history does NOT unexpose it
4. **GitHub cached views** — contact GitHub support to purge cached PR diffs
5. **Forks** — secrets may persist in forks you don't control

### Real-World Incident Response Playbook

```
1. IMMEDIATELY rotate the exposed credential
2. Check CloudTrail/audit logs for unauthorized usage
3. Remove from history using git filter-repo
4. Force push to all branches
5. Notify team to re-clone
6. Contact GitHub support if repo was ever public
7. Add detection rule to prevent recurrence
8. Post-mortem: document what happened
```



---

## 6. Branch Protection

Branch protection rules prevent accidental or malicious changes to critical branches.

### GitHub Branch Protection Setup

**Navigate to:** Repository → Settings → Branches → Add rule

**Pattern:** `main` (or `release/*` for wildcards)

### Required Pull Request Reviews

```
✅ Require a pull request before merging
   ✅ Required approving reviews: 2
   ✅ Dismiss stale pull request approvals when new commits are pushed
   ✅ Require review from code owners
```

**CODEOWNERS file (`.github/CODEOWNERS`):**
```
# Default owner for everything
*       @team-lead

# Security-sensitive files require security team
*.env*              @security-team
**/auth/**          @security-team
**/credentials/**   @security-team
Dockerfile          @devops-team @security-team
.github/workflows/* @devops-team
```

### Required Status Checks

```
✅ Require status checks to pass before merging
   ✅ Require branches to be up to date before merging
   Status checks:
   - ci/build
   - ci/test
   - security/gitleaks
   - security/snyk
```

### Require Signed Commits

```
✅ Require signed commits
```

This ensures every commit in a PR has a verified GPG or SSH signature.

### Restrict Force Pushes

```
✅ Do not allow force pushes
✅ Do not allow deletions
```

### Lock Branch (GitHub)

```
✅ Lock branch — branch is read-only, no pushes allowed
```

Use for `release/v*` branches after release.

### GitLab Protected Branches

```bash
# Via GitLab UI:
# Settings → Repository → Protected branches

# Allowed to merge: Maintainers
# Allowed to push: No one
# Allowed to force push: ❌
```

**GitLab Push Rules (additional):**
```
✅ Reject unsigned commits
✅ Check whether the commit author is a GitLab user
✅ Prevent pushing secret files
   File name pattern: (\.env|\.pem|id_rsa|.*\.key)$
```

### Branch Protection via GitHub API

```bash
# Set protection on main branch
curl -X PUT \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/OWNER/REPO/branches/main/protection \
  -d '{
    "required_status_checks": {
      "strict": true,
      "contexts": ["ci/build", "ci/test", "security/scan"]
    },
    "enforce_admins": true,
    "required_pull_request_reviews": {
      "required_approving_review_count": 2,
      "dismiss_stale_reviews": true,
      "require_code_owner_reviews": true
    },
    "restrictions": null,
    "required_linear_history": true,
    "allow_force_pushes": false,
    "allow_deletions": false
  }'
```

### Rulesets (GitHub — newer feature)

Rulesets are more flexible than branch protection rules and can target tags too:

```
Repository → Settings → Rules → Rulesets → New ruleset

Target: branches matching "main", "release/*"
Rules:
  - Restrict creations
  - Restrict deletions
  - Block force pushes
  - Require pull request (2 approvals)
  - Require status checks
  - Require signed commits
```

---

## 7. GitHub Security Features

### Dependabot

Automatically detects vulnerable dependencies and creates update PRs.

**Enable:** Repository → Settings → Code security and analysis → Dependabot

**Configuration (`.github/dependabot.yml`):**
```yaml
version: 2
updates:
  # npm dependencies
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
    open-pull-requests-limit: 10
    reviewers:
      - "security-team"
    labels:
      - "dependencies"
      - "security"

  # GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"

  # Docker
  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"

  # Python
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "daily"
```

**Dependabot alerts output example:**
```
⚠️ Critical vulnerability in lodash < 4.17.21
  CVE-2021-23337 — Command Injection
  Severity: Critical (CVSS 9.8)
  Fix: Upgrade to lodash >= 4.17.21
  
  [Dismiss] [Create PR] [View advisory]
```

### Secret Scanning

GitHub automatically scans for 200+ secret patterns from partners.

**Enable:** Settings → Code security → Secret scanning → Enable

**Push Protection (blocks push if secret detected):**
```
Settings → Code security → Secret scanning → Push protection → Enable
```

**When a developer tries to push a secret:**
```
remote: ——— GitHub Personal Access Token ———
remote: locations:
remote:   - commit: abc123d
remote:     path: src/config.js:5
remote: 
remote: To push, you must either:
remote:   1. Remove the secret from your commits
remote:   2. Use a bypass (requires justification)
```

**Custom secret scanning patterns:**
```
Settings → Code security → Secret scanning → Custom patterns

Name: Internal API Key
Pattern: INTERNAL-[A-Z0-9]{32}
Before: (api_key|apikey|API_KEY)\s*[:=]\s*["']?
After: ["']?\s*[;,\n]
```

### Code Scanning (CodeQL)

Static analysis that finds security vulnerabilities in your code.

**Enable via workflow (`.github/workflows/codeql.yml`):**
```yaml
name: "CodeQL Analysis"

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 6 * * 1'  # Weekly Monday 6 AM

jobs:
  analyze:
    name: Analyze
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
      security-events: write

    strategy:
      matrix:
        language: ['javascript', 'python']

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Initialize CodeQL
        uses: github/codeql-action/init@v3
        with:
          languages: ${{ matrix.language }}
          queries: +security-extended,security-and-quality

      - name: Autobuild
        uses: github/codeql-action/autobuild@v3

      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v3
```

**Example CodeQL finding:**
```
⚠️ SQL Injection vulnerability
  File: src/api/users.js:42
  
  const query = "SELECT * FROM users WHERE id = " + req.params.id;
  
  Recommendation: Use parameterized queries
  Severity: Critical
  CWE: CWE-89
```

### Security Advisories

For maintainers to privately discuss, fix, and disclose vulnerabilities.

```
Repository → Security → Advisories → New draft advisory

Fields:
  - Ecosystem: npm
  - Package: your-package
  - Affected versions: < 2.1.0
  - Patched versions: >= 2.1.0
  - Severity: High
  - CWE: CWE-79 (Cross-site Scripting)
  - CVE: (request one or enter existing)
  - Description: ...
```

**Workflow:**
1. Create private advisory
2. Create private fork for fix
3. Develop and test patch
4. Publish advisory (notifies dependents)
5. CVE is registered automatically



---

## 8. .gitignore for Security

### Files You Should NEVER Commit

```gitignore
# ============================================
# SECURITY-CRITICAL .gitignore
# ============================================

# ---- Environment & Config ----
.env
.env.*
.env.local
.env.production
.env.staging
*.env

# ---- Private Keys & Certificates ----
*.pem
*.key
*.p12
*.pfx
*.crt
*.cer
*.der
id_rsa
id_rsa.*
id_ed25519
id_ed25519.*
*.pub  # Be cautious — sometimes okay, but safer to exclude

# ---- Credentials & Secrets ----
credentials.json
service-account*.json
*-credentials.json
*.keystore
*.jks
token.json
.htpasswd
.netrc
.pgpass

# ---- Cloud Provider ----
.aws/credentials
.aws/config
gcp-key.json
azure-credentials.json
terraform.tfvars
*.auto.tfvars
terraform.tfstate
terraform.tfstate.backup

# ---- Application Secrets ----
config/secrets.yml
config/master.key
config/credentials.yml.enc  # Rails — debatable, key must never be committed
secret.yaml
secrets/

# ---- IDE & OS (may contain paths/tokens) ----
.idea/
.vscode/settings.json  # May contain tokens
*.swp
.DS_Store
Thumbs.db

# ---- Dependency Lockfiles with Integrity ----
# (These are fine to commit, but watch for embedded tokens)
# Check for registry tokens in .npmrc, .yarnrc
.npmrc  # Often contains auth tokens!
.yarnrc.yml  # May contain npmAuthToken

# ---- Database ----
*.sql
*.sqlite
*.sqlite3
*.db
dump.rdb

# ---- Logs (may contain secrets in debug mode) ----
*.log
logs/
```

### Verify Nothing Sensitive Is Tracked

```bash
# Check if any sensitive files are already tracked
git ls-files | grep -iE '\.(env|pem|key|p12|pfx)$'
git ls-files | grep -iE '(credential|secret|token|password)'
```

**If a file is already tracked:**
```bash
# Remove from tracking WITHOUT deleting the file
git rm --cached .env
git rm --cached config/secrets.yml

# Add to .gitignore
echo ".env" >> .gitignore

# Commit the removal
git commit -m "security: remove tracked secrets, add to .gitignore"
```

> ⚠️ The file is still in history! See [Section 5](#5-removing-secrets-from-history) to purge it.

### Global .gitignore (Personal Machine)

```bash
git config --global core.excludesfile ~/.gitignore_global
```

**`~/.gitignore_global`:**
```gitignore
# Never let these slip in from any repo
.env
*.pem
*.key
id_rsa*
id_ed25519*
.aws/credentials
```

### Real-World .gitignore Audit Script

```bash
#!/bin/bash
# audit-gitignore.sh — Check for common security gaps

echo "🔍 Scanning for potentially sensitive tracked files..."

PATTERNS=(
    '\.env'
    '\.pem$'
    '\.key$'
    'credentials'
    'secret'
    'password'
    'token'
    '\.p12$'
    '\.pfx$'
    'id_rsa'
    '\.npmrc'
)

for pattern in "${PATTERNS[@]}"; do
    matches=$(git ls-files | grep -iE "$pattern")
    if [ -n "$matches" ]; then
        echo "⚠️  POTENTIAL SECRET: $matches"
    fi
done

echo "✅ Audit complete."
```

---

## 9. Secure Collaboration

### Verifying Commits

Check if a commit is legitimately signed:

```bash
# Verify a specific commit
git verify-commit HEAD
git verify-commit abc123

# Verify a tag
git verify-tag v1.0.0

# Show verification in log
git log --show-signature --oneline -5
```

**Expected output (good signature):**
```
gpg: Signature made Wed Jun 17 13:00:00 2026
gpg: Good signature from "Developer Name <dev@company.com>" [full]
```

**Expected output (bad/missing signature):**
```
error: no signature found
# or
gpg: BAD signature from "Someone <fake@evil.com>"
```

### Enforce Signature Verification in CI

**GitHub Actions workflow:**
```yaml
name: Verify Commit Signatures
on: [pull_request]

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Verify all commits are signed
        run: |
          unsigned=$(git log origin/main..HEAD --format='%H %G?' | grep -v ' G$' | grep -v ' U$')
          if [ -n "$unsigned" ]; then
            echo "❌ Unsigned commits found:"
            echo "$unsigned"
            exit 1
          fi
          echo "✅ All commits are signed"
```

### Audit Log (GitHub)

**Organization audit log:**
```
Organization → Settings → Audit log

Filter examples:
  action:repo.create                    # New repos
  action:org.invite_member              # New members
  action:protected_branch.policy_override  # Protection bypasses
  action:repo.access                    # Permission changes
  actor:username                        # Actions by specific user
```

**Export via API:**
```bash
curl -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/orgs/YOUR-ORG/audit-log?phrase=action:repo.destroy" \
  | jq '.[] | {actor: .actor, action: .action, repo: .repo, created_at: .created_at}'
```

**GitLab audit events:**
```
Group → Security & Compliance → Audit Events

Filter by:
  - Member added/removed
  - Permission changes
  - Branch protection changes
  - Repository visibility changes
```

### 2FA Enforcement

**GitHub Organization:**
```
Organization → Settings → Authentication security
  ✅ Require two-factor authentication for everyone in the organization
```

**Effect:** Members without 2FA are removed from the org after a grace period.

**Check 2FA status via API:**
```bash
# List members WITHOUT 2FA
curl -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/orgs/YOUR-ORG/members?filter=2fa_disabled" \
  | jq '.[].login'
```

**GitLab:**
```
Group → Settings → General → Permissions
  ✅ Require all users in this group to set up two-factor authentication
  Grace period: 48 hours
```

### Secure Forking Policy

```
Organization → Settings → Member privileges
  ❌ Allow forking of private repositories
```

Prevents secrets from propagating to personal forks outside org control.

### Deploy Keys vs. Machine Users

| Method | Scope | Use Case |
|--------|-------|----------|
| Deploy Key | Single repo | CI reads one repo |
| Machine User | Multiple repos | CI needs cross-repo access |
| GitHub App | Org-wide, scoped | Production automation |

**Deploy key (read-only, preferred for CI):**
```bash
# Generate a dedicated key
ssh-keygen -t ed25519 -C "deploy-key-repo-ci" -f ./deploy_key -N ""

# Add public key to repo: Settings → Deploy keys → Add
# ❌ Do NOT check "Allow write access" unless required
```

---

## 10. Security Checklist

### Quick Reference Table

| Category | Check | Priority | Status |
|----------|-------|----------|--------|
| **Authentication** | SSH keys use Ed25519 | 🔴 High | ☐ |
| | SSH keys have passphrases | 🔴 High | ☐ |
| | 2FA enabled on GitHub/GitLab | 🔴 High | ☐ |
| | PATs have expiry dates | 🔴 High | ☐ |
| | PATs use minimal scopes | 🟡 Medium | ☐ |
| **Commits** | GPG signing configured | 🟡 Medium | ☐ |
| | Auto-sign enabled (`commit.gpgsign true`) | 🟡 Medium | ☐ |
| | Vigilant mode on GitHub | 🟢 Low | ☐ |
| **Secrets** | `.env` in `.gitignore` | 🔴 High | ☐ |
| | Pre-commit secret scanning | 🔴 High | ☐ |
| | No secrets in repo history | 🔴 High | ☐ |
| | CI secret scanning (gitleaks/trufflehog) | 🔴 High | ☐ |
| | GitHub push protection enabled | 🟡 Medium | ☐ |
| **Branch Protection** | Main branch protected | 🔴 High | ☐ |
| | Required reviews (≥2) | 🔴 High | ☐ |
| | Status checks required | 🔴 High | ☐ |
| | Force push disabled | 🔴 High | ☐ |
| | CODEOWNERS configured | 🟡 Medium | ☐ |
| **Dependencies** | Dependabot enabled | 🔴 High | ☐ |
| | Auto-merge for patch updates | 🟡 Medium | ☐ |
| | Lock file committed | 🟡 Medium | ☐ |
| **Monitoring** | Code scanning (CodeQL) enabled | 🟡 Medium | ☐ |
| | Audit log monitored | 🟡 Medium | ☐ |
| | Security advisories watched | 🟢 Low | ☐ |
| **Org Policy** | 2FA enforced for org | 🔴 High | ☐ |
| | Private fork disabled | 🟡 Medium | ☐ |
| | Base permissions = Read | 🟡 Medium | ☐ |
| | SSO/SAML configured | 🟢 Low | ☐ |

### New Repository Security Setup Script

```bash
#!/bin/bash
# secure-repo-init.sh — Apply security best practices to a new repo

set -e

echo "🔒 Securing repository..."

# 1. Create comprehensive .gitignore
cat >> .gitignore << 'EOF'
.env
.env.*
*.pem
*.key
*.p12
*.pfx
credentials.json
service-account*.json
terraform.tfvars
terraform.tfstate*
.npmrc
EOF

# 2. Install git-secrets
git secrets --install
git secrets --register-aws
git secrets --add 'sk-[a-zA-Z0-9]{48}'
git secrets --add '-----BEGIN.*PRIVATE KEY-----'

# 3. Create pre-commit hook for gitleaks
cat > .git/hooks/pre-commit << 'HOOK'
#!/bin/bash
if command -v gitleaks &> /dev/null; then
    gitleaks protect --staged --no-banner
    if [ $? -ne 0 ]; then
        echo "❌ Secret detected! Commit blocked."
        exit 1
    fi
fi
HOOK
chmod +x .git/hooks/pre-commit

# 4. Configure signed commits
git config commit.gpgsign true

# 5. Create CODEOWNERS
mkdir -p .github
cat > .github/CODEOWNERS << 'EOF'
* @default-team
*.env* @security-team
**/auth/** @security-team
Dockerfile @devops-team
.github/workflows/* @devops-team
EOF

echo "✅ Repository secured!"
echo ""
echo "Next steps:"
echo "  1. Add branch protection rules via GitHub UI"
echo "  2. Enable Dependabot and secret scanning"
echo "  3. Set up CodeQL workflow"
echo "  4. Configure .github/dependabot.yml"
```

### Security Audit One-Liner

```bash
# Run all checks quickly
echo "=== Git Security Audit ===" && \
echo "Signing: $(git config commit.gpgsign || echo 'NOT SET ⚠️')" && \
echo "GPG Key: $(git config user.signingkey || echo 'NOT SET ⚠️')" && \
echo "Credential helper: $(git config credential.helper || echo 'NOT SET ⚠️')" && \
echo "Tracked secrets:" && \
git ls-files | grep -iE '\.(env|pem|key|p12)$' || echo "  None found ✅" && \
echo "Hooks installed:" && \
ls .git/hooks/pre-commit 2>/dev/null && echo "  pre-commit ✅" || echo "  pre-commit MISSING ⚠️"
```

---

## Summary

| Threat | Mitigation | Tool/Command |
|--------|-----------|--------------|
| Unauthorized access | SSH + 2FA | `ssh-keygen -t ed25519` |
| Impersonation | GPG signed commits | `git commit -S` |
| Credential theft | Credential manager + rotation | `credential.helper manager` |
| Secret exposure | Pre-commit scanning | `gitleaks`, `git-secrets` |
| Secrets in history | History rewriting | `git filter-repo` |
| Unauthorized changes | Branch protection | GitHub/GitLab settings |
| Vulnerable deps | Automated scanning | Dependabot, Snyk |
| Insider threats | Audit logs + RBAC | Org audit log |

---

> **Remember:** Security is layers. No single control is sufficient. Implement defense in depth — from your local machine to your CI/CD pipeline to your hosting platform.

---

*Last updated: June 2026*
