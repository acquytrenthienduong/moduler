import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Base router helpers
/// Chỉ chứa helper classes, không chứa actual routes

/// Generic error page widget
/// App có thể customize bằng cách tạo ErrorPage riêng
class BaseErrorPage extends StatelessWidget {
  final String path;
  final String? message;
  final VoidCallback? onBackPressed;
  
  const BaseErrorPage({
    super.key,
    required this.path,
    this.message,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message ?? 'Trang không tồn tại',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Đường dẫn: $path',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            if (onBackPressed != null)
              ElevatedButton(
                onPressed: onBackPressed,
                child: const Text('Quay lại'),
              ),
          ],
        ),
      ),
    );
  }
}

