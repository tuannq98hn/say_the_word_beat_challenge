import '../../../base/base_bloc_state.dart';
import '../../../data/model/challenge.dart';

class TopicListState extends BaseBlocState {
  final String? loadingTopicId;
  final Challenge? selectedChallenge;

  const TopicListState({
    super.isLoading = false,
    super.error,
    this.loadingTopicId,
    this.selectedChallenge,
  });

  @override
  TopicListState copyWith({
    bool? isLoading,
    String? error,
    bool removeError = false,
    String? loadingTopicId,
    bool removeLoadingTopicId = false,
    Challenge? selectedChallenge,
    bool removeSelectedChallenge = false,
  }) {
    return TopicListState(
      isLoading: isLoading ?? this.isLoading,
      error: removeError ? null : (error ?? this.error),
      loadingTopicId: removeLoadingTopicId ? null : (loadingTopicId ?? this.loadingTopicId),
      selectedChallenge: removeSelectedChallenge ? null : (selectedChallenge ?? this.selectedChallenge),
    );
  }

  @override
  List<Object?> get props => [isLoading, error, loadingTopicId, selectedChallenge];
}

