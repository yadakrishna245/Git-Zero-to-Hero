[📖 README](README.md) | [🌳 Branching](git-branching.md) | [⚡ Commands](git-commands-cheatsheet.md) | [🔧 Internals](git-internals.md) | [🤝 Workflows](git-workflows.md) | [🚀 Advanced](git-advanced.md) | [🌐 GitHub/GitLab](github-gitlab-guide.md) | [🔥 Troubleshooting](git-troubleshooting.md) | [💼 Interview Prep](git-interview-questions.md) | [🔒 Security](git-security.md)

---

# 🌐 GitHub, GitLab & Bitbucket Guide

Platform-specific features, CI/CD, and best practices for the major Git hosting platforms.

---

## Table of Contents

### GitHub
1. [Repository Setup & Settings](#repository-setup--settings)
2. [Pull Requests](#pull-requests)
3. [GitHub Actions (CI/CD)](#github-actions-cicd)
4. [GitHub Pages](#github-pages)
5. [Releases and Tags](#releases-and-tags)
6. [Issues and Projects](#issues-and-projects)
7. [GitHub CLI](#github-cli)
8. [Branch Protection Rules](#branch-protection-rules)
9. [CODEOWNERS](#codeowners)
10. [GitHub Packages](#github-packages)
11. [GitHub Codespaces](#github-codespaces)
12. [Security Features](#security-features)

### GitLab
13. [Merge Requests vs Pull Requests](#merge-requests-vs-pull-requests)
14. [GitLab CI/CD](#gitlab-cicd)
15. [GitLab Runners](#gitlab-runners)
16. [GitLab Container Registry](#gitlab-container-registry)
17. [GitLab Pages](#gitlab-pages)
18. [Auto DevOps](#auto-devops)
19. [GitLab vs GitHub Comparison](#gitlab-vs-github-comparison)

### Bitbucket
20. [Bitbucket Pipelines](#bitbucket-pipelines)
21. [Key Differences](#bitbucket-key-differences)

---

# GitHub

---

## Repository Setup & Settings

### Creating a Repository

```bash
# From CLI
gh repo create my-project --public --clone
gh repo create org/my-project --private --team dev-team

# Initialize locally then push
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/user/repo.git
git push -u origin main
```

### Key Settings

| Setting | Purpose |
|---------|---------|
| **Default branch** | Set to `main` (Settings → Branches) |
| **Merge button** | Enable/disable merge, squash, rebase options |
| **Auto-delete head branches** | Clean up after PR merge |
| **Template repository** | Allow others to use as template |
| **Discussions** | Enable community Q&A |
| **Wiki** | Built-in documentation |
| **Vulnerability alerts** | Security notifications |

### Repository Templates

Create a `.github/` directory:

```
.github/
├── ISSUE_TEMPLATE/
│   ├── bug_report.md
│   └── feature_request.md
├── PULL_REQUEST_TEMPLATE.md
├── CONTRIBUTING.md
├── FUNDING.yml
└── workflows/
    └── ci.yml
```

---

## Pull Requests

### Creating a PR

```bash
# Via GitHub CLI
gh pr create --title "Add login feature" --body "Implements OAuth2 login" --base main

# With reviewers and labels
gh pr create --title "Fix auth bug" \
  --reviewer user1,user2 \
  --label "bug,priority:high" \
  --milestone "v2.0"

# Draft PR
gh pr create --draft --title "WIP: New dashboard"
```

### PR Review Process

```bash
# List open PRs
gh pr list

# Check out a PR locally
gh pr checkout 42

# Add review
gh pr review 42 --approve
gh pr review 42 --request-changes --body "Please fix the error handling"
gh pr review 42 --comment --body "Looks good overall"
```

### Merge Strategies

| Strategy | Effect | When to Use |
|----------|--------|-------------|
| **Merge commit** | Creates a merge commit | Preserves full history |
| **Squash and merge** | All PR commits → one commit | Clean linear history |
| **Rebase and merge** | Rebases commits onto base | Linear history, preserves commits |

```bash
# Merge via CLI
gh pr merge 42 --merge
gh pr merge 42 --squash
gh pr merge 42 --rebase

# Auto-merge when checks pass
gh pr merge 42 --auto --squash
```

---

## GitHub Actions (CI/CD)

### Basic CI Workflow

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20, 22]

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run linter
        run: npm run lint

      - name: Run tests
        run: npm test

      - name: Build
        run: npm run build
```

### Deploy to Production Workflow

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    tags: ['v*']

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    permissions:
      contents: read
      id-token: write

    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789:role/deploy-role
          aws-region: us-east-1

      - name: Build and push Docker image
        run: |
          docker build -t my-app:${{ github.ref_name }} .
          docker push $ECR_REGISTRY/my-app:${{ github.ref_name }}

      - name: Deploy to ECS
        run: |
          aws ecs update-service --cluster prod --service my-app --force-new-deployment
```

### Reusable Workflow

```yaml
# .github/workflows/reusable-test.yml
name: Reusable Test

on:
  workflow_call:
    inputs:
      node-version:
        required: true
        type: string

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
      - run: npm ci && npm test
```

```yaml
# Calling the reusable workflow
name: CI
on: [push]
jobs:
  call-tests:
    uses: ./.github/workflows/reusable-test.yml
    with:
      node-version: '20'
```


---

## GitHub Pages

### Deployment Methods

**1. From a branch:**

Settings → Pages → Source → Deploy from branch (`gh-pages` or `main/docs`)

**2. Using GitHub Actions:**

```yaml
# .github/workflows/pages.yml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci && npm run build
      - uses: actions/upload-pages-artifact@v3
        with:
          path: ./dist

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```

### Custom Domain

1. Add `CNAME` file to your repo root with: `www.yourdomain.com`
2. Configure DNS: CNAME record pointing to `username.github.io`
3. Enable HTTPS in Settings → Pages

---

## Releases and Tags

```bash
# Create a tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# Create release via CLI
gh release create v1.0.0 --title "v1.0.0" --notes "Release notes here"

# Upload assets
gh release create v1.0.0 ./dist/app.zip --title "v1.0.0"

# Generate release notes automatically
gh release create v1.0.0 --generate-notes

# List releases
gh release list
```

### Automated Release Workflow

```yaml
name: Release
on:
  push:
    tags: ['v*']

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4
      - run: npm ci && npm run build
      - uses: softprops/action-gh-release@v2
        with:
          files: dist/*
          generate_release_notes: true
```

---

## Issues and Projects

### Issue Templates

```yaml
# .github/ISSUE_TEMPLATE/bug_report.yml
name: Bug Report
description: File a bug report
labels: ["bug", "triage"]
body:
  - type: textarea
    id: description
    attributes:
      label: Describe the bug
    validations:
      required: true
  - type: textarea
    id: steps
    attributes:
      label: Steps to reproduce
  - type: dropdown
    id: severity
    attributes:
      label: Severity
      options:
        - Critical
        - High
        - Medium
        - Low
```

### GitHub Projects (Kanban)

- Create Project: Repository → Projects → New Project
- Views: Board (Kanban), Table, Roadmap
- Custom fields: Priority, Sprint, Size
- Automations: Auto-move issues on PR merge, auto-add new issues

```bash
# CLI project management
gh project list
gh project item-list 1
```

---

## GitHub CLI

### Essential Commands

```bash
# Authentication
gh auth login
gh auth status

# Repository
gh repo create my-app --public
gh repo clone user/repo
gh repo fork user/repo

# Pull Requests
gh pr create --title "Feature" --body "Description"
gh pr list --state open
gh pr checkout 42
gh pr merge 42 --squash
gh pr diff 42

# Issues
gh issue create --title "Bug" --label "bug"
gh issue list --assignee @me
gh issue close 15

# Workflows
gh run list
gh run view 12345
gh run rerun 12345
gh workflow run ci.yml

# Gists
gh gist create file.py --public

# Extensions
gh extension install dlvhdr/gh-dash
```

---

## Branch Protection Rules

Settings → Branches → Add rule:

| Rule | Description |
|------|-------------|
| **Require PR reviews** | 1+ approvals before merge |
| **Dismiss stale reviews** | Re-request review after new commits |
| **Require status checks** | CI must pass |
| **Require branches up to date** | Must rebase before merge |
| **Require signed commits** | All commits must be GPG signed |
| **Require linear history** | No merge commits (squash/rebase only) |
| **Restrict pushes** | Only specific people/teams can push |
| **Lock branch** | Read-only branch |

### Rulesets (Modern approach)

```
Repository → Settings → Rules → Rulesets
```

Rulesets are more flexible than branch protection rules and support:
- Targeting multiple branches with patterns
- Bypass lists for specific actors
- Tag protection
- Organization-level rules

---

## CODEOWNERS

Automatically request reviews from code owners.

```
# .github/CODEOWNERS

# Default owners for everything
* @org/core-team

# Frontend
/src/frontend/       @org/frontend-team
*.css                @org/design-team
*.tsx                @org/frontend-team

# Backend
/src/api/            @org/backend-team
/src/database/       @org/dba-team

# DevOps
/infrastructure/     @org/devops-team
/.github/workflows/  @org/devops-team
Dockerfile           @org/devops-team

# Documentation
/docs/               @org/docs-team
*.md                 @org/docs-team

# Security-sensitive files
/src/auth/           @org/security-team @org/backend-team
```


---

## GitHub Packages

Publish packages directly from your repository.

```yaml
# .github/workflows/publish.yml
name: Publish Package

on:
  release:
    types: [published]

jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      packages: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          registry-url: https://npm.pkg.github.com/
      - run: npm ci && npm publish
        env:
          NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Supported Registries

| Type | Registry URL |
|------|-------------|
| npm | `https://npm.pkg.github.com` |
| Maven | `https://maven.pkg.github.com` |
| Docker | `ghcr.io` |
| NuGet | `https://nuget.pkg.github.com` |
| RubyGems | `https://rubygems.pkg.github.com` |

### Docker with GHCR

```yaml
- name: Login to GHCR
  uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}

- name: Build and push
  uses: docker/build-push-action@v5
  with:
    push: true
    tags: ghcr.io/${{ github.repository }}:latest
```

---

## GitHub Codespaces

Cloud-hosted development environments.

### Configuration

```json
// .devcontainer/devcontainer.json
{
  "name": "My Project",
  "image": "mcr.microsoft.com/devcontainers/javascript-node:20",
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/devcontainers/features/aws-cli:1": {}
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode"
      ],
      "settings": {
        "editor.formatOnSave": true
      }
    }
  },
  "postCreateCommand": "npm install",
  "forwardPorts": [3000, 5432],
  "portsAttributes": {
    "3000": { "label": "App", "onAutoForward": "openPreview" }
  }
}
```

### CLI Usage

```bash
gh codespace create --repo user/repo --branch feature
gh codespace list
gh codespace ssh -c <codespace-name>
gh codespace stop -c <codespace-name>
```

---

## Security Features

### Dependabot

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
    open-pull-requests-limit: 10
    labels: ["dependencies"]
    reviewers: ["org/security-team"]
    groups:
      dev-dependencies:
        dependency-type: "development"
      production:
        dependency-type: "production"

  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

### Secret Scanning

- Automatically detects secrets pushed to repo
- Push protection blocks pushes containing secrets
- Custom patterns via Settings → Code security → Secret scanning

### Code Scanning (CodeQL)

```yaml
# .github/workflows/codeql.yml
name: CodeQL Analysis

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 6 * * 1'

jobs:
  analyze:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
    strategy:
      matrix:
        language: ['javascript', 'python']
    steps:
      - uses: actions/checkout@v4
      - uses: github/codeql-action/init@v3
        with:
          languages: ${{ matrix.language }}
      - uses: github/codeql-action/analyze@v3
```

---

# GitLab

---

## Merge Requests vs Pull Requests

| Feature | GitHub (Pull Request) | GitLab (Merge Request) |
|---------|----------------------|----------------------|
| Name | Pull Request | Merge Request |
| Draft/WIP | Draft PR | Draft MR (prefix `Draft:`) |
| Approvals | Require reviewers | Approval rules with groups |
| CI Required | Status checks | Pipeline must succeed |
| Merge options | Merge/Squash/Rebase | Merge/Squash/Fast-forward |
| Auto-merge | Auto-merge when checks pass | Merge when pipeline succeeds |
| Merge trains | Not native | Built-in merge trains |

---

## GitLab CI/CD

### Basic Pipeline

```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - deploy

variables:
  NODE_VERSION: "20"

build:
  stage: build
  image: node:${NODE_VERSION}
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 hour

test:
  stage: test
  image: node:${NODE_VERSION}
  script:
    - npm ci
    - npm run lint
    - npm test
  coverage: '/Lines\s*:\s*(\d+\.?\d*)%/'

deploy_staging:
  stage: deploy
  script:
    - echo "Deploying to staging..."
    - ./deploy.sh staging
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - develop

deploy_production:
  stage: deploy
  script:
    - echo "Deploying to production..."
    - ./deploy.sh production
  environment:
    name: production
    url: https://example.com
  only:
    - main
  when: manual
```

### Advanced Pipeline with Cache and Services

```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - docker
  - deploy

cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - node_modules/

test:
  stage: test
  image: node:20
  services:
    - postgres:15
    - redis:7
  variables:
    POSTGRES_DB: testdb
    POSTGRES_USER: test
    POSTGRES_PASSWORD: test
    DATABASE_URL: "postgresql://test:test@postgres:5432/testdb"
  script:
    - npm ci
    - npm test
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == "main"

docker_build:
  stage: docker
  image: docker:24
  services:
    - docker:24-dind
  variables:
    DOCKER_TLS_CERTDIR: "/certs"
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
```


---

## GitLab Runners

Agents that run your CI/CD jobs.

### Runner Types

| Type | Scope | Use Case |
|------|-------|----------|
| **Shared** | All projects in instance | General CI |
| **Group** | All projects in group | Team-specific |
| **Project** | Single project | Specialized needs |

### Registering a Runner

```bash
# Install GitLab Runner
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
sudo apt install gitlab-runner

# Register
sudo gitlab-runner register \
  --url https://gitlab.com/ \
  --registration-token YOUR_TOKEN \
  --executor docker \
  --docker-image node:20 \
  --description "Docker Runner" \
  --tag-list "docker,linux"
```

### Using Tags to Target Runners

```yaml
deploy:
  tags:
    - production
    - aws
  script:
    - ./deploy.sh
```

---

## GitLab Container Registry

Built-in Docker registry for every project.

```bash
# Login
docker login registry.gitlab.com

# Build and push
docker build -t registry.gitlab.com/group/project:latest .
docker push registry.gitlab.com/group/project:latest

# Pull
docker pull registry.gitlab.com/group/project:latest
```

### In CI Pipeline

```yaml
docker_build:
  image: docker:24
  services:
    - docker:24-dind
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
```

---

## GitLab Pages

```yaml
# .gitlab-ci.yml
pages:
  stage: deploy
  image: node:20
  script:
    - npm ci
    - npm run build
    - mv dist public   # GitLab Pages serves from 'public/' directory
  artifacts:
    paths:
      - public
  only:
    - main
```

Your site will be at: `https://username.gitlab.io/project-name/`

---

## Auto DevOps

GitLab's automated CI/CD pipeline that detects your project type and applies:
- Build (Auto Build using Buildpacks/Dockerfile)
- Test (Auto Test)
- Code Quality
- SAST/DAST (Security scanning)
- Container Scanning
- Deploy (Auto Deploy to Kubernetes)
- Monitoring

### Enable

Settings → CI/CD → Auto DevOps → Enable

Or in `.gitlab-ci.yml`:

```yaml
include:
  - template: Auto-DevOps.gitlab-ci.yml
```

---

## GitLab vs GitHub Comparison

| Feature | GitHub | GitLab |
|---------|--------|--------|
| **CI/CD** | GitHub Actions (YAML) | GitLab CI (.gitlab-ci.yml) |
| **Container Registry** | GHCR (ghcr.io) | Built-in per project |
| **Package Registry** | GitHub Packages | Built-in (npm, Maven, etc.) |
| **Code Review** | Pull Requests | Merge Requests |
| **Merge Trains** | ❌ Not native | ✅ Built-in |
| **Auto DevOps** | ❌ | ✅ Full pipeline |
| **Wiki** | Simple markdown wiki | Full wiki with versioning |
| **Issue Boards** | Projects (Kanban) | Issue Boards + Epics |
| **Self-hosted** | GitHub Enterprise | GitLab CE (free) |
| **Security Scanning** | CodeQL + Dependabot | SAST/DAST/Container/Dependency |
| **Environments** | Environments in Actions | Full environment management |
| **Feature Flags** | ❌ | ✅ Built-in |
| **Value Stream Analytics** | ❌ | ✅ Built-in |
| **Free Tier CI** | 2,000 min/month | 400 min/month |
| **Pricing Model** | Per user | Per user (more features in tiers) |

---

# Bitbucket

---

## Bitbucket Pipelines

Atlassian's CI/CD integrated with Jira and Trello.

### Basic Pipeline

```yaml
# bitbucket-pipelines.yml
image: node:20

pipelines:
  default:
    - step:
        name: Build and Test
        caches:
          - node
        script:
          - npm ci
          - npm run lint
          - npm test
          - npm run build
        artifacts:
          - dist/**

  branches:
    main:
      - step:
          name: Deploy to Production
          deployment: production
          script:
            - pipe: atlassian/aws-ecs-deploy:2.0.0
              variables:
                AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
                AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
                AWS_DEFAULT_REGION: "us-east-1"
                CLUSTER_NAME: "production"
                SERVICE_NAME: "my-app"

  pull-requests:
    '**':
      - step:
          name: PR Checks
          script:
            - npm ci
            - npm test
```

### Pipes (Reusable Components)

```yaml
- pipe: atlassian/slack-notify:2.0.0
  variables:
    WEBHOOK_URL: $SLACK_WEBHOOK
    MESSAGE: "Deployment successful! 🚀"
```

---

## Bitbucket Key Differences

| Feature | GitHub | GitLab | Bitbucket |
|---------|--------|--------|-----------|
| **CI/CD Config** | `.github/workflows/*.yml` | `.gitlab-ci.yml` | `bitbucket-pipelines.yml` |
| **PR Name** | Pull Request | Merge Request | Pull Request |
| **Built for** | Open source + Enterprise | DevOps platform | Atlassian ecosystem |
| **Integration** | Actions marketplace | Built-in tools | Jira, Confluence, Trello |
| **Free Private Repos** | ✅ Unlimited | ✅ Unlimited | ✅ (5 users limit) |
| **CI Free Tier** | 2,000 min/month | 400 min/month | 50 min/month |
| **Self-hosted** | Enterprise Server | CE/EE | Data Center |
| **Code Review** | Inline + suggestions | Inline + suggestions | Inline comments |
| **LFS** | ✅ | ✅ | ✅ |
| **Wiki** | ✅ | ✅ | ✅ (separate repo) |

### When to Choose

- **GitHub:** Open source, large community, Actions ecosystem
- **GitLab:** Full DevOps platform, self-hosted free tier, all-in-one
- **Bitbucket:** Atlassian shops (Jira/Confluence), small teams

---

## Summary

| Need | Platform | Feature |
|------|----------|---------|
| CI/CD | All three | Actions / GitLab CI / Pipelines |
| Container Registry | GitHub/GitLab | GHCR / Built-in |
| Security Scanning | GitHub/GitLab | Dependabot+CodeQL / SAST+DAST |
| Merge Trains | GitLab | Built-in |
| Jira Integration | Bitbucket | Native |
| Self-hosted (free) | GitLab | Community Edition |
| Open Source Hosting | GitHub | Largest community |

---

> 💡 **Pro Tip:** You don't have to choose just one! Many teams use GitHub for open-source projects and GitLab for internal CI/CD with self-hosted runners. Mirror repos between platforms for redundancy.
