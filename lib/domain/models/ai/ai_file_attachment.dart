import 'dart:typed_data';

/// Represents a file attached to an AI request.
class AiFileAttachment {
  /// The raw byte content of the file.
  final Uint8List bytes;

  /// The MIME type of the file (e.g., 'image/png', 'application/pdf').
  final String mimeType;

  /// The original name of the file.
  final String name;

  /// Creates an [AiFileAttachment] with the given [bytes], [mimeType], and [name].
  const AiFileAttachment({
    required this.bytes,
    required this.mimeType,
    required this.name,
  });

  /// Whether the attached file is an image.
  bool get isImage => mimeType.startsWith('image/');
}
