import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import '../di/injection.dart';
import '../../features/auth/auth.dart';
import '../../features/home/home.dart';

class AppRouter {
  static const String login = '/login';
  static const String home = '/home';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    redirect: (context, state) async {
      final authRepo = getIt<AuthRepository>();
      final isLoggedIn = await authRepo.isLoggedIn();
      final isLoggingIn = state.matchedLocation == login;

      // Nếu chưa đăng nhập và không phải trang login -> redirect login
      if (!isLoggedIn && !isLoggingIn) {
        return login;
      }

      // Nếu đã đăng nhập và đang ở trang login -> redirect home
      if (isLoggedIn && isLoggingIn) {
        return home;
      }

      // Không redirect
      return null;
    },
    routes: [
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
    ],
    errorBuilder: (context, state) => BaseErrorPage(
      path: state.uri.path,
      onBackPressed: () => context.go(login),
    ),
  );
}

