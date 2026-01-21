#!/bin/bash

# Shared validation script for commit message format
# Called by: pre-commit and commit-msg hooks
# Usage: bash validate-message.sh <commit-message-file>

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(head -n1 "$COMMIT_MSG_FILE")

# Allowed types
TYPES="feat|fix|docs|style|refactor|test|chore|ci|perf|build"

# Validate format: type(scope): message OR type: message
if ! echo "$COMMIT_MSG" | grep -qE "^($TYPES)(\(.+\))?:"; then
  echo -e "${RED}❌ Invalid commit message format!${NC}"
  echo -e "\n${YELLOW}Allowed format:${NC}"
  echo "  type(scope): subject"
  echo "  type: subject"
  echo -e "\n${YELLOW}Allowed types:${NC}"
  echo "  feat     - A new feature"
  echo "  fix      - A bug fix"
  echo "  docs     - Documentation"
  echo "  style    - Code style (formatting, missing semicolons)"
  echo "  refactor - Code refactoring"
  echo "  test     - Adding or updating tests"
  echo "  chore    - Build process, dependencies"
  echo "  ci       - CI/CD changes"
  echo "  perf     - Performance improvements"
  echo "  build    - Build system"
  echo -e "\n${YELLOW}Examples:${NC}"
  echo "  feat(auth): add login functionality"
  echo "  fix(home): resolve navigation bug"
  echo "  docs: update README"
  exit 1
fi

# Validate subject line (not too long)
SUBJECT_LENGTH=${#COMMIT_MSG}
if [ $SUBJECT_LENGTH -gt 100 ]; then
  echo -e "${RED}❌ Subject line too long (max 100 chars, got $SUBJECT_LENGTH)${NC}"
  exit 1
fi

# Validate subject starts with lowercase (after type and scope)
# Remove "type(scope): " or "type: " prefix to get the actual subject
SUBJECT=$(echo "$COMMIT_MSG" | sed -E 's/^[a-zA-Z]+(\([^)]*\))?:\s+//')
if [[ $SUBJECT =~ ^[A-Z] ]]; then
  echo -e "${RED}❌ Subject should start with lowercase${NC}"
  echo -e "${YELLOW}Current: $COMMIT_MSG${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Commit message format valid!${NC}"
exit 0
