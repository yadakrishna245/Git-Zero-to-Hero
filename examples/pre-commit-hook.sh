#!/bin/bash
# =============================================================================
# Pre-Commit Hook
# =============================================================================
# Install: cp pre-commit-hook.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
#
# This hook runs before each commit and checks for:
#   1. Debug/console statements left in code
#   2. Files larger than 5MB
#   3. Potential secrets or API keys
#   4. Linter errors (if linter is available)
# =============================================================================

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Track if any check fails
ERRORS=0

echo "🔍 Running pre-commit checks..."
echo ""

# -----------------------------------------------------------------------------
# 1. Check for debug statements
# -----------------------------------------------------------------------------
echo "Checking for debug statements..."

# Get list of staged files (only added/modified, exclude deleted)
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

# Patterns to check (adjust for your project)
DEBUG_PATTERNS="console\.log\|console\.debug\|debugger\|binding\.pry\|pdb\.set_trace\|print(\|var_dump\|dd("

FOUND_DEBUG=$(echo "$STAGED_FILES" | xargs grep -n --with-filename "$DEBUG_PATTERNS" 2>/dev/null | grep -v "// allow-debug\|# allow-debug")

if [ -n "$FOUND_DEBUG" ]; then
    echo -e "${YELLOW}⚠️  Debug statements found:${NC}"
    echo "$FOUND_DEBUG"
    echo -e "${YELLOW}   Add '// allow-debug' comment to suppress this warning.${NC}"
    echo ""
    ERRORS=$((ERRORS + 1))
fi

# -----------------------------------------------------------------------------
# 2. Check for large files (>5MB)
# -----------------------------------------------------------------------------
echo "Checking for large files..."

MAX_FILE_SIZE=5242880  # 5MB in bytes

for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        FILE_SIZE=$(wc -c < "$file" 2>/dev/null | tr -d ' ')
        if [ "$FILE_SIZE" -gt "$MAX_FILE_SIZE" ] 2>/dev/null; then
            SIZE_MB=$(echo "scale=2; $FILE_SIZE / 1048576" | bc)
            echo -e "${RED}❌ Large file detected: $file (${SIZE_MB}MB)${NC}"
            echo "   Consider using Git LFS for large files."
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

# -----------------------------------------------------------------------------
# 3. Check for secrets and API keys
# -----------------------------------------------------------------------------
echo "Checking for secrets/API keys..."

# Common secret patterns
SECRET_PATTERNS=(
    "AKIA[0-9A-Z]{16}"                      # AWS Access Key
    "(?i)(api[_-]?key|apikey)\s*[:=]\s*['\"][^\s'\"]{8,}"  # Generic API key
    "(?i)(secret|password|passwd|pwd)\s*[:=]\s*['\"][^\s'\"]{8,}"  # Passwords
    "ghp_[a-zA-Z0-9]{36}"                   # GitHub Personal Access Token
    "sk-[a-zA-Z0-9]{48}"                    # OpenAI API Key
    "-----BEGIN (RSA |EC )?PRIVATE KEY-----" # Private keys
)

for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        for pattern in "${SECRET_PATTERNS[@]}"; do
            MATCHES=$(grep -nP "$pattern" "$file" 2>/dev/null)
            if [ -n "$MATCHES" ]; then
                echo -e "${RED}❌ Potential secret found in $file:${NC}"
                echo "$MATCHES"
                ERRORS=$((ERRORS + 1))
            fi
        done
    fi
done

# -----------------------------------------------------------------------------
# 4. Run linter (if available)
# -----------------------------------------------------------------------------
echo "Checking for linter..."

if [ -f "package.json" ] && command -v npx &>/dev/null; then
    # JavaScript/TypeScript project — run ESLint on staged JS/TS files
    JS_FILES=$(echo "$STAGED_FILES" | grep -E '\.(js|jsx|ts|tsx)$')
    if [ -n "$JS_FILES" ]; then
        echo "Running ESLint..."
        echo "$JS_FILES" | xargs npx eslint --quiet 2>/dev/null
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ ESLint found errors.${NC}"
            ERRORS=$((ERRORS + 1))
        fi
    fi
elif [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
    # Python project — run flake8 if available
    PY_FILES=$(echo "$STAGED_FILES" | grep -E '\.py$')
    if [ -n "$PY_FILES" ] && command -v flake8 &>/dev/null; then
        echo "Running flake8..."
        echo "$PY_FILES" | xargs flake8
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ flake8 found errors.${NC}"
            ERRORS=$((ERRORS + 1))
        fi
    fi
fi

# -----------------------------------------------------------------------------
# Final result
# -----------------------------------------------------------------------------
echo ""
if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ Pre-commit check failed with $ERRORS issue(s).${NC}"
    echo "   Fix the issues above or commit with --no-verify to bypass."
    exit 1
else
    echo -e "${GREEN}✅ All pre-commit checks passed!${NC}"
    exit 0
fi
