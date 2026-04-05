#!/bin/bash
# auto_git.sh - Automatic git backup and GitHub repo creation
# Runs as a Stop hook after each Claude Code response
#
# 1. If no git repo, initializes one
# 2. If no GitHub remote, creates a private repo on sujai1
# 3. After 3 code-changing responses, auto-commits and pushes

# Prevent infinite loops: exit if this hook already triggered a continuation
INPUT=$(cat)
if echo "$INPUT" | grep -q '"stop_hook_active":\s*true'; then
    exit 0
fi

# Use git root if available, otherwise pwd
PROJECT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
PROJECT_NAME=$(basename "$PROJECT_DIR")
GITHUB_USER="sujai1"

# Safety: never auto-git the home directory or root
[ "$PROJECT_DIR" = "$HOME" ] && exit 0
[ "$PROJECT_DIR" = "/" ] && exit 0

# Counter state per project
COUNTER_DIR="/tmp/claude-auto-git"
mkdir -p "$COUNTER_DIR"
PROJECT_HASH=$(echo "$PROJECT_DIR" | md5 -q)
COUNTER_FILE="$COUNTER_DIR/$PROJECT_HASH.count"
STATE_FILE="$COUNTER_DIR/$PROJECT_HASH.state"

# --- Ensure git repo exists ---
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    # Only init if there are actual project files
    [ -z "$(ls -A 2>/dev/null)" ] && exit 0
    git init -q
    git add -A
    git commit -q -m "Initial commit (auto-generated)" || exit 0
fi

# Safety: don't operate if git root is the home directory
[ "$(git rev-parse --show-toplevel 2>/dev/null)" = "$HOME" ] && exit 0

# --- Ensure GitHub remote exists ---
if ! git remote get-url origin &>/dev/null; then
    gh repo create "$GITHUB_USER/$PROJECT_NAME" --private --source=. --push 2>/dev/null || true
fi

# --- Auto-commit after 3 code-changing responses ---
CURRENT_STATE=$(git status --porcelain 2>/dev/null)

# No uncommitted changes — nothing to do
[ -z "$CURRENT_STATE" ] && exit 0

# Detect if state actually changed since last check (new code modifications)
CURRENT_HASH=$(echo "$CURRENT_STATE" | md5 -q)
LAST_HASH=$(cat "$STATE_FILE" 2>/dev/null || echo "")

if [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
    # New changes detected — increment counter
    COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
    COUNT=$((COUNT + 1))
    echo "$COUNT" > "$COUNTER_FILE"
    echo "$CURRENT_HASH" > "$STATE_FILE"

    if [ "$COUNT" -ge 3 ]; then
        # Build commit message from changed files
        CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null)
        FILE_LIST=$(echo "$CHANGED_FILES" | sort -u | head -5 | tr '\n' ', ' | sed 's/,$//')
        FILE_COUNT=$(echo "$CHANGED_FILES" | sort -u | grep -c . || true)

        MSG="auto-backup: $FILE_LIST"
        [ "$FILE_COUNT" -gt 5 ] && MSG="auto-backup: $FILE_LIST (+$((FILE_COUNT - 5)) more)"

        git add -A
        git commit -q -m "$MSG" || true
        git push -q 2>/dev/null || git push -u origin HEAD -q 2>/dev/null || true

        # Reset counter
        echo 0 > "$COUNTER_FILE"
        echo "" > "$STATE_FILE"
    fi
fi
