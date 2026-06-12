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
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:quizdy/core/constants/quiz_metadata.dart';
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/core/extensions/string_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/core/theme/extensions/home_theme.dart';
import 'package:quizdy/data/repositories/quiz_file_repository.dart';
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
import 'package:quizdy/presentation/screens/widgets/home/home_recent_card.dart';
import 'package:quizdy/presentation/screens/widgets/home/home_action_card.dart';
import 'package:quizdy/presentation/screens/widgets/home/home_feedback_card.dart';
import 'package:quizdy/presentation/screens/widgets/home/home_global_drag_hint.dart';
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

  bool _isSidebarCollapsed = false;
  bool _showAllRecents = false;
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
      final isAiAvailable = await ServiceLocator.getIt<ConfigurationService>()
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

        if (context.mounted) {
          final unknownValue = AppLocalizations.of(
            context,
          )!.questionTypeUnknown;
          setState(() => _pendingDropMode = QuizMode.quiz);
          context.read<FileBloc>().add(
            CreateQuizWithQuestions(
              name: unknownValue,
              version: QuizMetadataConstants.version,
              description: unknownValue,
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
      final isAiAvailable = await ServiceLocator.getIt<ConfigurationService>()
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
          ServiceLocator.registerQuizFile(updatedQuizFile);

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
      if (tabIndex == 0) {
        _showAllRecents = false;
      }
    });
  }

  String _formatLastOpened(BuildContext context, DateTime lastOpened) {
    final now = DateTime.now();
    final difference = now.difference(lastOpened);
    final localizations = AppLocalizations.of(context)!;

    if (difference.inDays == 0) {
      if (lastOpened.day == now.day) {
        return localizations.homeRecentToday;
      } else {
        return localizations.homeRecentYesterday;
      }
    } else if (difference.inDays == 1) {
      return localizations.homeRecentYesterday;
    } else if (difference.inDays < 7) {
      return localizations.homeRecentDaysAgo(difference.inDays.toString());
    } else {
      return '${lastOpened.day.toString().padLeft(2, '0')}/${lastOpened.month.toString().padLeft(2, '0')}/${lastOpened.year}';
    }
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
            if (state is FileReplacementRequest) {
              if (context.currentRoute == AppRoutes.home) {
                context.read<FileBloc>().add(ConfirmFileReplacement());
              }
            }
            if (state is FileError && context.mounted) {
              setState(() => _isLoading = false);
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
                                icon: const Icon(LucideIcons.home),
                                label: AppLocalizations.of(
                                  context,
                                )!.homeMenuInicio,
                              ),
                              BottomNavigationBarItem(
                                icon: const Icon(LucideIcons.bookOpen),
                                label: AppLocalizations.of(
                                  context,
                                )!.homeMenuStudy,
                              ),
                              BottomNavigationBarItem(
                                icon: const Icon(LucideIcons.fileQuestion),
                                label: AppLocalizations.of(
                                  context,
                                )!.homeMenuQuiz,
                              ),
                              BottomNavigationBarItem(
                                icon: const Icon(LucideIcons.barChart2),
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
                            final renderBox =
                                context.findRenderObject() as RenderBox;
                            _pendingDropMode = _modeFromPosition(
                              details.localPosition,
                              renderBox.size,
                            );
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
                        if (!ServiceLocator.getIt<DialogDropGuard>().isActive) {
                          setState(() => _isDragging = true);
                        }
                      },
                      onDragUpdated: (details) {
                        if (!_isDragging) return;
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
                              Expanded(child: _buildActiveTabContent(context)),
                            ],
                          ),
                          if (_isDragging)
                            Positioned.fill(
                              child: HomeDragModeOverlay(
                                hoveredMode: _hoveredDropMode,
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

  Widget _buildActiveTabContent(BuildContext context) {
    final hasActiveFile = ServiceLocator.getIt.isRegistered<QuizFile>();

    switch (_selectedTabIndex) {
      case 0:
        return Column(
          children: [
            _buildTopBar(context),
            Expanded(child: _buildMainContentArea(context)),
          ],
        );
      case 1:
        if (hasActiveFile) {
          final file = ServiceLocator.getIt<QuizFile>();
          final study = file.study;
          final chunks = study?.content.cache ?? [];

          final initialChunks =
              widget.studyExtra?['initialChunks'] as List<StudyChunk>? ??
              chunks;
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

          return StudyScreen(
            key: ValueKey('study_${file.filePath ?? file.metadata.title}'),
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
            onExit:
                widget.onExit ??
                () {
                  setState(() {
                    _selectedTabIndex = 0;
                  });
                },
          );
        } else {
          return _buildNoActiveFileTab(context);
        }
      case 2:
        if (hasActiveFile) {
          final file = ServiceLocator.getIt<QuizFile>();
          return QuizLoadedScreen(
            key: ValueKey('quiz_${file.filePath ?? file.metadata.title}'),
            fileBloc: context.read<FileBloc>(),
            checkFileChangesUseCase:
                ServiceLocator.getIt<CheckFileChangesUseCase>(),
            quizFile: file,
            resetOnDispose: false,
            onExit:
                widget.onExit ??
                () {
                  setState(() {
                    _selectedTabIndex = 0;
                  });
                },
          );
        } else {
          return _buildNoActiveFileTab(context);
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

  Widget _buildNoActiveFileTab(BuildContext context) {
    return BlocBuilder<RecentQuizzesCubit, RecentQuizzesState>(
      builder: (context, recentState) {
        if (recentState is RecentQuizzesLoading ||
            recentState is RecentQuizzesInitial) {
          return const Center(child: QuizdyLoading());
        } else if (recentState is RecentQuizzesLoaded) {
          final list = recentState.recentQuizzes;
          if (list.length == 1) {
            final recent = list.first;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _handleRecentQuizTap(context, recent);
              }
            });
            return const Center(child: QuizdyLoading());
          } else if (list.length > 1) {
            return _buildRecentSelectorState(context, list);
          }
        }
        return _buildNoActiveFileState(context);
      },
    );
  }

  Widget _buildRecentSelectorState(
    BuildContext context,
    List<RecentQuiz> items,
  ) {
    final homeTheme = context.homeTheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.fileClock,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.homeRecentSectionTitle,
                style: TextStyle(
                  color: homeTheme.textPrimaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.homeCardLoadFileDesc,
                style: TextStyle(
                  color: homeTheme.textSecondaryColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 96,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return HomeRecentCard(
                        title: item.title,
                        progress: item.progress,
                        lastOpenedText: _formatLastOpened(
                          context,
                          item.lastOpened,
                        ),
                        onTap: () => _handleRecentQuizTap(context, item),
                        onDelete: () {
                          context.read<RecentQuizzesCubit>().deleteRecentQuiz(
                            item.id,
                          );
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickFile(context),
                    icon: const Icon(LucideIcons.upload, size: 16),
                    label: Text(l10n.homeCardLoadFileTitle),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => _showCreateQuizFileDialog(context),
                    icon: const Icon(LucideIcons.plusCircle, size: 16),
                    label: Text(l10n.homeCardCreateQuizTitle),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoActiveFileState(BuildContext context) {
    final homeTheme = context.homeTheme;
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.fileWarning,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.homeNoActiveFileError,
                style: TextStyle(
                  color: homeTheme.textPrimaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.homeCardLoadFileDesc,
                style: TextStyle(
                  color: homeTheme.textSecondaryColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickFile(context),
                    icon: const Icon(LucideIcons.upload, size: 16),
                    label: Text(l10n.homeCardLoadFileTitle),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showCreateQuizFileDialog(context),
                    icon: const Icon(LucideIcons.plusCircle, size: 16),
                    label: Text(l10n.homeCardCreateQuizTitle),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final homeTheme = context.homeTheme;
    final isMobile = context.isMobile;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: homeTheme.mainBackgroundColor,
        border: Border(
          bottom: BorderSide(color: homeTheme.borderColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.homeMenuInicio,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: homeTheme.textPrimaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isMobile)
            IconButton(
              icon: Icon(LucideIcons.settings, color: homeTheme.borderColor),
              onPressed: () => _showSettingsDialog(context),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContentArea(BuildContext context) {
    final isMobile = context.isMobile;
    final homeTheme = context.homeTheme;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<RecentQuizzesCubit>().loadRecentQuizzes();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16.0 : 40.0,
            vertical: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_showAllRecents) ...[
                // Welcome row
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.homeWelcomeTitle,
                      style: TextStyle(
                        color: homeTheme.textPrimaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.homeWelcomeSubtitle,
                      style: TextStyle(
                        color: homeTheme.textSecondaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Recent studies
              BlocBuilder<RecentQuizzesCubit, RecentQuizzesState>(
                builder: (context, recentState) {
                  if (recentState is RecentQuizzesLoaded) {
                    final recents = recentState.recentQuizzes;
                    if (recents.isEmpty && !_showAllRecents) {
                      return const SizedBox.shrink();
                    }

                    final listToDisplay = _showAllRecents
                        ? recents
                        : recents.take(3).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRecentHeader(context, recents.length),
                        const SizedBox(height: 12),
                        _buildRecentCardsGrid(context, listToDisplay),
                        const SizedBox(height: 24),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              if (!_showAllRecents) ...[
                // AI actions row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final useColumn = constraints.maxWidth < 600;
                    final cardWidgets = [
                      HomeActionCard(
                        title: AppLocalizations.of(
                          context,
                        )!.homeCardStudyAiTitle,
                        description: AppLocalizations.of(
                          context,
                        )!.homeCardStudyAiDesc,
                        badgeText: AppLocalizations.of(
                          context,
                        )!.homeCardStudyAiBadge,
                        backgroundColor: homeTheme.studyAiCardColor,
                        icon: LucideIcons.sparkles,
                        isPrimary: true,
                        onTap: () => _startStudyModeWithAI(context),
                      ),
                      HomeActionCard(
                        title: AppLocalizations.of(
                          context,
                        )!.homeCardQuizAiTitle,
                        description: AppLocalizations.of(
                          context,
                        )!.homeCardQuizAiDesc,
                        badgeText: AppLocalizations.of(
                          context,
                        )!.homeCardQuizAiBadge,
                        backgroundColor: homeTheme.quizAiCardColor,
                        icon: LucideIcons.graduationCap,
                        isPrimary: true,
                        onTap: () => _generateQuestionsWithAI(context),
                      ),
                    ];

                    return useColumn
                        ? Column(
                            children: cardWidgets
                                .map(
                                  (c) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: c,
                                  ),
                                )
                                .toList(),
                          )
                        : Row(
                            children: cardWidgets
                                .map(
                                  (c) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: c,
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                  },
                ),
                const SizedBox(height: 16),

                // Manual actions row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final useColumn = constraints.maxWidth < 600;
                    final cardWidgets = [
                      HomeActionCard(
                        title: AppLocalizations.of(
                          context,
                        )!.homeCardCreateQuizTitle,
                        description: AppLocalizations.of(
                          context,
                        )!.homeCardCreateQuizDesc,
                        badgeText: AppLocalizations.of(
                          context,
                        )!.homeCardCreateQuizBadge,
                        backgroundColor: homeTheme.cardBackgroundColor,
                        icon: LucideIcons.plusCircle,
                        isPrimary: false,
                        accentColor: Theme.of(context).colorScheme.primary,
                        onTap: () => _showCreateQuizFileDialog(context),
                      ),
                      HomeActionCard(
                        title: AppLocalizations.of(
                          context,
                        )!.homeCardLoadFileTitle,
                        description: AppLocalizations.of(
                          context,
                        )!.homeCardLoadFileDesc,
                        badgeText: AppLocalizations.of(
                          context,
                        )!.homeCardLoadFileBadge,
                        backgroundColor: homeTheme.cardBackgroundColor,
                        icon: LucideIcons.upload,
                        isPrimary: false,
                        accentColor: homeTheme.textSecondaryColor,
                        onTap: () => _pickFile(context),
                      ),
                    ];

                    return useColumn
                        ? Column(
                            children: cardWidgets
                                .map(
                                  (c) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: c,
                                  ),
                                )
                                .toList(),
                          )
                        : Row(
                            children: cardWidgets
                                .map(
                                  (c) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: c,
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                  },
                ),
                const SizedBox(height: 24),

                // Global drag hint card
                const HomeGlobalDragHint(),
                const SizedBox(height: 24),

                // Feedback card
                if (_showFeedbackBanner) ...[
                  HomeFeedbackCard(onTap: () => _openFeedbackForm(context)),
                  const SizedBox(height: 24),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentHeader(BuildContext context, int totalCount) {
    final homeTheme = context.homeTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (_showAllRecents)
              IconButton(
                icon: Icon(LucideIcons.arrowLeft, color: homeTheme.borderColor),
                onPressed: () {
                  setState(() {
                    _showAllRecents = false;
                  });
                },
              ),
            Text(
              AppLocalizations.of(context)!.homeRecentSectionTitle,
              style: TextStyle(
                color: homeTheme.textPrimaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (!_showAllRecents && totalCount > 3)
          TextButton(
            onPressed: () {
              setState(() {
                _showAllRecents = true;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.homeRecentViewAll,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  LucideIcons.chevronRight,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          )
        else if (_showAllRecents)
          TextButton(
            onPressed: () {
              context.read<RecentQuizzesCubit>().clearAllRecentQuizzes();
            },
            child: Text(
              AppLocalizations.of(context)!.homeClearHistoryButton,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentCardsGrid(BuildContext context, List<RecentQuiz> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : (constraints.maxWidth > 600 ? 2 : 1);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 96,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return HomeRecentCard(
              title: item.title,
              progress: item.progress,
              lastOpenedText: _formatLastOpened(context, item.lastOpened),
              onTap: () => _handleRecentQuizTap(context, item),
              onDelete: () {
                context.read<RecentQuizzesCubit>().deleteRecentQuiz(item.id);
              },
            );
          },
        );
      },
    );
  }
}
