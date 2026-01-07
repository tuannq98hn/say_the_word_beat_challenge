import 'package:equatable/equatable.dart';

class GuideState extends Equatable {
  final int currentStep;
  final int countdownValue;
  final bool isCompleted;
  final bool isCountDowning;

  const GuideState({
    this.currentStep = 0,
    this.countdownValue = 5,
    this.isCompleted = false,
    this.isCountDowning = true,
  });

  GuideState copyWith({
    int? currentStep,
    int? countdownValue,
    bool? isCompleted,
    bool? isCountDowning,
  }) {
    return GuideState(
      currentStep: currentStep ?? this.currentStep,
      isCompleted: isCompleted ?? this.isCompleted,
      isCountDowning: isCountDowning ?? this.isCountDowning,
      countdownValue: countdownValue ?? this.countdownValue,
    );
  }

  @override
  List<Object?> get props => [currentStep, isCompleted, isCountDowning, countdownValue];
}
