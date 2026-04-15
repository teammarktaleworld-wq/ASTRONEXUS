import 'package:intl/intl.dart';

class Formatters {
  /// Format a number as currency (₹1,234.00)
  static String price(num value) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN', // Indian locale
      symbol: '₹', // Currency symbol
      decimalDigits: 2, // 2 decimal places
    );
    return formatter.format(value);
  }

  /// Format DateTime as readable string
  static String date(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
