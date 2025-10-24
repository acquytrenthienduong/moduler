#!/bin/bash

# Script để tạo module mới cho Flutter project
# Usage: ./scripts/create_module.sh module_name

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check arguments
if [ -z "$1" ]; then
    echo -e "${RED}❌ Error: Module name is required${NC}"
    echo -e "${YELLOW}Usage: ./scripts/create_module.sh module_name${NC}"
    echo -e "${YELLOW}Example: ./scripts/create_module.sh order${NC}"
    exit 1
fi

MODULE_NAME=$1
MODULE_NAME_LOWER=$(echo "$MODULE_NAME" | tr '[:upper:]' '[:lower:]')

# Convert to PascalCase properly (e.g., user_profile -> UserProfile, map -> Map)
MODULE_NAME_PASCAL=$(echo "$MODULE_NAME_LOWER" | awk -F_ '{
  result = ""
  for(i=1; i<=NF; i++) {
    result = result toupper(substr($i,1,1)) tolower(substr($i,2))
  }
  print result
}')

# Convert to camelCase for provider names (e.g., user_profile -> userProfile, map -> map)
MODULE_NAME_CAMEL=$(echo "$MODULE_NAME_LOWER" | awk -F_ '{
  result = tolower($1)
  for(i=2; i<=NF; i++) {
    result = result toupper(substr($i,1,1)) tolower(substr($i,2))
  }
  print result
}')

echo -e "${BLUE}🚀 Creating module: ${MODULE_NAME_LOWER}${NC}"

# Paths
BASE_PATH="lib/features/${MODULE_NAME_LOWER}"
DATA_PATH="${BASE_PATH}/data"
PRESENTATION_PATH="${BASE_PATH}/presentation"

# Create directories
echo -e "${YELLOW}📁 Creating directories...${NC}"
mkdir -p "${DATA_PATH}/models"
mkdir -p "${DATA_PATH}/repositories"
mkdir -p "${PRESENTATION_PATH}/providers"
mkdir -p "${PRESENTATION_PATH}/pages"
mkdir -p "${PRESENTATION_PATH}/widgets"

# 1. Create Model (Freezed)
echo -e "${YELLOW}📝 Creating model...${NC}"
cat > "${DATA_PATH}/models/${MODULE_NAME_LOWER}.dart" << EOF
import 'package:freezed_annotation/freezed_annotation.dart';

part '${MODULE_NAME_LOWER}.freezed.dart';
part '${MODULE_NAME_LOWER}.g.dart';

@freezed
abstract class ${MODULE_NAME_PASCAL} with _\$${MODULE_NAME_PASCAL} {
  const factory ${MODULE_NAME_PASCAL}({
    required String id,
    required String name,
    String? description,
    @Default(true) bool isActive,
  }) = _${MODULE_NAME_PASCAL};

  factory ${MODULE_NAME_PASCAL}.fromJson(Map<String, Object?> json) =>
      _\$${MODULE_NAME_PASCAL}FromJson(json);
}
EOF

# 2. Create Repository
echo -e "${YELLOW}📝 Creating repository...${NC}"
cat > "${DATA_PATH}/repositories/${MODULE_NAME_LOWER}_repository.dart" << EOF
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../models/${MODULE_NAME_LOWER}.dart';

@singleton
class ${MODULE_NAME_PASCAL}Repository {
  final ApiClient _client;

  ${MODULE_NAME_PASCAL}Repository(this._client);

  /// Get all ${MODULE_NAME_LOWER}s
  Future<List<${MODULE_NAME_PASCAL}>> getAll() async {
    try {
      final response = await _client.get('/${MODULE_NAME_LOWER}s');
      return (response['data'] as List)
          .map((e) => ${MODULE_NAME_PASCAL}.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch ${MODULE_NAME_LOWER}s: \$e');
    }
  }

  /// Get ${MODULE_NAME_LOWER} by id
  Future<${MODULE_NAME_PASCAL}> getById(String id) async {
    try {
      final response = await _client.get('/${MODULE_NAME_LOWER}s/\$id');
      return ${MODULE_NAME_PASCAL}.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch ${MODULE_NAME_LOWER}: \$e');
    }
  }

  /// Create new ${MODULE_NAME_LOWER}
  Future<${MODULE_NAME_PASCAL}> create(${MODULE_NAME_PASCAL} ${MODULE_NAME_LOWER}) async {
    try {
      final response = await _client.post(
        '/${MODULE_NAME_LOWER}s',
        ${MODULE_NAME_LOWER}.toJson(),
      );
      return ${MODULE_NAME_PASCAL}.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create ${MODULE_NAME_LOWER}: \$e');
    }
  }

  /// Update ${MODULE_NAME_LOWER}
  Future<${MODULE_NAME_PASCAL}> update(String id, ${MODULE_NAME_PASCAL} ${MODULE_NAME_LOWER}) async {
    try {
      final response = await _client.put(
        '/${MODULE_NAME_LOWER}s/\$id',
        ${MODULE_NAME_LOWER}.toJson(),
      );
      return ${MODULE_NAME_PASCAL}.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update ${MODULE_NAME_LOWER}: \$e');
    }
  }

  /// Delete ${MODULE_NAME_LOWER}
  Future<void> delete(String id) async {
    try {
      await _client.delete('/${MODULE_NAME_LOWER}s/\$id');
    } catch (e) {
      throw Exception('Failed to delete ${MODULE_NAME_LOWER}: \$e');
    }
  }
}
EOF

# 3. Create Provider (Riverpod Generator)
echo -e "${YELLOW}📝 Creating provider...${NC}"
cat > "${PRESENTATION_PATH}/providers/${MODULE_NAME_LOWER}_provider.dart" << EOF
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:get_it/get_it.dart';
import '../../data/models/${MODULE_NAME_LOWER}.dart';
import '../../data/repositories/${MODULE_NAME_LOWER}_repository.dart';

part '${MODULE_NAME_LOWER}_provider.g.dart';

/// Repository provider
@riverpod
${MODULE_NAME_PASCAL}Repository ${MODULE_NAME_CAMEL}Repository(Ref ref) {
  return GetIt.instance<${MODULE_NAME_PASCAL}Repository>();
}

/// ${MODULE_NAME_PASCAL} List Provider
@riverpod
class ${MODULE_NAME_PASCAL}List extends _\$${MODULE_NAME_PASCAL}List {
  @override
  Future<List<${MODULE_NAME_PASCAL}>> build() async {
    return await _fetch${MODULE_NAME_PASCAL}s();
  }

  /// Refresh list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch${MODULE_NAME_PASCAL}s);
  }

  /// Add new ${MODULE_NAME_LOWER}
  Future<void> add(${MODULE_NAME_PASCAL} ${MODULE_NAME_LOWER}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(${MODULE_NAME_CAMEL}RepositoryProvider);
      await repo.create(${MODULE_NAME_LOWER});
      return await _fetch${MODULE_NAME_PASCAL}s();
    });
  }

  /// Delete ${MODULE_NAME_LOWER}
  Future<void> delete(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(${MODULE_NAME_CAMEL}RepositoryProvider);
      await repo.delete(id);
      return await _fetch${MODULE_NAME_PASCAL}s();
    });
  }

  Future<List<${MODULE_NAME_PASCAL}>> _fetch${MODULE_NAME_PASCAL}s() async {
    final repo = ref.read(${MODULE_NAME_CAMEL}RepositoryProvider);
    return await repo.getAll();
  }
}

/// ${MODULE_NAME_PASCAL} Detail Provider (with id parameter)
@riverpod
Future<${MODULE_NAME_PASCAL}> ${MODULE_NAME_CAMEL}Detail(
  Ref ref,
  String id,
) async {
  final repo = ref.watch(${MODULE_NAME_CAMEL}RepositoryProvider);
  return await repo.getById(id);
}
EOF

# 4. Create List Page
echo -e "${YELLOW}📝 Creating list page...${NC}"
cat > "${PRESENTATION_PATH}/pages/${MODULE_NAME_LOWER}_list_page.dart" << EOF
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/${MODULE_NAME_LOWER}_provider.dart';

class ${MODULE_NAME_PASCAL}ListPage extends ConsumerWidget {
  const ${MODULE_NAME_PASCAL}ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ${MODULE_NAME_LOWER}sAsync = ref.watch(${MODULE_NAME_CAMEL}ListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('${MODULE_NAME_PASCAL}s'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(${MODULE_NAME_CAMEL}ListProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: ${MODULE_NAME_LOWER}sAsync.when(
        data: (${MODULE_NAME_LOWER}s) {
          if (${MODULE_NAME_LOWER}s.isEmpty) {
            return const Center(
              child: Text('No ${MODULE_NAME_LOWER}s found'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(${MODULE_NAME_CAMEL}ListProvider.notifier).refresh();
            },
            child: ListView.builder(
              itemCount: ${MODULE_NAME_LOWER}s.length,
              itemBuilder: (context, index) {
                final ${MODULE_NAME_LOWER} = ${MODULE_NAME_LOWER}s[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(${MODULE_NAME_LOWER}.name[0].toUpperCase()),
                  ),
                  title: Text(${MODULE_NAME_LOWER}.name),
                  subtitle: Text(${MODULE_NAME_LOWER}.description ?? 'No description'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: Text('Delete \${${MODULE_NAME_LOWER}.name}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        await ref
                            .read(${MODULE_NAME_CAMEL}ListProvider.notifier)
                            .delete(${MODULE_NAME_LOWER}.id);
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Deleted successfully')),
                          );
                        }
                      }
                    },
                  ),
                  onTap: () {
                    // Navigate to detail page
                    // Navigator.push(context, ...);
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: \$error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(${MODULE_NAME_CAMEL}ListProvider.notifier).refresh();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create page
          // Navigator.push(context, ...);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
EOF

# 5. Create Barrel Export
echo -e "${YELLOW}📝 Creating barrel export...${NC}"
cat > "${BASE_PATH}/${MODULE_NAME_LOWER}.dart" << EOF
// Barrel export for ${MODULE_NAME_LOWER} module

// Models
export 'data/models/${MODULE_NAME_LOWER}.dart';

// Repositories
export 'data/repositories/${MODULE_NAME_LOWER}_repository.dart';

// Providers
export 'presentation/providers/${MODULE_NAME_LOWER}_provider.dart';

// Pages
export 'presentation/pages/${MODULE_NAME_LOWER}_list_page.dart';

// Widgets
// export 'presentation/widgets/${MODULE_NAME_LOWER}_card.dart';
EOF

# 6. Create README for the module
echo -e "${YELLOW}📝 Creating module README...${NC}"
cat > "${BASE_PATH}/README.md" << EOF
# ${MODULE_NAME_PASCAL} Module

## Structure

\`\`\`
${MODULE_NAME_LOWER}/
├── ${MODULE_NAME_LOWER}.dart              # Barrel export
├── data/
│   ├── models/
│   │   └── ${MODULE_NAME_LOWER}.dart      # Freezed model
│   └── repositories/
│       └── ${MODULE_NAME_LOWER}_repository.dart
└── presentation/
    ├── providers/
    │   └── ${MODULE_NAME_LOWER}_provider.dart
    ├── pages/
    │   └── ${MODULE_NAME_LOWER}_list_page.dart
    └── widgets/
        └── (custom widgets)
\`\`\`

## Usage

### Import
\`\`\`dart
import 'features/${MODULE_NAME_LOWER}/${MODULE_NAME_LOWER}.dart';
\`\`\`

### Provider
\`\`\`dart
// Watch list
final ${MODULE_NAME_LOWER}sAsync = ref.watch(${MODULE_NAME_CAMEL}ListProvider);

// Refresh
ref.read(${MODULE_NAME_CAMEL}ListProvider.notifier).refresh();

// Add
ref.read(${MODULE_NAME_CAMEL}ListProvider.notifier).add(new${MODULE_NAME_PASCAL});

// Delete
ref.read(${MODULE_NAME_CAMEL}ListProvider.notifier).delete(id);

// Get detail
final ${MODULE_NAME_LOWER} = ref.watch(${MODULE_NAME_CAMEL}DetailProvider(id));
\`\`\`

## Next Steps

1. Run code generation:
   \`\`\`bash
   fvm flutter pub run build_runner build --delete-conflicting-outputs
   \`\`\`

2. Update API endpoints in repository

3. Add to router (if needed):
   \`\`\`dart
   GoRoute(
     path: '/${MODULE_NAME_LOWER}s',
     builder: (context, state) => const ${MODULE_NAME_PASCAL}ListPage(),
   ),
   \`\`\`

4. Customize model fields

5. Add custom widgets in \`presentation/widgets/\`
EOF

echo -e "${GREEN}✅ Module created successfully!${NC}"
echo ""
echo -e "${BLUE}📂 Created files:${NC}"
echo "  - ${DATA_PATH}/models/${MODULE_NAME_LOWER}.dart"
echo "  - ${DATA_PATH}/repositories/${MODULE_NAME_LOWER}_repository.dart"
echo "  - ${PRESENTATION_PATH}/providers/${MODULE_NAME_LOWER}_provider.dart"
echo "  - ${PRESENTATION_PATH}/pages/${MODULE_NAME_LOWER}_list_page.dart"
echo "  - ${BASE_PATH}/${MODULE_NAME_LOWER}.dart (barrel export)"
echo "  - ${BASE_PATH}/README.md"
echo ""
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "  1. Run: fvm flutter pub run build_runner build --delete-conflicting-outputs"
echo "  2. Update API endpoints in ${MODULE_NAME_LOWER}_repository.dart"
echo "  3. Customize model fields in ${MODULE_NAME_LOWER}.dart"
echo "  4. Add route to app_router.dart (if needed)"
echo ""
echo -e "${GREEN}🎉 Happy coding!${NC}"

