# 🚀 Setup Instructions - Core Package Migration

## ✅ Đã hoàn thành:

1. ✅ Tạo cấu trúc package `core` tại `packages/core/`
2. ✅ Di chuyển tất cả core files vào package
3. ✅ Tạo barrel exports cho core package
4. ✅ Update `pubspec.yaml` của app để sử dụng core package
5. ✅ Update imports trong app từ relative paths sang `package:core/core.dart`

## 📋 Các bước cần chạy thủ công:

### Step 1: Install dependencies cho Core Package

```bash
cd packages/core
fvm flutter pub get
cd ../..
```

### Step 2: Run build_runner cho Core Package

```bash
cd packages/core
fvm flutter pub run build_runner build --delete-conflicting-outputs
cd ../..
```

### Step 3: Install dependencies cho App

```bash
cd skeleton_template
fvm flutter pub get
```

### Step 4: Run build_runner cho App

```bash
cd skeleton_template
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 5: Run app

```bash
cd skeleton_template
fvm flutter run -d macos
```

---

## 🎯 Hoặc sử dụng script tự động:

```bash
chmod +x setup_core.sh
./setup_core.sh
```

---

## 📦 Cấu trúc mới:

```
moduler_flutter_skeleton/
├── packages/
│   └── core/                    # ⭐ Core Package
│       ├── lib/
│       │   ├── src/
│       │   │   ├── constants/
│       │   │   ├── theme/
│       │   │   ├── models/
│       │   │   ├── network/
│       │   │   │   ├── api_client.dart
│       │   │   │   └── interceptors/
│       │   │   ├── di/
│       │   │   │   └── injection.dart
│       │   │   ├── router/
│       │   │   └── utils/
│       │   └── core.dart        # Barrel export
│       ├── pubspec.yaml
│       └── README.md
│
└── skeleton_template/           # Main app
    ├── lib/
    │   ├── features/            # Business features
    │   ├── core/
    │   │   └── router/          # App-specific router
    │   │       └── app_router.dart
    │   └── main.dart
    └── pubspec.yaml
        dependencies:
          core:
            path: ../packages/core
```

---

## 🔄 Thay đổi imports:

### Trước:
```dart
import '../../../core/network/api_client.dart';
import '../../../core/models/user.dart';
import '../../../core/utils/logger.dart';
```

### Sau:
```dart
import 'package:core/core.dart';
```

---

## ✅ Kiểm tra:

Sau khi chạy xong, kiểm tra:

1. **No errors**: `fvm flutter analyze`
2. **App runs**: `fvm flutter run -d macos`
3. **Login flow works**: Test login -> home -> logout

---

## 🐛 Troubleshooting:

### Lỗi: "Target of URI doesn't exist"
→ Chạy `fvm flutter pub get` trong cả `packages/core` và `skeleton_template`

### Lỗi: "Target of URI hasn't been generated"
→ Chạy `build_runner` trong cả `packages/core` và `skeleton_template`

### Lỗi: "Object not registered in GetIt"
→ Kiểm tra `injection.config.dart` đã được generate chưa

---

## 📝 Notes:

- Core package chứa tất cả infrastructure code
- App chỉ chứa business logic và features
- Imports giờ đơn giản hơn: `import 'package:core/core.dart';`
- Dễ dàng reuse core package cho các app khác

