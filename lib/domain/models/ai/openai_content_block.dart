import 'dart:convert';

import '../../../domain/models/ai/ai_file_attachment.dart';

sealed class OpenAIContentBlock {
  Map<String, dynamic> toJson();

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

class OpenAITextBlock extends OpenAIContentBlock {
  final String text;

  OpenAITextBlock(this.text);

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'text': text};
}

class OpenAIImageUrlBlock extends OpenAIContentBlock {
  final String url;

  OpenAIImageUrlBlock(this.url);

  @override
  Map<String, dynamic> toJson() => {
    'type': 'image_url',
    'image_url': {'url': url},
  };
}

class OpenAIFileBlock extends OpenAIContentBlock {
  final String fileName;
  final String fileData;

  OpenAIFileBlock({required this.fileName, required this.fileData});

  @override
  Map<String, dynamic> toJson() => {
    'type': 'file',
    'file': {'filename': fileName, 'file_data': fileData},
  };
}
