# 🛠️ Scripts

## create_module.sh

Script để tự động generate module mới với đầy đủ structure.

### Usage

```bash
# Basic
./scripts/create_module.sh module_name

# Examples
./scripts/create_module.sh order
./scripts/create_module.sh user_profile
./scripts/create_module.sh payment
```

### What it creates

```
lib/features/module_name/
├── module_name.dart                    # Barrel export
├── README.md                           # Module documentation
├── data/
│   ├── models/
│   │   └── module_name.dart           # Freezed model
│   └── repositories/
│       └── module_name_repository.dart # Injectable repository
└── presentation/
    ├── providers/
    │   └── module_name_provider.dart   # Riverpod Generator
    ├── pages/
    │   └── module_name_list_page.dart  # List page with CRUD
    └── widgets/
        └── (empty - add custom widgets)
```

### Generated Files Include

1. **Model (Freezed 3.x)**
   - Standard fields: id, name, description, isActive
   - JSON serialization
   - Immutable

2. **Repository (Injectable)**
   - CRUD methods: getAll, getById, create, update, delete
   - Error handling
   - ApiClient injection

3. **Provider (Riverpod Generator 3.x)**
   - Repository provider
   - List provider (AsyncNotifier)
   - Detail provider (with id parameter)
   - Methods: refresh, add, delete

4. **List Page (ConsumerWidget)**
   - ListView with RefreshIndicator
   - Delete confirmation dialog
   - Error handling with retry
   - Loading states
   - Empty state
   - FAB for add action

5. **Barrel Export**
   - Export all public APIs
   - Clean imports

6. **Module README**
   - Structure overview
   - Usage examples
   - Next steps

### After Running Script

```bash
# 1. Generate code
fvm flutter pub run build_runner build --delete-conflicting-outputs

# 2. Update API endpoints
# Edit: lib/features/module_name/data/repositories/module_name_repository.dart

# 3. Customize model
# Edit: lib/features/module_name/data/models/module_name.dart

# 4. Add route (optional)
# Edit: lib/core/router/app_router.dart
```

### Example Output

```bash
$ ./scripts/create_module.sh order

🚀 Creating module: order
📁 Creating directories...
📝 Creating model...
📝 Creating repository...
📝 Creating provider...
📝 Creating list page...
📝 Creating barrel export...
📝 Creating module README...
✅ Module created successfully!

📂 Created files:
  - lib/features/order/data/models/order.dart
  - lib/features/order/data/repositories/order_repository.dart
  - lib/features/order/presentation/providers/order_provider.dart
  - lib/features/order/presentation/pages/order_list_page.dart
  - lib/features/order/order.dart (barrel export)
  - lib/features/order/README.md

📝 Next steps:
  1. Run: fvm flutter pub run build_runner build --delete-conflicting-outputs
  2. Update API endpoints in order_repository.dart
  3. Customize model fields in order.dart
  4. Add route to app_router.dart (if needed)

🎉 Happy coding!
```

### Features

- ✅ Tự động tạo toàn bộ structure
- ✅ Follow project conventions
- ✅ Freezed 3.x syntax
- ✅ Riverpod Generator 3.x
- ✅ Injectable ready
- ✅ CRUD operations
- ✅ Error handling
- ✅ Loading states
- ✅ Barrel exports
- ✅ Documentation

### Customization

Sau khi generate, bạn có thể customize:

1. **Model fields** - Thêm/xóa fields trong model
2. **Repository methods** - Thêm custom queries
3. **Provider logic** - Thêm filters, sorting, pagination
4. **UI** - Customize list page, thêm detail page, form page
5. **Widgets** - Tạo custom widgets trong `presentation/widgets/`

### Tips

- Module name nên là **singular** (order, not orders)
- Script tự động convert sang PascalCase cho class names
- Script tự động convert sang snake_case cho file names
- Luôn run build_runner sau khi generate

### Troubleshooting

**Script không chạy:**
```bash
chmod +x scripts/create_module.sh
```

**Build errors sau khi generate:**
```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

**Import errors:**
- Check barrel export đã đúng chưa
- Check provider name (auto-generated)

---

**Happy Module Creating! 🎉**

