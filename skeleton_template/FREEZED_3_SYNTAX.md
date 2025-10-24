# 🔥 Freezed 3.x Syntax Guide

## ✅ Cú pháp ĐÚNG cho Freezed 3.x

### Model cơ bản
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'person.freezed.dart';
part 'person.g.dart';

@freezed
abstract class Person with _$Person {
  const factory Person({
    required String firstName,
    required String lastName,
    required int age,
  }) = _Person;

  factory Person.fromJson(Map<String, Object?> json) => 
      _$PersonFromJson(json);
}
```

## 📋 Key Points

### 1. **PHẢI dùng `abstract class`**
```dart
// ✅ ĐÚNG - Freezed 3.x
@freezed
abstract class Product with _$Product {
  const factory Product(...) = _Product;
}

// ❌ SAI - Cú pháp cũ (Freezed 2.x)
@freezed
class Product with _$Product {
  const factory Product(...) = _Product;
}
```

### 2. **Part directives**
```dart
// Luôn cần 2 part này
part 'model_name.freezed.dart';  // Freezed generation
part 'model_name.g.dart';        // JSON serialization
```

### 3. **Factory constructor**
```dart
const factory ModelName({
  required Type field1,
  Type? optionalField,
  @Default(value) Type fieldWithDefault,
}) = _ModelName;
```

### 4. **JSON serialization**
```dart
factory ModelName.fromJson(Map<String, Object?> json) => 
    _$ModelNameFromJson(json);
```

## 🎯 Examples

### Example 1: Product Model
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required String description,
    required double price,
    String? imageUrl,
    @Default(0) int stock,
    @Default(true) bool isAvailable,
  }) = _Product;

  factory Product.fromJson(Map<String, Object?> json) => 
      _$ProductFromJson(json);
}
```

### Example 2: User Model
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    String? avatar,
    @Default([]) List<String> roles,
  }) = _User;

  factory User.fromJson(Map<String, Object?> json) => 
      _$UserFromJson(json);
}
```

### Example 3: Nested Models
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
part 'order.g.dart';

@freezed
abstract class Order with _$Order {
  const factory Order({
    required String id,
    required User user,
    required List<Product> products,
    required double totalAmount,
    @Default(OrderStatus.pending) OrderStatus status,
  }) = _Order;

  factory Order.fromJson(Map<String, Object?> json) => 
      _$OrderFromJson(json);
}

enum OrderStatus {
  pending,
  processing,
  completed,
  cancelled,
}
```

### Example 4: Union Types (Multiple Constructors)
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

@freezed
abstract class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.error(String message) = Error<T>;
  const factory Result.loading() = Loading<T>;
}

// Usage:
// Result<User> result = Result.success(user);
// Result<User> result = Result.error('Failed to load');
// Result<User> result = Result.loading();
```

## 🔧 Common Annotations

### @Default
```dart
@Default(0) int count,
@Default('') String name,
@Default([]) List<String> items,
@Default(false) bool isActive,
```

### @JsonKey
```dart
@JsonKey(name: 'user_id') String userId,
@JsonKey(ignore: true) String? tempData,
@JsonKey(defaultValue: 0) int count,
```

### Custom JSON conversion
```dart
@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    @JsonKey(name: 'product_name') required String name,
    @JsonKey(fromJson: _priceFromJson, toJson: _priceToJson) 
    required double price,
  }) = _Product;

  factory Product.fromJson(Map<String, Object?> json) => 
      _$ProductFromJson(json);
}

double _priceFromJson(dynamic value) => (value as num).toDouble();
String _priceToJson(double value) => value.toStringAsFixed(2);
```

## 📝 Migration từ Freezed 2.x → 3.x

### Before (Freezed 2.x)
```dart
@freezed
class Product with _$Product {
  const factory Product(...) = _Product;
}
```

### After (Freezed 3.x)
```dart
@freezed
abstract class Product with _$Product {
  const factory Product(...) = _Product;
}
```

**Chỉ cần thêm `abstract` trước `class`!**

## 🚀 Generate Code

```bash
# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generate)
flutter pub run build_runner watch --delete-conflicting-outputs
```

## 💡 Pro Tips

### 1. Const constructor
```dart
// ✅ Sử dụng const để tối ưu performance
const user = User(id: '1', name: 'John');
```

### 2. CopyWith
```dart
final updatedUser = user.copyWith(name: 'Jane');
```

### 3. Equality
```dart
user1 == user2  // So sánh tất cả fields
```

### 4. ToString
```dart
print(user.toString());  // Auto-generated readable string
```

### 5. Custom methods
```dart
@freezed
abstract class User with _$User {
  const factory User({
    required String firstName,
    required String lastName,
  }) = _User;
  
  // Custom methods
  const User._();
  
  String get fullName => '$firstName $lastName';
  bool get hasLongName => fullName.length > 20;
}
```

## ⚠️ Common Mistakes

### ❌ Quên `abstract`
```dart
// SAI
@freezed
class Product with _$Product { }
```

### ❌ Thiếu part directives
```dart
// SAI - thiếu part directives
@freezed
abstract class Product with _$Product { }
```

### ❌ Sai tên file trong part
```dart
// SAI - tên file không khớp
part 'wrong_name.freezed.dart';
```

### ❌ Không có factory constructor
```dart
// SAI
@freezed
abstract class Product with _$Product {
  const Product({required String id});  // Không có 'factory'
}
```

## ✅ Complete Example

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required String description,
    required double price,
    String? imageUrl,
    @Default(0) int stock,
    @Default(true) bool isAvailable,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Product;

  factory Product.fromJson(Map<String, Object?> json) => 
      _$ProductFromJson(json);
}

// Usage:
void example() {
  // Create
  const product = Product(
    id: '1',
    name: 'iPhone',
    description: 'Apple iPhone',
    price: 999.99,
  );
  
  // CopyWith
  final updated = product.copyWith(price: 899.99);
  
  // JSON
  final json = product.toJson();
  final fromJson = Product.fromJson(json);
  
  // Equality
  print(product == updated);  // false
  
  // ToString
  print(product.toString());
}
```

## 📚 References

- [Freezed Documentation](https://pub.dev/packages/freezed)
- [Freezed 3.x Migration](https://pub.dev/packages/freezed#migration-guide)
- [JSON Serialization](https://pub.dev/packages/json_serializable)

**Remember: Luôn dùng `abstract class` trong Freezed 3.x!** 🔥
