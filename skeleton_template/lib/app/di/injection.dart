import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:core/core.dart' as core;
import '../../features/auth/data/repositories/auth_repository.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  // 1. Register core dependencies manually
  await _registerCoreDependencies();
  
  // 2. Setup app-specific dependencies (auto-generated)
  getIt.init(environment: Environment.dev);
  
  // 3. Manually register repositories that depend on core services
  // Injectable không thể auto-inject cross-package dependencies
  getIt.registerSingleton<AuthRepository>(
    AuthRepository(
      getIt<core.ApiClient>(),
      getIt<SharedPreferences>(),
    ),
  );
}

Future<void> _registerCoreDependencies() async {
  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  
  // Dio with interceptors
  final dio = Dio();
  dio.interceptors.addAll([
    core.AuthInterceptor(prefs),
    core.RefreshTokenInterceptor(dio, prefs),
    core.RetryInterceptor(),
    core.CustomLoggingInterceptor(),
  ]);
  getIt.registerSingleton<Dio>(dio);
  
  // ApiClient
  getIt.registerSingleton<core.ApiClient>(core.ApiClient());
}

