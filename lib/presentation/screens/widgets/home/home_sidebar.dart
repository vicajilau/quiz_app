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

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/extensions/home_theme.dart';

class HomeSidebar extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final ValueChanged<int> onTabSelected;
  final int selectedIndex;

  const HomeSidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.onTabSelected,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final homeTheme = context.homeTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isCollapsed ? 64 : 240,
      height: double.infinity,
      color: homeTheme.sidebarBackgroundColor,
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Sidebar top header
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: OverflowBox(
              minWidth: 0,
              maxWidth: 212,
              alignment: isCollapsed ? Alignment.center : Alignment.centerLeft,
              child: Row(
                mainAxisSize: isCollapsed ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.graduation_cap,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      if (!isCollapsed) ...[
                        const SizedBox(width: 12),
                        Text(
                          'Quizdy',
                          style: TextStyle(
                            color: homeTheme.textPrimaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (!isCollapsed)
                    IconButton(
                      icon: Icon(
                        LucideIcons.chevron_left,
                        color: homeTheme.textSecondaryColor,
                        size: 18,
                      ),
                      onPressed: onToggleCollapse,
                    ),
                ],
              ),
            ),
          ),
          if (isCollapsed)
            IconButton(
              icon: Icon(
                LucideIcons.chevron_right,
                color: homeTheme.textSecondaryColor,
                size: 18,
              ),
              onPressed: onToggleCollapse,
            ),
          Divider(color: homeTheme.borderColor, height: 1),

          // Menu navigation items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (!isCollapsed)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        top: 8,
                        bottom: 4,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.homeMenuSettings,
                        style: TextStyle(
                          color: homeTheme.textSecondaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  SidebarItem(
                    icon: LucideIcons.house,
                    label: AppLocalizations.of(context)!.homeMenuInicio,
                    isActive: selectedIndex == 0,
                    isCollapsed: isCollapsed,
                    onTap: () => onTabSelected(0),
                  ),
                  SidebarItem(
                    icon: LucideIcons.book_open,
                    label: AppLocalizations.of(context)!.homeMenuStudy,
                    isActive: selectedIndex == 1,
                    isCollapsed: isCollapsed,
                    onTap: () => onTabSelected(1),
                  ),
                  SidebarItem(
                    icon: LucideIcons.file_question_mark,
                    label: AppLocalizations.of(context)!.homeMenuQuiz,
                    isActive: selectedIndex == 2,
                    isCollapsed: isCollapsed,
                    onTap: () => onTabSelected(2),
                  ),
                  SidebarItem(
                    icon: LucideIcons.chart_column,
                    label: AppLocalizations.of(context)!.homeMenuEstadisticas,
                    isActive: selectedIndex == 3,
                    isCollapsed: isCollapsed,
                    onTap: () => onTabSelected(3),
                  ),
                ],
              ),
            ),
          ),

          Divider(color: homeTheme.borderColor, height: 1),
          // Sidebar bottom settings
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SidebarItem(
              icon: LucideIcons.settings,
              label: AppLocalizations.of(context)!.homeMenuSettings,
              isActive: false,
              isCollapsed: isCollapsed,
              onTap: () => onTabSelected(4),
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isCollapsed;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final homeTheme = context.homeTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Tooltip(
        message: isCollapsed ? label : '',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: OverflowBox(
              minWidth: 0,
              maxWidth: 220,
              alignment: isCollapsed ? Alignment.center : Alignment.centerLeft,
              child: Row(
                mainAxisSize: isCollapsed ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  if (!isCollapsed) const SizedBox(width: 12),
                  Icon(
                    icon,
                    size: 18,
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : homeTheme.textSecondaryColor,
                  ),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isActive
                              ? homeTheme.textPrimaryColor
                              : homeTheme.textSecondaryColor,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isActive)
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
