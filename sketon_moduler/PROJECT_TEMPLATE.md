# 🎯 Hướng dẫn sử dụng Project Template

## 📝 Checklist khi bắt đầu project mới

### 1. Setup cơ bản

```bash
# Clone template
git clone [this-repo] your-project-name
cd your-project-name

# Rename project (thủ công hoặc dùng tool)
# - Update name trong pubspec.yaml
# - Update package name trong android/app/build.gradle.kts
# - Update bundle identifier trong ios/Runner.xcodeproj

# Install dependencies
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Cấu hình API Clients

#### ✅ Chỉ có 1 API endpoint
Sử dụng `ApiClient` có sẵn:

```dart
// lib/core/network/api_client.dart
class ApiClient extends BaseApiClient {
  @override
  String get baseUrl => 'https://your-api.com';  // ✏️ Thay đổi URL
}
```

#### ✅ Có nhiều API endpoints khác nhau
Tạo thêm client cho mỗi service:

```dart
// lib/core/network/api_client.dart

// Main API
class ApiClient extends BaseApiClient {
  @override
  String get baseUrl => 'https://api.yourapp.com';
  
  @override
  Map<String, String> getHeaders() {
    final headers = super.getHeaders();
    final token = _getToken(); // Lấy từ storage
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}

// Analytics API
class AnalyticsApiClient extends BaseApiClient {
  @override
  String get baseUrl => 'https://analytics.yourapp.com';
  
  @override
  int get timeoutDuration => 10; // Timeout ngắn hơn
}

// Payment API
class PaymentApiClient extends BaseApiClient {
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
```

Sau đó đăng ký vào Injectable:

```dart
// lib/core/di/injection.dart
@module
abstract class AppModule {
  @singleton
  ApiClient get apiClient => ApiClient();
  
  @singleton
  AnalyticsApiClient get analyticsClient => AnalyticsApiClient();
  
  @singleton
  PaymentApiClient get paymentClient => PaymentApiClient();
}
```

Sử dụng trong Repository:

```dart
@singleton
class ProductRepository {
  final ApiClient _apiClient;
  
  ProductRepository(this._apiClient);
  
  Future<List<Product>> getProducts() async {
    final response = await _apiClient.get('/products');
    // ...
  }
}

@singleton
class AnalyticsRepository {
  final AnalyticsApiClient _analyticsClient;
  
  AnalyticsRepository(this._analyticsClient);
  
  Future<void> trackEvent(String event) async {
    await _analyticsClient.post('/events', {'event': event});
  }
}
```

### 3. Xóa code mẫu không cần thiết

```bash
# Xóa các module demo
rm -rf lib/features/product
rm -rf lib/features/profile
rm -rf lib/features/settings

# Giữ lại:
# - lib/features/auth (customize lại)
# - lib/features/home (customize lại)
```

Hoặc giữ lại làm reference, sau đó xóa khi cần.

### 4. Cấu hình constants

```dart
// lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName = 'Your App Name';  // ✏️ Thay đổi
  static const String baseUrl = 'https://api.yourapp.com';  // ✏️ Thay đổi
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String productsEndpoint = '/products';
  // ... thêm endpoints khác
}
```

### 5. Cấu hình theme

```dart
// lib/core/theme/app_theme.dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,  // ✏️ Thay đổi màu chính
    ),
    // ... customize theme
  );
}
```

### 6. Setup Firebase / Analytics (optional)

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^latest
  firebase_analytics: ^latest
  firebase_crashlytics: ^latest
```

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase
  await Firebase.initializeApp();
  
  // ... existing code
}
```

### 7. Cấu hình assets

```yaml
# pubspec.yaml
flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/fonts/
  
  fonts:
    - family: YourCustomFont
      fonts:
        - asset: assets/fonts/YourFont-Regular.ttf
        - asset: assets/fonts/YourFont-Bold.ttf
          weight: 700
```

### 8. Cấu hình Splash Screen & App Icon

```bash
# Add packages
flutter pub add flutter_native_splash
flutter pub add flutter_launcher_icons

# Configure
# flutter_native_splash.yaml
# flutter_launcher_icons.yaml

# Generate
flutter pub run flutter_native_splash:create
flutter pub run flutter_launcher_icons
```

---

## 🆕 Tạo module mới

### Template nhanh

```bash
# Tạo thư mục
mkdir -p lib/features/your_module/{data/{models,repositories},presentation/{providers,pages}}

# Tạo barrel export
touch lib/features/your_module/your_module.dart
```

### 1. Model (Freezed)

```dart
// lib/features/your_module/data/models/your_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'your_model.freezed.dart';
part 'your_model.g.dart';

@freezed
abstract class YourModel with _$YourModel {
  const factory YourModel({
    required String id,
    required String name,
  }) = _YourModel;

  factory YourModel.fromJson(Map<String, Object?> json) =>
      _$YourModelFromJson(json);
}
```

### 2. Repository (Injectable)

```dart
// lib/features/your_module/data/repositories/your_repository.dart
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';

@singleton
class YourRepository {
  final ApiClient _client;
  
  YourRepository(this._client);
  
  Future<List<YourModel>> getAll() async {
    final response = await _client.get('/your-endpoint');
    // Parse and return
  }
}
```

### 3. Provider (Riverpod Generator)

```dart
// lib/features/your_module/presentation/providers/your_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:get_it/get_it.dart';

part 'your_provider.g.dart';

@riverpod
YourRepository yourRepository(YourRepositoryRef ref) {
  return GetIt.instance<YourRepository>();
}

@riverpod
class YourList extends _$YourList {
  @override
  Future<List<YourModel>> build() async {
    return await _fetchData();
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchData);
  }
  
  Future<List<YourModel>> _fetchData() async {
    final repo = ref.read(yourRepositoryProvider);
    return await repo.getAll();
  }
}
```

### 4. Page (ConsumerWidget)

```dart
// lib/features/your_module/presentation/pages/your_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/your_provider.dart';

class YourPage extends ConsumerWidget {
  const YourPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(yourListProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Your Page')),
      body: dataAsync.when(
        data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return ListTile(title: Text(data[index].name));
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
```

### 5. Barrel Export

```dart
// lib/features/your_module/your_module.dart
export 'data/models/your_model.dart';
export 'data/repositories/your_repository.dart';
export 'presentation/providers/your_provider.dart';
export 'presentation/pages/your_page.dart';
```

### 6. Generate Code

```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📦 Shared Components Strategy

### ✅ Barrel Export cho Shared

```dart
// lib/shared/shared.dart
export 'widgets/custom_button.dart';
export 'widgets/loading_widget.dart';
export 'utils/validators.dart';
export 'utils/formatters.dart';
export 'utils/extensions.dart';
```

**Usage:**
```dart
import 'package:your_app/shared/shared.dart';

// Có thể dùng tất cả:
// - CustomButton
// - LoadingWidget
// - Validators
// - Formatters
// - Extensions
```

### Khi nào nên thêm vào Shared?

✅ **NÊN thêm vào shared/:**
- Widgets dùng >= 3 modules
- Validators, Formatters, Extensions chung
- Common models (User, Error, Response)
- Shared utilities

❌ **KHÔNG NÊN thêm vào shared/:**
- Widgets chỉ dùng 1-2 modules → Để trong module đó
- Business logic specific → Để trong feature module

---

## 🔧 Maintenance

### Update packages

```bash
# Check outdated
fvm flutter pub outdated

# Update all
fvm flutter pub upgrade

# Specific package
fvm flutter pub upgrade package_name
```

### Clean & regenerate

```bash
# Clean generated files
find . -name "*.g.dart" -delete
find . -name "*.freezed.dart" -delete
rm lib/core/di/injection.config.dart

# Regenerate
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### Testing strategy

```dart
// test/features/your_module/your_repository_test.dart
void main() {
  test('should fetch data successfully', () async {
    // Arrange
    final mockClient = MockApiClient();
    final repository = YourRepository(mockClient);
    
    // Act
    final result = await repository.getAll();
    
    // Assert
    expect(result, isNotEmpty);
  });
}
```

---

## 🎨 Code Style Guidelines

### Naming conventions
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `camelCase` (hoặc `SCREAMING_SNAKE_CASE` cho constants thật sự)
- **Private**: `_leadingUnderscore`

### Import order
```dart
// 1. Dart imports
import 'dart:async';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 4. Project imports (barrel exports preferred)
import '../../core/core.dart';
import '../product/product.dart';
```

### File organization
```dart
// 1. Imports
// 2. Part statements
// 3. Constants
// 4. Class definition
// 5. Constructor
// 6. Public methods
// 7. Private methods
```

---

## 🚀 Production Checklist

- [ ] Update app name & package name
- [ ] Configure API endpoints
- [ ] Setup Firebase/Analytics
- [ ] Configure Splash Screen & App Icon
- [ ] Remove demo/example code
- [ ] Add proper error handling
- [ ] Setup CI/CD
- [ ] Enable ProGuard/R8 (Android)
- [ ] Configure signing (Android/iOS)
- [ ] Test on real devices
- [ ] Performance profiling
- [ ] Security audit (API keys, tokens)
- [ ] Accessibility testing
- [ ] Update README.md với project info

---

## 📚 Additional Resources

- **README.md** - Project overview & quick start
- **FREEZED_3_SYNTAX.md** - Freezed 3.x reference
- **BARREL_EXPORTS.md** - Barrel export patterns

---

**Happy Coding! 🎉**

