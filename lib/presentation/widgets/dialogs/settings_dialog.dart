import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/settings.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/service_locator.dart';
import '../../../domain/models/maso/process_mode.dart';
import '../../../domain/models/settings_maso.dart';

class SettingsDialog extends StatefulWidget {
  final SettingsMaso settings;
  final ValueChanged<SettingsMaso> onSettingsChanged;

  const SettingsDialog({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late SettingsMaso currentSettings;

  @override
  void initState() {
    super.initState();
    currentSettings = widget.settings.copy();
  }

  void _updateContextSwitchTime(int newValue) {
    setState(() {
      currentSettings.contextSwitchTime = newValue;
    });
  }

  void _updateIoChannels(int newValue) {
    setState(() {
      currentSettings.ioChannels = newValue;
    });
  }

  void _updateCpuCount(int newValue) {
    setState(() {
      currentSettings.cpuCount = newValue;
    });
  }

  void _onConfirm() {
    if (currentSettings.processesMode != widget.settings.processesMode) {
      _updateMode();
    } else {
      widget.onSettingsChanged(currentSettings);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.settingsDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Column(
              spacing: 5,
              children: [
                Text(
                  AppLocalizations.of(context)!.settingsDialogDescription,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                /// Dropdown for ProcessesMode
                DropdownButton<ProcessesMode>(
                  value: currentSettings.processesMode,
                  onChanged: (mode) {
                    if (mode != null) {
                      setState(() {
                        currentSettings.processesMode = mode;
                      });
                    }
                  },
                  items: ProcessesMode.values.map((mode) {
                    return DropdownMenuItem<ProcessesMode>(
                      value: mode,
                      child: Text(_getProcessModeName(context, mode)),
                    );
                  }).toList(),
                ),
              ],
            ),

            /// Slider for Context Switch Time
            _buildSlider(
              context: context,
              label: AppLocalizations.of(context)!.contextSwitchTime,
              value: currentSettings.contextSwitchTime.toDouble(),
              min: Settings.minContextSwitchTime.toDouble(),
              max: Settings.maxContextSwitchTime.toDouble(),
              divisions:
                  Settings.maxContextSwitchTime - Settings.minContextSwitchTime,
              onChanged: (value) => _updateContextSwitchTime(value.toInt()),
            ),

            /// Slider for IO Channels
            _buildSlider(
              context: context,
              label: AppLocalizations.of(context)!.ioChannels,
              value: currentSettings.ioChannels.toDouble(),
              min: Settings.minIoChannels.toDouble(),
              max: Settings.maxIoChannels.toDouble(),
              divisions: ((Settings.minIoChannels == 0)
                          ? Settings.maxIoChannels /
                              (Settings.minIoChannels + 1)
                          : Settings.maxIoChannels / Settings.minIoChannels)
                      .toInt() -
                  1,
              onChanged: (value) => _updateIoChannels(value.toInt()),
            ),

            /// Slider for CPU Count
            _buildSlider(
              context: context,
              label: AppLocalizations.of(context)!.cpuCount,
              value: currentSettings.cpuCount.toDouble(),
              min: Settings.minCpuCount.toDouble(),
              max: Settings.maxCpuCount.toDouble(),
              divisions: ((Settings.minCpuCount == 0)
                          ? Settings.maxCpuCount / (Settings.minCpuCount + 1)
                          : Settings.maxCpuCount / Settings.minCpuCount)
                      .toInt() -
                  1,
              onChanged: (value) => _updateCpuCount(value.toInt()),
            ),
          ],
        ),
      ),
      actions: [
        /// Close Button
        TextButton(
          onPressed: () => context.pop(),
          child: Text(AppLocalizations.of(context)!.close),
        ),

        /// Confirm Button
        ElevatedButton(
          onPressed: _onConfirm,
          child: Text(AppLocalizations.of(context)!.confirm),
        ),
      ],
    );
  }

  /// Builds a slider with a label
  Widget _buildSlider({
    required BuildContext context,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// Returns the localized name for the given ProcessesMode
  String _getProcessModeName(BuildContext context, ProcessesMode mode) {
    switch (mode) {
      case ProcessesMode.regular:
        return AppLocalizations.of(context)!.processModeRegular;
      case ProcessesMode.burst:
        return AppLocalizations.of(context)!.processModeBurst;
    }
  }

  void _updateMode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.settingsDialogWarningTitle),
        content:
            Text(AppLocalizations.of(context)!.settingsDialogWarningContent),
        actions: [
          TextButton(
            onPressed: () => context.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              ServiceLocator.instance.registerSettings(currentSettings);
              widget.onSettingsChanged(currentSettings);
              context.pop();
            },
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }
}
