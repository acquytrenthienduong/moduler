/// Core Package - Foundation layer
/// 
/// Contains:
/// - Network (API client, interceptors, exceptions)
/// - Theme (App theming)
/// - Router (Navigation helpers)
/// - Utils (Logger, validators, etc.)
/// - Constants (App-wide constants)

library core;

// Constants
export 'src/constants/app_constants.dart';

// Theme
export 'src/theme/app_theme.dart';

// Router helpers (base classes only, not actual routes)
export 'src/router/app_router.dart';

// Network
export 'src/network/api_client.dart';
export 'src/network/interceptors/interceptors.dart';

// Utils
export 'src/utils/logger.dart';


