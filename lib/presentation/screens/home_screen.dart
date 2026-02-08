import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quiz_app/core/context_extension.dart';
import 'package:quiz_app/domain/models/custom_exceptions/bad_quiz_file_exception.dart';

import 'package:quiz_app/core/file_handler.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/core/service_locator.dart';
import 'package:quiz_app/routes/app_router.dart';
import 'package:quiz_app/core/constants/quiz_metadata.dart';
import 'package:quiz_app/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quiz_app/presentation/blocs/file_bloc/file_event.dart';
import 'package:quiz_app/presentation/blocs/file_bloc/file_state.dart';
import 'package:quiz_app/presentation/screens/dialogs/quiz_metadata_dialog.dart';
import 'package:quiz_app/presentation/screens/dialogs/settings_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  bool _isDragging = false;

  void _pickFile(BuildContext context) {
    if (_isLoading) return;
    context.read<FileBloc>().add(QuizFilePickRequested());
  }

  Future<void> _showCreateQuizFileDialog(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const QuizMetadataDialog(),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      final name = result['name']?.trim() ?? '';
      final description = result['description']?.trim() ?? '';
      const version = QuizMetadataConstants.version;
      final author = result['author']?.trim() ?? '';

      if (name.isNotEmpty && description.isNotEmpty && author.isNotEmpty) {
        context.read<FileBloc>().add(
          CreateQuizMetadata(
            name: name,
            version: version,
            description: description,
            author: author,
          ),
        );
      } else {
        context.presentSnackBar(
          AppLocalizations.of(context)!.requiredFieldsError,
        );
      }
    }
  }

  Future<void> _showSettingsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SettingsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FileBloc>(
      create: (_) => ServiceLocator.instance.getIt<FileBloc>(),
      child: BlocListener<FileBloc, FileState>(
        listener: (context, state) async {
          if (state is FileLoaded) {
            final _ = await context.push(AppRoutes.fileLoadedScreen);
            if (!context.mounted) return;
            context.read<FileBloc>().add(QuizFileReset());
          }
          if (state is FileError && context.mounted) {
            if (state.error is BadQuizFileException) {
              final badFileException = state.error as BadQuizFileException;
              context.presentSnackBar(badFileException.toString());
            } else {
              context.presentSnackBar(state.getDescription(context));
            }
          }
          if (state is FileLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }
        },
        child: Builder(
          builder: (context) {
            checkDeepLink(context);
            return Scaffold(
              body: DropTarget(
                onDragDone: (details) {
                  if (details.files.isNotEmpty && !_isLoading) {
                    if (context.currentRoute != AppRoutes.home) return;

                    final firstFile = details.files.first;
                    if (firstFile.path.isNotEmpty) {
                      if (!firstFile.name.toLowerCase().endsWith('.quiz')) {
                        context.presentSnackBar(
                          AppLocalizations.of(context)!.errorInvalidFile,
                        );
                        return;
                      }
                      context.read<FileBloc>().add(QuizFileReset());
                      context.read<FileBloc>().add(FileDropped(firstFile.path));
                    }
                  }
                  setState(() => _isDragging = false);
                },
                onDragEntered: (_) => setState(() => _isDragging = true),
                onDragExited: (_) => setState(() => _isDragging = false),
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      // Calculate the visual top margin:
                      // SafeArea (padding.top) + Header centering offset ((72 - 48) / 2 = 12)
                      final topPadding = MediaQuery.of(context).padding.top;
                      final visualTopMargin = topPadding + 12.0;

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? visualTopMargin : 48.0,
                        ),
                        child: Column(
                          children: [
                            _buildHeader(context),
                            Expanded(child: _buildDropZone(context)),
                            _buildFooter(context),
                          ],
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

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: IconButton(
              icon: const Icon(LucideIcons.settings),
              color: Theme.of(context).iconTheme.color,
              iconSize: 24,
              onPressed: _isLoading ? null : () => _showSettingsDialog(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropZone(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => _pickFile(context),
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 480,
                        maxHeight: 320,
                      ),
                      width: double.infinity,
                      height: 320,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: _isDragging
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).dividerColor,
                          width: 3,
                        ),
                        boxShadow: _isDragging
                            ? [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'images/QUIZ.png',
                            height: 180,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              Icon(
                                LucideIcons.upload,
                                size: 32,
                                color: Theme.of(context).hintColor,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppLocalizations.of(context)!.dropFileHere,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context).hintColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    AppLocalizations.of(context)!.clickOrDragFile,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 48, top: 32),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200, minWidth: 160),
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _showCreateQuizFileDialog(context),
                    icon: Icon(
                      LucideIcons.plus,
                      size: 22,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    label: Text(
                      AppLocalizations.of(context)!.create,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200, minWidth: 160),
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () {
                            context.read<FileBloc>().add(QuizFileReset());
                            context.read<FileBloc>().add(
                              QuizFilePickRequested(),
                            );
                          },
                    icon: const Icon(LucideIcons.folderOpen, size: 22),
                    label: Text(
                      AppLocalizations.of(context)!.load,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _isLoading ? null : () => context.go(AppRoutes.raffle),
            icon: Icon(
              LucideIcons.gift,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            label: Text(
              AppLocalizations.of(context)!.sorteosLabel,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void checkDeepLink(BuildContext c) {
    FileHandler.initialize((filePath) {
      c.read<FileBloc>().add(FileDropped(filePath));
    });
  }
}
