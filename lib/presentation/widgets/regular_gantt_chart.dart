import 'package:flutter/material.dart';
import 'package:quiz_app/domain/models/hardware_state.dart';
import 'package:quiz_app/domain/models/maso/regular_process.dart';

import '../../core/color_manager.dart';
import '../../domain/models/machine.dart';

/// Widget that renders a Gantt chart with time labels and multiple CPU rows.
class RegularGanttChart extends StatelessWidget {
  final Machine machine;
  final double cellSpacing = 5.0;
  final regularPadding = 60.0;
  final colorManager = ColorManager();

  RegularGanttChart({super.key, required this.machine});

  @override
  Widget build(BuildContext context) {
    // Step 1: Calculate total time across all CPUs (max timeline)
    int globalTime = 0;
    final cpuBlocks = <List<_GanttBlock>>[];

    for (var cpu in machine.cpus) {
      final blocks = <_GanttBlock>[];
      int currentTime = 0;

      for (var component in cpu.core) {
        final process = component.process as RegularProcess;
        final duration = process.serviceTime;

        blocks.add(
          _GanttBlock(
            label: process.id,
            state: component.state,
            startTime: currentTime,
            duration: duration,
          ),
        );

        currentTime += duration;
      }

      if (currentTime > globalTime) {
        globalTime = currentTime;
      }

      cpuBlocks.add(blocks);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Processor Usage Timeline",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        /// Unified scrollable area
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Time header row
              Row(
                children: [
                  SizedBox(width: regularPadding), // for CPU label spacing
                  ...List.generate(globalTime + 1, (i) {
                    return Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text("$i"),
                    );
                  }),
                ],
              ),

              /// Each CPU row
              for (int cpuIndex = 0; cpuIndex < cpuBlocks.length; cpuIndex++)
                _buildCpuRow(cpuBlocks[cpuIndex], cpuIndex + 1, globalTime),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a row for a single CPU with its blocks and label
  Widget _buildCpuRow(List<_GanttBlock> blocks, int cpuNumber, int globalTime) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Arrow row
          _buildArrowRow(blocks, globalTime),
          const SizedBox(height: 4),

          /// CPU label + blocks
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: regularPadding,
                alignment: Alignment.centerLeft,
                child: Text(
                  "CPU $cpuNumber",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(
                width: globalTime * 40.0,
                height: regularPadding,
                child: Stack(
                  children: blocks
                      .map(
                        (block) => Positioned(
                          left: block.startTime * 40.0 + 20,
                          child: _buildCell(
                            block.label,
                            block.state,
                            block.duration,
                            spacingRight: 0.0,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a row of arrows indicating when a process starts and ends
  Widget _buildArrowRow(List<_GanttBlock> blocks, int globalTime) {
    final Map<int, List<_ArrowInfo>> arrows = {};

    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      final processId = block.label;
      final isProcessBlock = block.state == HardwareState.busy;
      final color = _colorForState(block.state, block.label);

      if (!isProcessBlock) continue;

      // Add down arrow to the start of the process
      if (block.startTime == _getArrivalTimeOfProcess(processId, blocks)) {
        arrows.putIfAbsent(block.startTime, () => []);
        arrows[block.startTime]!.add(_ArrowInfo(Icons.arrow_downward, color));
      }

      // Add up arrow to the end of every process execution
      final endTime = block.startTime + block.duration;
      arrows.putIfAbsent(endTime, () => []);
      arrows[endTime]!.add(_ArrowInfo(Icons.arrow_upward, color));
    }

    return Padding(
      padding: EdgeInsets.only(left: regularPadding),
      child: Row(
        children: List.generate(globalTime + 1, (i) {
          final arrowList = arrows[i];
          return Container(
            width: 40,
            alignment: Alignment.center,
            child: arrowList != null && arrowList.isNotEmpty
                ? arrowList.length == 1
                      ? Icon(
                          arrowList.first.icon,
                          size: 15,
                          color: arrowList.first.color,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: arrowList
                              .map(
                                (arrow) => Icon(
                                  arrow.icon,
                                  size: 15,
                                  color: arrow.color,
                                ),
                              )
                              .toList(),
                        )
                : null,
          );
        }),
      ),
    );
  }

  /// Returns the arrivalTime (startTime) of the first block of that process.
  int _getArrivalTimeOfProcess(String processId, List<_GanttBlock> blocks) {
    for (var block in blocks) {
      if (block.label == processId) {
        return block.startTime;
      }
    }
    return -1; // Not found
  }

  /// Builds a single process/state block.
  Widget _buildCell(
    String text,
    HardwareState state,
    int timeUnits, {
    double spacingRight = 0.0,
  }) {
    final baseColor = _colorForState(state, text);
    final isFree = state == HardwareState.free;

    return Container(
      width: 40.0 * timeUnits,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isFree ? null : baseColor.withValues(alpha: 0.3),
        border: isFree ? null : Border.all(color: baseColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: isFree
          ? null
          : Text(
              text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
    );
  }

  /// Maps each HardwareState to a color.
  Color _colorForState(HardwareState state, String text) {
    switch (state) {
      case HardwareState.busy:
        return colorManager.getColorForProcess(text);
      case HardwareState.free:
        return Colors.transparent;
      case HardwareState.switchingContext:
        return Colors.orange;
    }
  }
}

/// Internal model to represent each block in the Gantt chart.
class _GanttBlock {
  final String label;
  final HardwareState state;
  final int startTime;
  final int duration;

  _GanttBlock({
    required this.label,
    required this.state,
    required this.startTime,
    required this.duration,
  });
}

class _ArrowInfo {
  final IconData icon;
  final Color color;

  _ArrowInfo(this.icon, this.color);
}
