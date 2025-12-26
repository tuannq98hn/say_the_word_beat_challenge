import '../../../base/base_bloc_state.dart';

class AppState extends BaseBlocState {
  const AppState({super.isLoading = false, super.error});

  @override
  AppState copyWith({
    bool? isLoading,
    String? error,
    bool removeError = false,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      error: removeError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [isLoading, error];
}
