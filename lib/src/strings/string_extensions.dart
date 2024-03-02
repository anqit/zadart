final digitRegex = RegExp(r'^[0-9]$');
extension StringExtensions on String {
  bool get isDigit => digitRegex.hasMatch(this);
}