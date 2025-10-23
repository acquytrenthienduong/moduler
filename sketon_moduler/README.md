# 🚀 Flutter Modular Skeleton

> **Clean Architecture** + **Riverpod 3.x** + **Freezed 3.x** + **Go Router** + **Injectable**

## 📋 Quick Start

```bash
# Setup
cd sketon_moduler
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs

# Run
fvm flutter run
```

**Demo Login**: Nhập bất kỳ email (có @) + password (>= 3 ký tự)

---

## 📦 Tech Stack

| Category | Package | Version |
|----------|---------|---------|
| **Framework** | Flutter | 3.35.0 |
| **Language** | Dart | 3.8.0 |
| **State** | flutter_riverpod | ^3.0.3 |
| | riverpod_generator | ^3.0.3 |
| **Navigation** | go_router | ^16.3.0 |
| **DI** | get_it + injectable | ^8.0.2 / ^2.5.0 |
| **HTTP** | **dio** ⭐ | **^5.9.0** |
| **Models** | freezed | ^3.1.0 |
| **Storage** | shared_preferences | ^2.3.3 |

---

## 📁 Cấu trúc Project

```
lib/
├── core/                           # Core utilities
│   ├── core.dart                   # ✅ Barrel export
│   ├── constants/
│   ├── di/                         # GetIt + Injectable
│   ├── models/
│   ├── network/                    # ApiClient
│   ├── router/                     # GoRouter + Auth guard
│   ├── theme/
│   └── utils/
│
├── features/                       # Modules (Feature-based)
│   ├── auth/
│   │   ├── auth.dart               # ✅ Barrel export
│   │   ├── data/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── providers/          # Riverpod providers
│   │       └── pages/
│   │
│   ├── home/
│   │   ├── home.dart               # ✅ Barrel export
│   │   └── presentation/pages/
│   │
│   ├── profile/                    # Tab 1
│   │   ├── profile.dart
│   │   └── presentation/pages/
│   │
│   ├── settings/                   # Tab 2
│   │   ├── settings.dart
│   │   └── presentation/pages/
│   │
│   └── product/                    # Example module
│       ├── product.dart            # ✅ Barrel export
│       ├── data/
│       │   ├── models/            # Freezed models
│       │   └── repositories/      # Injectable
│       └── presentation/
│           ├── providers/         # Riverpod Generator
│           └── pages/
│
├── shared/                         # Shared components
│   └── widgets/
│
└── main.dart
```

---

## 🎯 Tạo Module Mới

### Bước 1: Tạo Model (Freezed 3.x)

```dart
// features/product/data/models/product.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {  // ⭐ Phải có 'abstract'
  const factory Product({
    required String id,
    required String name,
    @Default(0) int stock,
  }) = _Product;

  factory Product.fromJson(Map<String, Object?> json) => 
      _$ProductFromJson(json);
}
```

### Bước 2: Tạo Repository (Injectable)

```dart
// features/product/data/repositories/product_repository.dart
import 'package:injectable/injectable.dart';

@singleton
class ProductRepository {
  final ApiClient _client;
  
  ProductRepository(this._client);  // Auto-injection
  
  Future<List<Product>> getAll() async {
    // Implementation
  }
}
```

### Bước 3: Tạo Provider (Riverpod Generator 3.x)

```dart
// features/product/presentation/providers/product_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_provider.g.dart';

// Repository provider
@riverpod
ProductRepository productRepository(ProductRepositoryRef ref) {
  return GetIt.instance<ProductRepository>();
}

// AsyncNotifier cho list
@riverpod
class ProductList extends _$ProductList {
  @override
  Future<List<Product>> build() async {
    return await _fetchProducts();
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchProducts);
  }
  
  Future<List<Product>> _fetchProducts() async {
    final repo = ref.read(productRepositoryProvider);
    return await repo.getAll();
  }
}

// Provider name: productListProvider (auto-generated)
```

### Bước 4: Tạo Page (ConsumerWidget)

```dart
// features/product/presentation/pages/product_list_page.dart
class ProductListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);
    
    return productsAsync.when(
      data: (products) => ListView.builder(...),
      loading: () => CircularProgressIndicator(),
      error: (e, s) => Text('Error: $e'),
    );
  }
}
```

### Bước 5: Barrel Export

```dart
// features/product/product.dart
export 'data/models/product.dart';
export 'data/repositories/product_repository.dart';
export 'presentation/providers/product_provider.dart';
export 'presentation/pages/product_list_page.dart';

// Usage:
// import '../product/product.dart';  // Thay vì nhiều imports
```

### Bước 6: Generate Code

```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 💡 Patterns Chính

### 1. Riverpod 3.x Provider Types

```dart
// Simple provider
@riverpod
String greeting(GreetingRef ref) => 'Hello';

// Async provider
@riverpod
Future<User> currentUser(CurrentUserRef ref) async {
  return await fetchUser();
}

// Notifier (sync state)
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;
  void increment() => state++;
}

// AsyncNotifier (async state)
@riverpod
class ProductList extends _$ProductList {
  @override
  Future<List<Product>> build() async => await fetch();
  
  Future<void> refresh() async {
    state = await AsyncValue.guard(fetch);
  }
}

// Family (với parameters)
@riverpod
Future<Product> productDetail(
  ProductDetailRef ref,
  String id,
) async {
  return await repo.getById(id);
}
```

### 2. Freezed 3.x Models

```dart
@freezed
abstract class Person with _$Person {  // ⭐ Cần 'abstract'
  const factory Person({
    required String name,
    @Default(0) int age,
  }) = _Person;
  
  factory Person.fromJson(Map<String, Object?> json) => 
      _$PersonFromJson(json);
}

// Usage:
final person = Person(name: 'John', age: 30);
final updated = person.copyWith(age: 31);
```

### 3. Ref Methods

```dart
// Watch - auto rebuild
final value = ref.watch(myProvider);

// Read - one-time, no rebuild
final value = ref.read(myProvider);

// Read notifier
ref.read(counterProvider.notifier).increment();

// Listen
ref.listen(myProvider, (prev, next) {
  // React to changes
});
```

### 4. AsyncValue Handling

```dart
asyncData.when(
  data: (data) => Text('$data'),
  loading: () => CircularProgressIndicator(),
  error: (e, s) => Text('Error: $e'),
);
```

---

## 🔄 Luồng App

```
Start → Auth Check → Login → Home (2 tabs) → Logout
         ↓                      ↓
      Redirect           Profile/Settings
```

**Chi tiết:**
1. App start → Check token (SharedPreferences)
2. Không có token → Login page
3. Login → Save token → Home
4. Home → 2 tabs (Profile, Settings)
5. Logout → Clear token → Login

---

## 📚 Cheat Sheet

### Provider Naming (Riverpod 3.x)

```dart
@riverpod
class ProductList extends _$ProductList { }
// → Provider name: productListProvider

@riverpod
Future<User> currentUser(...) { }
// → Provider name: currentUserProvider
```

### Build Runner Commands

```bash
# One-time
fvm flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode
fvm flutter pub run build_runner watch

# Clean
find . -name "*.g.dart" -delete
find . -name "*.freezed.dart" -delete
```

### Common Imports

```dart
// Core
import 'core/core.dart';

// Modules (barrel exports)
import 'features/auth/auth.dart';
import 'features/product/product.dart';
```

---

## ⚙️ Configuration

### FVM
```json
// .fvm/fvm_config.json
{
  "flutterSdkVersion": "3.35.0"
}
```

### IDE Setup
- **VS Code**: Set Flutter SDK = `.fvm/flutter_sdk`
- **Android Studio**: Settings → Flutter → SDK path = `[project]/.fvm/flutter_sdk`

---

## 🐛 Troubleshooting

### Error: "authNotifierProvider not found"
**Fix**: Riverpod 3.x naming changed
```dart
// ❌ OLD
ref.watch(authNotifierProvider)

// ✅ NEW
ref.watch(authProvider)
```

### Error: "Freezed syntax error"
**Fix**: Freezed 3.x cần `abstract class`
```dart
// ❌ OLD (Freezed 2.x)
@freezed
class Product with _$Product { }

// ✅ NEW (Freezed 3.x)
@freezed
abstract class Product with _$Product { }
```

### Error: "GetIt not registered"
**Fix**: Run build_runner
```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📖 Các file guide khác

- **FREEZED_3_SYNTAX.md** - Freezed 3.x chi tiết
- **BARREL_EXPORTS.md** - Barrel pattern chi tiết
- **FINAL_SETUP.md** - Setup status

---

## ✅ Features

- ✅ Modular architecture (feature-based)
- ✅ Riverpod 3.x state management
- ✅ Freezed 3.x immutable models
- ✅ Go Router 16.x với auth guard
- ✅ GetIt + Injectable DI
- ✅ Barrel exports cho clean imports
- ✅ Code generation
- ✅ Responsive design (ScreenUtil)
- ✅ Material 3 theme
- ✅ FVM Flutter 3.35.0

---

## 🎯 Best Practices

1. **Module Organization**: 1 module = 1 feature
2. **Barrel Exports**: `import 'features/product/product.dart'`
3. **Provider Naming**: Auto-generated từ class/function name
4. **Freezed Models**: Luôn dùng `abstract class`
5. **Repository**: Đánh dấu `@singleton` cho auto-registration
6. **Watch vs Read**: `watch` trong build, `read` trong callbacks

---

## 🚀 Production Checklist

- [ ] Update API endpoints trong `AppConstants`
- [ ] Implement real authentication
- [ ] Add error tracking (Sentry/Firebase Crashlytics)
- [ ] Add analytics
- [ ] Setup CI/CD
- [ ] Enable ProGuard/R8
- [ ] Test on real devices
- [ ] Performance profiling

---

## 📞 Support

Gặp vấn đề? Check:
1. **PROJECT_TEMPLATE.md** - Hướng dẫn setup project mới
2. **DIO_GUIDE.md** ⭐ - Dio API client guide (upload, download, errors)
3. **INTERCEPTORS_GUIDE.md** ⭐ - Interceptors chi tiết (Auth, RefreshToken, Retry, Logging)
4. **FREEZED_3_SYNTAX.md** - Freezed syntax reference
5. **BARREL_EXPORTS.md** - Import patterns reference
6. Run `fvm flutter pub run build_runner build --delete-conflicting-outputs`

---

## 🎯 Khi bắt đầu project mới

Xem chi tiết trong **PROJECT_TEMPLATE.md**

### Quick steps:
1. Clone template này
2. Rename project (pubspec.yaml, Android, iOS)
3. Cấu hình API clients trong `core/network/api_client.dart`
4. Update constants trong `core/constants/app_constants.dart`
5. Xóa code demo không cần thiết
6. Bắt đầu tạo modules mới!

---

**Happy Coding! 🎉**