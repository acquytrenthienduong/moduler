import 'package:dio/dio.dart';
import '../utils/logger.dart';

/// Base API Client với Dio
/// Sử dụng pattern này cho mỗi base URL khác nhau
abstract class BaseApiClient {
  late final Dio _dio;
  
  /// Override để set base URL riêng
  String get baseUrl;
  
  /// Override để set timeout riêng (mặc định 30s)
  int get timeoutDuration => 30;
  
  /// Override để thêm headers tùy chỉnh (auth token, etc)
  Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Override để customize Dio options
  BaseOptions getDioOptions() {
    return BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: timeoutDuration),
      receiveTimeout: Duration(seconds: timeoutDuration),
      headers: getHeaders(),
      validateStatus: (status) {
        // Accept all status codes để tự handle
        return status != null && status < 500;
      },
    );
  }

  /// Override để thêm interceptors
  List<Interceptor> getInterceptors() {
    return [
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => Logger.debug(obj.toString()),
      ),
    ];
  }

  BaseApiClient() {
    _dio = Dio(getDioOptions());
    _dio.interceptors.addAll(getInterceptors());
  }

  /// GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      Logger.error('GET request failed', error: e);
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      Logger.error('POST request failed', error: e);
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      Logger.error('PUT request failed', error: e);
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      Logger.error('PATCH request failed', error: e);
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        endpoint,
        queryParameters: queryParameters,
        data: data,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      Logger.error('DELETE request failed', error: e);
      throw _handleError(e);
    }
  }

  /// Upload file
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (additionalData != null) ...additionalData,
      });

      final response = await _dio.post<Map<String, dynamic>>(
        endpoint,
        data: formData,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      Logger.error('Upload failed', error: e);
      throw _handleError(e);
    }
  }

  /// Download file
  Future<void> downloadFile(
    String endpoint,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await _dio.download(
        endpoint,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      Logger.error('Download failed', error: e);
      throw _handleError(e);
    }
  }

  /// Handle response
  Map<String, dynamic> _handleResponse(Response<Map<String, dynamic>> response) {
    if (response.statusCode != null && 
        response.statusCode! >= 200 && 
        response.statusCode! < 300) {
      return response.data ?? {};
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.statusMessage ?? 'Unknown error',
        data: response.data,
      );
    }
  }

  /// Handle Dio errors
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          statusCode: 408,
          message: 'Request timeout',
          data: error.response?.data,
        );
      case DioExceptionType.badResponse:
        return ApiException(
          statusCode: error.response?.statusCode,
          message: error.response?.statusMessage ?? 'Bad response',
          data: error.response?.data,
        );
      case DioExceptionType.cancel:
        return ApiException(
          statusCode: 499,
          message: 'Request cancelled',
        );
      case DioExceptionType.connectionError:
        return ApiException(
          statusCode: 503,
          message: 'Connection error. Please check your internet connection.',
        );
      default:
        return ApiException(
          statusCode: 500,
          message: error.message ?? 'Unknown error occurred',
        );
    }
  }

  /// Get Dio instance (for advanced usage)
  Dio get dio => _dio;
}

/// Custom API Exception
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic data;

  ApiException({
    this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() {
    return 'ApiException(statusCode: $statusCode, message: $message, data: $data)';
  }
}

/// Main API Client cho app chính
class ApiClient extends BaseApiClient {
  static ApiClient? _instance;
  
  factory ApiClient() {
    _instance ??= ApiClient._internal();
    return _instance!;
  }
  
  ApiClient._internal() : super();
  
  /// Constructor để tạo instance mà không setup interceptors
  /// (dùng khi muốn inject dependencies từ bên ngoài)
  factory ApiClient.withoutInterceptors() {
    final client = ApiClient._internal();
    client.dio.interceptors.clear();
    return client;
  }

  @override
  String get baseUrl => 'https://api.example.com';

  @override
  List<Interceptor> getInterceptors() {
    // Empty - interceptors sẽ được add từ injection.dart
    // Xem: lib/core/di/injection.dart -> RegisterModule.apiClient()
    return [];
  }
}

/// Example: API Client cho service khác
class AnalyticsApiClient extends BaseApiClient {
  static final AnalyticsApiClient _instance = AnalyticsApiClient._internal();
  factory AnalyticsApiClient() => _instance;
  AnalyticsApiClient._internal() : super();

  @override
  String get baseUrl => 'https://analytics.example.com';

  @override
  int get timeoutDuration => 10; // Shorter timeout cho analytics
}

/// Example: API Client cho payment gateway
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
    };
  }
}

