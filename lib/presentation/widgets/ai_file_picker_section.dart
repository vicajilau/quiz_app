import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import '../../core/l10n/app_localizations.dart';
import '../../domain/models/ai/ai_file_attachment.dart';

class AiFilePickerSection extends StatelessWidget {
  final AiFileAttachment? fileAttachment;
  final ValueChanged<AiFileAttachment?> onFileChanged;

  const AiFilePickerSection({
    super.key,
    required this.fileAttachment,
    required this.onFileChanged,
  });

  Future<void> _pickFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        if (pickedFile.bytes != null) {
          onFileChanged(
            AiFileAttachment(
              bytes: pickedFile.bytes!,
              mimeType:
                  lookupMimeType(pickedFile.path!) ??
                  'application/octet-stream',
              name: pickedFile.name,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.aiFilePickerError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.aiAttachFile,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (fileAttachment != null)
          InputChip(
            label: Text(fileAttachment!.name, overflow: TextOverflow.ellipsis),
            avatar: const Icon(Icons.attach_file, size: 18),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () => onFileChanged(null),
            deleteButtonTooltipMessage: localizations.aiRemoveFile,
          )
        else
          OutlinedButton.icon(
            onPressed: () => _pickFile(context),
            icon: const Icon(Icons.upload_file),
            label: Text(localizations.aiAttachFile),
          ),
      ],
    );
  }
}
