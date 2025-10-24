# 📦 Barrel Exports Pattern

## ✅ Đã áp dụng Barrel Pattern

Tất cả modules đã có barrel export files để dễ dàng import.

## 📁 Cấu trúc Barrel Files

```
lib/
├── core/
│   └── core.dart                    # ✅ Core barrel
├── features/
│   ├── auth/
│   │   └── auth.dart                # ✅ Auth module barrel
│   ├── home/
│   │   └── home.dart                # ✅ Home module barrel
│   ├── profile/
│   │   └── profile.dart             # ✅ Profile module barrel
│   ├── settings/
│   │   └── settings.dart            # ✅ Settings module barrel
│   └── product/
│       └── product.dart             # ✅ Product module barrel
└── shared/
    └── shared.dart                  # Future: Shared barrel
```

## 🎯 Ưu điểm

### 1. **Clean Imports**
```dart
// ❌ TRƯỚC - Import nhiều files
import '../auth/data/repositories/auth_repository.dart';
import '../auth/presentation/providers/auth_provider.dart';
import '../auth/presentation/pages/login_page.dart';

// ✅ SAU - Import 1 barrel file
import '../auth/auth.dart';
```

### 2. **Encapsulation**
Module kiểm soát được public API của mình

### 3. **Easy Refactoring**
Di chuyển files bên trong module không ảnh hưởng imports bên ngoài

### 4. **Better Organization**
Module như một package độc lập

## 📝 Template Barrel File

### Module có đầy đủ layers
```dart
// features/[module_name]/[module_name].dart

// Data Layer - Models
export 'data/models/model_name.dart';

// Data Layer - Repositories
export 'data/repositories/repository_name.dart';

// Presentation Layer - Providers
export 'presentation/providers/provider_name.dart';

// Presentation Layer - Pages
export 'presentation/pages/page_name.dart';

// Presentation Layer - Widgets (nếu có)
export 'presentation/widgets/widget_name.dart';
```

### Module đơn giản
```dart
// features/home/home.dart

// Presentation Layer - Pages
export 'presentation/pages/home_page.dart';
```

## 🔍 Chi tiết Barrel Files

### 1. Core Barrel
```dart
// lib/core/core.dart
export 'constants/app_constants.dart';
export 'theme/app_theme.dart';
export 'router/app_router.dart';
export 'models/user.dart';
export 'network/api_client.dart';
export 'utils/logger.dart';
export 'di/injection.dart';
```

**Usage:**
```dart
import 'package:sketon_moduler/core/core.dart';

// Có thể dùng: AppConstants, AppTheme, AppRouter, User, ApiClient, Logger, etc.
```

### 2. Auth Module Barrel
```dart
// lib/features/auth/auth.dart
export 'data/repositories/auth_repository.dart';
export 'presentation/providers/auth_provider.dart';
export 'presentation/pages/login_page.dart';
```

**Usage:**
```dart
import '../../auth/auth.dart';

// Có thể dùng: AuthRepository, authProvider, LoginPage
```

### 3. Product Module Barrel
```dart
// lib/features/product/product.dart
export 'data/models/product.dart';
export 'data/repositories/product_repository.dart';
export 'presentation/providers/product_provider.dart';
export 'presentation/pages/product_list_page.dart';
```

**Usage:**
```dart
import '../product/product.dart';

// Có thể dùng: Product, ProductRepository, productListProvider, ProductListPage
```

## 💡 Best Practices

### 1. **Chỉ export public API**
```dart
// ✅ ĐÚNG - Chỉ export những gì cần
export 'data/models/product.dart';
export 'presentation/pages/product_page.dart';

// ❌ SAI - Đừng export internal files
// export 'presentation/widgets/internal/_internal_widget.dart';
```

### 2. **Tổ chức theo layers**
```dart
// Export theo thứ tự: Data → Presentation
// Data Layer
export 'data/models/...';
export 'data/repositories/...';

// Presentation Layer
export 'presentation/providers/...';
export 'presentation/pages/...';
```

### 3. **Comments để dễ đọc**
```dart
// Product Module Barrel Export

// Data Layer - Models
export 'data/models/product.dart';

// Data Layer - Repositories  
export 'data/repositories/product_repository.dart';
```

### 4. **Không export barrel trong barrel**
```dart
// ❌ SAI - Đừng export barrel files khác
export '../other_module/other_module.dart';

// ✅ ĐÚNG - Chỉ export files trong module
export 'data/models/product.dart';
```

## 📊 So sánh Import

### Trước khi dùng Barrel
```dart
// main.dart
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/di/injection.dart';

// home_page.dart
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

// Total: 6 imports
```

### Sau khi dùng Barrel
```dart
// main.dart
import 'core/core.dart';

// home_page.dart
import '../../../profile/profile.dart';
import '../../../settings/settings.dart';

// Total: 3 imports
```

**Giảm 50% số lượng imports!**

## 🚀 Cách tạo Barrel mới

### Bước 1: Tạo file barrel
```bash
# Tạo file [module_name].dart trong root của module
touch lib/features/notification/notification.dart
```

### Bước 2: Export public API
```dart
// lib/features/notification/notification.dart

// Models
export 'data/models/notification.dart';

// Repositories
export 'data/repositories/notification_repository.dart';

// Providers
export 'presentation/providers/notification_provider.dart';

// Pages
export 'presentation/pages/notification_page.dart';
```

### Bước 3: Sử dụng
```dart
// Trong file khác
import '../notification/notification.dart';

// Có thể dùng tất cả exports
final notif = Notification(...);
```

## 🎨 Examples

### Example 1: Simple Module
```dart
// features/splash/splash.dart
export 'presentation/pages/splash_page.dart';
```

### Example 2: Complex Module
```dart
// features/order/order.dart

// Models
export 'data/models/order.dart';
export 'data/models/order_item.dart';
export 'data/models/order_status.dart';

// Repositories
export 'data/repositories/order_repository.dart';

// Providers
export 'presentation/providers/order_provider.dart';
export 'presentation/providers/order_list_provider.dart';

// Pages
export 'presentation/pages/order_list_page.dart';
export 'presentation/pages/order_detail_page.dart';

// Widgets (shared trong module)
export 'presentation/widgets/order_card.dart';
```

### Example 3: Shared Components
```dart
// shared/shared.dart

// Widgets
export 'widgets/custom_button.dart';
export 'widgets/loading_widget.dart';

// Utils
export 'utils/validators.dart';
export 'utils/formatters.dart';
```

## ⚠️ Lưu ý

### 1. **Circular Dependencies**
```dart
// ❌ SAI - Tránh circular imports
// auth/auth.dart
export '../product/product.dart';  // Circular!

// product/product.dart
export '../auth/auth.dart';  // Circular!
```

### 2. **Generated Files**
```dart
// ✅ ĐÚNG - Có thể export generated files
export 'data/models/product.dart';  // Sẽ auto-export .freezed.dart và .g.dart

// ❌ KHÔNG CẦN - Đừng export trực tiếp generated files
// export 'data/models/product.g.dart';
// export 'data/models/product.freezed.dart';
```

### 3. **Test Files**
```dart
// ❌ SAI - Đừng export test files
// export 'test/product_test.dart';
```

## 📚 Tài liệu tham khảo

- [Dart Package Guide](https://dart.dev/guides/libraries/create-library-packages)
- [Effective Dart: Usage](https://dart.dev/guides/language/effective-dart/usage#do-use-strings-in-part-of-directives)
- [Flutter Architecture](https://docs.flutter.dev/development/data-and-backend/state-mgmt/options)

## ✅ Summary

| Aspect | Before Barrel | After Barrel |
|--------|--------------|--------------|
| Import lines | Nhiều | Ít hơn 50% |
| Organization | Scattered | Centralized |
| Refactoring | Khó | Dễ dàng |
| Encapsulation | Weak | Strong |
| Maintainability | Khó | Dễ |

**Barrel exports giúp code clean, modular và dễ maintain hơn! 🚀**
