import 'package:dio/dio.dart';
import '../../utils/logger.dart';

/// Interceptor để tự động retry request khi gặp lỗi network
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration initialDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check nếu request này nên retry
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    // Lấy số lần đã retry
    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

    if (retryCount >= maxRetries) {
      Logger.warning(
        'Max retries ($maxRetries) reached for ${err.requestOptions.path}',
      );
      return handler.next(err);
    }

    // Tăng retry count
    err.requestOptions.extra['retryCount'] = retryCount + 1;

    // Calculate delay (exponential backoff)
    final delay = _calculateDelay(retryCount);
    
    Logger.info(
      'Retrying request (${retryCount + 1}/$maxRetries) after ${delay.inSeconds}s: ${err.requestOptions.path}',
    );

    // Wait trước khi retry
    await Future.delayed(delay);

    try {
      // Retry request
      final response = await Dio().fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      // Nếu retry cũng fail, tiếp tục error handling
      return handler.next(e);
    }
  }

  /// Check xem có nên retry request này không
  bool _shouldRetry(DioException err) {
    // Retry cho timeout errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    // Retry cho connection errors
    if (err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry cho server errors (5xx)
    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 500 && statusCode < 600) {
      return true;
    }

    // Không retry cho các lỗi khác
    return false;
  }

  /// Calculate delay với exponential backoff
  Duration _calculateDelay(int retryCount) {
    // Exponential backoff: 1s, 2s, 4s, 8s, ...
    final multiplier = (1 << retryCount); // 2^retryCount
    return initialDelay * multiplier;
  }
}

