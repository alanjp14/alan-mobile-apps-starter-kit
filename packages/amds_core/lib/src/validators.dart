// AMDS · reusable field validators. Return null when valid, an error string
// otherwise. Compose with [Validators.all]. Validation *timing* (blur vs submit)
// is a UI concern — see docs/screen-library/form-design-system.md.

typedef Validator = String? Function(String? value);

abstract final class Validators {
  static const _emailRe =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$";

  static Validator required([String message = 'This field is required.']) =>
      (v) => (v == null || v.trim().isEmpty) ? message : null;

  static Validator email([String message = 'Enter a valid email address.']) => (v) {
        if (v == null || v.isEmpty) return null; // let `required` own emptiness
        return RegExp(_emailRe).hasMatch(v.trim()) ? null : message;
      };

  static Validator minLength(int n, [String? message]) =>
      (v) => (v ?? '').length < n ? (message ?? 'Must be at least $n characters.') : null;

  static Validator maxLength(int n, [String? message]) =>
      (v) => (v ?? '').length > n ? (message ?? 'Must be at most $n characters.') : null;

  static Validator pattern(RegExp re, String message) =>
      (v) => (v == null || v.isEmpty || re.hasMatch(v)) ? null : message;

  static Validator match(String Function() other, [String message = "Doesn't match."]) =>
      (v) => v == other() ? null : message;

  static Validator numeric([String message = 'Enter a number.']) =>
      (v) => (v == null || v.isEmpty || num.tryParse(v.replaceAll(',', '')) != null) ? null : message;

  static Validator range(num min, num max, [String? message]) => (v) {
        final n = num.tryParse((v ?? '').replaceAll(',', ''));
        if (n == null) return null;
        return (n < min || n > max) ? (message ?? 'Enter a value between $min and $max.') : null;
      };

  /// Runs validators in order, returning the first error.
  static Validator all(List<Validator> validators) => (v) {
        for (final validate in validators) {
          final error = validate(v);
          if (error != null) return error;
        }
        return null;
      };
}

/// Password policy shared by Register / Reset / Change Password. `check` returns
/// a per-rule pass/fail map for a live checklist; `validate` returns the first
/// failing message for form submission.
class PasswordPolicy {
  const PasswordPolicy({this.minLength = 12});

  final int minLength;

  Map<String, bool> check(String value, {String? notName, String? notEmail}) => {
        'At least $minLength characters': value.length >= minLength,
        'An uppercase letter': value.contains(RegExp('[A-Z]')),
        'A lowercase letter': value.contains(RegExp('[a-z]')),
        'A number': value.contains(RegExp('[0-9]')),
        'A symbol': value.contains(RegExp(r'[^A-Za-z0-9]')),
        if (notName != null && notName.isNotEmpty)
          "Not your name": !value.toLowerCase().contains(notName.toLowerCase()),
        if (notEmail != null && notEmail.isNotEmpty)
          "Not your email": !value.toLowerCase().contains(notEmail.split('@').first.toLowerCase()),
      };

  String? validate(String? value, {String? notName, String? notEmail, String? current}) {
    if (value == null || value.isEmpty) return 'Enter a new password.';
    if (current != null && value == current) return 'Choose a password different from your current one.';
    final failing = check(value, notName: notName, notEmail: notEmail).entries.where((e) => !e.value).toList();
    return failing.isEmpty ? null : failing.first.key;
  }
}
