# 🔧 Fix: AuthRepository Not Registered

## ❌ Lỗi hiện tại:

```
Bad state: GetIt: Object/factory with type AuthRepository is not registered inside GetIt.
```

## 🎯 Nguyên nhân:

- `AuthRepository` nằm trong **app** (skeleton_template)
- `injection.dart` trong **core package** không biết về app's repositories
- Cần tách DI thành 2 layers: Core DI + App DI

## ✅ Đã fix:

1. ✅ Tạo `lib/core/di/injection.dart` riêng cho app
2. ✅ Update `main.dart` để dùng app's injection
3. ✅ Tạo `build.yaml` cho app

## 🚀 Bước tiếp theo - Chạy lệnh này:

```bash
cd /Users/anhdinhhoangquang/moduler_flutter_skeleton/skeleton_template

# Regenerate injection.config.dart
fvm flutter pub run build_runner build --delete-conflicting-outputs

# Hot restart app
# Press 'R' trong terminal đang run app
```

## 📋 Cấu trúc DI mới:

```
Core Package (packages/core/):
  └── lib/src/di/injection.dart
      └── Registers: ApiClient, SharedPreferences, Interceptors

App (skeleton_template/):
  └── lib/core/di/injection.dart
      └── Registers: AuthRepository, và các repositories khác
      └── Gọi core.configureDependencies() trước
```

## 🔄 Flow:

```dart
main.dart:
  await app_di.configureDependencies()
    ↓
  1. core.configureDependencies()  // Register core stuff
  2. getIt.init()                  // Register app stuff (AuthRepository)
```

## ✅ Sau khi chạy build_runner:

1. File `lib/core/di/injection.config.dart` sẽ được generate
2. `AuthRepository` sẽ được register vào GetIt
3. Hot restart app (Press 'R')
4. Login flow sẽ hoạt động! 🎉

---

**Chạy lệnh và báo kết quả!** 🚀

