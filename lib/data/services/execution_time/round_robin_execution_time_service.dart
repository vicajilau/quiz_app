import 'package:quiz_app/core/constants/execution_time_constants.dart';
import 'package:quiz_app/data/services/execution_time/base_execution_time_service.dart';
import 'package:quiz_app/domain/models/machine.dart';

import '../../../domain/models/core_processor.dart';
import '../../../domain/models/hardware_component.dart';
import '../../../domain/models/hardware_state.dart';
import '../../../domain/models/maso/regular_process.dart';

/// Execution time service for the Round Robin scheduling algorithm.
///
/// This service schedules regular (non-burst) processes using the Round Robin strategy.
/// It handles quantum slicing and optional context switch delays between processes.
class RoundRobinExecutionTimeService extends BaseExecutionTimeService {
  /// Creates a Round Robin execution time service with the given processes and setup.
  RoundRobinExecutionTimeService(super.processes, super.executionSetup);

  /// Calculates the execution schedule for regular processes using Round Robin.
  ///
  /// - Processes are sorted by their arrival time.
  /// - Each process gets CPU time in `quantum`-sized slices.
  /// - Context switch time is inserted between process slices if configured.
  /// - Processes are requeued until their total service time is consumed.
  /// - Idle time is inserted if no processes are ready and a CPU is idle.
  @override
  Machine calculateMachineWithRegularProcesses() {
    // Filter and sort incoming processes by arrival time
    final filtered = processes.whereType<RegularProcess>().toList()
      ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    final numberOfCPUs = executionSetup.settings.cpuCount;
    final contextSwitchTime = executionSetup.settings.contextSwitchTime;
    final quantum = executionSetup.settings.quantum;

    // Create one CoreProcessor per CPU
    List<CoreProcessor> cpus = List.generate(
      numberOfCPUs,
      (_) => CoreProcessor.empty(),
    );

    // Tracks current time for each CPU
    List<int> cpuTimes = List.filled(numberOfCPUs, 0);

    // Ready queue and list of processes not yet arrived
    final queue = <RegularProcess>[];
    final pending = List<RegularProcess>.from(filtered);

    int globalTime = 0;

    // Main scheduling loop
    while (queue.isNotEmpty || pending.isNotEmpty) {
      // Enqueue processes that have arrived by global time
      pending.removeWhere((p) {
        if (p.arrivalTime <= globalTime) {
          queue.add(p.copy());
          return true;
        }
        return false;
      });

      bool anyExecuted = false;

      for (int cpu = 0; cpu < numberOfCPUs; cpu++) {
        final core = cpus[cpu].core;

        // Skip if no process is ready
        if (queue.isEmpty) {
          // Insert idle time if CPU is waiting for the next process
          if (pending.isNotEmpty && cpuTimes[cpu] < pending.first.arrivalTime) {
            final idleTime = pending.first.arrivalTime - cpuTimes[cpu];
            final idleProcess = RegularProcess(
              id: ExecutionTimeConstants.freeProcessId,
              arrivalTime: cpuTimes[cpu],
              serviceTime: idleTime,
              enabled: true,
            );

            core.add(HardwareComponent(HardwareState.free, idleProcess));
            cpuTimes[cpu] += idleTime;
            globalTime = cpuTimes.reduce((a, b) => a < b ? a : b);
          }

          continue;
        }

        // Get the next process in the ready queue
        final process = queue.removeAt(0);

        // Determine how much time to execute (up to quantum)
        final executionTime = process.serviceTime > quantum
            ? quantum
            : process.serviceTime;

        // Create the execution slice for this process
        final adjustedProcess = process.copy();
        adjustedProcess.arrivalTime = cpuTimes[cpu];
        adjustedProcess.serviceTime = executionTime;

        core.add(HardwareComponent(HardwareState.busy, adjustedProcess));
        cpuTimes[cpu] += executionTime;
        globalTime = cpuTimes.reduce((a, b) => a < b ? a : b);

        // If the process still has remaining time, requeue it
        final remainingTime = process.serviceTime - executionTime;
        if (remainingTime > 0) {
          final remaining = process.copy();
          remaining.serviceTime = remainingTime;
          remaining.arrivalTime = cpuTimes[cpu];
          queue.add(remaining);
        }

        // Add context switch if configured
        if (contextSwitchTime > 0) {
          final switchProcess = RegularProcess(
            id: ExecutionTimeConstants.switchContextProcessId,
            arrivalTime: cpuTimes[cpu],
            serviceTime: contextSwitchTime,
            enabled: true,
          );

          core.add(
            HardwareComponent(HardwareState.switchingContext, switchProcess),
          );

          cpuTimes[cpu] += contextSwitchTime;
          globalTime = cpuTimes.reduce((a, b) => a < b ? a : b);
        }

        anyExecuted = true;
      }

      // If no process executed and there are still pending ones, fast-forward time
      if (!anyExecuted && pending.isNotEmpty) {
        globalTime = pending.first.arrivalTime;
      }
    }

    return Machine(cpus: cpus, ioChannels: []);
  }

  /// Not implemented: Round Robin does not support burst processes in this version.
  @override
  Machine calculateMachineWithBurstProcesses() {
    throw UnimplementedError();
  }
}
