import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/services/configuration_service.dart';
import '../../../data/services/ai/ai_question_generation_service.dart';
import '../../../data/services/ai/ai_service.dart';
import '../../widgets/ai_service_model_selector.dart';
import '../../widgets/ai_question_type_selector.dart';

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

  // AI service and model from selector
  AIService? _selectedService;
  String? _selectedModel;

  // Check if we're in topic mode (less than 10 words)
  bool get _isTopicMode {
    return _currentWordCount < _topicModeThreshold;
  }

  // Get precision level based on word count
  String _getPrecisionLevel(AppLocalizations localizations) {
    if (_currentWordCount < 20) return localizations.aiPrecisionLow;
    if (_currentWordCount < 50) return localizations.aiPrecisionMedium;
    return localizations.aiPrecisionHigh;
  }

  // Get precision progress (0.0 to 1.0)
  double _getPrecisionProgress() {
    if (_currentWordCount < 10) return 0.0;
    if (_currentWordCount < 20) return 0.33;
    if (_currentWordCount < 50) return 0.66;
    return 1.0;
  }

  // Get supported languages from AppLocalizations
  List<String> get _supportedLanguages {
    return AppLocalizations.supportedLocales
        .map((locale) => locale.languageCode)
        .toList();
  }

  // Map with friendly language names
  String _getLanguageName(String languageCode) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return languageCode.toUpperCase();

    switch (languageCode) {
      case 'es':
        return localizations.languageSpanish;
      case 'en':
        return localizations.languageEnglish;
      case 'fr':
        return localizations.languageFrench;
      case 'de':
        return localizations.languageGerman;
      case 'el':
        return localizations.languageGreek;
      case 'it':
        return localizations.languageItalian;
      case 'pt':
        return localizations.languagePortuguese;
      case 'ca':
        return localizations.languageCatalan;
      case 'eu':
        return localizations.languageBasque;
      case 'gl':
        return localizations.languageGalician;
      case 'hi':
        return localizations.languageHindi;
      case 'zh':
        return localizations.languageChinese;
      case 'ar':
        return localizations.languageArabic;
      case 'ja':
        return localizations.languageJapanese;
      default:
        return languageCode.toUpperCase(); // Fallback to uppercase code
    }
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
      final draft = await ConfigurationService.instance.getAiDraftText();
      if (draft != null && draft.isNotEmpty && mounted) {
        setState(() {
          _textController.text = draft;
        });
      }
    }
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
      await ConfigurationService.instance.saveAiDraftText(
        _textController.text.trim(),
      );
    }
  }

  void _updateWordCount() {
    final text = _textController.text.trim();
    final words = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    setState(() {
      _currentWordCount = words;
    });
  }

  // Get color based on precision level
  Color _getPrecisionColor() {
    if (_currentWordCount < 20) return Colors.red;
    if (_currentWordCount < 50) return Colors.amber.shade700;
    return Colors.green;
  }

  Widget _buildModeIndicator(AppLocalizations localizations) {
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final contentColor = _isTopicMode ? secondaryColor : _getPrecisionColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: contentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: contentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _isTopicMode ? Icons.lightbulb_outline : Icons.article_outlined,
                size: 18,
                color: contentColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _isTopicMode
                                ? localizations.aiModeTopicTitle
                                : localizations.aiModeContentTitle,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: contentColor,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          localizations.aiWordCountIndicator(_currentWordCount),
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isTopicMode
                          ? localizations.aiModeTopicDescription
                          : localizations.aiModeContentDescription,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!_isTopicMode) ...[
            const SizedBox(width: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    localizations.aiPrecisionIndicator(
                      _getPrecisionLevel(localizations),
                    ),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: contentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 60,
                    child: LinearProgressIndicator(
                      value: _getPrecisionProgress(),
                      backgroundColor: contentColor.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(contentColor),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

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
                            child: Text(_getLanguageName(langCode)),
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
                        localizations.aiContentLabel,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),

                      // Mode indicator (Topic or Content)
                      if (_currentWordCount > 0) ...[
                        _buildModeIndicator(localizations),
                        const SizedBox(height: 12),
                      ],

                      // Text field
                      TextFormField(
                        controller: _textController,
                        enabled: _selectedService != null,
                        decoration: InputDecoration(
                          hintText: localizations.aiContentHint,
                          helperMaxLines: 2,
                          border: const OutlineInputBorder(),
                          helperText: localizations.aiContentHelperText,
                          suffixIcon: _textController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _textController.clear();
                                    // Also clear the draft
                                    ConfigurationService.instance
                                        .saveAiDraftText('');
                                  },
                                )
                              : null,
                        ),
                        maxLines: 8,
                        validator: (value) {
                          if (_selectedService == null) {
                            return null; // Skip validation if no service available
                          }

                          if (value == null || value.trim().isEmpty) {
                            return localizations.aiContentRequiredError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Additional information
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  localizations.aiInfoTitle,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              localizations.aiInfoDescription.replaceAll(
                                '\\n',
                                '\n',
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                          (_selectedService != null && _currentWordCount > 0)
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
