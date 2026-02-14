import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/presentation/blocs/locale_bloc/locale_event.dart';
import 'package:quiz_app/presentation/blocs/locale_bloc/locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc() : super(const LocaleInitial()) {
    on<ChangeLocale>((event, emit) {
      emit(LocaleUpdated(event.locale));
    });
  }
}
