# 📂 Git Zero-to-Hero — Examples

Practical, copy-paste ready configuration files and scripts for your Git workflow.

---

## 📁 Contents

| File | Description |
|------|-------------|
| [`.gitconfig`](.gitconfig) | Complete recommended Git configuration with 15+ aliases |
| [`pre-commit-hook.sh`](pre-commit-hook.sh) | Pre-commit hook: catches debug statements, large files, and secrets |
| [`commit-msg-hook.sh`](commit-msg-hook.sh) | Commit-msg hook: enforces Conventional Commits format |
| [`.gitignore-templates/`](.gitignore-templates/) | Language-specific .gitignore templates |
| [`github-actions/`](github-actions/) | CI/CD workflow templates for GitHub Actions |

---

## 🚀 Usage

### Git Configuration

```bash
# Copy to your home directory and customize the [user] section
cp .gitconfig ~/.gitconfig

# Or apply specific settings
git config --global alias.st "status -sb"
git config --global alias.lg "log --oneline --graph --decorate -20"
```

### Git Hooks

```bash
# Install pre-commit hook
cp pre-commit-hook.sh <your-repo>/.git/hooks/pre-commit
chmod +x <your-repo>/.git/hooks/pre-commit

# Install commit-msg hook
cp commit-msg-hook.sh <your-repo>/.git/hooks/commit-msg
chmod +x <your-repo>/.git/hooks/commit-msg
```

> **Tip:** Use [Husky](https://typicode.github.io/husky/) for team-wide hook management in Node.js projects.

### .gitignore Templates

```bash
# Copy the appropriate template to your project root
cp .gitignore-templates/node.gitignore <your-project>/.gitignore
```

### GitHub Actions

```bash
# Copy workflow files into your repo
mkdir -p <your-repo>/.github/workflows
cp github-actions/ci.yml <your-repo>/.github/workflows/ci.yml
cp github-actions/release.yml <your-repo>/.github/workflows/release.yml
```

---

## 📝 Customization Notes

- **`.gitconfig`** — Change the editor, merge tool, and credential helper to match your setup.
- **Hooks** — Adjust the debug patterns and secret regexes for your tech stack.
- **CI workflows** — Modify the Node.js version matrix and test commands for your project.
- **Release workflow** — Trigger by pushing a tag: `git tag v1.0.0 && git push origin v1.0.0`

---

## 📚 Related

These examples complement the [Git Zero-to-Hero](../README.md) guide. Refer to the main guide for detailed explanations of each concept.
