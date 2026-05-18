import '../../../base/base_bloc_state.dart';

class SplashState extends BaseBlocState {
  final bool isCompleted;
  final bool
  isOpenAppSuccess; // check trường hợp openad load failed hoặc closed
  final bool isCloseNative; // native fullscreen closed
  final bool isShowGuide;

  const SplashState({
    super.isLoading = false,
    super.error,
    this.isCompleted = false,
    this.isOpenAppSuccess = false,
    this.isCloseNative = false,
    this.isShowGuide = false,
  });

  @override
  SplashState copyWith({
    bool? isLoading,
    String? error,
    bool removeError = false,
    bool? isCompleted,
    bool? isOpenAppSuccess,
    bool? isCloseNative,
    bool? isShowGuide,
  }) {
    return SplashState(
      isLoading: isLoading ?? this.isLoading,
      error: removeError ? null : (error ?? this.error),
      isCompleted: isCompleted ?? this.isCompleted,
      isOpenAppSuccess: isOpenAppSuccess ?? this.isOpenAppSuccess,
      isCloseNative: isCloseNative ?? this.isCloseNative,
      isShowGuide: isShowGuide ?? this.isShowGuide,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, isCompleted, isOpenAppSuccess, isCloseNative, isShowGuide];
}
