[📖 README](README.md) | [🌳 Branching](git-branching.md) | [⚡ Commands](git-commands-cheatsheet.md) | [🔧 Internals](git-internals.md) | [🤝 Workflows](git-workflows.md) | [🚀 Advanced](git-advanced.md) | [🌐 GitHub/GitLab](github-gitlab-guide.md) | [🔥 Troubleshooting](git-troubleshooting.md) | [💼 Interview Prep](git-interview-questions.md)

---

# 🤝 Git Workflows — Team Collaboration Patterns

## Table of Contents

1. [Solo Developer Workflow](#solo-developer)
2. [Small Team Workflow](#small-team)
3. [Open Source Contribution Workflow](#open-source)
4. [Enterprise Workflow](#enterprise)
5. [Feature Flags Workflow](#feature-flags)
6. [Release Management](#release-management)
7. [Hotfix Workflow](#hotfix)
8. [Code Review Best Practices](#code-review)
9. [PR Templates](#pr-templates)
10. [Branch Protection Rules](#branch-protection)
11. [CODEOWNERS File](#codeowners)

---

## Solo Developer Workflow <a name="solo-developer"></a>

Even when working alone, using branches keeps your history clean and makes it easy to experiment without risk.

### The Pattern

```
main (stable, deployable)
 ├── feature/new-page
 ├── experiment/try-new-db
 └── fix/broken-css
```

### Step-by-Step

```bash
# 1. Start on main, always pull latest
$ git checkout main
$ git pull origin main

# 2. Create a feature branch
$ git switch -c feature/add-blog
Switched to a new branch 'feature/add-blog'

# 3. Work and commit frequently
$ git add src/blog.js
$ git commit -m "Add blog post component"

$ git add src/blog.css
$ git commit -m "Style blog layout"

# 4. When feature is done, merge to main
$ git checkout main
$ git merge --no-ff feature/add-blog
Merge made by the 'ort' strategy.

# 5. Push and clean up
$ git push origin main
$ git branch -d feature/add-blog
Deleted branch feature/add-blog (was a1b2c3d).

# 6. Tag releases
$ git tag -a v1.3.0 -m "Add blog feature"
$ git push origin v1.3.0
```

### Tips for Solo Developers

- Use `--no-ff` merges to preserve feature history
- Tag every deployment/release
- Use branches even for small experiments (they're free!)
- Squash messy commits before merging: `git rebase -i HEAD~5`

---

## Small Team Workflow <a name="small-team"></a>

For teams of 2-8 developers using GitHub/GitLab with Pull Requests.

### The Pattern

```
main (protected, auto-deploys to production)
 │
 ├── feature/user-auth (Alice)
 ├── feature/dashboard (Bob)
 ├── bugfix/login-error (Charlie)
 └── chore/update-deps (Alice)
```

### Step-by-Step

```bash
# === Developer Alice starts a feature ===

# 1. Sync with remote
$ git checkout main
$ git pull origin main

# 2. Create feature branch
$ git switch -c feature/user-auth
Switched to a new branch 'feature/user-auth'

# 3. Develop with meaningful commits
$ git add .
$ git commit -m "feat: add user registration endpoint"
$ git add .
$ git commit -m "feat: add login with JWT tokens"
$ git add .
$ git commit -m "test: add auth integration tests"

# 4. Stay updated with main (rebase preferred)
$ git fetch origin
$ git rebase origin/main
Successfully rebased and updated refs/heads/feature/user-auth.

# 5. Push feature branch
$ git push -u origin feature/user-auth

# 6. Create Pull Request
$ gh pr create \
    --title "feat: Add user authentication" \
    --body "Implements registration and JWT login" \
    --reviewer bob,charlie

# === Bob reviews the PR ===

# 7. Bob checks out the PR locally (optional)
$ gh pr checkout 42
Switched to branch 'feature/user-auth'

# 8. After approval, Alice merges (squash merge)
$ gh pr merge 42 --squash --delete-branch
✓ Squashed and merged pull request #42

# === Everyone syncs ===
# 9. Team members update their local main
$ git checkout main
$ git pull origin main
```

### Conflict Resolution in Team Setting

```bash
# Alice's branch has conflicts with main
$ git fetch origin
$ git rebase origin/main
CONFLICT (content): Merge conflict in src/api/routes.js

# Fix conflicts in editor
$ git add src/api/routes.js
$ git rebase --continue

# Force push (safe because it's Alice's own branch)
$ git push --force-with-lease origin feature/user-auth
```

---

## Open Source Contribution Workflow <a name="open-source"></a>

The fork-and-PR model used by most open source projects.

### Step-by-Step: Your First Contribution

```bash
# 1. Fork the repository on GitHub (via UI or CLI)
$ gh repo fork facebook/react
✓ Created fork yourname/react

# 2. Clone YOUR fork (not the original)
$ git clone https://github.com/yourname/react.git
$ cd react

# 3. Add upstream remote (the original repo)
$ git remote add upstream https://github.com/facebook/react.git
$ git remote -v
origin    https://github.com/yourname/react.git (fetch)
origin    https://github.com/yourname/react.git (push)
upstream  https://github.com/facebook/react.git (fetch)
upstream  https://github.com/facebook/react.git (push)

# 4. Sync your fork with upstream
$ git fetch upstream
$ git checkout main
$ git merge upstream/main
$ git push origin main

# 5. Create a feature branch
$ git switch -c fix/typo-in-docs
Switched to a new branch 'fix/typo-in-docs'

# 6. Make your changes
$ git add docs/getting-started.md
$ git commit -m "docs: fix typo in getting started guide"

# 7. Push to YOUR fork
$ git push -u origin fix/typo-in-docs

# 8. Create Pull Request to upstream
$ gh pr create \
    --repo facebook/react \
    --title "docs: fix typo in getting started guide" \
    --body "Fixed 'recieve' → 'receive' in getting-started.md"

# 9. Address review feedback
$ git add .
$ git commit -m "address review: also fix second typo"
$ git push

# 10. Maintainer might ask you to squash
$ git rebase -i HEAD~2
# Change second commit to 'squash'
$ git push --force-with-lease

# 11. After merge, clean up
$ git checkout main
$ git pull upstream main
$ git push origin main
$ git branch -d fix/typo-in-docs
$ git push origin --delete fix/typo-in-docs
```

### Keeping Your Fork in Sync

```bash
# Do this regularly (weekly/before starting new work)
$ git fetch upstream
$ git checkout main
$ git rebase upstream/main
$ git push origin main
```



---

## Enterprise Workflow <a name="enterprise"></a>

For large teams (10+ developers) with multiple environments, compliance requirements, and release trains.

### The Pattern

```
main ────────────── (production)
  │
staging ─────────── (pre-production testing)
  │
develop ─────────── (integration)
  │
  ├── feature/JIRA-101-payments (Team A)
  ├── feature/JIRA-205-reporting (Team B)
  ├── release/v3.2.0 (Release Manager)
  └── hotfix/SEC-001-xss-fix (Security Team)
```

### Step-by-Step

```bash
# === Feature Development (Developer) ===

# 1. Pick up JIRA ticket, create branch from develop
$ git checkout develop
$ git pull origin develop
$ git switch -c feature/JIRA-101-payment-gateway
Switched to a new branch 'feature/JIRA-101-payment-gateway'

# 2. Develop with conventional commits
$ git commit -m "feat(payments): add Stripe integration"
$ git commit -m "feat(payments): add webhook handler"
$ git commit -m "test(payments): add unit tests for Stripe service"

# 3. Push and create PR to develop
$ git push -u origin feature/JIRA-101-payment-gateway
$ gh pr create --base develop \
    --title "feat(payments): JIRA-101 Add payment gateway" \
    --body "## Summary\nIntegrates Stripe for payment processing"

# === Release Process (Release Manager) ===

# 4. Cut a release branch from develop
$ git checkout develop
$ git pull origin develop
$ git switch -c release/v3.2.0
Switched to a new branch 'release/v3.2.0'

# 5. Bump version numbers
$ npm version minor --no-git-tag-version
$ git commit -am "chore: bump version to 3.2.0"

# 6. Deploy to staging for QA
$ git push -u origin release/v3.2.0
# CI/CD deploys release/* branches to staging environment

# 7. Fix bugs found in QA (only bug fixes allowed on release branch)
$ git commit -am "fix: correct currency formatting"

# 8. Merge release to main AND develop
$ git checkout main
$ git merge --no-ff release/v3.2.0
$ git tag -a v3.2.0 -m "Release v3.2.0"
$ git push origin main --tags

$ git checkout develop
$ git merge --no-ff release/v3.2.0
$ git push origin develop

# 9. Clean up
$ git branch -d release/v3.2.0
$ git push origin --delete release/v3.2.0
```

### Environment Mapping

| Branch | Environment | Auto-deploy | Purpose |
|--------|-------------|-------------|---------|
| `feature/*` | Dev/Preview | Yes | Developer testing |
| `develop` | Development | Yes | Integration testing |
| `release/*` | Staging | Yes | QA/UAT testing |
| `main` | Production | Yes (or manual) | Live users |

---

## Feature Flags Workflow <a name="feature-flags"></a>

Decouple deployment from release — deploy incomplete code safely behind flags.

### The Pattern

```bash
# Code is on main but hidden behind a feature flag
if (featureFlags.isEnabled('new-checkout-flow')) {
  showNewCheckout();
} else {
  showOldCheckout();
}
```

### Step-by-Step

```bash
# 1. Create branch for flagged feature
$ git switch -c feature/new-checkout
Switched to a new branch 'feature/new-checkout'

# 2. Add code behind a feature flag
$ cat src/checkout.js
import { isFeatureEnabled } from './feature-flags';

export function renderCheckout() {
  if (isFeatureEnabled('new-checkout-flow')) {
    return renderNewCheckout();
  }
  return renderLegacyCheckout();
}

$ git add .
$ git commit -m "feat: add new checkout behind feature flag"

# 3. Merge to main quickly (code is safe — flag is OFF)
$ git push -u origin feature/new-checkout
$ gh pr create --title "feat: new checkout (flagged OFF)"
# PR is merged — deployed to production but invisible to users

# 4. Continue developing on new branches
$ git switch -c feature/new-checkout-part2
$ git commit -am "feat: add payment step to new checkout"
$ git push -u origin feature/new-checkout-part2
# Merge again — still behind flag

# 5. When ready, enable flag gradually
# - 5% of users → monitor errors
# - 25% of users → check metrics
# - 100% of users → full rollout

# 6. After full rollout, remove the flag (tech debt cleanup)
$ git switch -c chore/remove-checkout-flag
$ git commit -am "chore: remove new-checkout-flow feature flag"
$ git push -u origin chore/remove-checkout-flag
$ gh pr create --title "chore: remove checkout feature flag"
```

### Benefits

- Deploy anytime without risk
- Gradual rollouts (canary releases)
- Instant rollback (just turn off the flag)
- A/B testing built-in
- Trunk-based development becomes safe

---

## Release Management <a name="release-management"></a>

### Semantic Versioning

```
v MAJOR . MINOR . PATCH
  │        │       └── Bug fixes (backward compatible)
  │        └────────── New features (backward compatible)
  └─────────────────── Breaking changes
```

### Release Process

```bash
# 1. Ensure develop is stable
$ git checkout develop
$ git pull origin develop
$ npm test
All tests passed ✓

# 2. Create release branch
$ git switch -c release/v2.1.0
Switched to a new branch 'release/v2.1.0'

# 3. Update version and changelog
$ npm version minor --no-git-tag-version
v2.1.0
$ git add package.json package-lock.json
$ git commit -m "chore: bump version to 2.1.0"

# Update CHANGELOG.md
$ git commit -am "docs: update CHANGELOG for v2.1.0"

# 4. Final testing on release branch (only fixes allowed)
$ git commit -am "fix: correct edge case in validation"

# 5. Merge to main
$ git checkout main
$ git pull origin main
$ git merge --no-ff release/v2.1.0 -m "Release v2.1.0"

# 6. Tag the release
$ git tag -a v2.1.0 -m "Release v2.1.0 - Add dashboard widgets"
$ git push origin main --tags

# 7. Merge back to develop (include any release fixes)
$ git checkout develop
$ git merge --no-ff release/v2.1.0
$ git push origin develop

# 8. Clean up
$ git branch -d release/v2.1.0
$ git push origin --delete release/v2.1.0

# 9. Create GitHub Release (optional)
$ gh release create v2.1.0 \
    --title "v2.1.0 - Dashboard Widgets" \
    --notes "## What's New\n- Dashboard widgets\n- Performance improvements"
```

### Automated Release with Tags

```bash
# Many CI/CD systems trigger on tags
# .github/workflows/release.yml triggers on: push: tags: ['v*']
$ git tag -a v2.1.0 -m "Release v2.1.0"
$ git push origin v2.1.0
# CI automatically: builds → tests → deploys → creates GitHub release
```

---

## Hotfix Workflow <a name="hotfix"></a>

For critical bugs in production that can't wait for the next release.

### The Pattern

```
main ──●──────────●──── (bug found!) ──●──── (hotfix applied)
       │          │                     ↑
       │     tag v2.0.0          tag v2.0.1
       │                                │
       │                    hotfix/fix-crash
       │
develop ──●──●──●──●──●──●──●──●──●──●──── (also gets the fix)
```

### Step-by-Step

```bash
# 1. Create hotfix branch from main (production)
$ git checkout main
$ git pull origin main
$ git switch -c hotfix/fix-payment-crash
Switched to a new branch 'hotfix/fix-payment-crash'

# 2. Fix the bug (minimal change only!)
$ git add src/payment.js
$ git commit -m "fix: prevent null pointer in payment callback"

# 3. Add a test for the fix
$ git add tests/payment.test.js
$ git commit -m "test: add regression test for payment crash"

# 4. Bump patch version
$ npm version patch --no-git-tag-version
v2.0.1
$ git commit -am "chore: bump version to 2.0.1"

# 5. Merge to main and tag
$ git checkout main
$ git merge --no-ff hotfix/fix-payment-crash -m "Hotfix: fix payment crash"
$ git tag -a v2.0.1 -m "Hotfix v2.0.1 - Fix payment crash"
$ git push origin main --tags

# 6. Merge to develop (so the fix isn't lost)
$ git checkout develop
$ git merge --no-ff hotfix/fix-payment-crash
$ git push origin develop

# 7. Clean up
$ git branch -d hotfix/fix-payment-crash
$ git push origin --delete hotfix/fix-payment-crash

# 8. Deploy (if not automatic)
$ git push origin main
# CI/CD picks up the new tag and deploys
```

### Hotfix Rules

- Branch from `main`, never from `develop`
- Minimal changes only — fix the bug, nothing else
- Always merge back to both `main` AND `develop`
- Always bump the patch version
- Always add a regression test



---

## Code Review Best Practices <a name="code-review"></a>

### For PR Authors

```bash
# Keep PRs small and focused (< 400 lines ideal)
$ git diff --stat main..feature/my-branch
 src/auth.js     | 45 +++++++++++
 src/auth.test.js| 62 +++++++++++++++
 2 files changed, 107 insertions(+)

# Write a clear PR description (see template below)

# Self-review before requesting review
$ git diff main..HEAD

# Respond to all comments — resolve or explain why not
```

### For Reviewers

1. **Review within 24 hours** — Don't block teammates
2. **Be kind and constructive** — Suggest, don't command
3. **Focus on**:
   - Logic errors and bugs
   - Security vulnerabilities
   - Performance issues
   - Missing tests
   - Readability and maintainability
4. **Don't focus on** (automate these instead):
   - Formatting (use Prettier/ESLint)
   - Import order (use auto-sort)
   - Naming conventions (use linters)

### Review Commands

```bash
# Check out a PR locally for testing
$ gh pr checkout 42
Switched to branch 'feature/user-auth'

# Run tests on the PR branch
$ npm test

# View PR diff
$ gh pr diff 42

# Approve
$ gh pr review 42 --approve --body "LGTM! Clean implementation."

# Request changes
$ gh pr review 42 --request-changes --body "Please add error handling for the API call"

# Comment without approval/rejection
$ gh pr review 42 --comment --body "Looks good overall, one minor suggestion"
```

### Merge Strategies for PRs

| Strategy | When to Use | Command |
|----------|-------------|---------|
| Squash merge | Feature branches (clean history) | `gh pr merge --squash` |
| Merge commit | Preserve full branch history | `gh pr merge --merge` |
| Rebase merge | Linear history, meaningful commits | `gh pr merge --rebase` |

---

## PR Templates <a name="pr-templates"></a>

### GitHub PR Template

Create `.github/pull_request_template.md`:

```markdown
## Description

<!-- What does this PR do? Why is it needed? -->

## Type of Change

- [ ] 🐛 Bug fix (non-breaking change that fixes an issue)
- [ ] ✨ New feature (non-breaking change that adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to change)
- [ ] 📝 Documentation update
- [ ] 🔧 Refactoring (no functional changes)
- [ ] 🧪 Test addition/update

## Related Issues

<!-- Link to JIRA ticket or GitHub issue -->
Closes #

## Changes Made

<!-- List the specific changes made -->
- 
- 
- 

## Screenshots (if applicable)

<!-- Add screenshots for UI changes -->

## Testing

<!-- How was this tested? -->
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Tested on multiple browsers (if frontend)

## Checklist

- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented hard-to-understand areas
- [ ] I have updated documentation (if needed)
- [ ] My changes generate no new warnings
- [ ] New and existing unit tests pass locally
- [ ] Any dependent changes have been merged

## Deployment Notes

<!-- Any special deployment steps? Database migrations? Config changes? -->
None

## Reviewer Notes

<!-- Anything specific you'd like reviewers to focus on? -->
```

### Setting Up the Template

```bash
# Create the template directory
$ mkdir -p .github

# Create the template file
$ cat > .github/pull_request_template.md << 'EOF'
## Description
<!-- What does this PR do? -->

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation

## Testing
- [ ] Tests pass
- [ ] Manual testing done

## Checklist
- [ ] Self-reviewed
- [ ] Tests added
- [ ] Docs updated
EOF

# Commit the template
$ git add .github/pull_request_template.md
$ git commit -m "chore: add PR template"
$ git push origin main
```

---

## Branch Protection Rules <a name="branch-protection"></a>

### What Are Branch Protection Rules?

Rules that prevent direct pushes to important branches, requiring PRs, reviews, and passing CI checks.

### Setting Up via GitHub CLI

```bash
# Require PR reviews before merging to main
$ gh api repos/{owner}/{repo}/branches/main/protection -X PUT \
  --input - << 'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["ci/build", "ci/test", "ci/lint"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 2,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
```

### Common Protection Settings

| Setting | Purpose | Recommended |
|---------|---------|-------------|
| Require PR | No direct pushes | ✅ Always |
| Required reviewers | Minimum approvals | 1-2 for small teams, 2+ for enterprise |
| Dismiss stale reviews | Re-review after new pushes | ✅ Yes |
| Require status checks | CI must pass | ✅ Always |
| Require up-to-date | Branch must be current with base | ✅ For main |
| Require signed commits | GPG-signed commits only | Optional (enterprise) |
| Include administrators | Admins follow same rules | ✅ Yes |
| Allow force push | Allow `--force` | ❌ Never on main |
| Allow deletion | Allow branch deletion | ❌ Never on main |

### Setting Up via GitHub UI

```
Repository → Settings → Branches → Add rule

Branch name pattern: main

✅ Require a pull request before merging
   ✅ Require approvals: 2
   ✅ Dismiss stale pull request approvals when new commits are pushed
   ✅ Require review from Code Owners

✅ Require status checks to pass before merging
   ✅ Require branches to be up to date before merging
   Search for status checks: "CI / build", "CI / test"

✅ Require signed commits (optional)
✅ Include administrators
❌ Allow force pushes
❌ Allow deletions
```

### Rulesets (GitHub's Newer Approach)

```bash
# Create a ruleset via CLI
$ gh api repos/{owner}/{repo}/rulesets -X POST --input - << 'EOF'
{
  "name": "main-protection",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["refs/heads/main"],
      "exclude": []
    }
  },
  "rules": [
    { "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 2,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": true
      }
    },
    { "type": "required_status_checks",
      "parameters": {
        "required_status_checks": [
          { "context": "CI / build" },
          { "context": "CI / test" }
        ]
      }
    }
  ]
}
EOF
```

---

## CODEOWNERS File <a name="codeowners"></a>

### What Is CODEOWNERS?

A file that defines which teams/individuals are automatically requested for review when specific files are modified.

### File Location

Place in one of:
- `.github/CODEOWNERS`
- `docs/CODEOWNERS`
- `CODEOWNERS` (repository root)

### Syntax and Examples

```bash
# .github/CODEOWNERS

# Default owners for everything (last match wins)
* @team-leads

# Frontend team owns all JS/TS/CSS files
*.js @frontend-team
*.ts @frontend-team
*.tsx @frontend-team
*.css @frontend-team @design-team

# Backend team owns server code
/src/api/ @backend-team
/src/services/ @backend-team
/src/database/ @backend-team @dba-team

# DevOps owns infrastructure
/infrastructure/ @devops-team
Dockerfile @devops-team
docker-compose.yml @devops-team
.github/workflows/ @devops-team

# Security team reviews auth changes
/src/auth/ @security-team
/src/middleware/auth* @security-team

# Documentation
/docs/ @docs-team
*.md @docs-team

# Package dependencies need senior review
package.json @senior-devs
package-lock.json @senior-devs
Gemfile @senior-devs
requirements.txt @senior-devs

# Specific individuals for critical files
/src/billing/ @alice @bob
/src/config/production.yml @team-leads @devops-team
```

### Setting Up CODEOWNERS

```bash
# 1. Create the file
$ mkdir -p .github
$ cat > .github/CODEOWNERS << 'EOF'
# Default
* @myorg/engineering

# Frontend
/src/components/ @myorg/frontend
/src/pages/ @myorg/frontend
*.css @myorg/frontend

# Backend
/src/api/ @myorg/backend
/src/models/ @myorg/backend

# Infrastructure
/.github/ @myorg/devops
/terraform/ @myorg/devops
Dockerfile @myorg/devops

# Sensitive files
/src/auth/ @myorg/security
.env.example @myorg/security
EOF

# 2. Commit
$ git add .github/CODEOWNERS
$ git commit -m "chore: add CODEOWNERS file"
$ git push origin main
```

### How It Works

1. Developer opens a PR modifying `src/api/users.js`
2. GitHub checks CODEOWNERS → matches `/src/api/ @myorg/backend`
3. `@myorg/backend` team is automatically added as reviewers
4. If branch protection requires code owner review, a member of `@myorg/backend` MUST approve

### CODEOWNERS Rules

- Last matching pattern takes precedence (like `.gitignore`)
- Use `@username` for individuals, `@org/team-name` for teams
- Teams must have write access to the repository
- Empty pattern = no owner (overrides earlier rules)

```bash
# Example: docs team owns docs, but API docs need backend review too
/docs/ @docs-team
/docs/api/ @docs-team @backend-team
```

---

## Summary: Choosing the Right Workflow

| Scenario | Recommended Workflow |
|----------|---------------------|
| Solo project / personal | Solo with tags |
| Startup (2-5 devs) | GitHub Flow |
| Mid-size team (5-15) | GitHub Flow + branch protection |
| Large team (15+) | GitFlow or Trunk-Based |
| Open source project | Fork + PR model |
| Enterprise with compliance | GitFlow + release branches |
| High-velocity / SaaS | Trunk-Based + feature flags |

---

*Previous: [🌳 Branching](git-branching.md) ← | → Next: [🚀 Advanced](git-advanced.md)*
