#!/bin/bash

# Setup script - Initialize git hooks for the project
# Run this after cloning or setup
# Cross-platform compatible (macOS, Linux, Windows Git Bash)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Flutter Project - Git Hooks Setup${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

# Get project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS_DIR="$PROJECT_ROOT/.githooks"

echo -e "${YELLOW}📍 Project root: $PROJECT_ROOT${NC}"
echo -e "${YELLOW}📍 Hooks directory: $HOOKS_DIR${NC}\n"

# Check if git is installed
if ! command -v git &> /dev/null; then
  echo -e "${RED}❌ Git is not installed${NC}"
  exit 1
fi

# Check if flutter is installed
if ! command -v flutter &> /dev/null; then
  echo -e "${RED}❌ Flutter is not installed${NC}"
  exit 1
fi

# Configure git hooks path
echo -e "${YELLOW}🔧 Configuring git hooks...${NC}"
git config core.hooksPath .githooks

# Make hooks executable
echo -e "${YELLOW}📝 Making hooks executable...${NC}"
chmod +x "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/commit-msg"
chmod +x "$HOOKS_DIR/validate-message.sh"

echo -e "${YELLOW}📝 Making this script executable...${NC}"
chmod +x "$HOOKS_DIR/setup.sh"

# Test hooks
echo -e "\n${YELLOW}🧪 Testing hooks installation...${NC}"
HOOKS_PATH=$(git config core.hooksPath)

if [ "$HOOKS_PATH" = ".githooks" ]; then
  echo -e "${GREEN}✓ Git hooks configured successfully${NC}"
else
  echo -e "${RED}❌ Git hooks configuration failed${NC}"
  exit 1
fi

# Check if hooks files exist
if [ -f "$HOOKS_DIR/pre-commit" ] && [ -x "$HOOKS_DIR/pre-commit" ]; then
  echo -e "${GREEN}✓ pre-commit hook is ready${NC}"
else
  echo -e "${RED}❌ pre-commit hook not found or not executable${NC}"
  exit 1
fi

if [ -f "$HOOKS_DIR/commit-msg" ] && [ -x "$HOOKS_DIR/commit-msg" ]; then
  echo -e "${GREEN}✓ commit-msg hook is ready${NC}"
else
  echo -e "${RED}❌ commit-msg hook not found or not executable${NC}"
  exit 1
fi

if [ -f "$HOOKS_DIR/validate-message.sh" ] && [ -x "$HOOKS_DIR/validate-message.sh" ]; then
  echo -e "${GREEN}✓ validate-message script is ready${NC}"
else
  echo -e "${RED}❌ validate-message script not found or not executable${NC}"
  exit 1
fi

echo -e "\n${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Setup complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}📋 What happens on your next commit:${NC}"
echo -e "  1. Code will be auto-formatted (dart format)"
echo -e "  2. Code will be analyzed (flutter analyze)"
echo -e "  3. Tests will run (flutter test)"
echo -e "  4. Commit message will be validated\n"

echo -e "${YELLOW}💡 Tips:${NC}"
echo -e "  • To skip hooks: git commit --no-verify"
echo -e "  • Hook files: .githooks/"
echo -e "  • Edit hooks to customize behavior\n"

exit 0
