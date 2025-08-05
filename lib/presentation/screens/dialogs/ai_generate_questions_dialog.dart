import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/services/ai/ai_question_generation_service.dart';
import '../../../data/services/ai/ai_service_selector.dart';
import '../../../data/services/ai/ai_service.dart';

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

  AiQuestionType _selectedQuestionType = AiQuestionType.random;
  String _selectedLanguage = 'en'; // Will be updated in initState
  int _currentWordCount = 0;

  // Variables for AI selector
  List<AIService> _availableServices = [];
  AIService? _selectedService;
  bool _isLoadingServices = true;

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
    _loadAvailableServices();
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

  Future<void> _loadAvailableServices() async {
    try {
      final services = await AIServiceSelector.instance.getAvailableServices();
      if (mounted) {
        setState(() {
          _availableServices = services;
          _selectedService = services.isNotEmpty ? services.first : null;
          _isLoadingServices = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingServices = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_updateWordCount);
    _textController.dispose();
    _questionCountController.dispose();
    super.dispose();
  }

  void _updateWordCount() {
    final text = _textController.text.trim();
    final words = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    setState(() {
      _currentWordCount = words;
    });
  }

  String _getQuestionTypeLabel(AiQuestionType type) {
    final localizations = AppLocalizations.of(context)!;
    switch (type) {
      case AiQuestionType.multipleChoice:
        return localizations.questionTypeMultipleChoice;
      case AiQuestionType.singleChoice:
        return localizations.questionTypeSingleChoice;
      case AiQuestionType.trueFalse:
        return localizations.questionTypeTrueFalse;
      case AiQuestionType.essay:
        return localizations.questionTypeEssay;
      case AiQuestionType.random:
        return localizations.aiQuestionTypeRandom;
    }
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
                  Text(
                    localizations.aiGenerateDialogTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
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
                      // AI service selector
                      Text(
                        localizations.aiServiceLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.smart_toy,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            if (_isLoadingServices)
                              Expanded(
                                child: Text(localizations.aiServicesLoading),
                              )
                            else if (_availableServices.isEmpty)
                              Expanded(
                                child: Text(
                                  localizations.aiServicesNotConfigured,
                                ),
                              )
                            else
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<AIService>(
                                    value: _selectedService,
                                    isExpanded: true,
                                    items: _availableServices.map((service) {
                                      return DropdownMenuItem<AIService>(
                                        value: service,
                                        child: Row(
                                          children: [
                                            Icon(
                                              service.serviceName.contains(
                                                    'OpenAI',
                                                  )
                                                  ? Icons.auto_awesome
                                                  : Icons.auto_fix_high,
                                              size: 16,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              service.serviceName,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (AIService? newService) {
                                      if (newService != null) {
                                        setState(() {
                                          _selectedService = newService;
                                          // Revalidate content when service changes
                                          _updateWordCount();
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
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
                      DropdownButtonFormField<AiQuestionType>(
                        value: _selectedQuestionType,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: AiQuestionType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_getQuestionTypeLabel(type)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedQuestionType = value;
                            });
                          }
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
                        value: _selectedLanguage,
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

                      // Text field
                      TextFormField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: localizations.aiContentHint,
                          border: const OutlineInputBorder(),
                          helperText: localizations.aiContentHelperText,
                        ),
                        maxLines: 8,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return localizations.aiContentRequiredError;
                          }

                          if (_currentWordCount < 10) {
                            return localizations.aiMinWordsError;
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
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(localizations.cancel),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _selectedService != null
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              final config = AiQuestionGenerationConfig(
                                questionCount:
                                    _questionCountController.text.isEmpty
                                    ? null
                                    : int.parse(_questionCountController.text),
                                questionType: _selectedQuestionType,
                                language: _selectedLanguage,
                                content: _textController.text.trim(),
                                preferredService: _selectedService,
                              );
                              Navigator.of(context).pop(config);
                            }
                          }
                        : null,
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(localizations.aiGenerateButton),
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
