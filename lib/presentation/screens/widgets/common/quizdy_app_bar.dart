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
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/extensions/quiz_loaded_theme.dart';

class QuizdyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final bool showLeading;
  final VoidCallback? onLeadingPressed;
  final Widget? leading;
  final String? leadingTooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const QuizdyAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showLeading = true,
    this.onLeadingPressed,
    this.leading,
    this.leadingTooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final resolvedForegroundColor =
        foregroundColor ?? Theme.of(context).colorScheme.onPrimary;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      foregroundColor: resolvedForegroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      toolbarHeight: 72,
      leadingWidth: showLeading ? 72 : null,
      leading: showLeading
          ? (leading ??
                _DefaultLeadingButton(
                  onPressed: onLeadingPressed,
                  foregroundColor: resolvedForegroundColor,
                  tooltip: leadingTooltip ?? localizations.backSemanticLabel,
                ))
          : null,
      title: title,
      actions: actions,
    );
  }
}

class _DefaultLeadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color foregroundColor;
  final String tooltip;

  const _DefaultLeadingButton({
    required this.onPressed,
    required this.foregroundColor,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.quizLoadedTheme.appBarIconBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(LucideIcons.arrowLeft, color: foregroundColor, size: 20),
            tooltip: tooltip,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
