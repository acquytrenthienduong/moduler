/// Common validators cho forms
class Validators {
  Validators._(); // Private constructor

  /// Email validator
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được để trống';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    
    return null;
  }

  /// Password validator
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    
    if (value.length < minLength) {
      return 'Mật khẩu phải có ít nhất $minLength ký tự';
    }
    
    return null;
  }

  /// Phone number validator (Vietnam format)
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Số điện thoại không được để trống';
    }
    
    final phoneRegex = RegExp(r'^(0|\+84)[0-9]{9}$');
    
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Số điện thoại không hợp lệ';
    }
    
    return null;
  }

  /// Required field validator
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? "Trường này"} không được để trống';
    }
    return null;
  }

  /// Min length validator
  static String? minLength(String? value, int min) {
    if (value == null || value.isEmpty) {
      return 'Không được để trống';
    }
    
    if (value.length < min) {
      return 'Phải có ít nhất $min ký tự';
    }
    
    return null;
  }

  /// Max length validator
  static String? maxLength(String? value, int max) {
    if (value == null) return null;
    
    if (value.length > max) {
      return 'Không được vượt quá $max ký tự';
    }
    
    return null;
  }

  /// Numeric validator
  static String? numeric(String? value) {
    if (value == null || value.isEmpty) {
      return 'Không được để trống';
    }
    
    if (double.tryParse(value) == null) {
      return 'Phải là số hợp lệ';
    }
    
    return null;
  }

  /// URL validator
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL không được để trống';
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'URL không hợp lệ';
    }
    
    return null;
  }

  /// Compose multiple validators
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}

