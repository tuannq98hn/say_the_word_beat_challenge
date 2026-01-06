import 'package:flutter_bloc/flutter_bloc.dart';

import 'guide_event.dart';
import 'guide_state.dart';

class GuideBloc extends Bloc<GuideEvent, GuideState> {
  static const int totalSteps = 4;

  GuideBloc() : super(const GuideState()) {
    on<GuideInitialized>(_onInitialized);
    on<GuideNextPressed>(_onNextPressed);
    on<GuideSkipPressed>(_onSkipPressed);
  }

  void _onInitialized(GuideInitialized event, Emitter<GuideState> emit) {
    emit(const GuideState(currentStep: 0, isCompleted: false));
  }

  void _onNextPressed(GuideNextPressed event, Emitter<GuideState> emit) {
    if (state.currentStep >= totalSteps - 1) {
      emit(state.copyWith(isCompleted: true));
      return;
    }
    emit(state.copyWith(currentStep: state.currentStep + 1));
  }

  void _onSkipPressed(GuideSkipPressed event, Emitter<GuideState> emit) {
    emit(state.copyWith(isCompleted: true));
  }
}

