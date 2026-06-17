#!/bin/bash
# =============================================================================
# Commit Message Hook — Enforces Conventional Commits Format
# =============================================================================
# Install: cp commit-msg-hook.sh .git/hooks/commit-msg && chmod +x .git/hooks/commit-msg
#
# Conventional Commits format:
#   <type>(<scope>): <description>
#
# Valid types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
# Scope is optional.
#
# Examples:
#   feat(auth): add OAuth2 login support
#   fix: resolve null pointer in user service
#   docs: update API documentation
#   chore(deps): bump lodash to 4.17.21
# =============================================================================

COMMIT_MSG_FILE="$1"
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Skip merge commits and fixup/squash commits
if echo "$COMMIT_MSG" | grep -qE "^(Merge|fixup!|squash!)"; then
    exit 0
fi

# Conventional commit regex pattern
# Format: type(optional-scope): description
PATTERN="^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-zA-Z0-9._-]+\))?(!)?: .{1,}"

if ! echo "$COMMIT_MSG" | head -1 | grep -qE "$PATTERN"; then
    echo -e "${RED}❌ Invalid commit message format!${NC}"
    echo ""
    echo "Your message: $(head -1 "$COMMIT_MSG_FILE")"
    echo ""
    echo -e "${YELLOW}Expected format: <type>(<scope>): <description>${NC}"
    echo ""
    echo "Valid types:"
    echo "  feat     — A new feature"
    echo "  fix      — A bug fix"
    echo "  docs     — Documentation only changes"
    echo "  style    — Code style changes (formatting, semicolons, etc.)"
    echo "  refactor — Code change that neither fixes a bug nor adds a feature"
    echo "  perf     — Performance improvement"
    echo "  test     — Adding or updating tests"
    echo "  build    — Build system or external dependency changes"
    echo "  ci       — CI configuration changes"
    echo "  chore    — Other changes that don't modify src or test files"
    echo "  revert   — Reverts a previous commit"
    echo ""
    echo "Examples:"
    echo "  feat(auth): add Google OAuth login"
    echo "  fix: handle null response from API"
    echo "  docs: add contributing guidelines"
    echo "  feat!: drop support for Node 14"
    echo ""
    echo "Use --no-verify flag to bypass this check."
    exit 1
fi

# Check subject line length (max 72 characters)
SUBJECT_LENGTH=$(echo "$COMMIT_MSG" | head -1 | wc -c)
if [ "$SUBJECT_LENGTH" -gt 73 ]; then
    echo -e "${YELLOW}⚠️  Subject line is too long ($((SUBJECT_LENGTH - 1)) chars). Keep it under 72.${NC}"
    exit 1
fi

# Check that description doesn't start with uppercase
DESC=$(echo "$COMMIT_MSG" | head -1 | sed 's/^[^:]*: //')
if echo "$DESC" | grep -qE "^[A-Z]"; then
    echo -e "${YELLOW}⚠️  Description should start with lowercase letter.${NC}"
    echo "   Got: $DESC"
    exit 1
fi

echo -e "${GREEN}✅ Commit message follows conventional format.${NC}"
exit 0
