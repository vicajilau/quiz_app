import 'dart:typed_data';

import 'package:quiz_app/domain/models/export_formats.dart';

import '../../../domain/models/maso/maso_file.dart';

/// Abstract class representing the base event for file operations.
abstract class FileEvent {}

/// Event triggered when a file is dropped into the application.
class FileDropped extends FileEvent {
  final String filePath; // Path of the dropped file
  FileDropped(this.filePath);
}

/// Event triggered when a file save is requested, with the file path and data.
class MasoFileSaveRequested extends FileEvent {
  MasoFile masoFile; // The MasoFile object to be saved
  final String dialogTitle;
  final String fileName;
  MasoFileSaveRequested(this.masoFile, this.dialogTitle, this.fileName);
}

/// Event triggered when a exported file save is requested, with the file path and data.
class ExportedFileSaveRequested extends FileEvent {
  final Uint8List bytes; // The object to be saved
  final String dialogTitle;
  final String fileName;
  final ExportFormats fileFormat;
  ExportedFileSaveRequested(
    this.bytes,
    this.dialogTitle,
    this.fileName,
    this.fileFormat,
  );
}

/// Event triggered when a file is requested to be picked.
/// This event can be used to initiate the file selection process.
class MasoFilePickRequested extends FileEvent {}

/// Event triggered when a file is requested to be picked.
/// This event can be used to initiate the file selection process.
class CreateMasoMetadata extends FileEvent {
  final String name;
  final String version;
  final String description;
  CreateMasoMetadata({
    required this.name,
    required this.version,
    required this.description,
  });
}

/// Event triggered to reset the file state.
/// This event can be used to clear any file-related data or state.
class MasoFileReset extends FileEvent {}
