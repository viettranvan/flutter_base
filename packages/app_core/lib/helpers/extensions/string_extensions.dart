/// String utility extensions
extension StringX on String {
  /// Check if string is empty
  bool get isEmpty => this.isEmpty;

  /// Check if string is not empty
  bool get isNotEmpty => this.isNotEmpty;

  /// Check if string is whitespace only
  bool get isBlank => trim().isEmpty;

  /// Check if string is not whitespace only
  bool get isNotBlank => trim().isNotEmpty;

  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Check if valid email format
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Check if valid URL format
  bool get isValidUrl {
    try {
      final uri = Uri.parse(this);
      return uri.isAbsolute;
    } catch (e) {
      return false;
    }
  }

  /// Check if string contains only digits
  bool get isNumeric => RegExp(r'^[0-9]+$').hasMatch(this);

  /// Check if string contains only letters
  bool get isAlpha => RegExp(r'^[a-zA-Z]+$').hasMatch(this);

  /// Check if string contains letters and digits only
  bool get isAlphaNumeric => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);

  /// Remove all whitespace
  String removeWhitespace() => replaceAll(RegExp(r'\s+'), '');

  /// Limit string length with ellipsis
  String limitLength(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }

  /// Truncate decimal places for numeric string
  String truncateDecimals(int places) {
    if (!contains('.')) return this;
    final parts = split('.');
    return '${parts[0]}.${parts[1].substring(0, (places).clamp(0, parts[1].length))}';
  }
}
