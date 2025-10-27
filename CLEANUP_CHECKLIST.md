# 🧹 Cleanup Checklist

## ✅ Cần xóa các folder/file thừa:

### 1. Xóa thư mục `lib/core/` (rỗng)
```bash
cd skeleton_template
rm -rf lib/core
```

### 2. Chạy build_runner
```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Check warnings
```bash
fvm flutter analyze
```

### 4. Clean build
```bash
fvm flutter clean
fvm flutter pub get
```

### 5. Test app
```bash
fvm flutter run -d macos
```

---

## 📁 Cấu trúc cuối cùng (Clean):

```
skeleton_template/lib/
├── app/                    # ✅ App-level code
│   ├── di/
│   │   ├── injection.dart
│   │   └── injection.config.dart
│   └── router/
│       └── app_router.dart
│
├── features/               # ✅ Business features
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── user.dart
│   │   │   │   └── user.g.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   └── providers/
│   │   └── auth.dart
│   │
│   ├── home/
│   ├── profile/
│   ├── settings/
│   └── product/
│
├── shared/                 # ✅ Shared widgets/utils
│   ├── widgets/
│   └── utils/
│
└── main.dart
```

---

## ❌ Đã xóa:

- ❌ `lib/core/` (empty folders)
- ❌ `lib/core/models/user.dart` → Moved to `features/auth/data/models/`
- ❌ `lib/core/di/` → Moved to `lib/app/di/`
- ❌ `lib/core/router/` → Moved to `lib/app/router/`

---

## ✅ Principles:

1. **Core Package** = Pure infrastructure (network, DI, utils)
2. **App (`lib/app/`)** = App-level concerns (DI, router)
3. **Features** = Business logic + models
4. **Shared** = Reusable widgets/utils

---

**Chạy các lệnh trên và test app!** 🚀

