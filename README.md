## **My Flutter App**

[![Flutter Version](https://img.shields.io/badge/flutter-3.32.0-blue)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/dart-3.8.0-blue)](https://dart.dev)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)]()

A **Clean Architecture** Flutter starter project, using **Go Router** for navigation. Designed to be modular, testable, and scalable.

---

## 📖 Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Architecture](#architecture)
4. [Project Structure](#project-structure)
5. [Getting Started](#getting-started)
6. [Data Flow](#data-flow)
7. [Testing](#testing)
8. [Contributing](#contributing)
9. [License](#license)

---

## 🔍 Overview

A basic Flutter application built on **Clean Architecture** principles, with clear separation of concerns across presentation, domain, and data layers. Uses **Go Router** for declarative, type-safe routing.

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

## 🚀 Features

* **Modular**: Layers (presentation, domain, data) clearly separated.
* **Routing**: Uses Go Router for nested, declarative routes.
* **State Management**: Supports Bloc, Riverpod, Provider, or your choice.
* **Localization**: Built-in support with generated files in `generated/` and config in `l10n/`.
* **Core Utilities**: Network handling, error management, and common constants.
* **Theming & Assets**: Centralized design tokens and asset generation.
* **Testing**: Ready-made unit and integration test setups.

---

## 🏗 Architecture


```
                    +--------------------------+
                    |      presentation        |
                    |   (UI + State Manager)   |
                    +--------------------------+
                                |
                                ↓
                    +--------------------------+
                    |         domain           |
                    | (usecases + entities +   |
                    |   abstract repository)   |
                    +--------------------------+
                                |
                                ↓
                    +--------------------------+
                    |          data            |
                    | (models + repository     |
                    | implementation + API/db) |
                    +--------------------------+

```

1. **presentation/**

   * UI: Widgets & Screens
   * State: Bloc/Cubit, Riverpod, etc.
   * Depends *only* on domain use cases.

2. **domain/**

   * Entities: Pure data models.
   * UseCases: Business logic.
   * Abstract Repositories: Contracts for data.

3. **data/**

   * Models: from JSON/API.
   * DataSources: remote/local implementations.
   * RepositoryImpl: Fulfills domain contracts.

---

## 📁 Project Structure

```
lib/
├── generated/             # Localization & codegen
├── l10n/                  # Localization config
├── src/                   # Core source
│   ├── core/              # Network, errors, utils
│   ├── features/          # Feature modules
│   │   ├── auth/          # Authentication feature
│   │   ├── home/          # Home feature
│   │   └── profile/       # Profile feature
│   ├── app_nav.dart       # Route definitions
│   ├── page_index.dart    # Page mapping
│   ├── router/            # Routing logic - Using go router
│   └── injection_container.dart # Dependency Injection (GetIt)
├── main.dart              # Entry point
└── packages/              # Local & 3rd-party packages
```

* `core/`: Contains common components (networking, error handling, constants).
* `features/auth/`: Authentication feature (each feature contains: `data/`, `domain/`, `presentation/` and injection file)
  * `data/`: Contains data source (API), models, and implementation repository
  * `domain/`: Contains domain layer: entity definition, repository abstract, usecase
  * `presentation`: Interface & presentation logic for auth feature
  * `feature_injection.dart`: 
* `injection_container.dart`: Central file for dependency injection (GetIt).
* `page_index.dart` & `app_nav.dart`: Supports defining main routes (navigation)
* `packages/design_assets`: 
    * Contains assets (icons, images, fonts) of the project
    * Helper & wrapper: using `shared_preferences` and `flutter_secure_storage` to storage, `debouncer.dart` helps debounce input operations.
    * Consistent UI: define the theme, fonts, and typography used throughout.
    * Reusable Widgets: define common widgets (cache image, rating bar, shimmer, read-more)
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
