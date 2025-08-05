/// Extensions for String manipulation and formatting
extension StringExtensions on String {
  /// Removes the "Exception: " prefix from error messages
  ///
  /// Example:
  /// ```dart
  /// final error = "Exception: Something went wrong";
  /// print(error.cleanExceptionPrefix()); // "Something went wrong"
  /// ```
  String cleanExceptionPrefix() {
    if (startsWith('Exception: ')) {
      return substring('Exception: '.length);
    }
    return this;
  }

  /// Removes common exception prefixes from error messages
  ///
  /// Removes prefixes like "Exception: ", "Error: ", "FormatException: ", etc.
  ///
  /// Example:
  /// ```dart
  /// final error = "FormatException: Invalid format";
  /// print(error.cleanAllExceptionPrefixes()); // "Invalid format"
  /// ```
  String cleanAllExceptionPrefixes() {
    final prefixes = [
      'Exception: ',
      'Error: ',
      'FormatException: ',
      'StateError: ',
      'ArgumentError: ',
      'RangeError: ',
      'TypeError: ',
      'NoSuchMethodError: ',
      'UnsupportedError: ',
      'UnimplementedError: ',
      'ConcurrentModificationError: ',
      'OutOfMemoryError: ',
      'StackOverflowError: ',
    ];

    String result = this;
    for (final prefix in prefixes) {
      if (result.startsWith(prefix)) {
        result = result.substring(prefix.length);
        break;
      }
    }
    return result;
  }

  /// Comprehensive error message cleaning
  ///
  /// Removes exception prefixes and trims whitespace
  ///
  /// Example:
  /// ```dart
  /// final error = "  Exception: Something went wrong  ";
  /// print(error.cleanErrorMessage()); // "Something went wrong"
  /// ```
  String cleanErrorMessage() {
    return cleanAllExceptionPrefixes().trim();
  }
}
