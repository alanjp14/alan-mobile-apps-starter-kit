// AMDS · locale- and timezone-aware formatting. See
// docs/starter-template/code-style-and-guidelines.md.

import 'package:intl/intl.dart';

/// Central formatters. Construct one per locale (usually app-wide) and inject it.
class AmdsFormatters {
  AmdsFormatters({this.locale = 'en', DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  final String locale;
  final DateTime Function() _now;

  // ── numbers ────────────────────────────────────────────────────────────────

  /// Abbreviates from 10,000: `12.4k`, `1.2M`. Locale-aware grouping below that.
  String compactNumber(num value) {
    if (value.abs() >= 10000) {
      return NumberFormat.compact(locale: locale).format(value);
    }
    return NumberFormat.decimalPattern(locale).format(value);
  }

  String number(num value, {int decimals = 0}) =>
      NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: decimals)
          .format(value);

  /// `value` is a ratio 0..1 unless [alreadyPercent].
  String percent(num value, {int decimals = 0, bool alreadyPercent = false}) {
    final v = alreadyPercent ? value / 100 : value;
    return NumberFormat.decimalPercentPattern(
      locale: locale,
      decimalDigits: decimals,
    ).format(v);
  }

  /// [minorUnits] is the amount in the currency's smallest unit (e.g. cents).
  String currency(
    int minorUnits, {
    required String currencyCode,
    int decimalDigits = 2,
  }) {
    final major = minorUnits / _pow10(decimalDigits);
    return NumberFormat.currency(
      locale: locale,
      name: currencyCode,
      decimalDigits: decimalDigits,
    ).format(major);
  }

  // ── dates ──────────────────────────────────────────────────────────────────

  String date(DateTime dt) => DateFormat.yMMMd(locale).format(dt.toLocal());
  String time(DateTime dt) => DateFormat.jm(locale).format(dt.toLocal());
  String dateTime(DateTime dt) => '${date(dt)} · ${time(dt)}';

  /// Relative for < 24h ("2m ago", "9:12 AM"), then "Yesterday", then absolute.
  /// Computes against [_now] (inject a fixed clock in tests).
  String relative(DateTime dt) {
    final now = _now();
    final local = dt.toLocal();
    final diff = now.difference(local);

    if (diff.inSeconds < 45) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 12) return '${diff.inHours}h ago';
    if (_isSameDay(now, local)) return time(local);
    if (_isYesterday(now, local)) return 'Yesterday';
    if (diff.inDays < 7) return DateFormat.EEEE(locale).format(local);
    if (now.year == local.year) return DateFormat.MMMd(locale).format(local);
    return date(local);
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  static bool _isYesterday(DateTime now, DateTime b) =>
      _isSameDay(now.subtract(const Duration(days: 1)), b);
  static int _pow10(int n) => n <= 0 ? 1 : 10 * _pow10(n - 1);
}
