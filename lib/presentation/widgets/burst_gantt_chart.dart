import 'package:flutter/material.dart';
import 'package:quiz_app/core/extensions/string_extension.dart';
import 'package:quiz_app/domain/models/machine.dart';
import 'package:quiz_app/domain/models/maso/burst_process.dart';

import '../../core/extensions/color_extension.dart';

class BurstGanttChart extends StatelessWidget {
  final Machine machine;
  const BurstGanttChart({super.key, required this.machine});

  @override
  Widget build(BuildContext context) {
    List<BurstProcess> burstProcesses = machine.cpus.first.core
        .map((hardwareComponent) => hardwareComponent.process as BurstProcess)
        .toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Uso del procesador",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Table(
          border: TableBorder.all(),
          columnWidths: {
            for (var entry in burstProcesses.asMap().entries)
              entry.key: FlexColumnWidth(entry.value.arrivalTime.toDouble()),
          },
          children: [
            TableRow(
              children: machine.cpus.first.core.map((hardwareComponent) {
                return buildCell(
                  hardwareComponent.process?.id ??
                      hardwareComponent.state.name.capitalize(),
                  ColorExtension.random,
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildCell(String text, Color color) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      color: color.withValues(alpha: 0.3),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
