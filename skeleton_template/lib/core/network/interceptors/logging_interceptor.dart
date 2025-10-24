import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../utils/logger.dart';

/// Custom logging interceptor với format đẹp hơn
class CustomLoggingInterceptor extends Interceptor {
  final bool logRequest;
  final bool logResponse;
  final bool logError;

  CustomLoggingInterceptor({
    this.logRequest = true,
    this.logResponse = true,
    this.logError = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (logRequest && kDebugMode) {
      Logger.debug('┌── Request ────────────────────────────────────────');
      Logger.debug('│ ${options.method} ${options.uri}');
      Logger.debug('│ Headers:');
      options.headers.forEach((key, value) {
        // Ẩn sensitive headers
        if (_isSensitiveHeader(key)) {
          Logger.debug('│   $key: ***');
        } else {
          Logger.debug('│   $key: $value');
        }
      });

      if (options.data != null) {
        Logger.debug('│ Body: ${_formatData(options.data)}');
      }

      if (options.queryParameters.isNotEmpty) {
        Logger.debug('│ Query: ${options.queryParameters}');
      }
      Logger.debug('└───────────────────────────────────────────────────');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (logResponse && kDebugMode) {
      Logger.debug('┌── Response ───────────────────────────────────────');
      Logger.debug('│ ${response.requestOptions.method} ${response.requestOptions.uri}');
      Logger.debug('│ Status: ${response.statusCode}');
      Logger.debug('│ Data: ${_formatData(response.data)}');
      Logger.debug('└───────────────────────────────────────────────────');
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (logError && kDebugMode) {
      Logger.error('┌── Error ──────────────────────────────────────────');
      Logger.error('│ ${err.requestOptions.method} ${err.requestOptions.uri}');
      Logger.error('│ Type: ${err.type}');
      Logger.error('│ Message: ${err.message}');
      
      if (err.response != null) {
        Logger.error('│ Status: ${err.response?.statusCode}');
        Logger.error('│ Data: ${_formatData(err.response?.data)}');
      }
      Logger.error('└───────────────────────────────────────────────────');
    }

    handler.next(err);
  }

  /// Format data để log
  String _formatData(dynamic data) {
    if (data == null) return 'null';
    
    final str = data.toString();
    if (str.length > 500) {
      return '${str.substring(0, 500)}... (truncated)';
    }
    return str;
  }

  /// Check xem header có sensitive không
  bool _isSensitiveHeader(String key) {
    final lowerKey = key.toLowerCase();
    return lowerKey.contains('authorization') ||
           lowerKey.contains('token') ||
           lowerKey.contains('key') ||
           lowerKey.contains('secret');
  }
}

