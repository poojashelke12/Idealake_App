import 'package:intl/intl.dart';

/// Formatting Utility for Dates, Times, and Currency
class AppFormatter {
  AppFormatter._();

  static final DateFormat _defaultDateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final NumberFormat _inrCurrencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    return _defaultDateFormat.format(date);
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return _dateTimeFormat.format(dateTime);
  }

  static String formatTime(DateTime? time) {
    if (time == null) return '-';
    return _timeFormat.format(time);
  }

  static String formatCurrency(num? amount) {
    if (amount == null) return '₹0';
    return _inrCurrencyFormat.format(amount);
  }
}
