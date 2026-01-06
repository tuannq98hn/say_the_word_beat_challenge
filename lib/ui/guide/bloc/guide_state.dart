import 'package:equatable/equatable.dart';

class GuideState extends Equatable {
  final int currentStep;
  final bool isCompleted;

  const GuideState({
    this.currentStep = 0,
    this.isCompleted = false,
  });

  GuideState copyWith({
    int? currentStep,
    bool? isCompleted,
  }) {
    return GuideState(
      currentStep: currentStep ?? this.currentStep,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [currentStep, isCompleted];
}

