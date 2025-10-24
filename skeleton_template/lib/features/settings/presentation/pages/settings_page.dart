import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/auth.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          
          // Account section
          Text(
            'TÀI KHOẢN',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Thông tin cá nhân',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mở thông tin cá nhân')),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Đổi mật khẩu',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mở đổi mật khẩu')),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.security_outlined,
            title: 'Bảo mật',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mở cài đặt bảo mật')),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Preferences section
          Text(
            'TÙY CHỈNH',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Thông báo',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
            ),
          ),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Chế độ tối',
            trailing: Switch(
              value: false,
              onChanged: (value) {},
            ),
          ),
          _SettingsTile(
            icon: Icons.language_outlined,
            title: 'Ngôn ngữ',
            subtitle: 'Tiếng Việt',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chọn ngôn ngữ')),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // About section
          Text(
            'KHÁC',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Trợ giúp',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mở trợ giúp')),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'Về ứng dụng',
            subtitle: 'Version 1.0.0',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thông tin ứng dụng')),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Logout button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () async {
                // Hiển thị dialog xác nhận
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Đăng xuất'),
                    content: const Text('Bạn có chắc muốn đăng xuất?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Đăng xuất'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: trailing ?? 
          (onTap != null 
            ? const Icon(Icons.chevron_right) 
            : null),
        onTap: onTap,
      ),
    );
  }
}
