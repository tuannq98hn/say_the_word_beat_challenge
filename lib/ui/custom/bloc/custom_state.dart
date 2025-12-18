import '../../../base/base_bloc_state.dart';
import '../../../data/model/challenge.dart';

class CustomState extends BaseBlocState {
  final List<Challenge> customChallenges;

  const CustomState({
    super.isLoading = false,
    super.error,
    this.customChallenges = const [],
  });

  @override
  CustomState copyWith({
    bool? isLoading,
    String? error,
    bool removeError = false,
    List<Challenge>? customChallenges,
  }) {
    return CustomState(
      isLoading: isLoading ?? this.isLoading,
      error: removeError ? null : (error ?? this.error),
      customChallenges: customChallenges ?? this.customChallenges,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, customChallenges];
}

