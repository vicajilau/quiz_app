// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:quizdy/core/constants/quiz_metadata.dart';
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/core/extensions/string_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/core/theme/extensions/home_theme.dart';
import 'package:quizdy/domain/repositories/quiz_file_repository.dart';
import 'package:quizdy/data/services/ai/ai_question_generation_service.dart';
import 'package:quizdy/data/services/app_remote_config_service.dart';
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/domain/models/ai/ai_generation_config.dart';
import 'package:quizdy/domain/models/ai/ai_study_generation_config.dart';
import 'package:quizdy/domain/models/ai/ai_difficulty_level.dart';
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/domain/models/custom_exceptions/bad_quiz_file_exception.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/domain/models/quiz/study.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_content.dart';
import 'package:quizdy/domain/models/recent_quiz/recent_quiz.dart';
import 'package:quizdy/domain/use_cases/initialize_quiz_chunks_use_case.dart';
import 'package:quizdy/domain/use_cases/check_file_changes_use_case.dart';
import 'package:quizdy/presentation/blocs/app_update_cubit/app_update_cubit.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_event.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_state.dart';
import 'package:quizdy/presentation/blocs/recent_quizzes/recent_quizzes_cubit.dart';
import 'package:quizdy/presentation/blocs/recent_quizzes/recent_quizzes_state.dart';
import 'package:quizdy/presentation/screens/dialogs/ai_generate_questions_dialog.dart';
import 'package:quizdy/presentation/screens/dialogs/ai_generate_study_dialog.dart';
import 'package:quizdy/presentation/screens/dialogs/custom_confirm_dialog.dart';
import 'package:quizdy/presentation/screens/dialogs/force_update_dialog.dart';
import 'package:quizdy/presentation/screens/dialogs/mode_selection_dialog.dart';
import 'package:quizdy/presentation/screens/dialogs/quiz_metadata_dialog.dart';
import 'package:quizdy/presentation/screens/dialogs/settings_dialog.dart';
import 'package:quizdy/presentation/screens/widgets/home/home_drag_mode_overlay.dart';
import 'package:quizdy/presentation/screens/widgets/home/home_sidebar.dart';
import 'package:quizdy/presentation/screens/widgets/home/home_tabs/home_inicio_tab_view.dart';
import 'package:quizdy/presentation/screens/widgets/home/home_tabs/home_recent_selector_view.dart';
import 'package:quizdy/presentation/screens/widgets/home/home_tabs/home_no_active_file_view.dart';
import 'package:quizdy/presentation/screens/quiz_loaded_screen.dart';
import 'package:quizdy/presentation/screens/srs/srs_stats_screen.dart';
import 'package:quizdy/presentation/screens/study_screen.dart';
import 'package:quizdy/presentation/utils/dialog_drop_guard.dart';
import 'package:quizdy/presentation/widgets/app_update_banner.dart';
import 'package:quizdy/presentation/widgets/quizdy_loading.dart';
import 'package:quizdy/presentation/widgets/smart_app_banner.dart';
import 'package:quizdy/routes/app_router.dart';

class HomeScreen extends StatefulWidget {
  final String? initialDataUrl;
  final int initialTabIndex;
  final Map<String, dynamic>? studyExtra;
  final VoidCallback? onExit;

  const HomeScreen({
    super.key,
    this.initialDataUrl,
    this.initialTabIndex = 0,
    this.studyExtra,
    this.onExit,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDragging = false;
  bool _isLoading = false;
  bool _showFeedbackBanner = AppRemoteConfig.defaults().homeFeedbackEnabled;
  String? _feedbackFormUrl = AppRemoteConfig.defaults().homeFeedbackUrl;
  QuizMode? _hoveredDropMode;
  QuizMode? _pendingDropMode;
  bool _isAutomaticLoad = false;
  bool _isAutoLoading = false;

  bool _isSidebarCollapsed = false;
  late int _selectedTabIndex;

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      setState(() {
        _selectedTabIndex = widget.initialTabIndex;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    _loadRemoteConfig();

    if (kIsWeb) {
      String? dataUrl = widget.initialDataUrl;
      if (dataUrl == null || dataUrl.isEmpty) {
        dataUrl = Uri.base.queryParameters['data'];
      }

      if (dataUrl != null && dataUrl.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.read<FileBloc>().add(FileDropped(dataUrl!));
          }
        });
      }
    }
  }

  Future<void> _loadRemoteConfig() async {
    final remoteConfig = await ServiceLocator.getIt<AppRemoteConfigService>()
        .getConfig();
    if (!mounted) return;

    setState(() {
      _showFeedbackBanner = remoteConfig.homeFeedbackEnabled;
      _feedbackFormUrl = remoteConfig.homeFeedbackUrl;
    });
  }

  @protected
  void openUpdateStoreUrl() {
    final Uri url;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        url = Uri.parse('https://apps.apple.com/app/quiz-appl/id6758663432');
        break;
      case TargetPlatform.android:
        url = Uri.parse(
          'https://play.google.com/store/apps/details?id=es.victorcarreras.quiz_app',
        );
        break;
      case TargetPlatform.windows:
        url = Uri.parse('https://apps.microsoft.com/store/detail/9P77H0WRJSM2');
        break;
      case TargetPlatform.linux:
        url = Uri.parse('https://snapcraft.io/quiz-app');
        break;
      default:
        url = Uri.parse('https://github.com/vicajilau/quizdy/releases');
    }
    launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @protected
  void navigateByMode(BuildContext context, QuizMode mode, QuizFile quizFile) {
    if (mode == QuizMode.study) {
      setState(() {
        _selectedTabIndex = 1;
      });
    } else {
      setState(() {
        _selectedTabIndex = 2;
      });
    }
  }

  QuizMode _modeFromPosition(Offset localPosition, Size size) {
    if (context.isMobile) {
      return localPosition.dy < size.height / 2
          ? QuizMode.study
          : QuizMode.quiz;
    }
    return localPosition.dx < size.width / 2 ? QuizMode.study : QuizMode.quiz;
  }

  void _pickFile(BuildContext context) {
    if (_isLoading) return;
    if (_selectedTabIndex == 0) {
      _isAutomaticLoad = true;
    }
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

  Future<void> _openFeedbackForm(BuildContext context) async {
    final urlRaw = _feedbackFormUrl;
    if (urlRaw == null || urlRaw.trim().isEmpty) {
      context.presentSnackBar(AppLocalizations.of(context)!.featureComingSoon);
      return;
    }

    final url = Uri.tryParse(urlRaw.trim());
    if (url == null) {
      context.presentSnackBar(AppLocalizations.of(context)!.featureComingSoon);
      return;
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      context.presentSnackBar(
        AppLocalizations.of(context)!.couldNotOpenUrl(url.toString()),
      );
    }
  }

  Future<void> _generateQuestionsWithAI(BuildContext context) async {
    try {
      final isAiAvailable = ServiceLocator.getIt<ConfigurationService>()
          .getIsAiAvailable();

      if (!isAiAvailable) {
        if (context.mounted) {
          context.presentSnackBar(
            AppLocalizations.of(context)!.aiApiKeyRequired,
          );
        }
        return;
      }

      if (!context.mounted) return;
      final config = await showDialog<AiQuestionGenerationConfig>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AiGenerateQuestionsDialog(),
      );

      if (config == null || !context.mounted) return;

      setState(() => _isLoading = true);

      try {
        final aiService = ServiceLocator.getIt<AiQuestionGenerationService>();
        if (!context.mounted) return;
        final localizations = AppLocalizations.of(context)!;
        final generatedQuestions = await aiService.generateQuestions(
          config,
          localizations: localizations,
        );

        if (generatedQuestions.isEmpty) {
          setState(() => _isLoading = false);
          if (context.mounted) {
            context.presentSnackBar(
              AppLocalizations.of(context)!.aiGenerationFailed,
            );
          }
          return;
        }

        final metadata = await aiService.generateQuizMetadata(
          config,
          localizations: localizations,
        );

        if (context.mounted) {
          final unknownValue = AppLocalizations.of(
            context,
          )!.questionTypeUnknown;
          final title = metadata['title'] ?? unknownValue;
          final description = metadata['description'] ?? unknownValue;
          setState(() => _pendingDropMode = QuizMode.quiz);
          context.read<FileBloc>().add(
            CreateQuizWithQuestions(
              name: title,
              version: QuizMetadataConstants.version,
              description: description,
              author: unknownValue,
              questions: generatedQuestions,
              generationMode: config.generationMode,
              originalText: config.content,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          setState(() => _isLoading = false);
          await showDialog(
            context: context,
            builder: (context) => CustomConfirmDialog(
              title: AppLocalizations.of(context)!.aiGenerationErrorTitle,
              message: e.toString().cleanExceptionPrefix(),
              confirmText: AppLocalizations.of(context)!.acceptButton,
              showCloseButton: false,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        setState(() => _isLoading = false);
        context.presentSnackBar('Error: ${e.toString()}');
      }
    }
  }

  Future<void> _startStudyModeWithAI(BuildContext context) async {
    try {
      final isAiAvailable = ServiceLocator.getIt<ConfigurationService>()
          .getIsAiAvailable();

      if (!isAiAvailable) {
        if (context.mounted) {
          context.presentSnackBar(
            AppLocalizations.of(context)!.aiApiKeyRequired,
          );
        }
        return;
      }

      if (!context.mounted) return;
      final config = await showDialog<AiStudyGenerationConfig>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AiGenerateStudyDialog(),
      );

      if (config == null || !context.mounted) return;

      setState(() => _isLoading = true);

      try {
        if (!context.mounted) return;
        final localizations = AppLocalizations.of(context)!;

        String documentTitle = localizations.studyModeLabel;
        String? documentSummary;
        final documentId = 'study_${DateTime.now().millisecondsSinceEpoch}';

        final initializeUseCase =
            ServiceLocator.getIt<InitializeQuizChunksUseCase>();
        QuizFile? updatedQuizFile;
        List<StudyChunk> initialChunks = [];
        String? fileUri;

        if (config.hasFile) {
          final tempQuizFile = await ServiceLocator.getIt<QuizFileRepository>()
              .createQuizFile(
                title: documentTitle,
                description: documentSummary ?? '',
                version: '1.0.0',
                author: '',
              );

          updatedQuizFile = await initializeUseCase.execute(
            quizFile: tempQuizFile,
            file: config.file!,
            documentId: documentId,
            localizations: localizations,
            generationMode: config.generationMode,
            originalText: config.content,
            language: config.language,
            isAutoDifficulty: config.isAutoDifficulty,
            difficultyLevel: config.difficultyLevel,
          );

          initialChunks = updatedQuizFile.study?.content.cache ?? [];
          fileUri = updatedQuizFile.fileUri;
          documentTitle = updatedQuizFile.metadata.title;
          documentSummary = updatedQuizFile.metadata.description;
        } else {
          final result = await initializeUseCase.generateChunksFromText(
            content: config.content,
            generationMode: config.generationMode,
            documentId: documentId,
            localizations: localizations,
            language: config.language,
          );

          initialChunks = result['chunks'] as List<StudyChunk>;
          documentTitle = result['title'] ?? documentTitle;
          documentSummary = result['description'] ?? documentSummary;

          final tempQuizFile = await ServiceLocator.getIt<QuizFileRepository>()
              .createQuizFile(
                title: documentTitle,
                description: documentSummary ?? '',
                version: '1.0.0',
                author: '',
              );

          updatedQuizFile = tempQuizFile.copyWith(
            study: Study(
              content: StudyContent(
                progressPercentage: 0.0,
                totalChunks: initialChunks.length,
                processedChunks: 0,
                cache: initialChunks,
              ),
              generationMode: config.generationMode,
              originalText: config.content,
              language: config.language,
              isAutoDifficulty: config.isAutoDifficulty,
              difficultyLevel: config.difficultyLevel,
            ),
          );
        }

        if (context.mounted) {
          setState(() => _isLoading = false);
          _isAutomaticLoad = true;
          context.read<FileBloc>().add(LoadQuizFileFromData(updatedQuizFile));

          context.push(
            AppRoutes.studyScreen,
            extra: {
              'initialChunks': initialChunks,
              'fileAttachment': config.file,
              'fileUri': fileUri,
              'documentTitle': documentTitle,
              'documentSummary': documentSummary,
              'isAutoDifficulty': config.isAutoDifficulty,
              'difficultyLevel': config.difficultyLevel,
              'generationMode': config.generationMode,
              'originalText': config.content,
              'language': config.language,
            },
          );
        }
      } catch (e) {
        if (context.mounted) {
          setState(() => _isLoading = false);
          await showDialog(
            context: context,
            builder: (context) => CustomConfirmDialog(
              title: AppLocalizations.of(context)!.aiGenerationErrorTitle,
              message: e.toString().cleanExceptionPrefix(),
              confirmText: AppLocalizations.of(context)!.acceptButton,
              showCloseButton: false,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        setState(() => _isLoading = false);
        context.presentSnackBar('Error: ${e.toString()}');
      }
    }
  }

  void _handleRecentQuizTap(BuildContext context, RecentQuiz recent) {
    if (_selectedTabIndex == 0) {
      _isAutomaticLoad = true;
    }
    context.read<FileBloc>().add(LoadQuizFileFromData(recent.quizFile));
  }

  void _navigateTab(BuildContext context, int tabIndex) {
    if (tabIndex == 4) {
      // Settings
      _showSettingsDialog(context);
      return;
    }
    setState(() {
      _selectedTabIndex = tabIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeTheme = context.homeTheme;

    return BlocProvider<AppUpdateCubit>(
      create: (context) => ServiceLocator.getIt<AppUpdateCubit>(),
      child: BlocListener<AppUpdateCubit, AppUpdateState>(
        listener: (context, updateState) async {
          if (updateState is AppUpdateForceRequired && context.mounted) {
            await showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (_) =>
                  ForceUpdateDialog(onUpdatePressed: openUpdateStoreUrl),
            );
          }
        },
        child: BlocListener<FileBloc, FileState>(
          listener: (context, state) async {
            if (state is FileLoaded) {
              setState(() => _isLoading = false);
              // Refresh recent list in Cubit
              context.read<RecentQuizzesCubit>().loadRecentQuizzes();

              if (context.currentRoute != AppRoutes.home) return;
              final quizFile = state.quizFile;

              final dropMode = _pendingDropMode;
              _pendingDropMode = null;

              if (_isAutomaticLoad) {
                _isAutomaticLoad = false;
                return;
              }

              final QuizMode? choice;
              if (_selectedTabIndex == 1) {
                choice = QuizMode.study;
              } else if (_selectedTabIndex == 2) {
                choice = QuizMode.quiz;
              } else {
                choice = dropMode ?? await ModeSelectionDialog.show(context);
              }
              if (!context.mounted || choice == null) return;
              navigateByMode(context, choice, quizFile);
            }
            if (state is FileSaved) {
              setState(() => _isLoading = false);
              context.read<RecentQuizzesCubit>().loadRecentQuizzes();
            }
            if (state is FileReplacementRequest) {
              if (context.currentRoute == AppRoutes.home) {
                final newFile = state.newFile;
                final id =
                    newFile.filePath ??
                    'unsaved_${newFile.metadata.title.hashCode}';
                final recentsState = context.read<RecentQuizzesCubit>().state;
                RecentQuiz? existingRecent;
                if (recentsState is RecentQuizzesLoaded) {
                  final normalizedId = id.replaceAll('\\', '/').toLowerCase();
                  for (final q in recentsState.recentQuizzes) {
                    final normalizedQId = q.id
                        .replaceAll('\\', '/')
                        .toLowerCase();
                    if (normalizedQId == normalizedId) {
                      existingRecent = q;
                      break;
                    }
                  }
                }

                if (existingRecent != null) {
                  final isSame = existingRecent.quizFile == newFile;
                  final fileBloc = context.read<FileBloc>();
                  final localizations = AppLocalizations.of(context)!;
                  if (isSame) {
                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => CustomConfirmDialog(
                          title: localizations.documentAlreadyImportedTitle,
                          message: localizations.documentAlreadyImportedMessage(
                            newFile.metadata.title,
                          ),
                          confirmText: localizations.okButton,
                          showCloseButton: false,
                        ),
                      ).then((_) {
                        if (mounted) {
                          fileBloc.add(ConfirmFileReplacement());
                        }
                      });
                    }
                  } else {
                    if (mounted) {
                      showDialog<bool>(
                        context: context,
                        builder: (context) => CustomConfirmDialog(
                          title: localizations.updateDocumentTitle,
                          message: localizations.updateDocumentMessage(
                            newFile.metadata.title,
                          ),
                          confirmText: localizations.updateButton,
                        ),
                      ).then((confirmed) {
                        if (mounted) {
                          if (confirmed == true) {
                            fileBloc.add(ConfirmFileReplacement());
                          } else {
                            fileBloc.add(CancelFileReplacement());
                          }
                        }
                      });
                    }
                  }
                } else {
                  context.read<FileBloc>().add(ConfirmFileReplacement());
                }
              }
            }
            if (state is FileError && context.mounted) {
              setState(() {
                _isLoading = false;
                _isAutoLoading = false;
                _isAutomaticLoad = false;
              });
              if (state.error is BadQuizFileException) {
                final badFileException = state.error as BadQuizFileException;
                context.presentSnackBar(badFileException.toString());
              } else {
                context.presentSnackBar(state.getDescription(context));
              }
            }
            if (state is FileLoading) {
              setState(() => _isLoading = true);
            } else if (state is FileInitial) {
              setState(() => _isLoading = false);
            }
          },
          child: SmartAppBanner(
            child: BlocBuilder<AppUpdateCubit, AppUpdateState>(
              builder: (context, updateState) {
                final isDarkMode =
                    Theme.of(context).brightness == Brightness.dark;
                final scaffold = AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: isDarkMode
                        ? Brightness.light
                        : Brightness.dark,
                    statusBarBrightness: isDarkMode
                        ? Brightness.dark
                        : Brightness.light,
                    systemNavigationBarColor: homeTheme.mainBackgroundColor,
                    systemNavigationBarIconBrightness: isDarkMode
                        ? Brightness.light
                        : Brightness.dark,
                  ),
                  child: Scaffold(
                    backgroundColor: homeTheme.mainBackgroundColor,
                    bottomNavigationBar: context.isMobile
                        ? BottomNavigationBar(
                            backgroundColor: homeTheme.sidebarBackgroundColor,
                            selectedItemColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            unselectedItemColor: homeTheme.textSecondaryColor,
                            showUnselectedLabels: true,
                            type: BottomNavigationBarType.fixed,
                            currentIndex: _selectedTabIndex,
                            onTap: (index) => _navigateTab(context, index),
                            items: [
                              BottomNavigationBarItem(
                                icon: const Icon(LucideIcons.house),
                                label: AppLocalizations.of(
                                  context,
                                )!.homeMenuInicio,
                              ),
                              BottomNavigationBarItem(
                                icon: const Icon(LucideIcons.book_open),
                                label: AppLocalizations.of(
                                  context,
                                )!.homeMenuStudy,
                              ),
                              BottomNavigationBarItem(
                                icon: const Icon(
                                  LucideIcons.file_question_mark,
                                ),
                                label: AppLocalizations.of(
                                  context,
                                )!.homeMenuQuiz,
                              ),
                              BottomNavigationBarItem(
                                icon: const Icon(LucideIcons.chart_column),
                                label: AppLocalizations.of(
                                  context,
                                )!.homeMenuEstadisticas,
                              ),
                            ],
                          )
                        : null,
                    body: DropTarget(
                      onDragDone: (details) {
                        if (ServiceLocator.getIt<DialogDropGuard>().isActive) {
                          setState(() {
                            _isDragging = false;
                            _hoveredDropMode = null;
                          });
                          return;
                        }
                        if (_selectedTabIndex != 0) {
                          setState(() {
                            _isDragging = false;
                            _hoveredDropMode = null;
                          });
                          return;
                        }
                        if (details.files.isNotEmpty && !_isLoading) {
                          if (context.currentRoute != AppRoutes.home) return;

                          final firstFile = details.files.first;
                          if (firstFile.path.isNotEmpty) {
                            if (!firstFile.name.toLowerCase().endsWith(
                              '.quiz',
                            )) {
                              context.presentSnackBar(
                                AppLocalizations.of(context)!.errorInvalidFile,
                              );
                              setState(() {
                                _isDragging = false;
                                _hoveredDropMode = null;
                              });
                              return;
                            }
                            _isAutomaticLoad = true;
                            context.read<FileBloc>().add(QuizFileReset());
                            context.read<FileBloc>().add(
                              FileDropped(firstFile.path),
                            );
                          }
                        }
                        setState(() {
                          _isDragging = false;
                          _hoveredDropMode = null;
                        });
                      },
                      onDragEntered: (_) {
                        if (_selectedTabIndex == 0 &&
                            !ServiceLocator.getIt<DialogDropGuard>().isActive) {
                          setState(() => _isDragging = true);
                        }
                      },
                      onDragUpdated: (details) {
                        if (!_isDragging || _selectedTabIndex != 0) return;
                        final renderBox =
                            context.findRenderObject() as RenderBox;
                        final mode = _modeFromPosition(
                          details.localPosition,
                          renderBox.size,
                        );
                        if (mode != _hoveredDropMode) {
                          setState(() => _hoveredDropMode = mode);
                        }
                      },
                      onDragExited: (_) => setState(() {
                        _isDragging = false;
                        _hoveredDropMode = null;
                      }),
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              if (!context.isMobile)
                                HomeSidebar(
                                  isCollapsed: _isSidebarCollapsed,
                                  onToggleCollapse: () {
                                    setState(() {
                                      _isSidebarCollapsed =
                                          !_isSidebarCollapsed;
                                    });
                                  },
                                  onTabSelected: (index) =>
                                      _navigateTab(context, index),
                                  selectedIndex: _selectedTabIndex,
                                ),
                              Expanded(
                                child: BlocBuilder<FileBloc, FileState>(
                                  builder: (context, fileState) {
                                    return IndexedStack(
                                      index: _selectedTabIndex,
                                      children: [
                                        _buildTabContent(context, 0, fileState),
                                        _buildTabContent(context, 1, fileState),
                                        _buildTabContent(context, 2, fileState),
                                        _buildTabContent(context, 3, fileState),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (_isDragging)
                            Positioned.fill(
                              child: HomeDragModeOverlay(
                                hoveredMode: _hoveredDropMode,
                                isImportMode: _selectedTabIndex == 0,
                              ),
                            ),
                          if (_isLoading)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.3),
                                child: const Center(child: QuizdyLoading()),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );

                if (updateState is AppUpdateAvailable) {
                  return AppUpdateBanner(
                    newVersion: updateState.newVersion,
                    onUpdatePressed: openUpdateStoreUrl,
                    child: scaffold,
                  );
                }
                return scaffold;
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    int tabIndex,
    FileState fileState,
  ) {
    QuizFile? activeQuizFile;
    if (fileState is FileLoaded) {
      activeQuizFile = fileState.quizFile;
    } else if (fileState is FileSaved) {
      activeQuizFile = fileState.quizFile;
    } else if (fileState is FileReplacementRequest) {
      activeQuizFile = fileState.currentFile;
    }
    final hasActiveFile = activeQuizFile != null;

    switch (tabIndex) {
      case 0:
        return HomeInicioTabView(
          showFeedbackBanner: _showFeedbackBanner,
          onOpenFeedbackForm: () => _openFeedbackForm(context),
          onStartStudyModeWithAI: () => _startStudyModeWithAI(context),
          onGenerateQuestionsWithAI: () => _generateQuestionsWithAI(context),
          onCreateQuizFile: () => _showCreateQuizFileDialog(context),
          onLoadFile: () => _pickFile(context),
          onTapRecent: (recent) => _handleRecentQuizTap(context, recent),
          onShowSettings: () => _showSettingsDialog(context),
          activeQuiz: activeQuizFile,
        );
      case 1:
        if (hasActiveFile) {
          final file = activeQuizFile;
          final study = file.study;
          final chunks = study?.content.cache ?? [];

          final initialChunks = chunks.isNotEmpty
              ? chunks
              : (widget.studyExtra?['initialChunks'] as List<StudyChunk>? ??
                    const []);
          final fileAttachment =
              widget.studyExtra?['fileAttachment'] as AiFileAttachment? ??
              file.fileAttachment;
          final documentTitle =
              widget.studyExtra?['documentTitle'] as String? ??
              file.metadata.title;
          final documentSummary =
              widget.studyExtra?['documentSummary'] as String? ??
              file.metadata.description;
          final hideStartQuizButton =
              widget.studyExtra?['hideStartQuizButton'] as bool? ?? false;
          final isAutoDifficulty =
              widget.studyExtra?['isAutoDifficulty'] as bool? ??
              study?.isAutoDifficulty ??
              true;
          final difficultyLevel =
              widget.studyExtra?['difficultyLevel'] as AiDifficultyLevel? ??
              study?.difficultyLevel;
          final generationMode =
              widget.studyExtra?['generationMode'] as AiGenerationMode? ??
              study?.generationMode;
          final originalText =
              widget.studyExtra?['originalText'] as String? ??
              study?.originalText;
          final language =
              widget.studyExtra?['language'] as String? ?? study?.language;

          final studyScreenKeyStr =
              'study_${file.filePath ?? file.metadata.title}';
          return StudyScreen(
            key: ValueKey(studyScreenKeyStr),
            initialChunks: initialChunks,
            fileAttachment: fileAttachment,
            documentTitle: documentTitle,
            documentSummary: documentSummary,
            quizFile: file,
            hideStartQuizButton: hideStartQuizButton,
            isAutoDifficulty: isAutoDifficulty,
            difficultyLevel: difficultyLevel,
            generationMode: generationMode,
            originalText: originalText,
            language: language,
            showLeading: false,
            isActiveTab: _selectedTabIndex == 1,
            onExit:
                widget.onExit ??
                () {
                  setState(() {
                    _selectedTabIndex = 0;
                  });
                },
          );
        } else {
          return _buildNoActiveFileTab(context, activeQuizFile);
        }
      case 2:
        if (hasActiveFile) {
          final file = activeQuizFile;
          return QuizLoadedScreen(
            key: ValueKey('quiz_${file.filePath ?? file.metadata.title}'),
            fileBloc: context.read<FileBloc>(),
            checkFileChangesUseCase:
                ServiceLocator.getIt<CheckFileChangesUseCase>(),
            quizFile: file,
            resetOnDispose: false,
            isActiveTab: _selectedTabIndex == 2,
            onExit:
                widget.onExit ??
                () {
                  setState(() {
                    _selectedTabIndex = 0;
                  });
                },
          );
        } else {
          return _buildNoActiveFileTab(context, activeQuizFile);
        }
      case 3:
        return const SrsStatsScreen(
          key: ValueKey('stats'),
          showBackButton: false,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNoActiveFileTab(BuildContext context, QuizFile? activeQuiz) {
    return BlocBuilder<RecentQuizzesCubit, RecentQuizzesState>(
      builder: (context, recentState) {
        if (recentState is RecentQuizzesLoading ||
            recentState is RecentQuizzesInitial) {
          return const Center(child: QuizdyLoading());
        } else if (recentState is RecentQuizzesLoaded) {
          final list = recentState.recentQuizzes;
          if (list.length == 1) {
            final recent = list.first;
            if (!_isAutoLoading) {
              _isAutoLoading = true;
              _isAutomaticLoad = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _handleRecentQuizTap(context, recent);
                }
              });
            }
            return const Center(child: QuizdyLoading());
          } else if (list.length > 1) {
            return HomeRecentSelectorView(
              items: list,
              onTapRecent: (recent) => _handleRecentQuizTap(context, recent),
              onLoadFile: () => _pickFile(context),
              onCreateFile: () => _showCreateQuizFileDialog(context),
              activeQuiz: activeQuiz,
            );
          }
        }
        return HomeNoActiveFileView(
          onLoadFile: () => _pickFile(context),
          onCreateFile: () => _showCreateQuizFileDialog(context),
        );
      },
    );
  }
}
