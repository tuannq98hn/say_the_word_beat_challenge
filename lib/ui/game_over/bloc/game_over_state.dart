import '../../../base/base_bloc_state.dart';

class GameOverState extends BaseBlocState {
  const GameOverState({
    super.isLoading = false,
    super.error,
  });

  @override
  GameOverState copyWith({
    bool? isLoading,
    String? error,
    bool removeError = false,
  }) {
    return GameOverState(
      isLoading: isLoading ?? this.isLoading,
      error: removeError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [isLoading, error];
}

