import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _inrFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

  /// Formats price in standard Indian currency: e.g. ₹ 8,50,000
  static String formatCurrency(double amount) {
    return _inrFormatter.format(amount);
  }

  /// Formats price in convenient automotive Indian units: e.g. ₹8.50 Lakh, ₹1.25 Cr
  static String formatPriceLakh(double amount) {
    if (amount >= 10000000) {
      final cr = amount / 10000000;
      return '₹${cr.toStringAsFixed(cr.truncateToDouble() == cr ? 0 : 2)} Cr';
    } else if (amount >= 100000) {
      final lakh = amount / 100000;
      return '₹${lakh.toStringAsFixed(lakh.truncateToDouble() == lakh ? 0 : 2)} Lakh';
    } else {
      return _inrFormatter.format(amount);
    }
  }

  /// Formats km driven: e.g. 45,000 km
  static String formatKm(int km) {
    final formatter = NumberFormat('#,##,###');
    return '${formatter.format(km)} km';
  }

  /// Formats date: e.g. 15 Aug 2026
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Formats date and time: e.g. 15 Aug 2026, 04:30 PM
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }
}
