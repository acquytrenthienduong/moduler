# 📝 Module Naming Guide

## ✅ Naming Convention Fixed

Script đã được fix để convert tên đúng chuẩn:

### Examples

| Input | PascalCase (Class) | camelCase (Provider) | snake_case (File) |
|-------|-------------------|---------------------|------------------|
| `order` | `Order` | `order` | `order` |
| `map` | `Map` | `map` | `map` |
| `user_profile` | `UserProfile` | `userProfile` | `user_profile` |
| `payment_method` | `PaymentMethod` | `paymentMethod` | `payment_method` |
| `shopping_cart` | `ShoppingCart` | `shoppingCart` | `shopping_cart` |

### Generated Code

```bash
./scripts/create_module.sh user_profile
```

**Model (PascalCase)**:
```dart
@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({...}) = _UserProfile;
}
```

**Repository (PascalCase)**:
```dart
@singleton
class UserProfileRepository {
  ...
}
```

**Provider (camelCase)**:
```dart
@riverpod
UserProfileRepository userProfileRepository(Ref ref) {...}

@riverpod
class UserProfileList extends _$UserProfileList {...}
```

**Usage (camelCase)**:
```dart
// ✅ Đúng
ref.watch(userProfileListProvider)
ref.read(userProfileRepositoryProvider)
ref.watch(userProfileDetailProvider(id))

// ❌ Sai (cũ)
ref.watch(user_profileListProvider)  // snake_case
ref.watch(UserProfileListProvider)   // PascalCase
```

---

## ⚠️ Reserved Keywords

Tránh dùng các từ khóa reserved của Dart:

### Common Reserved Keywords
- `map` → Dùng `location`, `place`, `area` thay thế
- `list` → Dùng `items`, `collection` thay thế
- `set` → Dùng `group`, `collection` thay thế
- `class` → Dùng `category`, `type` thay thế
- `void` → Dùng `empty`, `blank` thay thế
- `int`, `double`, `num` → Dùng `number`, `value` thay thế
- `string` → Dùng `text`, `content` thay thế

### Full List
```
abstract, as, assert, async, await, break, case, catch, class,
const, continue, covariant, default, deferred, do, dynamic, else,
enum, export, extends, extension, external, factory, false, final,
finally, for, Function, get, hide, if, implements, import, in,
interface, is, late, library, mixin, new, null, on, operator,
part, required, rethrow, return, set, show, static, super, switch,
sync, this, throw, true, try, typedef, var, void, while, with, yield
```

---

## 🎯 Best Practices

### 1. Use Singular Names
```bash
# ✅ Good
./scripts/create_module.sh order
./scripts/create_module.sh product
./scripts/create_module.sh user

# ❌ Bad
./scripts/create_module.sh orders
./scripts/create_module.sh products
./scripts/create_module.sh users
```

### 2. Use Descriptive Names
```bash
# ✅ Good
./scripts/create_module.sh user_profile
./scripts/create_module.sh payment_method
./scripts/create_module.sh order_history

# ❌ Bad
./scripts/create_module.sh up
./scripts/create_module.sh pm
./scripts/create_module.sh oh
```

### 3. Use snake_case for Input
```bash
# ✅ Good
./scripts/create_module.sh user_profile
./scripts/create_module.sh shopping_cart

# ❌ Bad (will work but not recommended)
./scripts/create_module.sh UserProfile
./scripts/create_module.sh shoppingCart
```

### 4. Avoid Special Characters
```bash
# ✅ Good
./scripts/create_module.sh user_profile

# ❌ Bad
./scripts/create_module.sh user-profile
./scripts/create_module.sh user.profile
./scripts/create_module.sh user profile
```

---

## 🔍 Naming Convention Details

### Script Logic

```bash
# Input
MODULE_NAME="user_profile"

# Convert to lowercase
MODULE_NAME_LOWER="user_profile"

# Convert to PascalCase (UserProfile)
MODULE_NAME_PASCAL=$(echo "$MODULE_NAME_LOWER" | awk -F_ '{
  for(i=1;i<=NF;i++) 
    $i=toupper(substr($i,1,1)) tolower(substr($i,2))
}1' OFS="")

# Convert to camelCase (userProfile)
MODULE_NAME_CAMEL=$(echo "$MODULE_NAME_LOWER" | awk -F_ '{
  printf "%s", tolower($1); 
  for(i=2;i<=NF;i++) 
    printf "%s", toupper(substr($i,1,1)) tolower(substr($i,2))
}1')
```

### Results

| Variable | Value | Used For |
|----------|-------|----------|
| `MODULE_NAME_LOWER` | `user_profile` | File names, paths |
| `MODULE_NAME_PASCAL` | `UserProfile` | Class names |
| `MODULE_NAME_CAMEL` | `userProfile` | Provider names, variables |

---

## 🧪 Test Naming

Test script naming conversion:

```bash
# Test PascalCase
echo "user_profile" | awk -F_ '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' OFS=""
# Output: UserProfile

# Test camelCase
echo "user_profile" | awk -F_ '{printf "%s", tolower($1); for(i=2;i<=NF;i++) printf "%s", toupper(substr($i,1,1)) tolower(substr($i,2))}1'
# Output: userProfile
```

---

## 📚 Related

- `scripts/README.md` - Script usage guide
- `scripts/create_module.sh` - Module generator script
- `README.md` - Project overview

---

**Happy Naming! 🎉**

