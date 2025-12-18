import '../../../base/base_bloc_state.dart';

class HomeState extends BaseBlocState {
  const HomeState({
    super.isLoading = false,
    super.error,
  });

  @override
  HomeState copyWith({
    bool? isLoading,
    String? error,
    bool removeError = false,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: removeError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [isLoading, error];
}

