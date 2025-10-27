# 🎯 Core Package Architecture Principles

## 📦 Nguyên tắc phân chia Core vs App

### ✅ Core Package NÊN chứa:

#### 1. **Infrastructure Layer**
```
✅ Network:
   - API client (Dio setup)
   - Interceptors (Auth, Retry, Logging)
   - Base exceptions

✅ Dependency Injection:
   - GetIt setup
   - Injectable config
   - Core modules (ApiClient, SharedPreferences)

✅ Utils:
   - Logger
   - Validators (email, phone, etc.)
   - Formatters (date, currency, etc.)
   - Extensions (String, DateTime, etc.)

✅ Constants:
   - API endpoints base
   - Timeout configs
   - Storage keys

✅ Theme:
   - Base theme config
   - Colors, text styles
   - Common UI constants

✅ Router Helpers:
   - Base error pages
   - Route guards (abstract)
   - Navigation helpers
```

### ❌ Core Package KHÔNG NÊN chứa:

```
❌ Business Models:
   - User, Product, Order, etc.
   → Thuộc về App/Features

❌ Actual Routes:
   - /login, /home, /profile
   → Thuộc về App Router

❌ Feature-specific Logic:
   - AuthRepository, ProductRepository
   → Thuộc về App Features

❌ UI Components:
   - LoginPage, ProfilePage
   → Thuộc về App Features

❌ Business Constants:
   - Product categories
   - User roles
   → Thuộc về App
```

---

## 🏗️ Cấu trúc đúng:

### **Core Package** (Infrastructure)
```
packages/core/lib/src/
├── network/
│   ├── api_client.dart          ✅ Base API client
│   ├── interceptors/            ✅ Generic interceptors
│   └── exceptions/              ✅ Network exceptions
│
├── di/
│   └── injection.dart           ✅ Core DI (ApiClient, Prefs)
│
├── utils/
│   ├── logger.dart              ✅ Generic logger
│   ├── validators.dart          ✅ Generic validators
│   └── extensions.dart          ✅ Generic extensions
│
├── theme/
│   ├── app_theme.dart           ✅ Base theme
│   └── app_colors.dart          ✅ Color palette
│
├── constants/
│   └── app_constants.dart       ✅ Infrastructure constants
│
└── router/
    └── base_error_page.dart     ✅ Generic error page
```

### **App** (Business Logic)
```
skeleton_template/lib/
├── core/
│   ├── models/
│   │   └── user.dart            ✅ Business models
│   │
│   ├── di/
│   │   └── injection.dart       ✅ App DI (Repositories)
│   │
│   └── router/
│       └── app_router.dart      ✅ Actual routes
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── repositories/    ✅ AuthRepository
│   │   └── presentation/
│   │
│   └── product/
│       ├── data/
│       │   ├── models/          ✅ Product model
│       │   └── repositories/    ✅ ProductRepository
│       └── presentation/
│
└── shared/
    ├── widgets/                 ✅ Shared UI components
    └── utils/                   ✅ App-specific utils
```

---

## 🎓 Ví dụ cụ thể:

### ❌ SAI: User model trong Core

```dart
// ❌ packages/core/lib/src/models/user.dart
class User {
  final String id;
  final String email;
  // ...
}
```

**Tại sao sai?**
- `User` là **business concept** của app
- Core không nên biết app có entity nào
- Khó reuse core cho app khác (có thể không có User)

### ✅ ĐÚNG: User model trong App

```dart
// ✅ skeleton_template/lib/core/models/user.dart
class User {
  final String id;
  final String email;
  // ...
}
```

---

### ❌ SAI: Routes trong Core

```dart
// ❌ packages/core/lib/src/router/app_router.dart
class AppRouterConfig {
  static const String login = '/login';
  static const String home = '/home';
}
```

**Tại sao sai?**
- Routes là **app-specific**
- Core không biết app có pages nào
- Mỗi app có routes khác nhau

### ✅ ĐÚNG: Routes trong App

```dart
// ✅ skeleton_template/lib/core/router/app_router.dart
class AppRouter {
  static const String login = '/login';
  static const String home = '/home';
  
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(path: login, builder: (_, __) => LoginPage()),
      GoRoute(path: home, builder: (_, __) => HomePage()),
    ],
  );
}
```

**Core chỉ cung cấp helpers:**
```dart
// ✅ packages/core/lib/src/router/base_error_page.dart
class BaseErrorPage extends StatelessWidget {
  // Generic error page mà app có thể customize
}
```

---

## 🔍 Decision Tree: Core hay App?

```
Câu hỏi: "Tính năng X nên nằm ở đâu?"

1. X có phụ thuộc business logic không?
   YES → App
   NO  → Tiếp tục

2. X có thể reuse cho mọi app không?
   YES → Core
   NO  → App

3. X là infrastructure hay business?
   Infrastructure → Core
   Business       → App
```

### Ví dụ áp dụng:

**Logger:**
- ❓ Phụ thuộc business? NO
- ❓ Reuse được? YES
- ❓ Infrastructure? YES
- ✅ → **Core**

**User model:**
- ❓ Phụ thuộc business? YES
- ✅ → **App**

**ApiClient:**
- ❓ Phụ thuộc business? NO
- ❓ Reuse được? YES
- ❓ Infrastructure? YES
- ✅ → **Core**

**AuthRepository:**
- ❓ Phụ thuộc business? YES (login logic)
- ✅ → **App**

**AppTheme:**
- ❓ Phụ thuộc business? NO (chỉ là colors/fonts)
- ❓ Reuse được? YES (có thể customize)
- ❓ Infrastructure? YES
- ✅ → **Core**

**Routes config:**
- ❓ Phụ thuộc business? YES (biết app có pages nào)
- ✅ → **App**

---

## 📊 Tổng kết:

### Core Package = Infrastructure
- **Mục đích**: Reusable foundation
- **Nội dung**: Network, DI, Utils, Theme, Helpers
- **Không biết**: Business models, Features, Routes

### App = Business Logic
- **Mục đích**: Implement business requirements
- **Nội dung**: Models, Repositories, Features, Routes
- **Sử dụng**: Core package như một foundation

---

## ✅ Checklist khi thêm code:

Trước khi thêm file vào Core, hỏi:
- [ ] Code này có business logic không?
- [ ] Code này có thể dùng cho app khác không?
- [ ] Code này là infrastructure hay business?
- [ ] Code này có depend on features không?

**Nếu có bất kỳ câu trả lời "có business" → App, không phải Core!**

---

## 🎯 Kết luận:

**Core Package:**
- Pure infrastructure
- No business knowledge
- Maximum reusability

**App:**
- Business logic
- Feature implementation
- Uses core as foundation

**Separation = Clean Architecture = Maintainable Code** ✨

