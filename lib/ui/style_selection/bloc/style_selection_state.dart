import 'package:equatable/equatable.dart';

import '../../../data/model/game_settings.dart';

class StyleSelectionState extends Equatable {
  final bool isLoading;
  final bool isCompleted;
  final GameSettings settings;
  final String? error;

  const StyleSelectionState({
    this.isLoading = false,
    this.isCompleted = false,
    this.settings = const GameSettings(),
    this.error,
  });

  StyleSelectionState copyWith({
    bool? isLoading,
    bool? isCompleted,
    GameSettings? settings,
    String? error,
    bool removeError = false,
  }) {
    return StyleSelectionState(
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      settings: settings ?? this.settings,
      error: removeError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [isLoading, isCompleted, settings, error];
}

