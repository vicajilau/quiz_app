import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../../core/l10n/app_localizations.dart';

class QuestionImageSection extends StatelessWidget {
  final String? imageData;
  final VoidCallback onImagePicked;
  final VoidCallback onImageRemoved;
  final Function(String) onImageChanged;

  const QuestionImageSection({
    super.key,
    required this.imageData,
    required this.onImagePicked,
    required this.onImageRemoved,
    required this.onImageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.imageLabel,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        if (imageData != null) ...[
          // Image preview
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                _getImageBytes(imageData!)!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localizations.imageLoadError,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(context),
                icon: const Icon(Icons.swap_horiz),
                label: Text(localizations.changeImage),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onImageRemoved,
                icon: const Icon(Icons.delete_outline),
                label: Text(localizations.removeImage),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ] else ...[
          // No image state
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: () => _pickImage(context),
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.addImageTap,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizations.imageFormats,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Pick an image file and convert to base64
  Future<void> _pickImage(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          // Get file extension to determine mime type
          String extension = file.extension?.toLowerCase() ?? 'png';
          String mimeType = 'image/$extension';
          if (extension == 'jpg') mimeType = 'image/jpeg';

          // Convert to base64
          String base64String = base64Encode(file.bytes!);
          String imageData = 'data:$mimeType;base64,$base64String';

          onImageChanged(imageData);
        }
      }
    } catch (e) {
      // Handle error - could show a snackbar or dialog
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.imagePickError(e.toString()),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Extract image data from base64 string for preview
  Uint8List? _getImageBytes(String imageData) {
    try {
      // Extract base64 data after the comma
      final base64Data = imageData.split(',').last;
      return base64Decode(base64Data);
    } catch (e) {
      return null;
    }
  }
}
