import 'package:quiz_app/core/constants/execution_time_constants.dart';
import 'package:quiz_app/data/services/execution_time/base_execution_time_service.dart';
import 'package:quiz_app/domain/models/machine.dart';

import '../../../domain/models/core_processor.dart';
import '../../../domain/models/hardware_component.dart';
import '../../../domain/models/hardware_state.dart';
import '../../../domain/models/maso/regular_process.dart';

/// Execution time service for the Shortest Job First (SJF) scheduling algorithm.
///
/// This class implements the `BaseExecutionTimeService` interface,
/// supporting only regular (non-burst) processes.
/// It assigns processes to CPUs based on the shortest service time,
/// considering only those that have arrived at the current time.
/// Idle times and context switches are handled if configured.
class SjfExecutionTimeService extends BaseExecutionTimeService {
  SjfExecutionTimeService(super.processes, super.executionSetup);

  @override
  Machine calculateMachineWithRegularProcesses() {
    final readyQueue = processes.whereType<RegularProcess>().toList();

    final numberOfCPUs = executionSetup.settings.cpuCount;
    final contextSwitchTime = executionSetup.settings.contextSwitchTime;

    final cpus = List.generate(numberOfCPUs, (_) => CoreProcessor.empty());
    final cpuTimes = List.filled(numberOfCPUs, 0);

    int currentTime = 0;

    while (readyQueue.isNotEmpty) {
      // Process filter for processes that have arrived
      final available = readyQueue
          .where((p) => p.arrivalTime <= currentTime)
          .toList();

      // If there are no available processes, advance the time to the next arrival
      if (available.isEmpty) {
        final nextArrival = readyQueue
            .map((p) => p.arrivalTime)
            .reduce((a, b) => a < b ? a : b);
        currentTime = nextArrival;
        continue;
      }

      // Sort by service time
      available.sort((a, b) => a.serviceTime.compareTo(b.serviceTime));
      final selected = available.first;
      readyQueue.remove(selected);

      // Choose CPU with the shortest time on the CPU (the one that will be free before)
      int selectedCpu = 0;
      for (int i = 1; i < numberOfCPUs; i++) {
        if (cpuTimes[i] < cpuTimes[selectedCpu]) {
          selectedCpu = i;
        }
      }

      final core = cpus[selectedCpu].core;
      final cpuTime = cpuTimes[selectedCpu];
      final startTime = cpuTime < selected.arrivalTime
          ? selected.arrivalTime
          : cpuTime;

      // Insert idle time if necessary
      if (startTime > cpuTime) {
        final idle = RegularProcess(
          id: ExecutionTimeConstants.freeProcessId,
          arrivalTime: cpuTime,
          serviceTime: startTime - cpuTime,
          enabled: true,
        );
        core.add(HardwareComponent(HardwareState.free, idle));
      }

      // Clone process with adjusted arrival time
      final scheduled = selected.copy();
      scheduled.arrivalTime = startTime;
      core.add(HardwareComponent(HardwareState.busy, scheduled));

      cpuTimes[selectedCpu] = startTime + selected.serviceTime;
      currentTime = cpuTimes[selectedCpu];

      // Add context switch if there are more processes
      if (contextSwitchTime > 0 && readyQueue.isNotEmpty) {
        final switching = RegularProcess(
          id: ExecutionTimeConstants.switchContextProcessId,
          arrivalTime: cpuTimes[selectedCpu],
          serviceTime: contextSwitchTime,
          enabled: true,
        );
        core.add(HardwareComponent(HardwareState.switchingContext, switching));
        cpuTimes[selectedCpu] += contextSwitchTime;
        currentTime = cpuTimes[selectedCpu];
      }
    }

    return Machine(cpus: cpus, ioChannels: []);
  }

  @override
  Machine calculateMachineWithBurstProcesses() {
    throw UnimplementedError();
  }
}
