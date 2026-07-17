final _digitRegex = RegExp(r'^[0-9]$');

/// Extensions on [String].
extension StringExtensions on String {
  /// Whether this string is a single ASCII digit (`0`-`9`). False for empty or
  /// multi-character strings.
  bool get isDigit => _digitRegex.hasMatch(this);
}
