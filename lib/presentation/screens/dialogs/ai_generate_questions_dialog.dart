import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mime/mime.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/data/services/configuration_service.dart';
import 'package:quiz_app/data/services/ai/ai_question_generation_service.dart';
import 'package:quiz_app/data/services/ai/ai_service.dart';
import 'package:quiz_app/data/services/ai/ai_service_selector.dart';
import 'package:quiz_app/domain/models/quiz/question_type.dart';
import 'package:quiz_app/domain/models/ai/ai_file_attachment.dart';
import 'package:quiz_app/domain/models/ai/ai_generation_stored_settings.dart';

class AiGenerateQuestionsDialog extends StatefulWidget {
  const AiGenerateQuestionsDialog({super.key});

  @override
  State<AiGenerateQuestionsDialog> createState() =>
      _AiGenerateQuestionsDialogState();
}

class _AiGenerateQuestionsDialogState extends State<AiGenerateQuestionsDialog> {
  final _textController = TextEditingController();
  final _questionCountController = TextEditingController();

  int _currentStep = 0; // 0: Configuration, 1: Content

  Set<AiQuestionType> _selectedQuestionTypes = {AiQuestionType.random};
  String _selectedLanguage = 'en';
  List<AIService> _availableServices = [];
  AIService? _selectedService;
  String? _selectedModel;
  bool _isLoadingServices = true;

  AiFileAttachment? _fileAttachment;

  // Question Count state
  int _questionCount = 5;

  List<String> get _supportedLanguages {
    return AppLocalizations.supportedLocales
        .map((locale) => locale.languageCode)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadAvailableServices();
    await _loadDraft();
  }

  Future<void> _loadAvailableServices() async {
    setState(() {
      _isLoadingServices = true;
    });

    try {
      final services = await AIServiceSelector.instance.getAvailableServices();
      if (mounted) {
        setState(() {
          _availableServices = services;
          // Default to first service if available and none selected (and no draft)
          if (_selectedService == null && services.isNotEmpty) {
            // Logic to prefer saved default if draft doesn't override
          }
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

  Future<void> _loadDraft() async {
    final keepDraft = await ConfigurationService.instance.getAiKeepDraft();
    AIService? serviceToSet;
    String? modelToSet;

    // Use a local copy of available services for safety in async gap
    final services = _availableServices;

    if (keepDraft) {
      final settings = await ConfigurationService.instance
          .getAiGenerationSettings();

      if (mounted) {
        setState(() {
          if (settings.draftText != null && settings.draftText!.isNotEmpty) {
            _textController.text = settings.draftText!;
          }

          if (settings.questionCount != null) {
            _questionCount = settings.questionCount!;
            _questionCountController.text = _questionCount.toString();
          }

          if (settings.language != null &&
              _supportedLanguages.contains(settings.language)) {
            _selectedLanguage = settings.language!;
          }

          if (settings.questionTypes != null &&
              settings.questionTypes!.isNotEmpty) {
            final types = settings.questionTypes!
                .map((t) => _getAiQuestionTypeFromString(t))
                .where((t) => t != null)
                .cast<AiQuestionType>()
                .toSet();
            if (types.isNotEmpty) {
              _selectedQuestionTypes = types;
            }
          }
        });
      }

      // Determine Service
      if (settings.serviceName != null) {
        serviceToSet = services
            .where((s) => s.serviceName == settings.serviceName)
            .firstOrNull;
      }

      if (serviceToSet == null && services.isNotEmpty) {
        final defaultService = await ConfigurationService.instance
            .getDefaultAIService();
        if (defaultService != null) {
          serviceToSet = services
              .where((s) => s.serviceName == defaultService)
              .firstOrNull;
        }
        serviceToSet ??= services.first;
      }

      // Determine Model
      if (settings.modelName != null && serviceToSet != null) {
        if (serviceToSet.availableModels.contains(settings.modelName)) {
          modelToSet = settings.modelName;
        }
      }

      if (modelToSet == null && serviceToSet != null) {
        final defaultModel = await ConfigurationService.instance
            .getDefaultAIModel();
        if (defaultModel != null &&
            serviceToSet.availableModels.contains(defaultModel)) {
          modelToSet = defaultModel;
        } else {
          modelToSet = serviceToSet.defaultModel;
        }
      }
    } else {
      // Establish defaults if no draft
      if (services.isNotEmpty) {
        final defaultService = await ConfigurationService.instance
            .getDefaultAIService();
        if (defaultService != null) {
          serviceToSet = services
              .where((s) => s.serviceName == defaultService)
              .firstOrNull;
        }
        serviceToSet ??= services.first;
        modelToSet = serviceToSet.defaultModel;
      }
    }

    if (mounted) {
      setState(() {
        if (serviceToSet != null) _selectedService = serviceToSet;
        if (modelToSet != null) _selectedModel = modelToSet;
      });
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
    final systemLocale = Localizations.localeOf(context);
    final systemLanguageCode = systemLocale.languageCode;
    if (_supportedLanguages.contains(systemLanguageCode)) {
      // Only set if not already set (e.g. by draft)
      if (_selectedLanguage == 'en' && _textController.text.isEmpty) {
        // simplistic check
        // we let _loadDraft handle the definitive set, this is just a fallback
      }
      // For now, let's just default to system if not loaded
    }
  }

  int _getWordCount() {
    final text = _textController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  String _getWordCountText() {
    final count = _getWordCount();
    if (count <= 10) {
      return 'Topic Mode ($count words)';
    } else {
      return 'Text Mode ($count words)';
    }
  }

  @override
  void dispose() {
    _saveDraft();
    _textController.dispose();
    _questionCountController.dispose();
    super.dispose();
  }

  Future<void> _saveDraft() async {
    final keepDraft = await ConfigurationService.instance.getAiKeepDraft();
    if (keepDraft) {
      final settings = AiGenerationStoredSettings(
        serviceName: _selectedService?.serviceName,
        modelName: _selectedModel,
        language: _selectedLanguage,
        questionCount: _questionCount,
        questionTypes: _selectedQuestionTypes.map((t) => t.toString()).toList(),
        draftText: _textController.text.trim(),
      );
      await ConfigurationService.instance.saveAiGenerationSettings(settings);
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        if (pickedFile.bytes != null) {
          setState(() {
            _fileAttachment = AiFileAttachment(
              bytes: pickedFile.bytes!,
              mimeType:
                  lookupMimeType(
                    pickedFile.name,
                    headerBytes: pickedFile.bytes,
                  ) ??
                  'application/octet-stream',
              name: pickedFile.name,
            );
          });
        }
      }
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.aiFilePickerError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 0) {
      return _buildStep1(context);
    } else {
      return _buildStep2(context);
    }
  }

  Widget _buildStep1(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF27272A) : Colors.white;
    final borderColor = isDark ? Colors.transparent : const Color(0xFFE4E4E7);
    final titleColor = isDark ? Colors.white : const Color(0xFF18181B);
    final closeBtnColor = isDark
        ? const Color(0xFF3F3F46)
        : const Color(0xFFF4F4F5);
    final closeIconColor = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF71717A);
    final labelColor = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF71717A);

    final isGeminiSelected =
        _selectedService?.serviceName.toLowerCase().contains('gemini') ?? false;
    final isOpenAiSelected =
        _selectedService?.serviceName.toLowerCase().contains('openai') ?? false;

    // Check availability based on service list
    final isGeminiAvailable = _availableServices.any(
      (s) => s.serviceName.toLowerCase().contains('gemini'),
    );
    final isOpenAiAvailable = _availableServices.any(
      (s) => s.serviceName.toLowerCase().contains('openai'),
    );

    // Styling logic for buttons
    final geminiBgColor = isGeminiSelected
        ? const Color(0xFF8B5CF6)
        : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFF4F4F5));
    final geminiContentColor = isGeminiSelected
        ? Colors.white
        : (isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A));

    final openAiBgColor = isOpenAiSelected
        ? (isDark ? Colors.white : Colors.black)
        : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFF4F4F5));
    final openAiContentColor = isOpenAiSelected
        ? (isDark ? Colors.black : Colors.white)
        : (isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A));

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 560,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Generate with AI',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: closeBtnColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Icon(LucideIcons.x, color: closeIconColor, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // AI Service Label
            Text(
              'AI Service',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 12),

            // Service Options
            if (_isLoadingServices)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  // Gemini Button
                  Expanded(
                    child: GestureDetector(
                      onTap: isGeminiAvailable
                          ? () {
                              final service = _availableServices.firstWhere(
                                (s) => s.serviceName.toLowerCase().contains(
                                  'gemini',
                                ),
                              );
                              setState(() {
                                _selectedService = service;
                                _selectedModel = service.defaultModel;
                              });
                            }
                          : null,
                      child: Opacity(
                        opacity: isGeminiAvailable ? 1.0 : 0.5,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: geminiBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.sparkles,
                                color: geminiContentColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Gemini',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: geminiContentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // OpenAI Button
                  Expanded(
                    child: GestureDetector(
                      onTap: isOpenAiAvailable
                          ? () {
                              final service = _availableServices.firstWhere(
                                (s) => s.serviceName.toLowerCase().contains(
                                  'openai',
                                ),
                              );
                              setState(() {
                                _selectedService = service;
                                _selectedModel = service.defaultModel;
                              });
                            }
                          : null,
                      child: Opacity(
                        opacity: isOpenAiAvailable ? 1.0 : 0.5,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: openAiBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.bot,
                                color: openAiContentColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'OpenAI',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: openAiContentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Model Selection
            Text(
              'Model',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF3F3F46)
                    : const Color(0xFFF4F4F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedModel,
                  isExpanded: true,
                  icon: Icon(
                    LucideIcons.chevronDown,
                    color: closeIconColor,
                    size: 18,
                  ),
                  dropdownColor: isDark
                      ? const Color(0xFF3F3F46)
                      : const Color(0xFFF4F4F5),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: titleColor,
                  ),
                  hint: Text(
                    'Select Model',
                    style: TextStyle(color: labelColor),
                  ),
                  items:
                      _selectedService?.availableModels
                          .map(
                            (model) => DropdownMenuItem(
                              value: model,
                              child: Text(model),
                            ),
                          )
                          .toList() ??
                      [],
                  onChanged: (value) {
                    setState(() {
                      _selectedModel = value;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Question Types
            Text(
              'Question Types',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AiQuestionType.values
                  .where((type) => type != AiQuestionType.random)
                  .map((type) {
                    return _buildQuestionTypeChip(
                      context,
                      type: type,
                      isSelected: _selectedQuestionTypes.contains(type),
                      onTap: () {
                        setState(() {
                          if (_selectedQuestionTypes.contains(type)) {
                            _selectedQuestionTypes.remove(type);
                          } else {
                            _selectedQuestionTypes.add(type);
                          }
                        });
                      },
                      isDark: isDark,
                    );
                  })
                  .toList(),
            ),

            const SizedBox(height: 24),

            // Language
            Text(
              'Language',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF3F3F46)
                    : const Color(0xFFF4F4F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  isExpanded: true,
                  icon: Icon(
                    LucideIcons.chevronDown,
                    color: closeIconColor,
                    size: 18,
                  ),
                  dropdownColor: isDark
                      ? const Color(0xFF3F3F46)
                      : const Color(0xFFF4F4F5),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: titleColor,
                  ),
                  items: _supportedLanguages
                      .map(
                        (lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(_getLanguageName(lang, localizations)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLanguage = value;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Next Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _selectedService != null
                    ? () {
                        setState(() {
                          _currentStep = 1;
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Next'),
                    SizedBox(width: 8),
                    Icon(LucideIcons.arrowRight, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF27272A) : Colors.white;
    final borderColor = isDark ? Colors.transparent : const Color(0xFFE4E4E7);
    final titleColor = isDark ? Colors.white : const Color(0xFF18181B);
    final closeBtnColor = isDark
        ? const Color(0xFF3F3F46)
        : const Color(0xFFF4F4F5);
    final closeIconColor = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF71717A);
    final inputBg = isDark ? const Color(0xFF3F3F46) : const Color(0xFFF4F4F5);
    final placeholderColor = isDark
        ? const Color(0xFF71717A)
        : const Color(0xFFA1A1AA);
    final attachStroke = isDark
        ? const Color(0xFF52525B)
        : const Color(0xFFD4D4D8);
    final labelColor = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF71717A);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 800),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enter Content',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: closeBtnColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        LucideIcons.x,
                        color: closeIconColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the topic or paste content to generate questions from',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 24),

              // Input Area
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: titleColor,
                        ),
                        decoration: InputDecoration.collapsed(
                          hintText:
                              'Enter a topic like "World War II history" or paste text content here...',
                          hintStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: placeholderColor,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {}); // Trigger rebuild for counter
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _getWordCountText(),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: _getWordCount() > 10
                              ? const Color(0xFF8B5CF6) // Lilac for Text Mode
                              : labelColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Attach File
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  height: 64,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: attachStroke, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.paperclip, color: labelColor, size: 20),
                      const SizedBox(width: 12),
                      _fileAttachment != null
                          ? Expanded(
                              child: Text(
                                _fileAttachment!.name,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: labelColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : Text(
                              'Attach a file (PDF, TXT, DOCX)',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: labelColor,
                              ),
                            ),
                      if (_fileAttachment != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _fileAttachment = null;
                              });
                            },
                            child: Icon(
                              LucideIcons.x,
                              color: labelColor,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Question Types & Language (Preserved Logic)
              // Only showed briefly in design but logic requires them.
              // I'll put them in an expandable or just below?
              // Design doesn't visually emphasize them.
              // I will keep them hidden or minimal if they are not in the design screenshots I analyzed.
              // BUT functional requirements say we need language. Use system default if not shown?
              // The user said "Divide in 2 steps" based on design.
              // I'll assume standard question types (Random) and language (System) if not in design.
              // However, preserving 'AiQuestionTypeSelector' might be good.
              // I will add a small "Advanced Options" or similar if needed.
              // Ref checking: In original file, `_selectedQuestionTypes` and `_selectedLanguage` were there.
              // I'll leave them out of UI to match visual design STRICTLY, but assume defaults.
              // Wait, if I generate, I need to pass them.
              // I'll assume they stay at defaults (Random, System/Draft).
              const SizedBox(height: 24),

              // Question Count
              Text(
                'Number of Questions',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Minus
                  GestureDetector(
                    onTap: () {
                      if (_questionCount > 1) {
                        setState(() {
                          _questionCount--;
                          _questionCountController.text = _questionCount
                              .toString();
                        });
                      }
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: closeBtnColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LucideIcons.minus,
                        color: titleColor,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Display
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: closeBtnColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$_questionCount',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Plus
                  GestureDetector(
                    onTap: () {
                      if (_questionCount < 50) {
                        setState(() {
                          _questionCount++;
                          _questionCountController.text = _questionCount
                              .toString();
                        });
                      }
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.plus,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentStep = 0;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: closeBtnColor,
                          foregroundColor: titleColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.arrowLeft, size: 16),
                            SizedBox(width: 8),
                            Text('Back'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            (_textController.text.isNotEmpty ||
                                _fileAttachment != null)
                            ? () {
                                final config = AiQuestionGenerationConfig(
                                  questionCount: _questionCount,
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
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.sparkles, size: 16),
                            SizedBox(width: 8),
                            Text('Generate'),
                          ],
                        ),
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

  String _getLanguageName(String code, AppLocalizations localizations) {
    switch (code) {
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
        return code.toUpperCase();
    }
  }

  Widget _buildQuestionTypeChip(
    BuildContext context, {
    required AiQuestionType type,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    // Resolve label and icon from QuestionType if possible
    String label;
    IconData icon;

    switch (type) {
      case AiQuestionType.multipleChoice:
        label = QuestionType.multipleChoice.getQuestionTypeLabel(context);
        icon = QuestionType.multipleChoice.getQuestionTypeIcon();
        break;
      case AiQuestionType.singleChoice:
        label = QuestionType.singleChoice.getQuestionTypeLabel(context);
        icon = QuestionType.singleChoice.getQuestionTypeIcon();
        break;
      case AiQuestionType.trueFalse:
        label = QuestionType.trueFalse.getQuestionTypeLabel(context);
        icon = QuestionType.trueFalse.getQuestionTypeIcon();
        break;
      case AiQuestionType.essay:
        label = QuestionType.essay.getQuestionTypeLabel(context);
        icon = QuestionType.essay.getQuestionTypeIcon();
        break;
      case AiQuestionType.random:
        label = 'Random'; // Fallback, though we filter it out
        icon = LucideIcons.shuffle;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8B5CF6)
              : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFF4F4F5)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? LucideIcons.checkCircle2 : icon,
              size: 14,
              color: isSelected
                  ? Colors.white
                  : (isDark
                        ? const Color(0xFFA1A1AA)
                        : const Color(0xFF71717A)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? const Color(0xFFA1A1AA)
                          : const Color(0xFF71717A)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
