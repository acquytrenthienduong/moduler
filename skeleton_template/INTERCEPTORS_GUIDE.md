# 🔌 Interceptors Guide

## 📍 Vị trí add Interceptors

Interceptors được config ở **2 nơi**:

### 1. ✅ PRODUCTION (Recommended): `lib/core/di/injection.dart`

```dart
@module
abstract class RegisterModule {
  @singleton
  ApiClient apiClient(SharedPreferences prefs) {
    final client = ApiClient._withoutInterceptors();
    
    // ⭐ ADD INTERCEPTORS Ở ĐÂY
    client.dio.interceptors.addAll([
      CustomLoggingInterceptor(...),
      AuthInterceptor(prefs),
      RefreshTokenInterceptor(client.dio, prefs),
      RetryInterceptor(...),
    ]);
    
    return client;
  }
}
```

**Lợi ích:**
- ✅ Dependency Injection đúng cách
- ✅ Dễ test (có thể mock interceptors)
- ✅ Flexible (có thể thay đổi interceptors theo environment)

### 2. SIMPLE: `lib/core/network/api_client.dart`

```dart
class ApiClient extends BaseApiClient {
  @override
  List<Interceptor> getInterceptors() {
    return [
      CustomLoggingInterceptor(...),
      RetryInterceptor(...),
    ];
  }
}
```

**Lợi ích:**
- ✅ Đơn giản, nhanh
- ❌ Khó inject dependencies (SharedPreferences, etc)
- ❌ Khó test

---

## 🔧 Các Interceptors có sẵn

### 1. AuthInterceptor
**Vị trí:** `lib/core/network/interceptors/auth_interceptor.dart`

**Chức năng:** Tự động thêm auth token vào header của mỗi request

```dart
// Request
GET /products
Headers: { Authorization: Bearer [token] }

// Token được lấy từ SharedPreferences
```

**Setup:**
```dart
AuthInterceptor(prefs)
```

### 2. RefreshTokenInterceptor
**Vị trí:** `lib/core/network/interceptors/refresh_token_interceptor.dart`

**Chức năng:** Tự động refresh token khi gặp 401 Unauthorized

**Flow:**
```
1. Request → 401 Unauthorized
2. Call /auth/refresh with refresh_token
3. Save new access_token
4. Retry original request with new token
5. Success ✅

Nếu refresh fail:
→ Clear auth data
→ User cần login lại
```

**Setup:**
```dart
RefreshTokenInterceptor(dio, prefs)
```

**API Endpoint cần implement:**
```dart
POST /auth/refresh
Body: { "refresh_token": "..." }
Response: {
  "access_token": "new_token",
  "refresh_token": "new_refresh_token" (optional)
}
```

### 3. RetryInterceptor
**Vị trí:** `lib/core/network/interceptors/retry_interceptor.dart`

**Chức năng:** Tự động retry khi gặp lỗi network

**Retry khi:**
- Connection timeout
- Send timeout
- Receive timeout
- Connection error
- Server error (5xx)

**Exponential backoff:**
```
Retry 1: wait 1s
Retry 2: wait 2s
Retry 3: wait 4s
```

**Setup:**
```dart
RetryInterceptor(
  maxRetries: 3,
  initialDelay: Duration(seconds: 1),
)
```

### 4. CustomLoggingInterceptor
**Vị trí:** `lib/core/network/interceptors/logging_interceptor.dart`

**Chức năng:** Log request/response với format đẹp

**Output:**
```
┌── Request ────────────────────────────────────────
│ GET https://api.example.com/products
│ Headers:
│   Authorization: ***
│   Content-Type: application/json
│ Query: {limit: 10}
└───────────────────────────────────────────────────

┌── Response ───────────────────────────────────────
│ GET https://api.example.com/products
│ Status: 200
│ Data: [{id: 1, name: Product 1}, ...]
└───────────────────────────────────────────────────
```

**Setup:**
```dart
CustomLoggingInterceptor(
  logRequest: true,
  logResponse: true,
  logError: true,
)
```

**Production:** Disable logging
```dart
CustomLoggingInterceptor(
  logRequest: kDebugMode,
  logResponse: kDebugMode,
  logError: true,
)
```

---

## 📋 Thứ tự Interceptors (Quan trọng!)

```dart
client.dio.interceptors.addAll([
  // 1. Logging - LUÔN ĐẦU TIÊN
  CustomLoggingInterceptor(...),
  
  // 2. Auth - Thêm token trước khi request
  AuthInterceptor(prefs),
  
  // 3. Refresh Token - Handle 401
  RefreshTokenInterceptor(dio, prefs),
  
  // 4. Retry - Retry network errors
  RetryInterceptor(...),
]);
```

**Tại sao thứ tự này?**
1. **Logging first** → Log tất cả requests (kể cả modified bởi interceptors khác)
2. **Auth second** → Add token trước khi send
3. **RefreshToken third** → Handle 401 và retry
4. **Retry last** → Handle network errors cuối cùng

---

## 🎨 Custom Interceptor

### Tạo interceptor mới

```dart
// lib/core/network/interceptors/analytics_interceptor.dart
import 'package:dio/dio.dart';

class AnalyticsInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Track request
    _trackRequest(options.path);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Track response time
    final duration = response.requestOptions.extra['start_time'];
    _trackResponseTime(duration);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Track errors
    _trackError(err);
    handler.next(err);
  }
}
```

### Add vào ApiClient

```dart
@singleton
ApiClient apiClient(SharedPreferences prefs) {
  final client = ApiClient._withoutInterceptors();
  
  client.dio.interceptors.addAll([
    CustomLoggingInterceptor(...),
    AuthInterceptor(prefs),
    RefreshTokenInterceptor(client.dio, prefs),
    RetryInterceptor(...),
    
    // Custom interceptor
    AnalyticsInterceptor(), // ⭐ ADD HERE
  ]);
  
  return client;
}
```

---

## 🔍 Debug Interceptors

### 1. Check thứ tự interceptors

```dart
print('Interceptors count: ${dio.interceptors.length}');
for (var i = 0; i < dio.interceptors.length; i++) {
  print('$i: ${dio.interceptors[i].runtimeType}');
}
```

### 2. Disable specific interceptor

```dart
// Remove all logging
dio.interceptors.removeWhere((i) => i is CustomLoggingInterceptor);

// Remove all
dio.interceptors.clear();
```

### 3. Conditional interceptors

```dart
if (kDebugMode) {
  client.dio.interceptors.add(CustomLoggingInterceptor(...));
}

if (kReleaseMode) {
  client.dio.interceptors.add(SentryInterceptor());
}
```

---

## 🎯 Use Cases

### Use Case 1: App có auth

```dart
client.dio.interceptors.addAll([
  CustomLoggingInterceptor(...),
  AuthInterceptor(prefs),           // ✅ Add token
  RefreshTokenInterceptor(...),     // ✅ Auto refresh
  RetryInterceptor(...),
]);
```

### Use Case 2: App không có auth

```dart
client.dio.interceptors.addAll([
  CustomLoggingInterceptor(...),
  RetryInterceptor(...),            // ✅ Chỉ retry
]);
```

### Use Case 3: Multiple API clients

```dart
// Main API - có auth
@singleton
ApiClient mainApi(SharedPreferences prefs) {
  final client = ApiClient._withoutInterceptors();
  client.dio.interceptors.addAll([
    AuthInterceptor(prefs),
    RefreshTokenInterceptor(client.dio, prefs),
  ]);
  return client;
}

// Public API - không auth
@singleton
PublicApiClient publicApi() {
  final client = PublicApiClient();
  client.dio.interceptors.addAll([
    RetryInterceptor(...),
  ]);
  return client;
}
```

---

## ⚠️ Common Issues

### Issue 1: RefreshToken gọi API nhiều lần

**Nguyên nhân:** Nhiều requests cùng nhận 401

**Giải pháp:** RefreshTokenInterceptor đã handle với `_isRefreshing` flag và request queue

### Issue 2: Interceptor không chạy

**Check:**
1. Đã add vào `dio.interceptors`?
2. Thứ tự đúng chưa?
3. `handler.next()` được gọi chưa?

### Issue 3: Infinite loop

**Nguyên nhân:** RefreshToken endpoint cũng return 401

**Giải pháp:** Skip interceptor cho refresh endpoint
```dart
if (options.path.contains('/auth/refresh')) {
  return handler.next(options);
}
```

---

## 📚 Related Files

- `lib/core/di/injection.dart` - Setup interceptors
- `lib/core/network/api_client.dart` - ApiClient
- `lib/core/network/interceptors/` - Tất cả interceptors
- `DIO_GUIDE.md` - Dio general guide

---

## 🔗 References

- [Dio Interceptors Documentation](https://pub.dev/packages/dio#interceptors)
- [Flutter DI Best Practices](https://pub.dev/packages/injectable)

---

**Summary:**
- ✅ Add interceptors trong `injection.dart` (production)
- ✅ Thứ tự: Logging → Auth → RefreshToken → Retry
- ✅ 4 interceptors có sẵn: Auth, RefreshToken, Retry, Logging
- ✅ Dễ dàng tạo custom interceptors

