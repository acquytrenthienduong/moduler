# Core Package

Core infrastructure package containing:

## 📦 Contents

- **Network**: API client, interceptors, exceptions
- **DI**: Dependency injection setup (GetIt + Injectable)
- **Storage**: Local storage abstractions
- **Router**: Navigation configuration
- **Models**: Shared data models
- **Theme**: App theming
- **Utils**: Common utilities (logger, validators, etc.)
- **Constants**: App-wide constants

## 🔧 Usage

```yaml
dependencies:
  core:
    path: ../packages/core
```

```dart
import 'package:core/core.dart';

// Use API client
final client = ApiClient();

// Use DI
await configureDependencies();
final repo = getIt<AuthRepository>();

// Use logger
Logger.info('Hello from core!');
```

## 🏗️ Architecture

This package is the foundation layer and should:
- ✅ Be independent of business logic
- ✅ Be reusable across multiple apps
- ✅ Have minimal dependencies
- ❌ NOT depend on feature packages

