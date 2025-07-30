import 'package:quiz_app/core/constants/execution_time_constants.dart';
import 'package:quiz_app/data/services/execution_time/base_execution_time_service.dart';
import 'package:quiz_app/domain/models/machine.dart';

import '../../../domain/models/core_processor.dart';
import '../../../domain/models/hardware_component.dart';
import '../../../domain/models/hardware_state.dart';
import '../../../domain/models/maso/regular_process.dart';

/// Execution time service for the Shortest Remaining Time First (SRTF) scheduling algorithm.
///
/// This algorithm is a preemptive version of SJF. At each unit of time,
/// the process with the shortest remaining time among the arrived ones
/// is selected and may preempt the currently running process.
class SrtfExecutionTimeService extends BaseExecutionTimeService {
  SrtfExecutionTimeService(super.processes, super.executionSetup);

  @override
  Machine calculateMachineWithRegularProcesses() {
    final readyQueue = processes
        .whereType<RegularProcess>()
        .map((p) => p.copy()) // Copy to modify remainingTime
        .toList();

    final numberOfCPUs = executionSetup.settings.cpuCount;
    final contextSwitchTime = executionSetup.settings.contextSwitchTime;

    final cpus = List.generate(numberOfCPUs, (_) => CoreProcessor.empty());
    final List<RegularProcess?> cpuStates = List.filled(numberOfCPUs, null);
    final cpuTimes = List.filled(numberOfCPUs, 0);

    final remainingTimes = <String, int>{
      for (var p in readyQueue) p.id: p.serviceTime,
    };

    int currentTime = 0;

    allDone() => readyQueue.isEmpty && cpuStates.every((p) => p == null);

    while (!allDone()) {
      // Get processes that have arrived
      final available = readyQueue
          .where((p) => p.arrivalTime <= currentTime)
          .toList();

      for (int i = 0; i < numberOfCPUs; i++) {
        final current = cpuStates[i];
        final core = cpus[i].core;

        // See if there is a better candidate for preemption
        final preemptCandidate =
            available.where((p) {
              return current == null ||
                  remainingTimes[p.id]! < remainingTimes[current.id]!;
            }).toList()..sort(
              (a, b) => remainingTimes[a.id]!.compareTo(remainingTimes[b.id]!),
            );

        // If there is a candidate, preempt if better or start new process
        if (preemptCandidate.isNotEmpty) {
          final next = preemptCandidate.first;

          // If preempt or first process
          if (current == null || current.id != next.id) {
            // Context switch
            if (current != null && contextSwitchTime > 0) {
              final switching = RegularProcess(
                id: ExecutionTimeConstants.switchContextProcessId,
                arrivalTime: currentTime,
                serviceTime: contextSwitchTime,
                enabled: true,
              );
              core.add(
                HardwareComponent(HardwareState.switchingContext, switching),
              );
              currentTime += contextSwitchTime;
              cpuTimes[i] = currentTime;
            }

            if (current != null) {
              readyQueue.add(current);
            }

            // Execute a `next` tick
            final running = next.copy();
            running.arrivalTime = currentTime;
            running.serviceTime = 1;

            core.add(HardwareComponent(HardwareState.busy, running));
            remainingTimes[next.id] = remainingTimes[next.id]! - 1;

            cpuStates[i] = remainingTimes[next.id] == 0 ? null : next;

            if (remainingTimes[next.id] == 0) {
              readyQueue.removeWhere((p) => p.id == next.id);
            }

            cpuTimes[i] = currentTime + 1;
          }
        } else if (current != null) {
          // Continue the current process 1 more unit
          final running = current.copy();
          running.arrivalTime = currentTime;
          running.serviceTime = 1;

          core.add(HardwareComponent(HardwareState.busy, running));
          remainingTimes[current.id] = remainingTimes[current.id]! - 1;

          if (remainingTimes[current.id] == 0) {
            cpuStates[i] = null;
            readyQueue.removeWhere((p) => p.id == current.id);
          }

          cpuTimes[i] = currentTime + 1;
        } else {
          // CPU is idle
          final idle = RegularProcess(
            id: ExecutionTimeConstants.freeProcessId,
            arrivalTime: currentTime,
            serviceTime: 1,
            enabled: true,
          );
          core.add(HardwareComponent(HardwareState.free, idle));
          cpuTimes[i] = currentTime + 1;
        }
      }

      currentTime++;
    }

    return Machine(cpus: cpus, ioChannels: []);
  }

  @override
  Machine calculateMachineWithBurstProcesses() {
    throw UnimplementedError();
  }
}
