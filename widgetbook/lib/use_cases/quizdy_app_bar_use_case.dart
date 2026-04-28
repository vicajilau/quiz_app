// Copyright (C) 2026 Victor Carreras
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
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/presentation/screens/widgets/common/quizdy_app_bar.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'All variants', type: QuizdyAppBar)
Widget buildQuizdyAppBarUseCase(BuildContext context) {
  return Localizations(
    locale: const Locale('en'),
    delegates: AppLocalizations.localizationsDelegates,
    child: SingleChildScrollView(
      child: Column(
        children: [
          _AppBarCard(
            title: 'With leading (back button)',
            appBar: QuizdyAppBar(
              title: const Text('Quiz title'),
              onLeadingPressed: () {},
            ),
          ),
          const SizedBox(height: 10.0),
          const _AppBarCard(
            title: 'Without leading',
            appBar: QuizdyAppBar(title: Text('Home'), showLeading: false),
          ),
          const SizedBox(height: 10.0),
          _AppBarCard(
            title: 'With actions',
            appBar: QuizdyAppBar(
              title: const Text('Quiz title'),
              onLeadingPressed: () {},
              actions: [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          _AppBarCard(
            title: 'Custom background color (teal)',
            appBar: QuizdyAppBar(
              title: const Text('Custom color'),
              onLeadingPressed: () {},
              backgroundColor: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Interactive', type: QuizdyAppBar)
Widget buildInteractiveQuizdyAppBarUseCase(BuildContext context) {
  final titleText = context.knobs.string(
    label: 'Title',
    initialValue: 'Page Title',
  );
  final showLeading = context.knobs.boolean(
    label: 'Show leading',
    initialValue: true,
  );
  final showActions = context.knobs.boolean(
    label: 'Show actions',
    initialValue: false,
  );
  final leadingTooltip = context.knobs.stringOrNull(
    label: 'Leading tooltip',
    initialValue: null,
  );
  final useCustomBg = context.knobs.boolean(
    label: 'Custom background color',
    initialValue: false,
  );
  final backgroundColor = context.knobs.object.dropdown<Color>(
    label: 'Background color',
    options: [AppTheme.secondaryColor, AppTheme.errorColor],
    initialOption: AppTheme.secondaryColor,
    labelBuilder: (c) => c == AppTheme.secondaryColor ? 'Secondary' : 'Error',
  );
  final useCustomFg = context.knobs.boolean(
    label: 'Custom foreground color',
    initialValue: false,
  );
  final foregroundColor = context.knobs.object.dropdown<Color>(
    label: 'Foreground color',
    options: [Colors.white, Colors.black],
    initialOption: Colors.white,
    labelBuilder: (c) => c == Colors.white ? 'White' : 'Black',
  );

  return Localizations(
    locale: const Locale('en'),
    delegates: AppLocalizations.localizationsDelegates,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 72,
        child: QuizdyAppBar(
          title: Text(titleText),
          showLeading: showLeading,
          onLeadingPressed: showLeading ? () {} : null,
          leadingTooltip: leadingTooltip,
          backgroundColor: useCustomBg ? backgroundColor : null,
          foregroundColor: useCustomFg ? foregroundColor : null,
          actions: showActions
              ? [
                  IconButton(icon: const Icon(Icons.share), onPressed: () {}),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                ]
              : null,
        ),
      ),
    ),
  );
}

class _AppBarCard extends StatelessWidget {
  final String title;
  final QuizdyAppBar appBar;

  const _AppBarCard({required this.title, required this.appBar});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: appBar.preferredSize.height,
                child: appBar,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
