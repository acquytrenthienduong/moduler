import 'package:intl/intl.dart';

/// Common formatters cho app
class Formatters {
  Formatters._(); // Private constructor

  /// Format số tiền (VND)
  static String currency(num amount, {String symbol = '₫'}) {
    final formatter = NumberFormat('#,##0', 'vi_VN');
    return '${formatter.format(amount)}$symbol';
  }

  /// Format số với phân cách
  static String number(num value, {int decimalDigits = 0}) {
    final formatter = NumberFormat.decimalPattern('vi_VN');
    if (decimalDigits > 0) {
      return value.toStringAsFixed(decimalDigits);
    }
    return formatter.format(value);
  }

  /// Format phần trăm
  static String percent(num value, {int decimalDigits = 0}) {
    return '${value.toStringAsFixed(decimalDigits)}%';
  }

  /// Format date (dd/MM/yyyy)
  static String date(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format datetime (dd/MM/yyyy HH:mm)
  static String dateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Format time (HH:mm)
  static String time(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Format relative time (vừa xong, 5 phút trước, etc)
  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks tuần trước';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years năm trước';
    }
  }

  /// Format số điện thoại (0xxx xxx xxx)
  static String phoneNumber(String phone) {
    if (phone.length >= 10) {
      return '${phone.substring(0, 4)} ${phone.substring(4, 7)} ${phone.substring(7)}';
    }
    return phone;
  }

  /// Truncate text với ...
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Title case (Capitalize Each Word)
  static String titleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }
}

