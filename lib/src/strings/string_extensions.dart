final _digitRegex = RegExp(r'^[0-9]$');

extension StringExtensions on String {
  bool get isDigit => _digitRegex.hasMatch(this);
}
