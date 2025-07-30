/// Enum representing the operational modes of a process.
enum ProcessesMode {
  /// Regular mode for standard operations.
  regular,

  /// Burst mode for high-intensity or accelerated operations.
  burst;

  /// Converts a string to a `ProcessesMode` enum.
  ///
  /// This method parses the input string and returns the corresponding
  /// `ProcessesMode` value. If the input does not match any defined mode,
  /// an `ArgumentError` is thrown.
  ///
  /// - [value]: A string representation of the mode.
  /// - Returns: The matching `ProcessesMode` value.
  /// - Throws: `ArgumentError` if the input string is invalid.
  static ProcessesMode fromJson(String value) {
    switch (value) {
      case 'regular':
        return ProcessesMode.regular;
      case 'burst':
        return ProcessesMode.burst;
    }
    throw ArgumentError("Invalid ProcessesMode value: $value");
  }

  @override
  String toString() {
    switch (this) {
      case ProcessesMode.regular:
        return 'regular';
      case ProcessesMode.burst:
        return 'burst';
    }
  }
}
