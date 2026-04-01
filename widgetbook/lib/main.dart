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
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';
import 'package:quizdy/presentation/widgets/quizdy_switch.dart';
import 'package:quizdy/presentation/widgets/quizdy_text_field.dart';
import 'package:widgetbook/widgetbook.dart';

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
                  builder: (context) => QuizdyButton(
                    title: 'Start quiz',
                    type: QuizdyButtonType.primary,
                    onPressed: () {},
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Secondary',
                  builder: (context) => QuizdyButton(
                    title: 'Cancel',
                    type: QuizdyButtonType.secondary,
                    onPressed: () {},
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Loading',
                  builder: (context) => const QuizdyButton(
                    title: 'Generating',
                    isLoading: true,
                    onPressed: null,
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'QuizdyTextField',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) {
                    final controller = TextEditingController(text: 'Quizdy');
                    return QuizdyTextField(
                      controller: controller,
                      hint: 'Type a prompt',
                    );
                  },
                ),
                WidgetbookUseCase(
                  name: 'Error',
                  builder: (context) {
                    final controller = TextEditingController(
                      text: 'Invalid value',
                    );
                    return QuizdyTextField(
                      controller: controller,
                      hint: 'Type a prompt',
                      errorText: 'Please enter a valid value',
                    );
                  },
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'QuizdySwitch',
              useCases: [
                WidgetbookUseCase(
                  name: 'Enabled',
                  builder: (context) =>
                      QuizdySwitch(value: true, onChanged: (_) {}),
                ),
                WidgetbookUseCase(
                  name: 'Disabled',
                  builder: (context) =>
                      const QuizdySwitch(value: false, onChanged: null),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
