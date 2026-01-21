#!/usr/bin/env sh

# Shared validation script for commit message format
# Usage: validate-message.sh <commit-message-file>

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
  printf "%b\n" "$1"
}

COMMIT_MSG_FILE="$1"
COMMIT_MSG=$(head -n1 "$COMMIT_MSG_FILE")

# ===============================
# Allow fixup! / squash! commits
# ===============================
if printf "%s" "$COMMIT_MSG" | grep -qE '^(fixup|squash)! '; then
  log "${GREEN}✓ Fixup/Squash commit detected — skipping validation${NC}"
  exit 0
fi

# ===============================
# Allowed types
# ===============================
TYPES="feat|fix|docs|style|refactor|test|chore|ci|perf|build"

# ===============================
# Validate format
# ===============================
if ! printf "%s" "$COMMIT_MSG" | grep -qE "^($TYPES)(\([a-z0-9_-]+\))?:\s.+"; then
  log "${RED}❌ Invalid commit message format!${NC}"
  log ""
  log "${YELLOW}Allowed format:${NC}"
  log "  type(scope): subject"
  log "  type: subject"
  log ""
  log "${YELLOW}Allowed types:${NC}"
  log "  feat | fix | docs | style | refactor | test | chore | ci | perf | build"
  log ""
  log "${YELLOW}Examples:${NC}"
  log "  feat(auth): add login functionality"
  log "  fix(home): resolve navigation bug"
  log "  docs: update README"
  exit 1
fi

# ===============================
# Validate subject length
# ===============================
SUBJECT_LENGTH=${#COMMIT_MSG}
if [ "$SUBJECT_LENGTH" -gt 100 ]; then
  log "${RED}❌ Subject line too long (max 100 chars, got $SUBJECT_LENGTH)${NC}"
  exit 1
fi

# ===============================
# Validate subject lowercase
# ===============================
SUBJECT=$(printf "%s" "$COMMIT_MSG" | sed -E 's/^[a-z]+(\([^)]*\))?:\s+//')

if printf "%s" "$SUBJECT" | grep -qE '^[A-Z]'; then
  log "${RED}❌ Subject should start with lowercase${NC}"
  log "${YELLOW}Current:${NC} $COMMIT_MSG"
  exit 1
fi

log "${GREEN}✅ Commit message format valid!${NC}"
exit 0