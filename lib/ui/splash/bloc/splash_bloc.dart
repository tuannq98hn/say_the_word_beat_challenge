import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../base/base_bloc.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends BaseBloc<SplashEvent, SplashState> {
  SplashBloc() : super(const SplashState()) {
    on<SplashInitialized>(_onSplashInitialized);
  }

  Future<void> _onSplashInitialized(
    SplashInitialized event,
    Emitter<SplashState> emit,
  ) async {
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(isCompleted: true));
  }
}

