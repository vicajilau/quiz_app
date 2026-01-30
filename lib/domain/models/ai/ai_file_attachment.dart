import 'dart:typed_data';

class AiFileAttachment {
  final Uint8List bytes;
  final String mimeType;
  final String name;

  const AiFileAttachment({
    required this.bytes,
    required this.mimeType,
    required this.name,
  });

  bool get isImage => mimeType.startsWith('image/');
}
