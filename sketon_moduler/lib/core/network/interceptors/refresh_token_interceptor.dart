import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/logger.dart';

/// Interceptor để tự động refresh token khi hết hạn
class RefreshTokenInterceptor extends Interceptor {
  final Dio _dio;
  final SharedPreferences _prefs;
  
  // Để tránh multiple refresh cùng lúc
  bool _isRefreshing = false;
  final List<_RequestHolder> _pendingRequests = [];

  RefreshTokenInterceptor(this._dio, this._prefs);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Chỉ xử lý khi response là 401 (Unauthorized)
    if (err.response?.statusCode == 401) {
      Logger.warning('Token expired, attempting refresh...');

      try {
        // Nếu đang refresh, queue request này lại
        if (_isRefreshing) {
          Logger.debug('Refresh in progress, queuing request');
          final completer = _RequestHolder(err.requestOptions);
          _pendingRequests.add(completer);

          try {
            final response = await completer.completer.future;
            return handler.resolve(response);
          } catch (e) {
            return handler.reject(err);
          }
        }

        // Bắt đầu refresh token
        _isRefreshing = true;

        final newToken = await _refreshToken();

        if (newToken != null) {
          // Save new token
          await _prefs.setString('auth_token', newToken);
          Logger.info('Token refreshed successfully');

          // Retry request gốc với token mới
          final response = await _retryRequest(err.requestOptions, newToken);
          
          // Resolve tất cả pending requests
          _resolvePendingRequests(newToken);

          return handler.resolve(response);
        } else {
          // Refresh thất bại
          Logger.error('Token refresh failed');
          _rejectPendingRequests(err);
          
          // Clear tokens và redirect to login
          await _clearAuthAndRedirectToLogin();
          
          return handler.reject(err);
        }
      } catch (e) {
        Logger.error('Error during token refresh', error: e);
        _rejectPendingRequests(err);
        await _clearAuthAndRedirectToLogin();
        return handler.reject(err);
      } finally {
        _isRefreshing = false;
      }
    }

    handler.next(err);
  }

  /// Gọi API refresh token
  Future<String?> _refreshToken() async {
    try {
      final refreshToken = _prefs.getString('refresh_token');

      if (refreshToken == null) {
        Logger.error('No refresh token found');
        return null;
      }

      // Call refresh token API
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {
            'Authorization': 'Bearer $refreshToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'] as String?;
        final newRefreshToken = response.data['refresh_token'] as String?;

        // Update refresh token nếu có
        if (newRefreshToken != null) {
          await _prefs.setString('refresh_token', newRefreshToken);
        }

        return newAccessToken;
      }

      return null;
    } catch (e) {
      Logger.error('Refresh token request failed', error: e);
      return null;
    }
  }

  /// Retry request với token mới
  Future<Response> _retryRequest(
    RequestOptions requestOptions,
    String newToken,
  ) async {
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $newToken',
      },
    );

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Resolve tất cả pending requests với token mới
  void _resolvePendingRequests(String newToken) {
    for (final holder in _pendingRequests) {
      _retryRequest(holder.requestOptions, newToken).then(
        (response) => holder.completer.complete(response),
        onError: (error) => holder.completer.completeError(error),
      );
    }
    _pendingRequests.clear();
  }

  /// Reject tất cả pending requests
  void _rejectPendingRequests(DioException error) {
    for (final holder in _pendingRequests) {
      holder.completer.completeError(error);
    }
    _pendingRequests.clear();
  }

  /// Clear auth data và redirect to login
  Future<void> _clearAuthAndRedirectToLogin() async {
    await _prefs.remove('auth_token');
    await _prefs.remove('refresh_token');
    await _prefs.remove('user');
    
    Logger.info('Auth cleared, user should be redirected to login');
    
    // Note: Redirect logic nên được handle ở UI layer
    // Có thể emit event hoặc dùng global navigation
  }
}

/// Helper class để hold request trong queue
class _RequestHolder {
  final RequestOptions requestOptions;
  final completer = Completer<Response>();

  _RequestHolder(this.requestOptions);
}

