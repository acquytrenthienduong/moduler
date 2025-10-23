# 📂 Project Structure

## 🎯 Overview

Project được tổ chức theo **Feature-based Modular Architecture** với **Clean Architecture principles**.

```
lib/
├── core/                      # Core utilities & configuration
├── features/                  # Feature modules (business logic)
├── shared/                    # Shared components
└── main.dart                  # Entry point
```

---

## 📁 Detailed Structure

### 1. Core Layer (`lib/core/`)

Chứa utilities, configuration, và services dùng chung cho toàn app.

```
core/
├── core.dart                  ✅ Barrel export
│
├── constants/
│   └── app_constants.dart     # App-wide constants (API URLs, timeout, etc)
│
├── di/
│   ├── injection.dart         # GetIt + Injectable config
│   └── injection.config.dart  # Generated (build_runner)
│
├── models/
│   └── user.dart              # Core models (User, Error, Response)
│
├── network/
│   └── api_client.dart        # BaseApiClient + multiple API clients
│
├── router/
│   └── app_router.dart        # GoRouter config + auth guards
│
├── theme/
│   └── app_theme.dart         # Material theme configuration
│
└── utils/
    └── logger.dart            # Logging utility
```

**Key files:**
- **api_client.dart**: Pattern để tạo nhiều API clients cho các base URL khác nhau
- **injection.dart**: Dependency Injection setup
- **app_router.dart**: Routing + authentication guards
- **core.dart**: Export tất cả core utilities

---

### 2. Features Layer (`lib/features/`)

Mỗi **feature = 1 module độc lập** với cấu trúc theo Clean Architecture.

```
features/
├── auth/
│   ├── auth.dart              ✅ Barrel export
│   ├── data/
│   │   └── repositories/
│   │       └── auth_repository.dart      # @singleton
│   └── presentation/
│       ├── pages/
│       │   └── login_page.dart           # ConsumerWidget
│       └── providers/
│           └── auth_provider.dart         # Riverpod Generator
│
├── home/
│   ├── home.dart              ✅ Barrel export
│   └── presentation/
│       └── pages/
│           └── home_page.dart
│
├── profile/
│   ├── profile.dart           ✅ Barrel export
│   └── presentation/
│       └── pages/
│           └── profile_page.dart
│
├── settings/
│   ├── settings.dart          ✅ Barrel export
│   └── presentation/
│       └── pages/
│           └── settings_page.dart
│
└── product/                   # Example module (full structure)
    ├── product.dart           ✅ Barrel export
    ├── data/
    │   ├── models/
    │   │   ├── product.dart            # Freezed model
    │   │   ├── product.freezed.dart    # Generated
    │   │   └── product.g.dart          # Generated
    │   └── repositories/
    │       └── product_repository.dart  # @singleton
    └── presentation/
        ├── pages/
        │   └── product_list_page.dart   # ConsumerWidget
        └── providers/
            ├── product_provider.dart    # Riverpod Generator
            └── product_provider.g.dart  # Generated
```

**Module structure pattern:**
```
feature_name/
├── feature_name.dart          # Barrel export
├── data/
│   ├── models/               # Freezed models + JSON serialization
│   ├── repositories/         # Business logic + API calls
│   └── datasources/          # (optional) API/Database layer
└── presentation/
    ├── pages/                # UI screens
    ├── providers/            # State management (Riverpod)
    └── widgets/              # Feature-specific widgets
```

---

### 3. Shared Layer (`lib/shared/`)

Components dùng chung >= 3 modules.

```
shared/
├── shared.dart                ✅ Barrel export
│
├── utils/
│   ├── validators.dart        # Form validators (email, phone, etc)
│   ├── formatters.dart        # Data formatters (currency, date, etc)
│   └── extensions.dart        # Dart extensions (String, DateTime, etc)
│
└── widgets/
    ├── custom_button.dart     # Reusable button
    ├── loading_widget.dart    # Loading indicator
    └── ...                    # Other shared widgets
```

**Guidelines:**
- ✅ Widgets dùng >= 3 modules → Shared
- ❌ Widgets dùng 1-2 modules → Giữ trong feature module đó

---

## 🔄 Data Flow

### Request Flow (User → API)

```
UI (Page)
  ↓ ref.read(provider.notifier).action()
Provider (Riverpod)
  ↓ ref.read(repositoryProvider)
Repository (@singleton)
  ↓ apiClient.get/post()
ApiClient
  ↓ HTTP Request
API Server
```

### Response Flow (API → User)

```
API Server
  ↓ JSON Response
ApiClient
  ↓ Map<String, dynamic>
Repository
  ↓ fromJson() → Model (Freezed)
Provider
  ↓ state = AsyncValue<Model>
UI (Page)
  ↓ ref.watch(provider) → UI update
User sees result
```

---

## 📦 Import Strategy

### ✅ Barrel Exports (Recommended)

Mỗi module có 1 barrel export file:

```dart
// features/product/product.dart
export 'data/models/product.dart';
export 'data/repositories/product_repository.dart';
export 'presentation/providers/product_provider.dart';
export 'presentation/pages/product_list_page.dart';
```

**Usage:**
```dart
// ✅ Clean - 1 import
import '../product/product.dart';

// ❌ Messy - nhiều imports
import '../product/data/models/product.dart';
import '../product/data/repositories/product_repository.dart';
import '../product/presentation/providers/product_provider.dart';
```

### Import Order (Convention)

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Packages
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// 4. App - Core (barrel export)
import '../../core/core.dart';

// 5. App - Features (barrel exports)
import '../auth/auth.dart';
import '../product/product.dart';

// 6. App - Shared (barrel export)
import '../../shared/shared.dart';

// 7. Relative imports (same module)
import 'widgets/product_card.dart';
```

---

## 🔧 Code Generation Files

Generated files (không commit vào git):

```
*.g.dart              # json_serializable, riverpod_generator
*.freezed.dart        # freezed
*.config.dart         # injectable_generator
```

Regenerate:
```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🎨 Architecture Principles

### 1. Separation of Concerns
- **Data layer**: Models, Repositories, DataSources
- **Presentation layer**: Pages, Widgets, Providers

### 2. Dependency Injection
- `@singleton` cho repositories, services
- `GetIt` + `Injectable` auto-registration
- Riverpod cho state management

### 3. Single Responsibility
- 1 file = 1 class/widget/function chính
- Tách logic phức tạp thành functions/classes riêng

### 4. Immutability
- Freezed models (immutable)
- Riverpod state (immutable updates)

### 5. Testability
- Repository có thể mock ApiClient
- Provider có thể override trong tests
- UI logic tách riêng khỏi widgets

---

## 📊 Complexity Levels

### Simple Module (Profile)
```
profile/
├── profile.dart
└── presentation/
    └── pages/
        └── profile_page.dart
```
→ Chỉ UI, không có business logic

### Standard Module (Auth)
```
auth/
├── auth.dart
├── data/
│   └── repositories/
│       └── auth_repository.dart
└── presentation/
    ├── pages/
    │   └── login_page.dart
    └── providers/
        └── auth_provider.dart
```
→ Có repository + provider

### Complex Module (Product)
```
product/
├── product.dart
├── data/
│   ├── models/
│   │   └── product.dart (Freezed)
│   ├── repositories/
│   │   └── product_repository.dart
│   └── datasources/
│       ├── product_remote_datasource.dart
│       └── product_local_datasource.dart
└── presentation/
    ├── pages/
    │   ├── product_list_page.dart
    │   └── product_detail_page.dart
    ├── providers/
    │   ├── product_list_provider.dart
    │   └── product_detail_provider.dart
    └── widgets/
        ├── product_card.dart
        └── product_filter.dart
```
→ Full Clean Architecture với local cache

---

## 🚀 Scaling Strategy

### Khi module trở nên lớn:

1. **Tách thành sub-features**
```
product/
├── list/
├── detail/
└── cart/
```

2. **Tách domain layer**
```
product/
├── domain/
│   ├── entities/
│   └── usecases/
├── data/
└── presentation/
```

3. **Micro-frontend approach**
```
modules/
├── product_module/
├── order_module/
└── user_module/
```

---

## 📖 Related Documentation

- **README.md** - Project overview & quick start
- **PROJECT_TEMPLATE.md** - Setup guide cho project mới
- **FREEZED_3_SYNTAX.md** - Freezed reference
- **BARREL_EXPORTS.md** - Import patterns

---

**Last updated:** Oct 2024

