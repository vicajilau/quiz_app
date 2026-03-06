import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// coverage:ignore-file
class QuizdyBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    debugPrint('${bloc.runtimeType} was created');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint(
      '$runtimeType - ${bloc.runtimeType} changed: ${change.nextState}',
    );
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint('$runtimeType - ${bloc.runtimeType} new event: $event');
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    debugPrint('$runtimeType - ${bloc.runtimeType} was closed');
  }
}
