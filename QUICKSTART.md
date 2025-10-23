# 🚀 Quick Start

## 1. Clone & Setup

```bash
git clone [this-repo] your-project-name
cd your-project-name/sketon_moduler

# Install dependencies
fvm flutter pub get

# Generate code
fvm flutter pub run build_runner build --delete-conflicting-outputs

# Run
fvm flutter run
```

## 2. Demo Login

- Email: `bất kỳ (có @)`
- Password: `bất kỳ (>= 3 ký tự)`

## 3. Read Documentation

1. **README.md** - Project overview & patterns
2. **PROJECT_TEMPLATE.md** - Setup cho project mới
3. **STRUCTURE.md** - Architecture details

## 4. Customize cho project mới

```dart
// 1. Update API URL
// lib/core/network/api_client.dart
@override
String get baseUrl => 'https://your-api.com';

// 2. Update constants
// lib/core/constants/app_constants.dart
static const String appName = 'Your App';

// 3. Xóa demo modules
rm -rf lib/features/product
rm -rf lib/features/profile
rm -rf lib/features/settings
```

## 5. Tạo module mới

Xem chi tiết trong `README.md` hoặc copy structure từ `lib/features/product/`

**Happy Coding! 🎉**

