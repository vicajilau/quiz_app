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
import 'package:quizdy/presentation/screens/widgets/study/study_progress_bar.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'All variants', type: StudyProgressBar)
Widget buildStudyProgressBarUseCase(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      children: const [
        _ProgressCard(label: '0%', value: 0),
        SizedBox(height: 10.0),
        _ProgressCard(label: '25%', value: 25),
        SizedBox(height: 10.0),
        _ProgressCard(label: '50%', value: 50),
        SizedBox(height: 10.0),
        _ProgressCard(label: '75%', value: 75),
        SizedBox(height: 10.0),
        _ProgressCard(label: '100%', value: 100),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Interactive', type: StudyProgressBar)
Widget buildInteractiveStudyProgressBarUseCase(BuildContext context) {
  final progress = context.knobs.double.slider(
    label: 'Progress (%)',
    initialValue: 50,
    min: 0,
    max: 100,
    divisions: 100,
  );

  return StudyProgressBar(progressPercentage: progress);
}

class _ProgressCard extends StatelessWidget {
  final String label;
  final double value;

  const _ProgressCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12.0),
            StudyProgressBar(progressPercentage: value),
          ],
        ),
      ),
    );
  }
}
