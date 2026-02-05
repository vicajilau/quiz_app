import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/extensions/string_extension.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/data/services/configuration_service.dart';
import 'package:quiz_app/data/services/ai/ai_question_generation_service.dart';
import 'package:quiz_app/data/services/ai/ai_service.dart';
import 'package:quiz_app/domain/models/ai/ai_file_attachment.dart';
import 'package:quiz_app/domain/models/ai/ai_generation_stored_settings.dart';
import 'package:quiz_app/presentation/widgets/ai_content_info_box.dart';
import 'package:quiz_app/presentation/widgets/ai_file_picker_section.dart';
import 'package:quiz_app/presentation/widgets/ai_question_mode_indicator.dart';
import 'package:quiz_app/presentation/widgets/ai_service_model_selector.dart';
import 'package:quiz_app/presentation/widgets/ai_question_type_selector.dart';

enum AIQuestionMode { topic, content, file }

class AiGenerateQuestionsDialog extends StatefulWidget {
  const AiGenerateQuestionsDialog({super.key});

  @override
  State<AiGenerateQuestionsDialog> createState() =>
      _AiGenerateQuestionsDialogState();
}

class _AiGenerateQuestionsDialogState extends State<AiGenerateQuestionsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _questionCountController = TextEditingController();

  Set<AiQuestionType> _selectedQuestionTypes = {AiQuestionType.random};
  String _selectedLanguage = 'en'; // Will be updated in initState
  int _currentWordCount = 0;

  // Threshold for topic mode (creative exploration)
  static const int _topicModeThreshold = 10;

  // AI service from selector
  AIService? _selectedService;
  // AI model name from selector
  String? _selectedModel;

  // Saved service name to restore
  String? _savedServiceName;
  // Saved model name to restore
  String? _savedModelName;

  // File attachment state
  AiFileAttachment? _fileAttachment;

  AIQuestionMode get _currentMode {
    if (_fileAttachment != null) return AIQuestionMode.file;
    if (_currentWordCount < _topicModeThreshold) return AIQuestionMode.topic;
    return AIQuestionMode.content;
  }

  // Get supported languages from AppLocalizations
  List<String> get _supportedLanguages {
    return AppLocalizations.supportedLocales
        .map((locale) => locale.languageCode)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateWordCount);
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    final keepDraft = await ConfigurationService.instance.getAiKeepDraft();
    if (keepDraft) {
      // Load saved settings
      final settings = await ConfigurationService.instance
          .getAiGenerationSettings();

      if (settings.draftText != null &&
          settings.draftText!.isNotEmpty &&
          mounted) {
        setState(() {
          _textController.text = settings.draftText!;
        });
      }

      if (settings.serviceName != null && mounted) {
        setState(() {
          _savedServiceName = settings.serviceName;
        });
      }

      if (settings.modelName != null && mounted) {
        setState(() {
          _savedModelName = settings.modelName;
        });
      }

      // Load saved language
      if (settings.language != null &&
          _supportedLanguages.contains(settings.language) &&
          mounted) {
        setState(() {
          _selectedLanguage = settings.language!;
        });
      }

      // Load saved question count
      if (settings.questionCount != null && mounted) {
        _questionCountController.text = settings.questionCount.toString();
      }

      // Load saved question types
      if (settings.questionTypes != null &&
          settings.questionTypes!.isNotEmpty &&
          mounted) {
        final types = settings.questionTypes!
            .map((t) => _getAiQuestionTypeFromString(t))
            .where((t) => t != null)
            .cast<AiQuestionType>()
            .toSet();

        if (types.isNotEmpty) {
          setState(() {
            _selectedQuestionTypes = types;
          });
        }
      }
    }
  }

  AiQuestionType? _getAiQuestionTypeFromString(String type) {
    for (final value in AiQuestionType.values) {
      if (value.toString() == type) {
        return value;
      }
    }
    return null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setDefaultLanguage();
  }

  void _setDefaultLanguage() {
    // Get the system locale
    final systemLocale = Localizations.localeOf(context);
    final systemLanguageCode = systemLocale.languageCode;

    // Check if the system language is supported
    if (_supportedLanguages.contains(systemLanguageCode)) {
      setState(() {
        _selectedLanguage = systemLanguageCode;
      });
    } else {
      // Fallback to English if system language is not supported
      setState(() {
        _selectedLanguage = 'en';
      });
    }
  }

  @override
  void dispose() {
    _saveDraft();
    _textController.removeListener(_updateWordCount);
    _textController.dispose();
    _questionCountController.dispose();
    super.dispose();
  }

  Future<void> _saveDraft() async {
    final keepDraft = await ConfigurationService.instance.getAiKeepDraft();
    if (keepDraft) {
      int? count;
      if (_questionCountController.text.isNotEmpty) {
        count = int.tryParse(_questionCountController.text);
      }

      final settings = AiGenerationStoredSettings(
        serviceName: _selectedService?.serviceName,
        modelName: _selectedModel,
        language: _selectedLanguage,
        questionCount: count,
        questionTypes: _selectedQuestionTypes.map((t) => t.toString()).toList(),
        draftText: _textController.text.trim(),
      );

      await ConfigurationService.instance.saveAiGenerationSettings(settings);
    }
  }

  void _updateWordCount() {
    final text = _textController.text.trim();
    final words = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    setState(() {
      _currentWordCount = words;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final mode = _currentMode;
    final isFileMode = mode == AIQuestionMode.file;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.purple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      localizations.aiGenerateDialogTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI service and model selectors
                      AiServiceModelSelector(
                        initialService: _savedServiceName,
                        initialModel: _savedModelName,
                        onServiceChanged: (service) {
                          setState(() {
                            _selectedService = service;
                          });
                        },
                        onModelChanged: (model) {
                          setState(() {
                            _selectedModel = model;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      // Number of questions (optional)
                      Text(
                        localizations.aiQuestionCountLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _questionCountController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          hintMaxLines: 2,
                          hintText: localizations.aiQuestionCountHint,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final number = int.tryParse(value);
                            if (number == null || number < 1 || number > 50) {
                              return localizations.aiQuestionCountValidation;
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Question type
                      Text(
                        localizations.aiQuestionTypeLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      AiQuestionTypeSelector(
                        selectedTypes: _selectedQuestionTypes,
                        onSelectedTypesChanged: (newTypes) {
                          setState(() {
                            _selectedQuestionTypes = newTypes;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // File attachment section
                      AiFilePickerSection(
                        fileAttachment: _fileAttachment,
                        onFileChanged: (file) {
                          setState(() {
                            _fileAttachment = file;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Language
                      Text(
                        localizations.aiLanguageLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedLanguage,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: _supportedLanguages.map((langCode) {
                          return DropdownMenuItem(
                            value: langCode,
                            child: Text(langCode.languageName(context)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedLanguage = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Content label
                      Text(
                        isFileMode
                            ? localizations.aiCommentsLabel
                            : localizations.aiContentLabel,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),

                      // Mode indicator (Topic, Content, or File)
                      if (isFileMode || _currentWordCount > 0) ...[
                        AiQuestionModeIndicator(
                          mode: mode,
                          wordCount: _currentWordCount,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Text field
                      TextFormField(
                        controller: _textController,
                        enabled: _selectedService != null,
                        decoration: InputDecoration(
                          hintText: isFileMode
                              ? localizations.aiCommentsHint
                              : localizations.aiContentHint,
                          helperMaxLines: 2,
                          border: const OutlineInputBorder(),
                          helperText: isFileMode
                              ? localizations.aiCommentsHelperText
                              : localizations.aiContentHelperText,
                          suffixIcon: _textController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _textController.clear();
                                    // Also clear the draft
                                    ConfigurationService.instance
                                        .saveAiGenerationSettings(
                                          const AiGenerationStoredSettings(
                                            draftText: '',
                                          ),
                                        );
                                  },
                                )
                              : null,
                        ),
                        maxLines: 8,
                        validator: (value) {
                          if (_selectedService == null) {
                            return null; // Skip validation if no service available
                          }

                          // In file mode, text is optional
                          if (isFileMode) {
                            return null;
                          }

                          if (value == null || value.trim().isEmpty) {
                            return localizations.aiContentRequiredError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Additional information
                      const AiContentInfoBox(),
                    ],
                  ),
                ),
              ),

              // Buttons
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(localizations.cancel),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          (_selectedService != null &&
                              (_currentWordCount > 0 || isFileMode))
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                final config = AiQuestionGenerationConfig(
                                  questionCount:
                                      _questionCountController.text.isEmpty
                                      ? null
                                      : int.parse(
                                          _questionCountController.text,
                                        ),
                                  questionTypes: _selectedQuestionTypes
                                      .toList(),
                                  language: _selectedLanguage,
                                  content: _textController.text.trim(),
                                  preferredService: _selectedService,
                                  preferredModel: _selectedModel,
                                  file: _fileAttachment,
                                );
                                context.pop(config);
                              }
                            }
                          : null,
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(
                        localizations.aiGenerateButton,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
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
}
