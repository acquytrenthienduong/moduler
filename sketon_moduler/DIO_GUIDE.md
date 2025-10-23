# 🚀 Dio API Client Guide

## 📖 Overview

Project sử dụng **Dio 5.9.0** - HTTP client mạnh mẽ cho Flutter với nhiều tính năng:
- ✅ Interceptors (logging, auth, retry)
- ✅ Request cancellation
- ✅ File upload/download với progress
- ✅ Timeout configuration
- ✅ Error handling tốt hơn
- ✅ FormData support

---

## 🎯 BaseApiClient Structure

```dart
abstract class BaseApiClient {
  late final Dio _dio;
  
  // Override methods:
  String get baseUrl;                    // Base URL
  int get timeoutDuration => 30;         // Timeout (seconds)
  Map<String, String> getHeaders();      // Headers
  BaseOptions getDioOptions();           // Dio options
  List<Interceptor> getInterceptors();   // Interceptors
}
```

---

## 🔧 Basic Usage

### 1. Sử dụng ApiClient có sẵn

```dart
// lib/features/product/data/repositories/product_repository.dart
@singleton
class ProductRepository {
  final ApiClient _client;
  
  ProductRepository(this._client);
  
  Future<List<Product>> getProducts() async {
    final response = await _client.get('/products');
    return (response['data'] as List)
        .map((e) => Product.fromJson(e))
        .toList();
  }
  
  Future<Product> getProductById(String id) async {
    final response = await _client.get(
      '/products/$id',
      queryParameters: {'include': 'reviews'},
    );
    return Product.fromJson(response['data']);
  }
  
  Future<Product> createProduct(Product product) async {
    final response = await _client.post(
      '/products',
      product.toJson(),
    );
    return Product.fromJson(response['data']);
  }
}
```

---

## 🌟 Advanced Features

### 1. Query Parameters

```dart
// GET /products?category=electronics&limit=10
final response = await _client.get(
  '/products',
  queryParameters: {
    'category': 'electronics',
    'limit': 10,
  },
);
```

### 2. File Upload

```dart
Future<String> uploadAvatar(String filePath) async {
  final response = await _client.uploadFile(
    '/users/avatar',
    filePath,
    fieldName: 'avatar',
    additionalData: {'userId': '123'},
  );
  return response['url'];
}
```

### 3. File Download với Progress

```dart
Future<void> downloadFile(String url, String savePath) async {
  await _client.downloadFile(
    url,
    savePath,
    onReceiveProgress: (received, total) {
      final progress = (received / total * 100).toStringAsFixed(0);
      print('Download progress: $progress%');
    },
  );
}
```

### 4. PATCH Request

```dart
Future<Product> updateProduct(String id, Map<String, dynamic> updates) async {
  final response = await _client.patch('/products/$id', updates);
  return Product.fromJson(response['data']);
}
```

---

## 🎨 Customize API Clients

### Example 1: Main API với Auth Token

```dart
class ApiClient extends BaseApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal() : super();

  @override
  String get baseUrl => 'https://api.yourapp.com';

  @override
  Map<String, String> getHeaders() {
    final headers = super.getHeaders();
    
    // Lấy token từ storage
    final token = _getTokenFromStorage();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  @override
  List<Interceptor> getInterceptors() {
    return [
      ...super.getInterceptors(),
      // Custom interceptors
      _AuthInterceptor(),
      _RefreshTokenInterceptor(),
    ];
  }
  
  String? _getTokenFromStorage() {
    // Implement token retrieval
    return null;
  }
}
```

### Example 2: Analytics API (Shorter Timeout)

```dart
class AnalyticsApiClient extends BaseApiClient {
  static final AnalyticsApiClient _instance = AnalyticsApiClient._internal();
  factory AnalyticsApiClient() => _instance;
  AnalyticsApiClient._internal() : super();

  @override
  String get baseUrl => 'https://analytics.yourapp.com';

  @override
  int get timeoutDuration => 10; // 10s timeout

  @override
  List<Interceptor> getInterceptors() {
    return [
      LogInterceptor(
        requestBody: false,  // Không log body cho analytics
        responseBody: false,
      ),
    ];
  }
}
```

### Example 3: Payment API với Custom Headers

```dart
class PaymentApiClient extends BaseApiClient {
  static final PaymentApiClient _instance = PaymentApiClient._internal();
  factory PaymentApiClient() => _instance;
  PaymentApiClient._internal() : super();

  @override
  String get baseUrl => 'https://payment-gateway.com';

  @override
  Map<String, String> getHeaders() {
    return {
      ...super.getHeaders(),
      'X-API-Key': 'your-payment-api-key',
      'X-API-Version': '2024-01',
    };
  }

  @override
  BaseOptions getDioOptions() {
    return BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: 45), // Longer for payment
      receiveTimeout: Duration(seconds: 45),
      headers: getHeaders(),
      validateStatus: (status) => status != null && status < 500,
    );
  }
}
```

---

## 🔌 Custom Interceptors

### 1. Auth Interceptor (Add Token)

```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  String? _getToken() {
    // Get from storage
    return null;
  }
}
```

### 2. Refresh Token Interceptor

```dart
class RefreshTokenInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try refresh
      try {
        final newToken = await _refreshToken();
        
        // Retry request với token mới
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newToken';
        
        final response = await Dio().fetch(opts);
        return handler.resolve(response);
      } catch (e) {
        // Refresh failed, logout user
        return handler.reject(err);
      }
    }
    handler.next(err);
  }
  
  Future<String> _refreshToken() async {
    // Implement refresh logic
    throw UnimplementedError();
  }
}
```

### 3. Retry Interceptor

```dart
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  
  RetryInterceptor({this.maxRetries = 3});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err) && err.requestOptions.extra['retryCount'] < maxRetries) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
      err.requestOptions.extra['retryCount'] = retryCount + 1;
      
      // Wait before retry
      await Future.delayed(Duration(seconds: retryCount + 1));
      
      try {
        final response = await Dio().fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }
    handler.next(err);
  }
  
  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           (err.response?.statusCode ?? 0) >= 500;
  }
}
```

---

## 🛡️ Error Handling

### ApiException

```dart
try {
  final products = await repository.getProducts();
} on ApiException catch (e) {
  switch (e.statusCode) {
    case 401:
      // Unauthorized - redirect to login
      break;
    case 404:
      // Not found
      print('Resource not found');
      break;
    case 408:
      // Timeout
      print('Request timeout. Please try again.');
      break;
    case 503:
      // Connection error
      print('No internet connection');
      break;
    default:
      print('Error: ${e.message}');
  }
}
```

### Trong Provider (Riverpod)

```dart
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
    try {
      final repo = ref.read(productRepositoryProvider);
      return await repo.getProducts();
    } on ApiException catch (e) {
      throw 'Error ${e.statusCode}: ${e.message}';
    }
  }
}
```

### Trong UI

```dart
final productsAsync = ref.watch(productListProvider);

return productsAsync.when(
  data: (products) => ListView(...),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) {
    if (error.toString().contains('503')) {
      return Text('No internet connection');
    }
    return Text('Error: $error');
  },
);
```

---

## 🔍 Debugging

### Enable Logging

Dio LogInterceptor đã được bật mặc định:

```dart
List<Interceptor> getInterceptors() {
  return [
    LogInterceptor(
      requestBody: true,    // Log request body
      responseBody: true,   // Log response body
      error: true,          // Log errors
      logPrint: (obj) => Logger.debug(obj.toString()),
    ),
  ];
}
```

### Disable Logging (Production)

```dart
@override
List<Interceptor> getInterceptors() {
  if (kDebugMode) {
    return [LogInterceptor(...)];
  }
  return [];
}
```

---

## 📊 Advanced Use Cases

### 1. Request Cancellation

```dart
final cancelToken = CancelToken();

// Start request
final futureResponse = _client.dio.get(
  '/large-data',
  cancelToken: cancelToken,
);

// Cancel after 5s
Future.delayed(Duration(seconds: 5), () {
  cancelToken.cancel('Request cancelled by user');
});
```

### 2. Multiple Concurrent Requests

```dart
Future<void> loadAllData() async {
  final results = await Future.wait([
    _client.get('/products'),
    _client.get('/categories'),
    _client.get('/users'),
  ]);
  
  final products = results[0];
  final categories = results[1];
  final users = results[2];
}
```

### 3. FormData (Multipart)

```dart
Future<void> updateProfile(String name, String avatarPath) async {
  final formData = FormData.fromMap({
    'name': name,
    'avatar': await MultipartFile.fromFile(
      avatarPath,
      filename: 'avatar.jpg',
    ),
  });
  
  await _client.dio.post('/profile', data: formData);
}
```

---

## 🎓 Migration từ HTTP package

### Before (HTTP)

```dart
final response = await http.get(
  Uri.parse('$baseUrl/products'),
  headers: {'Authorization': 'Bearer $token'},
);
final data = json.decode(response.body);
```

### After (Dio)

```dart
final response = await _client.get('/products');
// data = response (already parsed to Map)
```

**Lợi ích:**
- ✅ Không cần parse JSON thủ công
- ✅ Timeout tự động
- ✅ Error handling tốt hơn
- ✅ Interceptors support
- ✅ Progress callbacks

---

## 📝 Best Practices

1. **Single Instance**: Dùng singleton pattern cho mỗi API client
2. **Inject vào Repository**: Không dùng trực tiếp trong UI
3. **Handle Errors**: Luôn catch `ApiException`
4. **Use Interceptors**: Cho auth, logging, retry
5. **Configure Timeouts**: Phù hợp với từng API
6. **Disable Logs**: Trong production

---

## 🔗 Related Files

- `lib/core/network/api_client.dart` - Implementation
- `lib/core/core.dart` - Barrel export
- `README.md` - Project overview

---

**Dio Documentation**: https://pub.dev/packages/dio

