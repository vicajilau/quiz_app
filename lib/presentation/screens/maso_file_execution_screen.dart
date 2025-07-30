import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/context_extension.dart';
import 'package:quiz_app/domain/models/export_formats.dart';
import 'package:quiz_app/presentation/widgets/regular_gantt_chart.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:platform_detail/platform_detail.dart';

import '../../core/constants/maso_metadata.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/service_locator.dart';
import '../../data/services/execution_time_calculator_service.dart';
import '../../domain/models/machine.dart';
import '../../domain/models/maso/maso_file.dart';
import '../blocs/file_bloc/file_bloc.dart';
import '../blocs/file_bloc/file_event.dart';
import '../blocs/file_bloc/file_state.dart';
import '../widgets/burst_gantt_chart.dart';
import '../widgets/request_file_name_dialog.dart';

class MasoFileExecutionScreen extends StatefulWidget {
  const MasoFileExecutionScreen({super.key});

  @override
  State<MasoFileExecutionScreen> createState() =>
      _MasoFileExecutionScreenState();
}

class _MasoFileExecutionScreenState extends State<MasoFileExecutionScreen> {
  late Machine _machine;
  final GlobalKey _repaintKey = GlobalKey(); // Key for capturing the content

  @override
  void initState() {
    super.initState();
    // Start the execution of the processes immediately
    executeProcesses();
  }

  void executeProcesses() {
    final executionTimeCalculator = ServiceLocator.instance
        .getIt<ExecutionTimeCalculatorService>();
    // Load the ExecutionSetup and the MasoFile from the ServiceLocator
    final masoFile = ServiceLocator.instance.getIt<MasoFile>();

    // Load _machine from the MASO file
    _machine = executionTimeCalculator.calculateExecutionTimes(
      masoFile.processes.elements,
    );

    setState(() {});
  }

  Future<Uint8List?> _captureImage() async {
    try {
      final boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      if (mounted) {
        context.presentSnackBar(
          AppLocalizations.of(context)!.failedToCaptureImage(e.toString()),
        );
      }
      return null;
    }
  }

  Future<void> _copyImageToClipboard() async {
    final buffer = await _captureImage();
    if (buffer != null) {
      await Pasteboard.writeImage(buffer);
      if (mounted) {
        context.presentSnackBar(
          AppLocalizations.of(context)!.imageCopiedToClipboard,
        );
      }
    }
  }

  Future<void> _exportAsImage(BuildContext con) async {
    final buffer = await _captureImage();
    if (buffer != null && mounted) {
      final String? fileName;
      if (PlatformDetail.isWeb) {
        final result = await showDialog<String>(
          context: context,
          builder: (_) =>
              RequestFileNameDialog(format: ExportFormats.image.getFormat()),
        );
        fileName = result;
      } else {
        fileName = AppLocalizations.of(context)!.saveDialogTitle;
      }
      if (fileName != null && con.mounted) {
        con.read<FileBloc>().add(
          ExportedFileSaveRequested(
            buffer,
            fileName,
            MasoMetadata.exportImageFileName,
            ExportFormats.image,
          ),
        );
      }
    }
  }

  Future<void> _exportAsPdf(BuildContext con) async {
    final bytes = await _captureImage();
    final buffer = await createPdfFromImage(bytes);
    if (buffer != null && mounted) {
      final String? fileName;
      if (PlatformDetail.isWeb) {
        final result = await showDialog<String>(
          context: context,
          builder: (_) =>
              RequestFileNameDialog(format: ExportFormats.pdf.getFormat()),
        );
        fileName = result;
      } else {
        fileName = AppLocalizations.of(context)!.saveDialogTitle;
      }
      if (fileName != null && con.mounted) {
        con.read<FileBloc>().add(
          ExportedFileSaveRequested(
            buffer,
            fileName,
            MasoMetadata.exportPdfFileName,
            ExportFormats.pdf,
          ),
        );
      }
    }
  }

  Future<Uint8List?> createPdfFromImage(Uint8List? bytes) async {
    if (bytes == null) return null;
    final pdf = pw.Document();
    final image = pw.MemoryImage(bytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(image));
        },
      ),
    );

    return await pdf.save();
  }

  void _showExportOptions(BuildContext con) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: Text(AppLocalizations.of(context)!.exportTimelineImage),
                onTap: () {
                  context.pop();
                  _exportAsImage(con);
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: Text(AppLocalizations.of(context)!.exportTimelinePdf),
                onTap: () {
                  context.pop();
                  _exportAsPdf(con);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FileBloc>(
      create: (_) => ServiceLocator.instance.getIt<FileBloc>(),
      child: BlocListener<FileBloc, FileState>(
        listener: (context, state) async {
          if (state is FileExported) {
            switch (state.fileFormat) {
              case ExportFormats.pdf:
                context.presentSnackBar(
                  AppLocalizations.of(context)!.pdfExported,
                );
              case ExportFormats.image:
                context.presentSnackBar(
                  AppLocalizations.of(context)!.imageExported,
                );
            }
          }
          if (state is FileError && context.mounted) {
            context.presentSnackBar(state.getDescription(context));
          }
        },
        child: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  AppLocalizations.of(context)!.executionTimelineTitle,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: AppLocalizations.of(context)!.clipboardTooltip,
                    onPressed: _copyImageToClipboard,
                  ),
                  IconButton(
                    icon: const Icon(Icons.file_download),
                    tooltip: AppLocalizations.of(context)!.exportTooltip,
                    onPressed: () => _showExportOptions(context),
                  ),
                ],
              ),
              body: RepaintBoundary(
                key: _repaintKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      (_machine.cpus.first.isRegularProcessInside())
                          ? RegularGanttChart(machine: _machine)
                          : BurstGanttChart(machine: _machine),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
