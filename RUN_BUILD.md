# 🔧 Fix Warning: Cross-Package Dependencies

## ✅ Đã fix:

**Vấn đề:** Injectable không thể auto-inject dependencies từ core package vào app repositories.

**Solution:** Register manually trong `injection.dart`

---

## 📋 Chạy lệnh này:

```bash
cd skeleton_template
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

**Sau đó hot restart:**
```
R  # Trong terminal đang run app
```

---

## 🎯 Cách hoạt động:

### **AuthRepository** (depends on core services):
```dart
// ❌ KHÔNG dùng @singleton
class AuthRepository {
  AuthRepository(ApiClient apiClient, SharedPreferences prefs);
}
```

**Lý do:** `ApiClient` và `SharedPreferences` đến từ core package, Injectable không thể auto-wire cross-package.

**Fix:** Register manually trong `injection.dart`:
```dart
getIt.registerSingleton<AuthRepository>(
  AuthRepository(
    getIt<core.ApiClient>(),
    getIt<SharedPreferences>(),
  ),
);
```

---

### **ProductRepository** (no core dependencies):
```dart
// ✅ Dùng @singleton bình thường
@singleton
class ProductRepository {
  ProductRepository();  // Không depend vào core
}
```

**Lý do:** Không depend vào core services → Injectable có thể auto-register.

---

## 📝 Rule:

**Repository depends on core services?**
- **YES** → Không dùng `@singleton`, register manually
- **NO** → Dùng `@singleton` bình thường

---

## ✅ Expected result:

Sau khi chạy build_runner, warning sẽ mất:
```
✅ Built with build_runner in 10s; wrote 4 outputs.
```

Không còn:
```
❌ [AuthRepository] depends on unregistered type [ApiClient]
```

---

**Chạy lệnh và báo kết quả!** 🚀

