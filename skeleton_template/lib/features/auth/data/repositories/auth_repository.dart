import 'package:shared_preferences/shared_preferences.dart';
import 'package:core/core.dart';
import '../models/user.dart';

// Note: Không dùng @singleton vì dependencies (ApiClient, SharedPreferences)
// đến từ core package. Sẽ được register manually trong injection.dart
class AuthRepository {
  // final ApiClient _apiClient; // Reserved for future API calls
  final SharedPreferences _prefs;

  AuthRepository(ApiClient apiClient, this._prefs);

  Future<User> login(String email, String password) async {
    try {
      // Mock login - thay bằng API thật
      await Future.delayed(const Duration(seconds: 1));
      
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email và password không được để trống');
      }
      
      final user = User(
        id: '1',
        email: email,
        name: 'Demo User',
        avatar: null,
      );
      
      // Lưu token vào local storage
      await _prefs.setString('auth_token', 'mock_token_123');
      await _prefs.setString('user_email', email);
      
      return user;
    } catch (e) {
      throw Exception('Đăng nhập thất bại: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _prefs.remove('auth_token');
      await _prefs.remove('user_email');
    } catch (e) {
      throw Exception('Đăng xuất thất bại: $e');
    }
  }
  
  Future<bool> isLoggedIn() async {
    final token = _prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }
  
  Future<User?> getCurrentUser() async {
    final email = _prefs.getString('user_email');
    if (email == null) return null;
    
    return User(
      id: '1',
      email: email,
      name: 'Demo User',
      avatar: null,
    );
  }
}
