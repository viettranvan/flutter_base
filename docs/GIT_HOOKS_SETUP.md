# Git Hooks Setup Guide

> 🎯 Tự động chuẩn hóa commit message và chất lượng code mà **không cần cài thêm tools** (pure Git + shell scripts)

## 🚀 Quick Start

### Lần đầu tiên (sau khi clone)

```bash
# Chạy setup script
bash .githooks/setup.sh
```

**Hoặc manual:**
```bash
# Configure git
git config core.hooksPath .githooks

# Make executable
chmod +x .githooks/pre-commit
chmod +x .githooks/commit-msg
```

---

## 📋 Các bước tự động chạy trước mỗi commit

### **Pre-commit Hook** - Tự động chạy trước khi commit

1. **Format code** 🎨
   - Tự động format toàn bộ Dart files
   - Line length: 120 characters
   - Formatted files tự động được re-stage

2. **Analyze code** 🔍
   - Chạy `flutter analyze`
   - Phát hiện lỗi, warnings

3. **Run tests** 🧪
   - Chạy unit tests
   - Đảm bảo code không break

### **Commit-msg Hook** - Validate commit message

Format được yêu cầu:
```
type(scope): subject
```

**Allowed types:**
- `feat` - Tính năng mới
- `fix` - Bug fix
- `docs` - Documentation
- `style` - Formatting
- `refactor` - Refactor code
- `test` - Tests
- `chore` - Build, dependencies
- `ci` - CI/CD changes
- `perf` - Performance
- `build` - Build system

**Examples:**
```bash
git commit -m "feat(auth): add login functionality"
git commit -m "fix(home): resolve navigation bug"
git commit -m "docs: update README"
git commit -m "refactor(core): simplify error handling"
```

---

## 🛠️ Tùy chỉnh hooks

### Chỉnh sửa pre-commit hook

File: [.githooks/pre-commit](./.githooks/pre-commit)

```bash
# Ví dụ: Bỏ test (nếu quá chậm)
# Comment out dòng: flutter test --coverage
```

### Chỉnh sửa commit-msg validation

File: [.githooks/validate-message.sh](./.githooks/validate-message.sh)

```bash
# Ví dụ: Thêm type mới
TYPES="feat|fix|docs|style|refactor|test|chore|your-type"
```

---

## ⚡ Bypass hooks (nếu cần)

```bash
# Skip pre-commit checks
git commit --no-verify -m "your message"

# Hoặc short form
git commit -n -m "your message"
```

---

## 🔍 Troubleshooting

### ❌ "permission denied: .githooks/pre-commit"

```bash
chmod +x .githooks/pre-commit
chmod +x .githooks/commit-msg
chmod +x .githooks/validate-message.sh
```

### ❌ "dart: command not found"

Đảm bảo Flutter đã được cài đặt và thêm vào PATH:
```bash
flutter --version
```

### ❌ "Hooks không chạy"

Kiểm tra git config:
```bash
git config core.hooksPath
# Output: .githooks
```

Nếu trống, chạy:
```bash
bash scripts/setup-hooks.sh
```

---

## 📂 File Structure

```
.githooks/
├── pre-commit              # Main hook: validate → format → analyze → test
├── commit-msg              # Safety hook: validate message (if edited)
└── validate-message.sh     # Shared validation logic (DRY)
```

---

## 💡 Tips

- Hooks chạy **local only**, không ảnh hưởng server
- Nếu format code thay đổi, hooks sẽ **re-stage** tự động
- Tất cả team members dùng **cùng config**
- **Cross-platform**: macOS, Linux, Windows (Git Bash)

---

## ✅ Checklist sau setup

- [ ] Chạy `bash .githooks/setup.sh`
- [ ] Test commit: `git commit -m "test: verify hooks work"`
- [ ] Nếu failed, fix lỗi suggestion
- [ ] Nếu thành công, continue normal workflow
