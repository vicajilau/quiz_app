import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/context_extension.dart';
import 'package:platform_detail/platform_detail.dart';

import '../../core/constants/maso_metadata.dart';
import '../../core/file_handler.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/service_locator.dart';
import '../../domain/models/custom_exceptions/bad_maso_file_exception.dart';
import '../../domain/models/settings_maso.dart';
import '../../routes/app_router.dart';
import '../blocs/file_bloc/file_bloc.dart';
import '../blocs/file_bloc/file_event.dart';
import '../blocs/file_bloc/file_state.dart';
import '../widgets/dialogs/create_maso_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false; // Variable to track loading state

  Future<void> _showCreateMasoFileDialog(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const CreateMasoFileDialog(),
    );

    if (result != null &&
        result['name'] != null &&
        result['description'] != null &&
        context.mounted) {
      context.read<FileBloc>().add(
        CreateMasoMetadata(
          name: result['name']!,
          version: MasoMetadata.version,
          description: result['description']!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FileBloc>(
      create: (_) => ServiceLocator.instance.getIt<FileBloc>(),
      child: BlocListener<FileBloc, FileState>(
        listener: (context, state) async {
          if (state is FileLoaded) {
            context.presentSnackBar(
              AppLocalizations.of(context)!.fileLoaded(
                state.masoFile.filePath ??
                    "${state.masoFile.metadata.name}${MasoMetadata.format}",
              ),
            );
            final settings = await SettingsMaso.loadFromPreferences(
              state.masoFile.processes.mode,
            );
            ServiceLocator.instance.registerSettings(settings);
            if (!context.mounted) return;
            final _ = await context.push(AppRoutes.fileLoadedScreen);
            if (!context.mounted) return;
            context.read<FileBloc>().add(MasoFileReset());
          }
          if (state is FileError && context.mounted) {
            if (state.error is BadMasoFileException) {
              final badFileException = state.error as BadMasoFileException;
              context.presentSnackBar(badFileException.description(context));
            } else {
              context.presentSnackBar(state.getDescription(context));
            }
          }
          if (state is FileLoading) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        },
        child: Builder(
          builder: (context) {
            checkDeepLink(context);
            return Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.titleAppBar),
                actions: [
                  // Disable the create and load button if a file is loading
                  Tooltip(
                    message: AppLocalizations.of(context)!.createFileTooltip,
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => _showCreateMasoFileDialog(context),
                      child: Text(
                        AppLocalizations.of(context)!.create,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Tooltip(
                    message: AppLocalizations.of(context)!.loadFileTooltip,
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => context.read<FileBloc>().add(
                              MasoFilePickRequested(),
                            ),
                      child: Text(
                        AppLocalizations.of(context)!.load,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              body: PlatformDetail.isMobile
                  ? Center(child: Image.asset('MASO.png', fit: BoxFit.contain))
                  : DropTarget(
                      onDragDone: (details) {
                        if (context.read<FileBloc>().state is! FileLoaded) {
                          context.read<FileBloc>().add(
                            FileDropped(details.files.first.path),
                          );
                        }
                      },
                      child: Center(
                        child: DragTarget<String>(
                          builder: (context, candidateData, rejectedData) {
                            return Container(
                              padding: const EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.dropFileHere,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  /// Check if there is a deep link and handle it
  void checkDeepLink(BuildContext c) {
    FileHandler.initialize((filePath) {
      c.read<FileBloc>().add(FileDropped(filePath));
    });
  }
}
