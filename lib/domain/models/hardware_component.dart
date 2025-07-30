import 'hardware_state.dart';
import 'maso/i_process.dart';

class HardwareComponent {
  HardwareState state;
  IProcess? process;

  HardwareComponent(this.state, this.process);

  @override
  String toString() => "HardwareComponent(state: $state, process: $process)";
}
