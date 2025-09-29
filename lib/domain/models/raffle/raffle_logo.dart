import 'dart:typed_data';

/// Represents the logo data with its type information
class RaffleLogo {
  /// The raw bytes of the logo
  final Uint8List data;

  /// The type of the logo (e.g., 'svg', 'png', 'jpg', 'gif')
  final String type;

  /// The original filename (optional)
  final String? filename;

  const RaffleLogo({required this.data, required this.type, this.filename});

  /// Creates a RaffleLogo from file bytes and filename
  factory RaffleLogo.fromFile(Uint8List data, String? filename) {
    String type = 'unknown';

    if (filename != null) {
      final extension = filename.toLowerCase().split('.').last;
      switch (extension) {
        case 'svg':
          type = 'svg';
          break;
        case 'png':
          type = 'png';
          break;
        case 'jpg':
        case 'jpeg':
          type = 'jpg';
          break;
        case 'gif':
          type = 'gif';
          break;
        case 'webp':
          type = 'webp';
          break;
        default:
          // Try to detect from data
          type = _detectTypeFromData(data);
      }
    } else {
      type = _detectTypeFromData(data);
    }

    return RaffleLogo(data: data, type: type, filename: filename);
  }

  /// Detects file type from data bytes
  static String _detectTypeFromData(Uint8List data) {
    if (data.length < 10) return 'unknown';

    // SVG detection - look for XML declaration or <svg tag
    final startString = String.fromCharCodes(data.take(100));
    if (startString.contains('<svg') || startString.contains('<?xml')) {
      return 'svg';
    }

    // PNG signature
    if (data.length >= 4 &&
        data[0] == 0x89 &&
        data[1] == 0x50 &&
        data[2] == 0x4E &&
        data[3] == 0x47) {
      return 'png';
    }

    // JPEG signature
    if (data.length >= 2 && data[0] == 0xFF && data[1] == 0xD8) {
      return 'jpg';
    }

    // GIF signature
    if (data.length >= 6) {
      final header = String.fromCharCodes(data.take(6));
      if (header == 'GIF87a' || header == 'GIF89a') {
        return 'gif';
      }
    }

    // WebP signature
    if (data.length >= 12 &&
        data[0] == 0x52 &&
        data[1] == 0x49 &&
        data[2] == 0x46 &&
        data[3] == 0x46 &&
        data[8] == 0x57 &&
        data[9] == 0x45 &&
        data[10] == 0x42 &&
        data[11] == 0x50) {
      return 'webp';
    }

    return 'unknown';
  }

  /// Check if the logo is an SVG
  bool get isSvg => type == 'svg';

  /// Check if the logo is a raster image (PNG, JPG, etc.)
  bool get isRaster => ['png', 'jpg', 'jpeg', 'gif', 'webp'].contains(type);

  /// Get SVG string content (only for SVG files)
  String? get svgString {
    if (!isSvg) return null;
    return String.fromCharCodes(data);
  }

  @override
  String toString() =>
      'RaffleLogo(type: $type, filename: $filename, size: ${data.length} bytes)';
}
