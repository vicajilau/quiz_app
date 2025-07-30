/// Provides metadata constants and version management for MASO files.
class MasoMetadata {
  /// The current supported MASO file version.
  static const String version = "1.0.0";

  /// The default name format for exported MASO files.
  static const String masoFileName = "output-file$format";

  /// The default name for exported execution timeline images.
  static const String exportImageFileName = "execution_timeline.png";

  /// The default name for exported execution timeline PDFs.
  static const String exportPdfFileName = "execution_timeline.pdf";

  /// The file extension for MASO files.
  static const String format = ".maso";

  /// Determines whether the given version `v1` is supported based on the current MASO version.
  ///
  /// Versions must follow the "X.Y.Z" format, where X, Y, and Z are integers.
  /// The comparison is made against `v2`, which represents the highest MASO file version
  /// that the current application can support.
  ///
  /// Returns `true` if `v1` is equal to or greater than `v2`, otherwise `false`.
  ///
  /// Example:
  /// ```dart
  /// MasoMetadata.isSupportedVersion("1.2.3"); // true (if MASO version is "1.2.0")
  /// MasoMetadata.isSupportedVersion("1.0.0"); // true (if MASO version is "1.0.0")
  /// MasoMetadata.isSupportedVersion("0.9.9"); // false (if MASO version is "1.0.0")
  /// ```
  static bool isSupportedVersion(String v1) {
    /// `v2` represents the highest MASO file version that the current application can support.
    const v2 = MasoMetadata.version;

    // Split the version strings into lists of integers
    List<int> v1Parts = v1.split('.').map(int.parse).toList();
    List<int> v2Parts = v2.split('.').map(int.parse).toList();

    // add 0s if they were omitted
    if (v1Parts.length < v2Parts.length) {
      return false;
    }

    // Compare each part (major, minor, patch)
    for (int i = 0; i < v2Parts.length; i++) {
      if (v1Parts[i] > v2Parts[i]) return false; // `v1` is newer
      if (v1Parts[i] < v2Parts[i]) return true; // `v1` is older
    }

    return true; // Versions are identical
  }
}
