import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/logger.dart';

/// Interceptor để tự động thêm auth token vào mỗi request
class AuthInterceptor extends Interceptor {
  final SharedPreferences _prefs;

  AuthInterceptor(this._prefs);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Lấy token từ storage
      final token = _prefs.getString('auth_token');

      if (token != null && token.isNotEmpty) {
        // Thêm token vào header
        options.headers['Authorization'] = 'Bearer $token';
        Logger.debug('Auth token added to request: ${options.path}');
      }

      handler.next(options);
    } catch (e) {
      Logger.error('Error in AuthInterceptor', error: e);
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      Logger.warning('Unauthorized request: ${err.requestOptions.path}');
      // Token invalid hoặc expired
      // RefreshTokenInterceptor sẽ xử lý việc refresh
    }
    handler.next(err);
  }
}

