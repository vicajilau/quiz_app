import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeHeaderWidget extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSettingsTap;

  const HomeHeaderWidget({
    super.key,
    required this.isLoading,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
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
              onPressed: isLoading ? null : onSettingsTap,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
