import 'package:flutter/material.dart';
import 'package:quiz_app/data/services/configuration_service.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/data/services/ai/ai_service.dart';
import 'package:quiz_app/data/services/ai/ai_service_selector.dart';

class AiServiceModelSelector extends StatefulWidget {
  final String? initialService;
  final String? initialModel;
  final ValueChanged<AIService?>? onServiceChanged;
  final ValueChanged<String?>? onModelChanged;
  final ValueChanged<bool>? onLoadingChanged;
  final bool enabled;
  final bool saveToPreferences;

  final String? geminiApiKey;
  final String? openaiApiKey;

  const AiServiceModelSelector({
    super.key,
    this.initialService,
    this.initialModel,
    this.onServiceChanged,
    this.onModelChanged,
    this.onLoadingChanged,
    this.enabled = true,
    this.saveToPreferences = false,
    this.geminiApiKey,
    this.openaiApiKey,
  });

  @override
  State<AiServiceModelSelector> createState() => _AiServiceModelSelectorState();
}

class _AiServiceModelSelectorState extends State<AiServiceModelSelector> {
  static const String _defaultModelFallback = 'gemini-flash-latest';

  List<AIService> _availableServices = [];
  AIService? _selectedService;
  String? _selectedModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableServices();
  }

  @override
  void didUpdateWidget(AiServiceModelSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload services when API keys change or initial values change
    if (oldWidget.geminiApiKey != widget.geminiApiKey ||
        oldWidget.openaiApiKey != widget.openaiApiKey ||
        oldWidget.initialService != widget.initialService ||
        oldWidget.initialModel != widget.initialModel) {
      _loadAvailableServices();
    }
  }

  Future<void> _loadAvailableServices() async {
    try {
      // Load saved preferences
      final savedServiceName = await ConfigurationService.instance
          .getDefaultAIService();
      final savedModel = await ConfigurationService.instance
          .getDefaultAIModel();

      // Get available services
      final services = await AIServiceSelector.instance.getAvailableServices();

      if (mounted) {
        AIService? newService;
        String? newModel;

        // Try to find saved service, or use first available
        if (widget.initialService != null &&
            services.any((s) => s.serviceName == widget.initialService)) {
          newService = services.firstWhere(
            (s) => s.serviceName == widget.initialService,
          );
        } else if (savedServiceName != null &&
            services.any((s) => s.serviceName == savedServiceName)) {
          newService = services.firstWhere(
            (s) => s.serviceName == savedServiceName,
          );
        } else if (services.isNotEmpty) {
          newService = services.first;
        }

        // Set model: use saved, or initialModel from widget, or find default
        if (savedModel != null &&
            newService != null &&
            newService.availableModels.contains(savedModel)) {
          newModel = savedModel;
        } else if (widget.initialModel != null &&
            newService != null &&
            newService.availableModels.contains(widget.initialModel)) {
          newModel = widget.initialModel;
        } else if (newService != null) {
          // Try to use _defaultModelFallback if available
          if (newService.availableModels.contains(_defaultModelFallback)) {
            newModel = _defaultModelFallback;
          } else {
            newModel = newService.defaultModel;
          }
        }

        setState(() {
          _availableServices = services;
          _selectedService = newService;
          _selectedModel = newModel;
          _isLoading = false;
        });

        // Notify parent of initial values
        widget.onServiceChanged?.call(newService);
        widget.onModelChanged?.call(newModel);
        widget.onLoadingChanged?.call(false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        widget.onLoadingChanged?.call(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI service selector
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                child: _isLoading
                    ? Text(localizations.aiServicesLoading)
                    : _availableServices.isEmpty
                    ? Text(localizations.aiServicesNotConfigured)
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<AIService>(
                          value: _selectedService,
                          isExpanded: true,
                          items: _availableServices.map((service) {
                            return DropdownMenuItem<AIService>(
                              value: service,
                              child: Text(
                                service.serviceName,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            );
                          }).toList(),
                          onChanged: widget.enabled
                              ? (AIService? newService) async {
                                  if (newService != null) {
                                    final newModel = newService.defaultModel;
                                    setState(() {
                                      _selectedService = newService;
                                      _selectedModel = newModel;
                                    });
                                    widget.onServiceChanged?.call(newService);
                                    widget.onModelChanged?.call(newModel);
                                    if (widget.saveToPreferences) {
                                      await ConfigurationService.instance
                                          .saveDefaultAIService(
                                            newService.serviceName,
                                          );
                                      await ConfigurationService.instance
                                          .saveDefaultAIModel(newModel);
                                    }
                                  }
                                }
                              : null,
                        ),
                      ),
              ),
            ],
          ),
        ),
        // Model selector (only show if there are available services)
        if (_selectedService != null && _availableServices.isNotEmpty) ...[
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.aiModelLabel,
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
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedModel,
                      isExpanded: true,
                      items: _selectedService!.availableModels.map((model) {
                        return DropdownMenuItem<String>(
                          value: model,
                          child: Text(
                            model,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                      }).toList(),
                      onChanged: widget.enabled
                          ? (String? newModel) async {
                              if (newModel != null) {
                                setState(() {
                                  _selectedModel = newModel;
                                });
                                widget.onModelChanged?.call(newModel);
                                if (widget.saveToPreferences) {
                                  await ConfigurationService.instance
                                      .saveDefaultAIModel(newModel);
                                }
                              }
                            }
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
