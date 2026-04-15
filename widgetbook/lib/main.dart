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
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:widgetbook/widgetbook.dart';

import 'use_cases/quizdy_app_bar_use_case.dart';
import 'use_cases/quizdy_button_use_case.dart';
import 'use_cases/quizdy_loading_use_case.dart';
import 'use_cases/quizdy_empty_state_use_case.dart';
import 'use_cases/quizdy_latex_text_use_case.dart';
import 'use_cases/quizdy_markdown_use_case.dart';
import 'use_cases/quizdy_selectable_card_use_case.dart';
import 'use_cases/quizdy_stepper_field_use_case.dart';
import 'use_cases/quizdy_switch_use_case.dart';
import 'use_cases/quizdy_text_field_use_case.dart';
import 'use_cases/study_progress_bar_use_case.dart';

void main() {
  runApp(const QuizdyWidgetbookApp());
}

class QuizdyWidgetbookApp extends StatelessWidget {
  const QuizdyWidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      appBuilder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: Padding(padding: const EdgeInsets.all(24), child: child),
          ),
        ),
      ),
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: AppTheme.lightTheme),
            WidgetbookTheme(name: 'Dark', data: AppTheme.darkTheme),
          ],
        ),
        TextScaleAddon(),
      ],
      directories: [
        WidgetbookFolder(
          name: 'Quizdy',
          children: [
            WidgetbookComponent(
              name: 'QuizdyButton',
              useCases: [
                WidgetbookUseCase(
                  name: 'Primary',
                  builder: buildPrimaryQuizdyButtonUseCase,
                ),
                WidgetbookUseCase(
                  name: 'Secondary',
                  builder: buildSecondaryQuizdyButtonUseCase,
                ),
                WidgetbookUseCase(
                  name: 'Tertiary',
                  builder: buildTertiaryQuizdyButtonUseCase,
                ),
                WidgetbookUseCase(
                  name: 'Warning',
                  builder: buildWarningQuizdyButtonUseCase,
                ),
                WidgetbookUseCase(
                  name: 'Interactive',
                  builder: buildInteractiveQuizdyButtonUseCase,
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'QuizdyTextField',
              useCases: [
                WidgetbookUseCase(
                  name: 'All variants',
                  builder: buildQuizdyTextFieldUseCase,
                ),
                WidgetbookUseCase(
                  name: 'Interactive',
                  builder: buildInteractiveQuizdyTextFieldUseCase,
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'QuizdySwitch',
              useCases: [
                WidgetbookUseCase(
                  name: 'All variants',
                  builder: buildQuizdySwitchUseCase,
                ),
                WidgetbookUseCase(
                  name: 'Interactive',
                  builder: buildInteractiveQuizdySwitchUseCase,
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'QuizdyStepperField',
              useCases: [
                WidgetbookUseCase(
                  name: 'All variants',
                  builder: buildQuizdyStepperFieldUseCase,
                ),
                WidgetbookUseCase(
                  name: 'Interactive',
                  builder: buildInteractiveQuizdyStepperFieldUseCase,
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'QuizdyAppBar',
              useCases: [
                WidgetbookUseCase(
                  name: 'All variants',
                  builder: buildQuizdyAppBarUseCase,
                ),
                WidgetbookUseCase(
                  name: 'Interactive',
                  builder: buildInteractiveQuizdyAppBarUseCase,
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'QuizdyLatexText',
              useCases: [
                WidgetbookUseCase(
                  name: 'All variants',
                  builder: buildQuizdyLatexTextUseCase,
                ),
                WidgetbookUseCase(
                  name: 'Interactive',
                  builder: buildInteractiveQuizdyLatexTextUseCase,
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'QuizdyMarkdown',
              useCases: [
                WidgetbookUseCase(
                  name: 'All variants',
                  builder: buildQuizdyMarkdownUseCase,
                ),
                WidgetbookUseCase(
                  name: 'Interactive',
                  builder: buildInteractiveQuizdyMarkdownUseCase,
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'QuizdyEmptyState',
              useCases: [
                WidgetbookUseCase(
                  name: 'All variants',
                  builder: buildQuizdyEmptyStateUseCase,
                ),
                WidgetbookUseCase(
                  name: 'Interactive',
                  builder: buildInteractiveQuizdyEmptyStateUseCase,
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'StudyProgressBar',
              useCases: [
                WidgetbookUseCase(
                  name: 'All variants',
                  builder: buildStudyProgressBarUseCase,
                ),
                WidgetbookUseCase(
                  name: 'Interactive',
                  builder: buildInteractiveStudyProgressBarUseCase,
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'QuizdySelectableCard',
              useCases: [
                WidgetbookUseCase(
                  name: 'All variants',
                  builder: buildQuizdySelectableCardUseCase,
                ),
                WidgetbookUseCase(
                  name: 'Interactive',
                  builder: buildInteractiveQuizdySelectableCardUseCase,
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'QuizdyLoading',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: buildQuizdyLoadingUseCase,
                ),
                WidgetbookUseCase(
                  name: 'Interactive',
                  builder: buildInteractiveQuizdyLoadingUseCase,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
