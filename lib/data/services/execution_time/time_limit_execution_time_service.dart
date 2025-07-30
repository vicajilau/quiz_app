import 'package:quiz_app/core/constants/execution_time_constants.dart';
import 'package:quiz_app/data/services/execution_time/base_execution_time_service.dart';
import 'package:quiz_app/domain/models/machine.dart';

import '../../../domain/models/core_processor.dart';
import '../../../domain/models/hardware_component.dart';
import '../../../domain/models/hardware_state.dart';
import '../../../domain/models/maso/regular_process.dart';

/// Execution time service for the Time Limit scheduling algorithm.
///
/// Each process is given a maximum execution time (`timeLimit`) per turn.
/// If it doesn't finish in that time, it is re-added to the queue with the remaining time.
/// Context switches and idle times are handled accordingly.
class TimeLimitExecutionTimeService extends BaseExecutionTimeService {
  TimeLimitExecutionTimeService(super.processes, super.executionSetup);

  @override
  Machine calculateMachineWithRegularProcesses() {
    final queue = processes.whereType<RegularProcess>().toList()
      ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    final numberOfCPUs = executionSetup.settings.cpuCount;
    final contextSwitchTime = executionSetup.settings.contextSwitchTime;
    final timeLimit = executionSetup.settings.timeLimit;

    final cpus = List.generate(numberOfCPUs, (_) => CoreProcessor.empty());
    final cpuTimes = List.filled(numberOfCPUs, 0);
    final remainingTimes = Map.fromEntries(
      queue.map((p) => MapEntry(p.id, p.serviceTime)),
    );

    final readyQueue = <RegularProcess>[];
    int currentTime = 0;

    while (queue.isNotEmpty || readyQueue.isNotEmpty) {
      // Move arrived processes to ready queue
      queue.removeWhere((p) {
        if (p.arrivalTime <= currentTime) {
          readyQueue.add(p);
          return true;
        }
        return false;
      });

      if (readyQueue.isEmpty) {
        currentTime++;
        continue;
      }

      for (int cpu = 0; cpu < numberOfCPUs; cpu++) {
        if (readyQueue.isEmpty) break;

        final core = cpus[cpu].core;
        final cpuTime = cpuTimes[cpu];
        if (cpuTime > currentTime) continue;

        final selected = readyQueue.removeAt(0);
        final remaining = remainingTimes[selected.id]!;
        final slice = remaining <= timeLimit ? remaining : timeLimit;
        final startTime = cpuTime < selected.arrivalTime
            ? selected.arrivalTime
            : cpuTime;

        // Idle time if CPU is waiting
        if (startTime > cpuTime) {
          final idle = RegularProcess(
            id: ExecutionTimeConstants.freeProcessId,
            arrivalTime: cpuTime,
            serviceTime: startTime - cpuTime,
            enabled: true,
          );
          core.add(HardwareComponent(HardwareState.free, idle));
        }

        // Process execution slice
        final scheduled = selected.copy();
        scheduled.arrivalTime = startTime;
        scheduled.serviceTime = slice;
        core.add(HardwareComponent(HardwareState.busy, scheduled));

        cpuTimes[cpu] = startTime + slice;
        currentTime = cpuTimes[cpu];

        final remainingAfter = remaining - slice;
        if (remainingAfter > 0) {
          remainingTimes[selected.id] = remainingAfter;
          // Re-enqueue with updated arrival time
          readyQueue.add(selected.copy());
        }

        // Context switch
        if (contextSwitchTime > 0 &&
            (remainingAfter > 0 || readyQueue.isNotEmpty || queue.isNotEmpty)) {
          final switching = RegularProcess(
            id: ExecutionTimeConstants.switchContextProcessId,
            arrivalTime: cpuTimes[cpu],
            serviceTime: contextSwitchTime,
            enabled: true,
          );
          core.add(
            HardwareComponent(HardwareState.switchingContext, switching),
          );
          cpuTimes[cpu] += contextSwitchTime;
          currentTime = cpuTimes[cpu];
        }
      }
    }

    return Machine(cpus: cpus, ioChannels: []);
  }

  @override
  Machine calculateMachineWithBurstProcesses() {
    throw UnimplementedError();
  }
}
