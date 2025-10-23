import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../../features/auth/auth.dart';
import '../../features/home/home.dart';

class AppRouter {
  static const String login = '/login';
  static const String home = '/home';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    redirect: (context, state) async {
      final authRepo = GetIt.instance<AuthRepository>();
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
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Trang không tồn tại',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Đường dẫn: ${state.uri.path}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(login),
              child: const Text('Về trang đăng nhập'),
            ),
          ],
        ),
      ),
    ),
  );
}
