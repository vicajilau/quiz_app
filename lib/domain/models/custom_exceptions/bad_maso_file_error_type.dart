/// Enum representing different types of errors that can occur in a MASO file.
enum BadMasoFileErrorType {
  /// Indicates that the metadata content is invalid.
  metadataBadContent,

  /// Indicates that the process list has invalid content.
  processesBadContent,

  /// Indicates that the MASO file version is not supported.
  unsupportedVersion,

  /// Indicates that the extension file is not .maso.
  invalidExtension,
}