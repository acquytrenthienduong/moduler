# 🔧 Injection.dart - Khi nào cần can thiệp?

## 📍 File: `lib/core/di/injection.dart`

File này quản lý **Dependency Injection** cho toàn bộ app.

---

## ✅ KHI NÀO CẦN CAN THIỆP

### 1. ❌ KHÔNG CẦN (Auto-generated)

Các trường hợp sau **KHÔNG** cần sửa `injection.dart`:

#### ✅ Tạo Repository mới với `@singleton`
```dart
// lib/features/order/data/repositories/order_repository.dart
@singleton
class OrderRepository {
  final ApiClient _client;
  OrderRepository(this._client);  // ✅ Auto-inject
}
```
→ **Injectable tự động register**, không cần thêm vào `injection.dart`

#### ✅ Tạo Provider mới (Riverpod)
```dart
// lib/features/order/presentation/providers/order_provider.dart
@riverpod
OrderRepository orderRepository(Ref ref) {
  return GetIt.instance<OrderRepository>();  // ✅ Tự lấy từ GetIt
}
```
→ **Riverpod tự generate**, không cần config

#### ✅ Tạo Model mới (Freezed)
```dart
@freezed
abstract class Order with _$Order {...}
```
→ **Freezed tự generate**, không cần DI

---

### 2. ✅ CẦN CAN THIỆP

Các trường hợp sau **CẦN** sửa `injection.dart`:

#### 1️⃣ Thêm API Client mới (Multiple APIs)

**Khi nào**: App cần call nhiều API khác nhau (analytics, payment, etc)

**Ví dụ**:
```dart
@module
abstract class RegisterModule {
  @preResolve
  @singleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  /// Main API Client
  @singleton
  ApiClient apiClient(SharedPreferences prefs) {
    final client = ApiClient.withoutInterceptors();
    client.dio.interceptors.addAll([...]);
    return client;
  }

  /// ⭐ THÊM: Analytics API Client
  @singleton
  AnalyticsApiClient analyticsClient() {
    return AnalyticsApiClient();
  }

  /// ⭐ THÊM: Payment API Client
  @singleton
  PaymentApiClient paymentClient() {
    return PaymentApiClient();
  }
}
```

**Sau đó run**:
```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

---

#### 2️⃣ Customize Interceptors

**Khi nào**: Cần thay đổi interceptors (thêm/xóa/sửa)

**Ví dụ 1: Disable logging trong production**
```dart
@singleton
ApiClient apiClient(SharedPreferences prefs) {
  final client = ApiClient.withoutInterceptors();
  
  client.dio.interceptors.addAll([
    // ⭐ CHỈ log trong debug mode
    if (kDebugMode)
      CustomLoggingInterceptor(
        logRequest: true,
        logResponse: true,
        logError: true,
      ),
    
    AuthInterceptor(prefs),
    RefreshTokenInterceptor(client.dio, prefs),
    RetryInterceptor(maxRetries: 3),
  ]);
  
  return client;
}
```

**Ví dụ 2: Thêm custom interceptor**
```dart
@singleton
ApiClient apiClient(SharedPreferences prefs) {
  final client = ApiClient.withoutInterceptors();
  
  client.dio.interceptors.addAll([
    CustomLoggingInterceptor(...),
    AuthInterceptor(prefs),
    RefreshTokenInterceptor(client.dio, prefs),
    RetryInterceptor(...),
    
    // ⭐ THÊM: Analytics interceptor
    AnalyticsInterceptor(),
    
    // ⭐ THÊM: Sentry interceptor
    SentryInterceptor(),
  ]);
  
  return client;
}
```

**Ví dụ 3: Thay đổi retry config**
```dart
RetryInterceptor(
  maxRetries: 5,              // ⭐ Tăng từ 3 lên 5
  initialDelay: Duration(seconds: 2),  // ⭐ Tăng delay
),
```

---

#### 3️⃣ Register Service/Utility mới (Không phải Repository)

**Khi nào**: Cần register service không phải repository

**Ví dụ 1: Local Storage Service**
```dart
@module
abstract class RegisterModule {
  @preResolve
  @singleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  /// ⭐ THÊM: Hive Database
  @preResolve
  @singleton
  Future<Box> get hiveBox async {
    await Hive.initFlutter();
    return await Hive.openBox('app_box');
  }
}
```

**Ví dụ 2: Firebase Service**
```dart
@module
abstract class RegisterModule {
  /// ⭐ THÊM: Firebase Analytics
  @singleton
  FirebaseAnalytics get analytics => FirebaseAnalytics.instance;

  /// ⭐ THÊM: Firebase Crashlytics
  @singleton
  FirebaseCrashlytics get crashlytics => FirebaseCrashlytics.instance;
}
```

**Ví dụ 3: Custom Service**
```dart
@module
abstract class RegisterModule {
  /// ⭐ THÊM: Location Service
  @singleton
  LocationService locationService() {
    return LocationService();
  }

  /// ⭐ THÊM: Notification Service
  @singleton
  NotificationService notificationService() {
    return NotificationService();
  }
}
```

---

#### 4️⃣ Environment-specific Configuration

**Khi nào**: Cần config khác nhau cho dev/staging/prod

**Ví dụ**:
```dart
@module
abstract class RegisterModule {
  @singleton
  ApiClient apiClient(SharedPreferences prefs) {
    final client = ApiClient.withoutInterceptors();
    
    client.dio.interceptors.addAll([
      // ⭐ Dev: Full logging
      if (kDebugMode)
        CustomLoggingInterceptor(
          logRequest: true,
          logResponse: true,
          logError: true,
        ),
      
      // ⭐ Production: Only errors
      if (kReleaseMode)
        CustomLoggingInterceptor(
          logRequest: false,
          logResponse: false,
          logError: true,
        ),
      
      AuthInterceptor(prefs),
      
      // ⭐ Dev: No retry (faster debugging)
      if (kDebugMode)
        RetryInterceptor(maxRetries: 1),
      
      // ⭐ Production: More retries
      if (kReleaseMode)
        RetryInterceptor(maxRetries: 5),
    ]);
    
    return client;
  }
}
```

---

#### 5️⃣ Thay đổi Singleton Scope

**Khi nào**: Cần thay đổi lifecycle của dependency

**Ví dụ**:
```dart
@module
abstract class RegisterModule {
  /// ⭐ Singleton - Dùng chung 1 instance
  @singleton
  ApiClient apiClient(SharedPreferences prefs) {...}

  /// ⭐ Factory - Tạo mới mỗi lần dùng (HIẾM KHI DÙNG)
  @factoryMethod
  TemporaryService tempService() {
    return TemporaryService();
  }

  /// ⭐ Lazy Singleton - Chỉ tạo khi cần
  @lazySingleton
  HeavyService heavyService() {
    return HeavyService();
  }
}
```

**⚠️ Lưu ý**: 
- `@factoryMethod` cho **functions/utilities**, KHÔNG dùng cho Models
- Models (Freezed) tự tạo factory constructor, KHÔNG cần register trong DI
- Repository luôn dùng `@singleton`

---

## ❌ KHI NÀO KHÔNG NÊN CAN THIỆP

### 1. Thêm Repository thông thường
```dart
// ❌ KHÔNG CẦN thêm vào injection.dart
@singleton
class ProductRepository {
  final ApiClient _client;
  ProductRepository(this._client);
}
```
→ Injectable tự động register

### 2. Thêm Provider mới
```dart
// ❌ KHÔNG CẦN thêm vào injection.dart
@riverpod
ProductRepository productRepository(Ref ref) {
  return GetIt.instance<ProductRepository>();
}
```
→ Riverpod tự generate

### 3. Thêm Model mới
```dart
// ❌ KHÔNG CẦN thêm vào injection.dart
@freezed
abstract class Product with _$Product {...}
```
→ Freezed tự generate

---

## 📋 Checklist: Cần can thiệp?

| Trường hợp | Cần sửa injection.dart? | Lý do |
|-----------|------------------------|-------|
| Tạo Repository mới với `@singleton` | ❌ KHÔNG | Injectable auto-register |
| Tạo Provider mới (Riverpod) | ❌ KHÔNG | Riverpod auto-generate |
| Tạo Model mới (Freezed) | ❌ KHÔNG | Freezed auto-generate |
| Thêm API Client mới | ✅ CẦN | Multiple APIs |
| Thay đổi Interceptors | ✅ CẦN | Custom config |
| Register Service mới | ✅ CẦN | Non-repository service |
| Environment config | ✅ CẦN | Dev/Prod differences |
| Thay đổi scope | ✅ CẦN | Lifecycle management |

---

## 🔄 Workflow

### Khi CẦN can thiệp:

```bash
# 1. Sửa injection.dart
# Thêm/sửa code trong RegisterModule

# 2. Generate code
fvm flutter pub run build_runner build --delete-conflicting-outputs

# 3. Verify
fvm flutter analyze

# 4. Test
fvm flutter run
```

### Khi KHÔNG CẦN can thiệp:

```bash
# 1. Tạo Repository/Model/Provider với annotations
# @singleton, @freezed, @riverpod

# 2. Generate code
fvm flutter pub run build_runner build --delete-conflicting-outputs

# 3. Done! Injectable/Riverpod/Freezed tự động handle
```

---

## 💡 Tips

### 1. Kiểm tra đã register chưa
```dart
// Check trong code
if (GetIt.instance.isRegistered<MyService>()) {
  print('Already registered');
}
```

### 2. Debug DI issues
```bash
# Xem tất cả registered services
print(GetIt.instance.allReadySync());
```

### 3. Lazy loading
```dart
// Chỉ load khi cần
@lazySingleton
class HeavyService {...}
```

### 4. Testing
```dart
// Override trong tests
GetIt.instance.registerSingleton<ApiClient>(mockApiClient);
```

---

## 🎯 Common Use Cases

### Use Case 1: App đơn giản (1 API)
```dart
@module
abstract class RegisterModule {
  @preResolve
  @singleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @singleton
  ApiClient apiClient(SharedPreferences prefs) {...}
}
```
→ **Không cần thêm gì**

### Use Case 2: App phức tạp (Multiple APIs)
```dart
@module
abstract class RegisterModule {
  @preResolve
  @singleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @singleton
  ApiClient mainApi(SharedPreferences prefs) {...}

  @singleton
  AnalyticsApiClient analyticsApi() {...}  // ⭐ THÊM

  @singleton
  PaymentApiClient paymentApi() {...}     // ⭐ THÊM
}
```
→ **Cần thêm API clients**

### Use Case 3: Production app
```dart
@module
abstract class RegisterModule {
  @preResolve
  @singleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @singleton
  ApiClient apiClient(SharedPreferences prefs) {
    // ⭐ Custom interceptors cho production
    final client = ApiClient.withoutInterceptors();
    client.dio.interceptors.addAll([
      if (kDebugMode) CustomLoggingInterceptor(...),
      AuthInterceptor(prefs),
      RefreshTokenInterceptor(client.dio, prefs),
      if (kReleaseMode) SentryInterceptor(),  // ⭐ THÊM
      RetryInterceptor(...),
    ]);
    return client;
  }

  @singleton
  FirebaseAnalytics get analytics => FirebaseAnalytics.instance;  // ⭐ THÊM
}
```
→ **Cần thêm services & custom interceptors**

---

## 📚 Related Files

- `lib/core/di/injection.config.dart` - Generated (KHÔNG SỬA)
- `lib/core/network/api_client.dart` - API client definitions
- `lib/core/network/interceptors/` - Interceptor implementations

---

## 🎓 Summary

**TL;DR:**

- ❌ **Repository mới**: KHÔNG cần sửa (Injectable auto)
- ❌ **Provider mới**: KHÔNG cần sửa (Riverpod auto)
- ❌ **Model mới**: KHÔNG cần sửa (Freezed auto)
- ✅ **API Client mới**: CẦN sửa
- ✅ **Custom Interceptors**: CẦN sửa
- ✅ **Service mới**: CẦN sửa
- ✅ **Environment config**: CẦN sửa

**Quy tắc vàng**: Nếu có `@singleton` annotation trong Repository → KHÔNG cần sửa injection.dart

---

**Last updated**: October 2024

