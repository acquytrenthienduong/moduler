# 🎯 Flutter Modular Skeleton Template

> Production-ready Flutter template với Clean Architecture, Riverpod 3.x, Freezed 3.x

## 📦 What's Inside?

- ✅ **Modular Architecture** - Feature-based organization
- ✅ **Riverpod 3.x** - State management với Generator
- ✅ **Freezed 3.x** - Immutable models
- ✅ **GetIt + Injectable** - Dependency Injection
- ✅ **GoRouter 16.x** - Navigation với auth guards
- ✅ **Multiple API Clients** - Support nhiều endpoints
- ✅ **Barrel Exports** - Clean imports
- ✅ **Shared Utilities** - Validators, Formatters, Extensions
- ✅ **Complete Auth Flow** - Login → Home → Logout
- ✅ **FVM Support** - Flutter 3.35.0

## 🚀 Quick Start

```bash
cd sketon_moduler
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter run
```

**Demo Login**: Bất kỳ email (có @) + password (>= 3 ký tự)

## 📚 Documentation

| File | Description |
|------|-------------|
| **QUICKSTART.md** | Quick start guide |
| **sketon_moduler/README.md** | Project overview & patterns |
| **sketon_moduler/PROJECT_TEMPLATE.md** | Setup guide cho project mới |
| **sketon_moduler/STRUCTURE.md** | Architecture details |
| **sketon_moduler/CHECKLIST.md** | Features checklist |
| **sketon_moduler/FREEZED_3_SYNTAX.md** | Freezed reference |
| **sketon_moduler/BARREL_EXPORTS.md** | Import patterns |

## 🎯 Use This Template

### Option 1: Clone trực tiếp
```bash
git clone [this-repo] your-project-name
cd your-project-name
# Xem sketon_moduler/PROJECT_TEMPLATE.md để setup
```

### Option 2: GitHub Template
1. Click "Use this template" button
2. Clone your new repo
3. Follow `sketon_moduler/PROJECT_TEMPLATE.md`

## 🔧 Tech Stack

- Flutter 3.35.0 + Dart 3.8.0
- flutter_riverpod 3.0.3 + riverpod_generator
- freezed 3.1.0
- go_router 16.3.0
- get_it 8.0.2 + injectable 2.5.0
- dio 5.9.0

## 📂 Structure

```
sketon_moduler/
├── lib/
│   ├── core/              # Core utilities
│   │   ├── core.dart      # Barrel export
│   │   ├── di/            # GetIt + Injectable
│   │   ├── network/       # API clients (multiple support)
│   │   ├── router/        # GoRouter + auth guards
│   │   └── ...
│   │
│   ├── features/          # Feature modules
│   │   ├── auth/
│   │   │   ├── auth.dart  # Barrel export
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   ├── home/
│   │   ├── product/       # Example module
│   │   └── ...
│   │
│   └── shared/            # Shared components
│       ├── shared.dart    # Barrel export
│       ├── widgets/
│       └── utils/         # Validators, Formatters, Extensions
│
└── [Documentation files]
```

## 🌟 Highlights

### 1. Multiple API Clients Support
```dart
// Dễ dàng add nhiều API endpoints
class ApiClient extends BaseApiClient {
  @override String get baseUrl => 'https://api.example.com';
}

class AnalyticsClient extends BaseApiClient {
  @override String get baseUrl => 'https://analytics.com';
}
```

### 2. Complete Shared Utilities
```dart
import 'shared/shared.dart';

Validators.email(email);
Formatters.currency(1000000);  // 1,000,000₫
'test@email.com'.isEmail;      // Extensions
```

### 3. Barrel Exports Pattern
```dart
// Clean imports
import 'features/product/product.dart';
// instead of multiple imports
```

## 🎓 Getting Started

1. **First time?** → Read `QUICKSTART.md`
2. **Want to understand?** → Read `sketon_moduler/README.md`
3. **Start new project?** → Follow `sketon_moduler/PROJECT_TEMPLATE.md`
4. **Need architecture details?** → Check `sketon_moduler/STRUCTURE.md`

## 📝 Create New Module

```bash
# 1. Create structure
mkdir -p lib/features/your_module/{data/{models,repositories},presentation/{providers,pages}}

# 2. Create barrel export
touch lib/features/your_module/your_module.dart

# 3. Follow patterns trong product module
# 4. Run build_runner
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

Chi tiết trong `sketon_moduler/README.md` section "Tạo Module Mới"

## ✅ Features Checklist

- [x] Authentication flow (login/logout)
- [x] Multiple API clients support
- [x] Riverpod 3.x state management
- [x] Freezed 3.x models
- [x] GoRouter navigation
- [x] Injectable DI
- [x] Barrel exports
- [x] Shared utilities (Validators, Formatters, Extensions)
- [x] Material 3 theme
- [x] Error handling
- [x] Loading states
- [x] Code generation setup

## 🚀 Production Checklist

Khi deploy project thật, check:
- [ ] Update API URLs
- [ ] Remove demo code
- [ ] Configure Firebase/Analytics
- [ ] Setup Splash Screen & Icon
- [ ] Configure signing (Android/iOS)
- [ ] Setup CI/CD
- [ ] Test on real devices

Chi tiết trong `sketon_moduler/PROJECT_TEMPLATE.md`

## 🤝 Contributing

Feel free to:
- Report issues
- Suggest improvements
- Submit PRs

## 📄 License

MIT License - Free to use for any project

## 💬 Support

Có vấn đề? Check:
1. Documentation files
2. Run `fvm flutter clean && fvm flutter pub get`
3. Run build_runner
4. Check GitHub issues

---

**Happy Coding! 🎉**

*Template version 1.0.0 | Flutter 3.35.0 | Oct 2024*
