# Overview

A basic Flutter project based on Clean Architecture and using Go Router

```
[✓] Flutter (Channel stable, 3.32.0, on macOS 14.1.1 23B81 darwin-arm64, locale en-VN) [5.4s]
    • Flutter version 3.32.0 on channel stable
    • Engine revision 1881800949
    • Dart version 3.8.0
    • DevTools version 2.45.1

[✓] Android toolchain - develop for Android devices (Android SDK version 33.0.2) [12.2s]
    • Java version OpenJDK Runtime Environment (build 17.0.10+0-17.0.10b1087.21-11609105)

[✓] VS Code (version 1.91.1) [9ms]
    • Flutter extension version 3.110.0

```

## OVERVIEW OF CLEAN ARCHITECTURE MODEL

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
1. `presentation/`:
    * Tasks: UI (Widgets, Screens), state management (Bloc, Riverpod, Provider,...)
    * Does not contain business logic.
    * Only calls UseCase from domain.
2. `domain/`: The central layer of the system, Includes:
    * Entities: pure objects (pure models), not dependent on Flutter.
    * UseCases: independent business logic.
    * Abstract Repositories: defines what the repository needs to do (not concerned with installation).
    
    🔸 => This is the only layer that does not depend on any other layer.
3. `data/`: Contains all specific settings:
    * Model (usually from JSON API)
    * DataSources (remote/local)
    * Repository Implementations: implement interfaces in domain

    Can call `http`, `shared_preferences`, `sqflite`, etc.
  
## Project structure
```
lib/
├── generated/                  # Generated localization files, codegen, etc.
├── l10n/                       # App localization config
├── src/                        # Main source code
│   ├── core/                   # Core utilities: network, error handling
│   │   ├── network/
│   │   ├── errors.dart
│   ├── features/               # Main app features
│   │   ├── auth/               # Authentication feature
│   │   │   ├── data/           # Data layer: API, models, repos
│   │   │   │   ├── datasources/
│   │   │   │   │   └── auth_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── authenticate_model.dart
│   │   │   │   │   └── user_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   ├── domain/         # Domain layer: entities, usecases, abstract repos
│   │   │   │   ├── entities/
│   │   │   │   │   ├── authenticate.dart
│   │   │   │   │   └── user.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── login_usecase.dart
│   │   │   │       └── register_user.dart
│   │   │   ├── presentation/   # UI & state management
│   │   │   │   ├── pages/      # UI
│   │   │   │   ├── auth_index.dart   # Entry point for auth feature UI
│   │   │   │   └── auth_injection.dart # Dependency injection for auth
│   │   ├── home/               # Home feature
│   │   ├── profile/            # Profile feature
│   ├── app_nav.dart            # App navigation config
│   ├── page_index.dart         # Page index mapping (navigation)
│   ├── router/                 # Routing logic
│   ├── injection_container.dart # Global Dependency Injection (get_it)
├── main.dart                   # App entry point
├── packages/                   # Third-party packages or local packages
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

    **Note:** To generate assets path, firstly you have to navigate to the root directory, then run following command:
    ```bash
    dart run packages/design_assets/tools/generate_paths.dart
    ```

## DATA FLOW
1. UI (`presentation`): Bloc handles event → call `usecase` in `domain`
2. `UseCase` → call `repository` (abstract)
3. `Repository` is implemented in `data` (`RepositoryImpl`), where API or database calls are made.
4. `RepositoryImpl` convert `Model.toEntity()` → `Entity`
4. Results flow back: `data` → `domain` (`UseCase`) → `presentation` (`Bloc`)

## Unit test

1. **Main tool**: package using
    * `flutter_test`: basic testing framework
    * `mocktail`: mock and verify dependencies
    * `dartz`: using `Either<L,R>` to test success/failure
    * `bloc_test`: test the state flow of Bloc/Cubit

2. **Test writing flow**:
    * `Model Tests`: Test AuthenticateModel.fromJson(...), .toEntity(), props.
    * `Datasource Tests`: Mock `Dio` returns `Response` success/error, check datasource throws correct error or returns model.
    * `Repository Tests`: Mock Dio returns Response success/error, check datasource throws correct error or returns model.
    * `Repository Tests`: Mock datasource, when success returns `Right(entity)`, when datasource throws must catch and return `Left(ServerFailure)`.
    * `UseCase Tests`: Mock repository, test `usecase.call(...)` returns correct Either.
    * `Bloc Tests`: Mock usecase (and storage if any), use `blocTest` to send event, assert correct sequence of states, verify correct dependency call.