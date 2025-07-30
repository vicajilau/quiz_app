import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/context_extension.dart';
import 'package:quiz_app/core/service_locator.dart';
import 'package:quiz_app/domain/models/execution_setup.dart';
import 'package:quiz_app/routes/app_router.dart';
import 'package:platform_detail/platform_detail.dart';

import '../../core/constants/maso_metadata.dart';
import '../../core/l10n/app_localizations.dart';
import '../../domain/models/maso/i_process.dart';
import '../../domain/models/maso/maso_file.dart';
import '../../domain/models/maso/process_mode.dart';
import '../../domain/models/settings_maso.dart';
import '../../domain/use_cases/check_file_changes_use_case.dart';
import '../blocs/file_bloc/file_bloc.dart';
import '../blocs/file_bloc/file_event.dart';
import '../blocs/file_bloc/file_state.dart';
import '../widgets/dialogs/add_edit_process_dialog/add_edit_process_dialog.dart';
import '../widgets/dialogs/execution_setup_dialog.dart';
import '../widgets/dialogs/exit_confirmation_dialog.dart';
import '../widgets/dialogs/process_list_widget/process_list_widget.dart';
import '../widgets/dialogs/settings_dialog.dart';
import '../widgets/request_file_name_dialog.dart';

class FileLoadedScreen extends StatefulWidget {
  final FileBloc fileBloc;
  final CheckFileChangesUseCase checkFileChangesUseCase;
  final MasoFile masoFile;

  const FileLoadedScreen({
    super.key,
    required this.fileBloc,
    required this.checkFileChangesUseCase,
    required this.masoFile,
  });

  @override
  State<FileLoadedScreen> createState() => _FileLoadedScreenState();
}

class _FileLoadedScreenState extends State<FileLoadedScreen> {
  late MasoFile cachedMasoFile;
  bool _hasFileChanged = false; // Variable to track file change status

  // Function to check if the file has changed
  void _checkFileChange() {
    final hasChanged = widget.checkFileChangesUseCase.execute(cachedMasoFile);
    setState(() {
      _hasFileChanged = hasChanged;
    });
  }

  Future<bool> _confirmExit() async {
    if (widget.checkFileChangesUseCase.execute(cachedMasoFile)) {
      return await showDialog<bool>(
            context: context,
            builder: (context) => ExitConfirmationDialog(),
          ) ??
          false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    cachedMasoFile = widget.masoFile;
    _checkFileChange(); // Check the file change status when the screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _confirmExit();
        return shouldExit;
      },
      child: BlocProvider<FileBloc>(
        create: (_) => widget.fileBloc,
        child: BlocListener<FileBloc, FileState>(
          listener: (context, state) {
            if (state is FileLoaded) {
              context.presentSnackBar(
                AppLocalizations.of(
                  context,
                )!.fileSaved(state.masoFile.filePath!),
              );
              _checkFileChange();
            }
            if (state is FileError) {
              context.presentSnackBar(state.getDescription(context));
            }
          },
          child: Builder(
            builder: (context) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    "${cachedMasoFile.metadata.name} - ${cachedMasoFile.metadata.description}",
                  ),
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      semanticLabel: AppLocalizations.of(
                        context,
                      )!.backSemanticLabel,
                    ),
                    onPressed: () async {
                      final shouldExit = await _confirmExit();
                      if (shouldExit && context.mounted) {
                        context.pop();
                      }
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: 'Settings',
                      onPressed: () async {
                        final settings = await SettingsMaso.loadFromPreferences(
                          cachedMasoFile.processes.mode,
                        );
                        if (!context.mounted) return;
                        await showDialog<ProcessesMode>(
                          context: context,
                          builder: (context) => SettingsDialog(
                            settings: settings,
                            onSettingsChanged: (SettingsMaso modifiedSettings) {
                              modifiedSettings.saveToPreferences();
                              ServiceLocator.instance.registerSettings(
                                modifiedSettings,
                              );
                              if (modifiedSettings.processesMode !=
                                  cachedMasoFile.processes.mode) {
                                cachedMasoFile.processes.elements.clear();
                                cachedMasoFile.processes.mode =
                                    modifiedSettings.processesMode;
                                setState(() {
                                  _checkFileChange();
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                    IconButton(
                      onPressed: () async {
                        final createdProcess = await showDialog<IProcess>(
                          context: context,
                          builder: (context) =>
                              AddEditProcessDialog(masoFile: cachedMasoFile),
                        );
                        if (createdProcess != null) {
                          cachedMasoFile.processes.elements.add(createdProcess);
                          _checkFileChange();
                        }
                      },
                      icon: const Icon(Icons.add),
                      tooltip: AppLocalizations.of(context)!.addTooltip,
                    ),
                    // Save Action
                    IconButton(
                      icon: const Icon(Icons.save),
                      tooltip: _hasFileChanged
                          ? AppLocalizations.of(context)!.saveTooltip
                          : AppLocalizations.of(context)!.saveDisabledTooltip,
                      onPressed: _hasFileChanged
                          ? () async {
                              await _onSavePressed(context);
                            }
                          : null, // Disable button if file hasn't changed
                    ),
                  ],
                ),
                body: ProcessListWidget(
                  maso: cachedMasoFile,
                  onFileChange: _checkFileChange,
                ),
                floatingActionButton:
                    cachedMasoFile.processes.elements.isNotEmpty
                    ? FloatingActionButton(
                        tooltip: AppLocalizations.of(context)!.executeTooltip,
                        onPressed: () async {
                          final executionSetup =
                              await showDialog<ExecutionSetup>(
                                context: context,
                                builder: (context) => ExecutionSetupDialog(),
                              );
                          if (executionSetup != null) {
                            ServiceLocator.instance.registerExecutionSetup(
                              executionSetup,
                            );
                            executionSetup.settings =
                                await SettingsMaso.loadFromPreferences(
                                  cachedMasoFile.processes.mode,
                                );
                            if (context.mounted) {
                              context.push(AppRoutes.masoFileExecutionScreen);
                            }
                          }
                        },
                        child: const Icon(Icons.play_arrow),
                      )
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _onSavePressed(BuildContext context) async {
    final String? fileName;
    if (PlatformDetail.isWeb) {
      final result = await showDialog<String>(
        context: context,
        builder: (_) => RequestFileNameDialog(format: '.maso'),
      );
      fileName = result;
    } else {
      fileName = AppLocalizations.of(context)!.saveDialogTitle;
    }
    if (fileName != null && context.mounted) {
      context.read<FileBloc>().add(
        MasoFileSaveRequested(
          cachedMasoFile,
          fileName,
          MasoMetadata.masoFileName,
        ),
      );
    }
  }
}
