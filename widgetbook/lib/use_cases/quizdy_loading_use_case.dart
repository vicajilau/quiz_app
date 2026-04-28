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
import 'package:quizdy/presentation/widgets/quizdy_loading.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: QuizdyLoading)
Widget buildQuizdyLoadingUseCase(BuildContext context) => const QuizdyLoading();

@widgetbook.UseCase(name: 'Interactive', type: QuizdyLoading)
Widget buildInteractiveQuizdyLoadingUseCase(BuildContext context) {
  final height = context.knobs.double.slider(
    label: 'Height',
    initialValue: 80,
    min: 20,
    max: 300,
  );
  final width = context.knobs.double.slider(
    label: 'Width',
    initialValue: 80,
    min: 20,
    max: 300,
  );

  return QuizdyLoading(height: height, width: width);
}
