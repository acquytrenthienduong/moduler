Bạn là một Flutter architect chuyên nghiệp. 
Hãy tạo một Flutter monorepo hoàn chỉnh, cấu trúc theo chuẩn Modular Architecture, với các yêu cầu sau:

---------------------------------------------------
1️⃣ CẤU TRÚC CHUNG CỦA WORKSPACE
---------------------------------------------------
Tạo workspace sử dụng Melos, có cấu trúc như sau:

```
project_root/
├── melos.yaml
├── pubspec.yaml
├── apps/
│   └── main_app/
│       ├── lib/
│       │   └── main.dart
│       └── pubspec.yaml
├── packages/
│   ├── core/
│   │   ├── lib/
│   │   │   ├── core.dart
│   │   │   └── src/
│   │   │       ├── di/
│   │   │       ├── network/
│   │   │       ├── providers/
│   │   │       ├── theme/
│   │   │       ├── utils/
│   │   │       └── widgets/
│   │   └── pubspec.yaml
│   ├── feature_auth/
│   │   ├── lib/
│   │   │   ├── feature_auth.dart
│   │   │   └── src/
│   │   │       ├── data/
│   │   │       ├── domain/
│   │   │       └── presentation/
│   │   └── pubspec.yaml
│   ├── feature_home/
│   │   ├── lib/
│   │   │   ├── feature_home.dart
│   │   │   └── src/
│   │   │       ├── data/
│   │   │       ├── domain/
│   │   │       └── presentation/
│   │   └── pubspec.yaml
│   └── shared_ui/
│       ├── lib/
│       │   ├── shared_ui.dart
│       │   └── src/widgets/
│       │       ├── app_button.dart
│       │       ├── app_loading.dart
│       │       └── app_error.dart
│       └── pubspec.yaml
```

---------------------------------------------------
2️⃣ CÔNG NGHỆ & CẤU HÌNH CHÍNH
---------------------------------------------------
**Core Technologies:**
- **Melos** - Quản lý workspace monorepo
- **GetIt** - Dependency Injection container
- **Riverpod 3.x+** - State management với code generation
- **Freezed** - Immutable classes & unions cho models/entities
- **json_annotation** + **json_serializable** - JSON serialization cho models
- **Dio** - HTTP client cho network layer
- **GoRouter** Navigation và routing
- **Clean Architecture** - Áp dụng đầy đủ cho mỗi feature module (data/domain/presentation với usecases)

**Code Generation Required:**
- Sử dụng `flutter pub run build_runner build --delete-conflicting-outputs` để generate code
- Freezed cho immutable data classes
- json_serializable cho JSON parsing
- riverpod_generator cho providers

**Best Practices:**
- Tuân thủ chuẩn đặt tên Dart/Flutter
- Separate public API từ internal implementation (export barrel files)
- Type-safe dependency injection
- Error handling với sealed classes (Freezed unions)

---------------------------------------------------
3️⃣ NỘI DUNG CỤ THỂ CÁC PACKAGE
---------------------------------------------------

### 🔹 core
**Mục đích:** Cung cấp hạ tầng chung cho toàn bộ app

**Dependencies:**
```yaml
dependencies:
  flutter_riverpod: ^3.0.3
  get_it: ^8.0.2
  dio: ^5.9.0
  
dev_dependencies:
  riverpod_annotation: ^3.0.3
  riverpod_generator: ^3.0.3
  build_runner: ^2.4.13
```

**Cấu trúc:**
- `di/injection_container.dart`: Đăng ký dependencies với GetIt
- `network/`
  - `base_api_client.dart`: Abstract base class cho API clients
  - `api_client_factory.dart`: Factory để tạo nhiều Dio instances cho các backend khác nhau
  - `interceptors/`
    - `auth_interceptor.dart`: Thêm token vào headers
    - `logging_interceptor.dart`: Log requests/responses
    - `error_interceptor.dart`: Chuyển đổi Dio errors
  - `network_exceptions.dart`: Custom exceptions cho network layer
- `providers/`
  - `dio_provider.dart`: Riverpod provider cho Dio instance
  - `app_providers.dart`: Các providers chung (theme, locale)
- `theme/`
  - `app_theme.dart`: Material theme configuration
  - `app_colors.dart`: Color palette
  - `app_text_styles.dart`: Typography
- `utils/`
  - `logger.dart`: Centralized logging utility
  - `date_utils.dart`: Date formatting helpers
  - `validators.dart`: Input validation functions
- `widgets/`
  - `app_loading.dart`: Loading indicator
  - `app_button.dart`: Custom button widget
  - `app_error.dart`: Error display widget
  - `app_text_field.dart`: Custom text input

**Ví dụ `base_api_client.dart`:**
```dart
import 'package:dio/dio.dart';

abstract class BaseApiClient {
  final Dio dio;
  
  BaseApiClient(this.dio);
  
  // GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // PUT request
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // DELETE request
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Error handling
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return NetworkException('Connection timeout');
        case DioExceptionType.badResponse:
          return NetworkException('Bad response: ${error.response?.statusCode}');
        case DioExceptionType.cancel:
          return NetworkException('Request cancelled');
        default:
          return NetworkException('Network error');
      }
    }
    return Exception('Unknown error');
  }
}
```

**Ví dụ `api_client_factory.dart`:**
```dart
import 'package:dio/dio.dart';
import 'package:core/src/network/base_api_client.dart';
import 'package:core/src/network/interceptors/auth_interceptor.dart';
import 'package:core/src/network/interceptors/logging_interceptor.dart';
import 'package:core/src/network/interceptors/error_interceptor.dart';

enum BackendType {
  mainApi,      // Main backend API
  authApi,      // Authentication API
  paymentApi,   // Payment gateway API
  storageApi,   // File storage API
}

class ApiClientFactory {
  static final Map<BackendType, Dio> _dioInstances = {};
  
  /// Get Dio instance for specific backend
  static Dio getDio(BackendType type) {
    if (_dioInstances.containsKey(type)) {
      return _dioInstances[type]!;
    }
    
    final dio = _createDio(type);
    _dioInstances[type] = dio;
    return dio;
  }
  
  /// Create Dio instance for specific backend
  static Dio _createDio(BackendType type) {
    final baseUrl = _getBaseUrl(type);
    
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Add interceptors based on backend type
    dio.interceptors.addAll([
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
    
    // Only add auth interceptor for authenticated backends
    if (type != BackendType.storageApi) {
      dio.interceptors.add(AuthInterceptor());
    }
    
    return dio;
  }
  
  /// Get base URL for specific backend
  static String _getBaseUrl(BackendType type) {
    switch (type) {
      case BackendType.mainApi:
        return 'https://api.example.com';
      case BackendType.authApi:
        return 'https://auth.example.com';
      case BackendType.paymentApi:
        return 'https://payment.example.com';
      case BackendType.storageApi:
        return 'https://storage.example.com';
    }
  }
  
  /// Create API client instance for specific backend
  static BaseApiClient createApiClient(BackendType type) {
    final dio = getDio(type);
    return BaseApiClient(dio);
  }
}
```

**Ví dụ `injection_container.dart`:**
```dart
import 'package:get_it/get_it.dart';
import 'package:core/src/network/api_client_factory.dart';
import 'package:core/src/network/base_api_client.dart';

final sl = GetIt.instance;

Future<void> initCoreDependencies() async {
  // Register Dio instances for different backends
  sl.registerLazySingleton<Dio>(() => 
    ApiClientFactory.getDio(BackendType.mainApi),
    instanceName: 'mainApi',
  );
  
  sl.registerLazySingleton<Dio>(() => 
    ApiClientFactory.getDio(BackendType.authApi),
    instanceName: 'authApi',
  );
  
  sl.registerLazySingleton<Dio>(() => 
    ApiClientFactory.getDio(BackendType.paymentApi),
    instanceName: 'paymentApi',
  );
  
  sl.registerLazySingleton<Dio>(() => 
    ApiClientFactory.getDio(BackendType.storageApi),
    instanceName: 'storageApi',
  );
  
  // Register API clients
  sl.registerLazySingleton<BaseApiClient>(() => 
    ApiClientFactory.createApiClient(BackendType.mainApi),
    instanceName: 'mainApiClient',
  );
  
  sl.registerLazySingleton<BaseApiClient>(() => 
    ApiClientFactory.createApiClient(BackendType.authApi),
    instanceName: 'authApiClient',
  );
  
  // Other dependencies...
}
```

**Ví dụ `dio_provider.dart` (Riverpod Generator):**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:core/src/network/base_api_client.dart';
import 'package:core/src/network/api_client_factory.dart';

part 'dio_provider.g.dart';

// Main API providers
@riverpod
Dio mainDio(MainDioRef ref) {
  return GetIt.instance<Dio>(instanceName: 'mainApi');
}

@riverpod
BaseApiClient mainApiClient(MainApiClientRef ref) {
  return GetIt.instance<BaseApiClient>(instanceName: 'mainApiClient');
}

// Auth API providers
@riverpod
Dio authDio(AuthDioRef ref) {
  return GetIt.instance<Dio>(instanceName: 'authApi');
}

@riverpod
BaseApiClient authApiClient(AuthApiClientRef ref) {
  return GetIt.instance<BaseApiClient>(instanceName: 'authApiClient');
}

// Payment API providers
@riverpod
Dio paymentDio(PaymentDioRef ref) {
  return ApiClientFactory.getDio(BackendType.paymentApi);
}

// Storage API providers
@riverpod
Dio storageDio(StorageDioRef ref) {
  return ApiClientFactory.getDio(BackendType.storageApi);
}
```

### 🔹 feature_auth
**Mục đích:** Xử lý logic đăng nhập/đăng ký - Theo Clean Architecture

**Dependencies:**
```yaml
dependencies:
  core:
    path: ../../core
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0
  flutter_riverpod: ^3.0.0
  
dev_dependencies:
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  riverpod_annotation: ^3.0.0
  riverpod_generator: ^3.0.0
```

### Cấu trúc Clean Architecture:

**Domain Layer (Innermost):**
- `entities/`
  - `user_entity.dart`: Pure domain object (Freezed immutable, NO fromJson)
  - `auth_state.dart`: Sealed union cho auth states
- `repositories/auth_repository.dart`: Abstract interface (chỉ định nghĩa methods)
- `usecases/`
  - `login_usecase.dart`: Business logic cho login
  - `logout_usecase.dart`: Business logic cho logout

**Data Layer (Outer):**
- `models/`
  - `user_model.dart`: JSON model (Freezed + json_serializable)
  - `login_request_model.dart`: Request DTO
  - `login_response_model.dart`: Response DTO
  - **Mapper:** Model ↔ Entity conversion
- `datasources/`
  - `auth_remote_datasource.dart`: Gọi BaseApiClient
  - `auth_local_datasource.dart`: Local storage (SharedPreferences)
- `repositories/auth_repository_impl.dart`: Implement domain interface

**Presentation Layer (Outermost):**
- `providers/`: Riverpod providers (dùng usecases)
- `pages/`: UI screens
- `widgets/`: UI components

---

### Ví dụ Code Clean Architecture:

**`domain/entities/user_entity.dart` (Pure Domain Object):**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String email,
    required String name,
    String? avatarUrl,
  }) = _UserEntity;
}
// Note: KHÔNG có fromJson - đây là pure domain object
```

**`data/models/user_model.dart` (Model với Mapper):**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String name,
    String? avatarUrl,
  }) = _UserModel;
  
  // JSON serialization
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  
  // Mapper: Model → Entity
  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    name: name,
    avatarUrl: avatarUrl,
  );
  
  // Factory: Entity → Model
  factory UserModel.fromEntity(UserEntity entity) => UserModel(
    id: entity.id,
    email: entity.email,
    name: entity.name,
    avatarUrl: entity.avatarUrl,
  );
}
```

**`data/models/user_model.dart`:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String name,
    String? avatarUrl,
  }) = _UserModel;
  
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  
  // Convert to Entity
  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    name: name,
    avatarUrl: avatarUrl,
  );
  
  // Factory from Entity
  factory UserModel.fromEntity(UserEntity entity) => UserModel(
    id: entity.id,
    email: entity.email,
    name: entity.name,
    avatarUrl: entity.avatarUrl,
  );
}
```

**`domain/repositories/auth_repository.dart`:**
```dart
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
}
```

**`data/datasources/auth_remote_datasource.dart`:**
```dart
import 'package:core/core.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> login(String email, String password);
  Future<void> logout();
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final BaseApiClient apiClient;

  AuthRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<UserModel> login(String email, String password) async {
    final json = await apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return UserModel.fromJson(json);
  }

  @override
  Future<void> logout() async {
    await apiClient.post<void>('/auth/logout');
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final json = await apiClient.get<Map<String, dynamic>>('/auth/me');
    return UserModel.fromJson(json);
  }
}
```

**`data/repositories/auth_repository_impl.dart`:**
```dart
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final AuthLocalDatasource localDatasource;

  AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<UserEntity> login(String email, String password) async {
    // Map: Model → Entity
    final model = await remoteDatasource.login(email, password);
    final entity = model.toEntity();
    
    // Save to local
    await localDatasource.saveUser(model);
    
    return entity;
  }

  @override
  Future<void> logout() async {
    await remoteDatasource.logout();
    await localDatasource.clearUser();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final model = await localDatasource.getUser();
    return model?.toEntity();
  }
}
```

**`presentation/providers/auth_provider.dart` (với usecase):**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';

part 'auth_provider.g.dart';

// Usecase
@riverpod
class LoginUsecase extends _$LoginUsecase {
  @override
  Future<UserEntity> build() async {
    throw UnimplementedError();
  }
  
  Future<UserEntity> execute(String email, String password) async {
    final repository = ref.read(authRepositoryProvider);
    return await repository.login(email, password);
  }
}

// Provider
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthState> build() async {
    final repository = ref.read(authRepositoryProvider);
    final user = await repository.getCurrentUser();
    return AuthState(user: user);
  }
  
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    
    // Use usecase thay vì gọi repository trực tiếp
    final usecase = ref.read(loginUsecaseProvider.notifier);
    
    state = await AsyncValue.guard(() async {
      final user = await usecase.execute(email, password);
      return AuthState(user: user);
    });
  }
}
```

**Lưu ý Pattern 2 (Clean Architecture):**
- ✅ Có Domain Layer với entities thuần
- ✅ Có UseCase layer cho business logic phức tạp
- ✅ Có Datasource layer tách biệt
- ✅ Model và Entity riêng biệt + Mapper
- ✅ Repository chỉ làm việc với Entity

---

### 🔹 feature_home
**Mục đích:** Hiển thị dashboard chính sau khi đăng nhập - Theo Clean Architecture

**Cấu trúc tương tự feature_auth:**
- **Domain Layer:** Entities, repositories (abstract), usecases
- **Data Layer:** Models, datasources, repositories (implementation)
- **Presentation Layer:** Providers, pages, widgets

### 🔹 shared_ui
**Mục đích:** Các widget dùng chung across features

**Widgets:**
- `app_button.dart`: Primary, secondary, outlined buttons
- `app_loading.dart`: Circular/linear progress indicators
- `app_error.dart`: Error display với retry functionality
- `app_text_field.dart`: Custom text input với validation
- `app_dialog.dart`: Modal dialogs
- `app_snackbar.dart`: Toast notifications

### 🔹 apps/main_app
**Mục đích:** Entry point của application

**Dependencies:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  core:
    path: ../../packages/core
  feature_auth:
    path: ../../packages/feature_auth
  feature_home:
    path: ../../packages/feature_home
  shared_ui:
    path: ../../packages/shared_ui
  flutter_riverpod: ^3.0.0
  go_router: ^13.0.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
```

**Main.dart structure:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_home/feature_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize core dependencies
  await initCoreDependencies();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Modular App',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      routerConfig: router,
    );
  }
}

// Router configuration with GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
    ],
    redirect: (context, state) {
      // Check auth state and redirect accordingly
      final authState = ref.read(authNotifierProvider);
      final isLoggedIn = authState.hasValue && authState.value != null;
      
      final isGoingToLogin = state.matchedLocation == '/login';
      
      if (!isLoggedIn && !isGoingToLogin) return '/login';
      if (isLoggedIn && isGoingToLogin) return '/home';
      
      return null;
    },
  );
});
```

---------------------------------------------------
4️⃣ MELOS CONFIG
---------------------------------------------------
**melos.yaml:**
```yaml
name: modular_flutter_workspace

repository: https://github.com/your-org/your-repo

packages:
  - "apps/**"
  - "packages/**"

scripts:
  build:
    run: flutter build apk --release
    description: Build the app for Android
    
  generate:
    run: melos exec -- "flutter pub run build_runner build --delete-conflicting-outputs"
    description: Run code generation for all packages
    
  bootstrap:
    description: Bootstrap the workspace
  clean:
    description: Clean workspace
  version:
    description: Version all packages
  publish:
    description: Publish all packages to pub.dev
  test:
    run: melos exec -- "flutter test"
    description: Run tests for all packages
```

**Root pubspec.yaml:**
```yaml
name: modular_flutter_workspace

environment:
  sdk: '>=3.0.0 <4.0.0'

dev_dependencies:
  melos: ^6.0.0
```

---------------------------------------------------
5️⃣ WORKFLOW KHUYẾN NGHỊ
---------------------------------------------------
**Khởi tạo workspace:**
```bash
# Activate Melos globally
dart pub global activate melos

# Bootstrap dependencies
melos bootstrap

# Run code generation
melos generate

# Run the app
cd apps/main_app
flutter run

# Or with Melos
melos run --scope=main_app -- flutter run
```

**Development workflow:**
1. Create/modify features trong `packages/feature_*`
2. Run `melos generate` để generate code (Freezed, JSON, Riverpod)
3. Test locally với `flutter test` trong từng package
4. Run integration tests với `melos test`
5. Build release với `melos build`

**Code generation command:**
```bash
# Generate code for all packages
melos generate

# Or for specific package
cd packages/feature_auth
flutter pub run build_runner build --delete-conflicting-outputs
```

---------------------------------------------------
6️⃣ TÓM TẮT CLEAN ARCHITECTURE
---------------------------------------------------

### Dependency Rule (Quy tắc phụ thuộc):
- **Domain Layer** (Innermost): Không phụ thuộc vào bất kỳ layer nào
  - Chỉ chứa entities, usecases, và repository interfaces
  - Pure business logic, không có framework dependencies
  
- **Data Layer**: Phụ thuộc Domain Layer
  - Implement repository interfaces từ domain
  - Chuyển đổi Models ↔ Entities
  
- **Presentation Layer**: Phụ thuộc cả Domain và Data
  - Sử dụng usecases từ domain
  - Không gọi trực tiếp repository implementations

### Key Principles:
1. **Separation of Concerns**: Mỗi layer có trách nhiệm riêng
2. **Dependency Inversion**: Depend on abstractions, not concretions
3. **Single Responsibility**: Mỗi class chỉ làm 1 việc
4. **Testability**: Dễ test nhờ interfaces và mocks

### Áp dụng cho dự án:
- ✅ Mỗi feature module tuân theo Clean Architecture
- ✅ Domain layer độc lập với framework
- ✅ Dễ test và maintain
- ✅ Có thể swap infrastructure (database, API) mà không ảnh hưởng business logic
