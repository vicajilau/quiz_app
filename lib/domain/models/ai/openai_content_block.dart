import 'dart:convert';

import 'package:quiz_app/domain/models/ai/ai_file_attachment.dart';

/// Represents a block of content in an OpenAI chat message.
///
/// Content blocks can be text, image URLs, or file references.
sealed class OpenAIContentBlock {
  /// Converts the content block to a JSON map for the OpenAI API.
  Map<String, dynamic> toJson();

  /// Helper method to create a list of content blocks from a text prompt and an [AiFileAttachment].
  ///
  /// This automatically determines whether the file should be handled as an image
  /// or a generic file block.
  static List<OpenAIContentBlock> fromPromptAndFile(
    String prompt,
    AiFileAttachment file,
  ) {
    final base64Data = base64Encode(file.bytes);
    final dataUri = 'data:${file.mimeType};base64,$base64Data';

    return [
      OpenAITextBlock(prompt),
      if (file.isImage)
        OpenAIImageUrlBlock(dataUri)
      else
        OpenAIFileBlock(fileName: file.name, fileData: dataUri),
    ];
  }
}

/// A content block containing plain text.
class OpenAITextBlock extends OpenAIContentBlock {
  /// The text content of the block.
  final String text;

  /// Creates an [OpenAITextBlock] with the specified [text].
  OpenAITextBlock(this.text);

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'text': text};
}

/// A content block containing a reference to an image URL (often a data URI).
class OpenAIImageUrlBlock extends OpenAIContentBlock {
  /// The URL or data URI of the image.
  final String url;

  /// Creates an [OpenAIImageUrlBlock] with the specified [url].
  OpenAIImageUrlBlock(this.url);

  @override
  Map<String, dynamic> toJson() => {
    'type': 'image_url',
    'image_url': {'url': url},
  };
}

/// A content block containing file data for processing.
class OpenAIFileBlock extends OpenAIContentBlock {
  /// The name of the file.
  final String fileName;

  /// The encoded file data (usually a data URI).
  final String fileData;

  /// Creates an [OpenAIFileBlock] with the specified [fileName] and [fileData].
  OpenAIFileBlock({required this.fileName, required this.fileData});

  @override
  Map<String, dynamic> toJson() => {
    'type': 'file',
    'file': {'filename': fileName, 'file_data': fileData},
  };
}
