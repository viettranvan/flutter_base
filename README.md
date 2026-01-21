## **Flutter Base Project**

[![Flutter Version](https://img.shields.io/badge/flutter-3.32.0-blue)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/dart-3.8.0-blue)](https://dart.dev)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)]()

A **production-ready Flutter base** with **Clean Architecture**, **BLoC pattern**, and **centralized error handling**. Built for team scalability and feature extensibility.

> **New to this project?** Start with [⚡ QUICK_START.md](./QUICK_START.md) (5 min setup)
> 
> **Want deep dive?** Read [📖 DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)

---

## 📖 Table of Contents

1. [Quick Start](#quick-start)
2. [Overview](#overview)
3. [Features](#features)
4. [Architecture](#architecture)
5. [Key Technologies](#key-technologies)
6. [Project Structure](#project-structure)
7. [Guides](#guides)
8. [Development](#development)
9. [Testing](#testing)
10. [Contributing](#contributing)
11. [License](#license)

---

## ⚡ Quick Start

```bash
# 1. Clone & setup
git clone <repo>
cd flutter_base
flutter pub get

# 2. Setup Git Hooks (auto format, analyze, test)
bash .githooks/setup.sh

# 3. Run
flutter run

# 4. Test login (debug console shows cURL command)
# Email: eve.holt@reqres.in | Any password
```

**See [QUICK_START.md](./QUICK_START.md) for details.**

> 💡 **Git Hooks Setup**: Runs `dart format`, `flutter analyze`, `flutter test`, and validates commit messages automatically.  
> Read more: [GIT_HOOKS_SETUP.md](./docs/GIT_HOOKS_SETUP.md)

---

## 🔍 Overview

A **production-ready** Flutter base built on **Clean Architecture** with:
- **Exception-based error handling** (no Either/dartz)
- **BLoC pattern** for state management
- **Centralized dependency injection** (GetIt)
- **Multiple HTTP clients** for different APIs
- **Auto curl extraction** for API debugging
- **Global error UI** (SnackBar/Dialog)

All designed for **team scalability** and **feature extensibility**.

<details>
  <summary>🛠 Environment</summary>

```
Flutter (Channel stable, 3.32.0, on macOS 14.1.1 23B81 darwin-arm64, locale en-VN)
• Flutter version 3.32.0 on channel stable
• Engine revision 1881800949
• Dart version 3.8.0
• DevTools version 2.45.1

Android toolchain (Android SDK version 33.0.2)
• Java OpenJDK 17.0.10

VS Code (version 1.91.1)
• Flutter extension v3.110.0
```

</details>

---

## 🚀 Key Features

* **Exception Pattern**: Simplified error handling (no Either/Left-Right)
* **BLoC State Management**: Consistent bloc pattern across features
* **Centralized DI**: GetIt with structured feature registration
* **Multiple HTTP Clients**: Named instances for different APIs (main + public)
* **Auto cURL Extraction**: Copy & test API calls instantly
* **Global Error Handler**: Automatic, smart UI error display
* **Feature Template**: Copy-paste structure for new features
* **Comprehensive Docs**: [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md) with patterns & examples
* **Localization**: Built-in support with generated files
* **Testing**: Unit & BLoC tests with Mocktail

---

## 🏗 Architecture

### Clean Architecture Pattern

```
┌─────────────────────────────────┐
│    PRESENTATION (UI + BLoC)     │
│  - Pages, Widgets, BLoCs        │
│  - State Management             │
└─────────────────┬───────────────┘
                  │ (depends on)
┌─────────────────▼───────────────┐
│      DOMAIN (Business Logic)    │
│  - Entities, UseCases           │
│  - Abstract Repositories        │
└─────────────────┬───────────────┘
                  │ (implements)
┌─────────────────▼───────────────┐
│  DATA (API, Local Storage)      │
│  - Models, DataSources          │
│  - Repository Implementations   │
└─────────────────────────────────┘
```

### Error Flow
```
Datasource (throws AppException)
    ↓
Repository (transforms model)
    ↓
BLoC (catches exception)
    ↓
GlobalErrorHandler (shows UI)
```

### Dependency Injection
Each feature has `dependencies.dart`:
```
Feature → _registerDataSources()
       → _registerRepositories()
       → _registerUseCases()
       → _registerBlocs()
       → buildFeaturePage()
```

---

## 📁 Project Structure

```
lib/
├── generated/              # Localization & codegen
├── l10n/                   # Localization files
├── src/
│   ├── core/               # Network, errors, utils
│   │   ├── errors/         # AppException hierarchy
│   │   ├── network/        # HTTP client, interceptors
│   │   └── utils/          # Logger, storage, etc
│   ├── features/           # Feature modules
│   │   ├── auth/           # Auth feature (example)
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   ├── presentation/
│   │   │   └── dependencies.dart  ← DI setup
│   │   ├── home/           # Home feature (example)
│   │   │   └── dependencies.dart
│   │   └── your_feature/   ← Add new features here
│   ├── router/             # Go Router setup
│   ├── error_handler.dart  # GlobalErrorHandler
│   ├── main.dart           # Entry point
│   └── injection_container.dart  # Central DI setup
└── packages/
    └── app_core/           # Shared packages
```

---

## 📖 Guides

### Getting Started
- **[QUICK_START.md](./QUICK_START.md)** - 5 min setup + key features
- **[DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)** - Deep dive architecture + patterns
    * Automation: generate_paths.dart scans the assets folder and “generates” a Dart file containing path constants—reducing errors when refactoring assets.


> **Note:** Run `dart run packages/design_assets/tools/generate_paths.dart` to sync assets paths.

---

## ⚙️ Data Flow

1. UI (`presentation`): Bloc handles event → call `usecase` in `domain`
2. `UseCase` → call `repository` (abstract)
3. `Repository` is implemented in `data` (`RepositoryImpl`), where API or database calls are made.
4. `RepositoryImpl` convert `Model.toEntity()` → `Entity`
5. Results flow back: `data` → `domain` (`UseCase`) → `presentation` (`Bloc`)

---

## 🧪 Testing

* **Frameworks**: `flutter_test`, `bloc_test`, `mocktail`, `dartz`.
* **Test Types**:

  * Model: JSON serialization & entity conversion.
  * DataSource: Mock API/DB responses.
  * Repository: Success/failure via `Either<L, R>`.
  * UseCase: Business logic validation.
  * Presentation: Bloc/Cubit state flow.

---
