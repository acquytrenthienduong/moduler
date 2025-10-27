import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'injection.config.dart';
import '../network/api_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/refresh_token_interceptor.dart';
import '../network/interceptors/retry_interceptor.dart';
import '../network/interceptors/logging_interceptor.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  await getIt.init();
}

@module
abstract class RegisterModule {
  @preResolve
  @singleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  /// ApiClient với interceptors được inject
  /// ⭐ Interceptors include: Auth, RefreshToken, Retry, Logging
  @singleton
  ApiClient apiClient(SharedPreferences prefs) {
    final client = ApiClient.withoutInterceptors();
    
    // Setup interceptors với proper dependencies
    client.dio.interceptors.addAll([
      // 1. Logging - luôn đầu tiên để log tất cả
      CustomLoggingInterceptor(
        logRequest: true,
        logResponse: true,
        logError: true,
      ),
      
      // 2. Auth - thêm token vào request
      AuthInterceptor(prefs),
      
      // 3. Refresh Token - auto refresh khi 401
      RefreshTokenInterceptor(client.dio, prefs),
      
      // 4. Retry - retry khi network error
      RetryInterceptor(
        maxRetries: 3,
        initialDelay: const Duration(seconds: 1),
      ),
    ]);
    
    return client;
  }
}

