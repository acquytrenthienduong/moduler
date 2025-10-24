# 🏗️ Architecture & Development Guide - Final

> **Clean Architecture** + **Riverpod 3.x** + **Dio 5.x** + **Freezed 3.x** + **Injectable**

---

## 📊 Project Overview

### Stats
- **Source Files**: 35 Dart files
- **Modules**: 5 features (auth, home, profile, settings, product)
- **Interceptors**: 4 (Auth, RefreshToken, Retry, Logging)
- **Documentation**: 8 MD files
- **Build Status**: ✅ 0 errors

### Tech Stack
| Component | Package | Version |
|-----------|---------|---------|
| Framework | Flutter | 3.35.0 |
| Language | Dart | 3.8.0 |
| State | Riverpod + Generator | 3.0.3 |
| HTTP | **Dio** | 5.9.0 |
| DI | GetIt + Injectable | 8.0.2 / 2.5.0 |
| Router | GoRouter | 16.3.0 |
| Models | Freezed | 3.1.0 |
| Storage | SharedPreferences | 2.3.3 |

---

## 🎯 Kiến trúc Tổng quan

```
┌─────────────────────────────────────────────────────┐
│                   PRESENTATION                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │  Pages   │→ │ Providers│→ │  Widgets │          │
│  │(UI/UX)   │  │(Riverpod)│  │(Reusable)│          │
│  └──────────┘  └──────────┘  └──────────┘          │
└────────────────────┬────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────┐
│                     DOMAIN                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │  Models  │  │Repositories│ │ Use Cases│          │
│  │(Freezed) │  │(Business)  │ │(Optional)│          │
│  └──────────┘  └──────────┘  └──────────┘          │
└────────────────────┬────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────┐
│                      DATA                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │   API    │  │  Local   │  │  Models  │          │
│  │ (Dio)    │  │(SharedP.)│  │  (DTO)   │          │
│  └──────────┘  └──────────┘  └──────────┘          │
└─────────────────────────────────────────────────────┘
```

---

## 📁 Cấu trúc Project Chi tiết

### 1. Core Layer (`lib/core/`)

**Purpose**: Utilities, configuration, services dùng chung

```
core/
├── core.dart                    ⭐ Barrel export
│
├── constants/
│   └── app_constants.dart       # URLs, timeouts, configs
│
├── di/                          # Dependency Injection
│   ├── injection.dart           # GetIt setup + Interceptors config
│   └── injection.config.dart    # Generated
│
├── models/                      # Core models
│   ├── user.dart                # Freezed model
│   ├── user.freezed.dart        # Generated
│   └── user.g.dart              # Generated
│
├── network/                     # API Layer
│   ├── api_client.dart          # BaseApiClient + ApiClient (Dio)
│   └── interceptors/            # 4 interceptors
│       ├── auth_interceptor.dart
│       ├── refresh_token_interceptor.dart
│       ├── retry_interceptor.dart
│       ├── logging_interceptor.dart
│       └── interceptors.dart    # Barrel export
│
├── router/
│   └── app_router.dart          # GoRouter + auth guards
│
├── theme/
│   └── app_theme.dart           # Material 3 theme
│
└── utils/
    └── logger.dart              # Logging utility
```

**Key Points:**
- ✅ Barrel export: `import 'core/core.dart';`
- ✅ Interceptors setup trong `injection.dart`
- ✅ BaseApiClient pattern để support nhiều APIs

---

### 2. Features Layer (`lib/features/`)

**Purpose**: Feature modules (business logic + UI)

**Standard Module Structure:**
```
feature_name/
├── feature_name.dart            ⭐ Barrel export
│
├── data/
│   ├── models/                  # Freezed models
│   │   ├── model.dart
│   │   ├── model.freezed.dart   # Generated
│   │   └── model.g.dart         # Generated
│   │
│   ├── repositories/            # Business logic + API calls
│   │   └── repository.dart      # @singleton
│   │
│   └── datasources/             # (Optional) Tách API/DB layer
│       ├── remote_datasource.dart
│       └── local_datasource.dart
│
└── presentation/
    ├── pages/                   # UI screens
    │   └── page.dart            # ConsumerWidget/StatefulWidget
    │
    ├── providers/               # Riverpod state management
    │   ├── provider.dart        # Riverpod Generator
    │   └── provider.g.dart      # Generated
    │
    └── widgets/                 # Feature-specific widgets
        └── custom_widget.dart
```

**Current Modules:**

1. **auth/** - Authentication
   - `login_page.dart` - UI login
   - `auth_provider.dart` - State management
   - `auth_repository.dart` - Business logic

2. **home/** - Home screen với tabs
   - `home_page.dart` - Container cho 2 tabs

3. **profile/** - User profile tab
   - `profile_page.dart` - Display user info

4. **settings/** - Settings tab
   - `settings_page.dart` - Settings + logout

5. **product/** - Example full module
   - Models: `product.dart` (Freezed)
   - Repository: `product_repository.dart`
   - Provider: `product_provider.dart`
   - UI: `product_list_page.dart`

---

### 3. Shared Layer (`lib/shared/`)

**Purpose**: Components dùng >= 3 modules

```
shared/
├── shared.dart                  ⭐ Barrel export
│
├── utils/                       # Utilities
│   ├── validators.dart          # Form validators
│   ├── formatters.dart          # Data formatters
│   └── extensions.dart          # Dart extensions
│
└── widgets/                     # Reusable widgets
    ├── custom_button.dart
    └── loading_widget.dart
```

**Guidelines:**
- ✅ Dùng >= 3 modules → shared
- ❌ Dùng 1-2 modules → giữ trong module đó

---

## 🔄 Data Flow

### Request Flow
```
User Action (UI)
    ↓
ref.read(provider.notifier).action()
    ↓
Provider (Riverpod)
    ↓
ref.read(repositoryProvider)
    ↓
Repository (@singleton)
    ↓
ApiClient.get/post() (Dio)
    ↓
[Interceptors]
  1. Logging
  2. Auth (add token)
  3. RefreshToken (handle 401)
  4. Retry (network errors)
    ↓
HTTP Request → API Server
```

### Response Flow
```
API Server (JSON)
    ↓
[Interceptors process]
    ↓
ApiClient (Map<String, dynamic>)
    ↓
Repository
  - fromJson() → Model (Freezed)
  - Business logic
    ↓
Provider
  - state = AsyncValue<Model>
    ↓
UI rebuild (ref.watch)
    ↓
User sees result
```

---

## 🔌 Interceptors Architecture

### Setup Location
**File:** `lib/core/di/injection.dart`

```dart
@singleton
ApiClient apiClient(SharedPreferences prefs) {
  final client = ApiClient.withoutInterceptors();
  
  // Thứ tự quan trọng!
  client.dio.interceptors.addAll([
    // 1. Logging - LUÔN ĐẦU TIÊN
    CustomLoggingInterceptor(
      logRequest: true,
      logResponse: true,
      logError: true,
    ),
    
    // 2. Auth - Add token
    AuthInterceptor(prefs),
    
    // 3. RefreshToken - Handle 401
    RefreshTokenInterceptor(client.dio, prefs),
    
    // 4. Retry - Network errors
    RetryInterceptor(
      maxRetries: 3,
      initialDelay: Duration(seconds: 1),
    ),
  ]);
  
  return client;
}
```

### Interceptor Flow
```
Request
  ↓
1. LoggingInterceptor.onRequest
  ↓
2. AuthInterceptor.onRequest (add token)
  ↓
[HTTP Request]
  ↓
Response/Error
  ↓
3. RefreshTokenInterceptor.onError (if 401)
  - Call /auth/refresh
  - Retry with new token
  ↓
4. RetryInterceptor.onError (if timeout/5xx)
  - Exponential backoff
  - Retry max 3 times
  ↓
5. LoggingInterceptor.onResponse/onError
  ↓
Return to caller
```

---

## 🎯 Development Workflow

### 1. Tạo Module Mới

**Step 1: Tạo structure**
```bash
mkdir -p lib/features/new_feature/{data/{models,repositories},presentation/{providers,pages,widgets}}
touch lib/features/new_feature/new_feature.dart
```

**Step 2: Model (Freezed)**
```dart
// lib/features/new_feature/data/models/item.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'item.freezed.dart';
part 'item.g.dart';

@freezed
abstract class Item with _$Item {
  const factory Item({
    required String id,
    required String name,
  }) = _Item;

  factory Item.fromJson(Map<String, Object?> json) =>
      _$ItemFromJson(json);
}
```

**Step 3: Repository (Injectable)**
```dart
// lib/features/new_feature/data/repositories/item_repository.dart
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';

@singleton
class ItemRepository {
  final ApiClient _client;
  
  ItemRepository(this._client);
  
  Future<List<Item>> getItems() async {
    final response = await _client.get('/items');
    return (response['data'] as List)
        .map((e) => Item.fromJson(e))
        .toList();
  }
}
```

**Step 4: Provider (Riverpod Generator)**
```dart
// lib/features/new_feature/presentation/providers/item_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:get_it/get_it.dart';

part 'item_provider.g.dart';

@riverpod
ItemRepository itemRepository(ItemRepositoryRef ref) {
  return GetIt.instance<ItemRepository>();
}

@riverpod
class ItemList extends _$ItemList {
  @override
  Future<List<Item>> build() async {
    return await _fetchItems();
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchItems);
  }
  
  Future<List<Item>> _fetchItems() async {
    final repo = ref.read(itemRepositoryProvider);
    return await repo.getItems();
  }
}
```

**Step 5: Page (UI)**
```dart
// lib/features/new_feature/presentation/pages/item_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemListProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('Items')),
      body: itemsAsync.when(
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, i) => ListTile(
            title: Text(items[i].name),
          ),
        ),
        loading: () => CircularProgressIndicator(),
        error: (e, s) => Text('Error: $e'),
      ),
    );
  }
}
```

**Step 6: Barrel Export**
```dart
// lib/features/new_feature/new_feature.dart
export 'data/models/item.dart';
export 'data/repositories/item_repository.dart';
export 'presentation/providers/item_provider.dart';
export 'presentation/pages/item_list_page.dart';
```

**Step 7: Generate**
```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📝 Coding Standards

### 1. Naming Conventions
```dart
// Files
login_page.dart
auth_provider.dart
user_repository.dart

// Classes
class LoginPage
class AuthProvider
class UserRepository

// Variables/Functions
final userName = 'John';
void getUserData() {}

// Constants
static const maxRetries = 3;

// Private
final _privateField;
void _privateMethod() {}
```

### 2. Import Order
```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Packages
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

// 4. Core (barrel)
import '../../core/core.dart';

// 5. Features (barrel)
import '../product/product.dart';

// 6. Shared (barrel)
import '../../shared/shared.dart';

// 7. Relative (same module)
import 'widgets/custom_widget.dart';
```

### 3. File Organization
```dart
// 1. Imports
import 'package:flutter/material.dart';

// 2. Part statements
part 'file.g.dart';

// 3. Constants
const maxLength = 100;

// 4. Class definition
class MyWidget extends StatelessWidget {
  // 5. Static fields
  static const tag = 'MyWidget';
  
  // 6. Instance fields
  final String title;
  
  // 7. Constructor
  const MyWidget({required this.title});
  
  // 8. Lifecycle methods
  @override
  void initState() {}
  
  // 9. Build method
  @override
  Widget build(BuildContext context) {}
  
  // 10. Public methods
  void publicMethod() {}
  
  // 11. Private methods
  void _privateMethod() {}
}
```

---

## 🧪 Testing Strategy

### Unit Tests
```dart
// test/features/product/product_repository_test.dart
void main() {
  test('should fetch products', () async {
    // Arrange
    final mockClient = MockApiClient();
    final repository = ProductRepository(mockClient);
    
    // Act
    final result = await repository.getProducts();
    
    // Assert
    expect(result, isNotEmpty);
  });
}
```

### Provider Tests
```dart
test('should load products', () async {
  final container = ProviderContainer();
  
  final products = await container.read(productListProvider.future);
  
  expect(products, isA<List<Product>>());
});
```

---

## 🚀 Production Checklist

### Setup
- [ ] Update `app_constants.dart` với API URLs thật
- [ ] Config `injection.dart` cho production interceptors
- [ ] Setup Firebase/Analytics
- [ ] Configure Sentry error tracking

### Security
- [ ] Implement SSL pinning
- [ ] Secure token storage (FlutterSecureStorage)
- [ ] Obfuscate code
- [ ] Remove debug logs

### Performance
- [ ] Enable ProGuard/R8 (Android)
- [ ] Optimize images
- [ ] Lazy load modules
- [ ] Profile memory usage

### Build
- [ ] Setup Fastlane/CI-CD
- [ ] Configure signing keys
- [ ] Test on real devices
- [ ] Generate release builds

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| **README.md** | Quick start, overview, patterns |
| **ARCHITECTURE_FINAL.md** | This file - architecture guide |
| **PROJECT_TEMPLATE.md** | Setup cho project mới |
| **STRUCTURE.md** | Structure chi tiết |
| **DIO_GUIDE.md** | Dio usage (upload, download) |
| **INTERCEPTORS_GUIDE.md** | Interceptors setup |
| **FREEZED_3_SYNTAX.md** | Freezed reference |
| **BARREL_EXPORTS.md** | Import patterns |
| **CHECKLIST.md** | Features checklist |

---

## 🎓 Learning Path

### Beginner
1. Đọc README.md
2. Chạy project demo
3. Hiểu auth flow (login → home → logout)
4. Tìm hiểu 1 module (product)

### Intermediate
1. Đọc ARCHITECTURE_FINAL.md (this file)
2. Tạo module mới theo guide
3. Hiểu Riverpod Generator patterns
4. Customize interceptors

### Advanced
1. Setup multiple API clients
2. Implement offline-first với Hive
3. Add custom interceptors
4. Optimize performance
5. Setup CI/CD

---

## ⚡ Quick Commands

```bash
# Setup
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs

# Development
fvm flutter run
fvm flutter pub run build_runner watch

# Testing
fvm flutter test
fvm flutter analyze

# Clean
fvm flutter clean
find . -name "*.g.dart" -delete
find . -name "*.freezed.dart" -delete

# Build
fvm flutter build apk --release
fvm flutter build ios --release
```

---

## 🔍 Troubleshooting

### Build errors
```bash
# Clean và rebuild
fvm flutter clean
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### Provider not found
- Check đã generate code chưa?
- Check import đúng provider name?
- Provider name = className + "Provider"

### Interceptor không chạy
- Check thứ tự interceptors
- Check `handler.next()` được gọi?
- Check Dio instance đúng?

### API không có token
- Check AuthInterceptor đã add?
- Check token đã save vào SharedPreferences?
- Check thứ tự interceptors

---

## ✨ Best Practices

1. **Module Organization**: 1 feature = 1 module
2. **Barrel Exports**: Luôn dùng cho clean imports
3. **Provider Naming**: Auto-generated, đừng guess
4. **Freezed Models**: Luôn dùng `abstract class` (3.x)
5. **Repository**: Đánh dấu `@singleton`
6. **Watch vs Read**: `watch` trong build, `read` trong callbacks
7. **Interceptors**: Setup trong injection.dart, không hardcode
8. **Error Handling**: Dùng `AsyncValue.guard()` trong providers
9. **Logging**: Disable trong production
10. **Testing**: Mock ApiClient, không mock Dio

---

**Version**: 1.0.0  
**Last Updated**: October 2024  
**Flutter**: 3.35.0  
**Status**: ✅ Production Ready

---

**Happy Coding! 🎉**
