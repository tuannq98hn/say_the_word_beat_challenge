import '../../../base/base_bloc_state.dart';

class SplashState extends BaseBlocState {
  final bool isCompleted;

  const SplashState({
    super.isLoading = false,
    super.error,
    this.isCompleted = false,
  });

  @override
  SplashState copyWith({
    bool? isLoading,
    String? error,
    bool removeError = false,
    bool? isCompleted,
  }) {
    return SplashState(
      isLoading: isLoading ?? this.isLoading,
      error: removeError ? null : (error ?? this.error),
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, isCompleted];
}

