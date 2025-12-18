import '../../../base/base_bloc_state.dart';
import '../../../data/model/challenge.dart';
import '../../../data/model/round.dart';

class GameState extends BaseBlocState {
  final Challenge? challenge;
  final int currentRoundIndex;
  final int beatInBar;
  final bool isCountingDown;
  final int countdownValue;
  final int activeCardIndex;
  final int visibleCardsCount;
  final String? flashFeedback;
  final int tick;

  const GameState({
    super.isLoading = false,
    super.error,
    this.challenge,
    this.currentRoundIndex = 0,
    this.beatInBar = 0,
    this.isCountingDown = true,
    this.countdownValue = 3,
    this.activeCardIndex = -1,
    this.visibleCardsCount = 0,
    this.flashFeedback,
    this.tick = 0,
  });

  Round? get currentRound {
    if (challenge == null || currentRoundIndex >= challenge!.rounds.length) {
      return null;
    }
    return challenge!.rounds[currentRoundIndex];
  }

  @override
  GameState copyWith({
    bool? isLoading,
    String? error,
    bool removeError = false,
    Challenge? challenge,
    int? currentRoundIndex,
    int? beatInBar,
    bool? isCountingDown,
    int? countdownValue,
    int? activeCardIndex,
    int? visibleCardsCount,
    String? flashFeedback,
    bool removeFlashFeedback = false,
    int? tick,
  }) {
    return GameState(
      isLoading: isLoading ?? this.isLoading,
      error: removeError ? null : (error ?? this.error),
      challenge: challenge ?? this.challenge,
      currentRoundIndex: currentRoundIndex ?? this.currentRoundIndex,
      beatInBar: beatInBar ?? this.beatInBar,
      isCountingDown: isCountingDown ?? this.isCountingDown,
      countdownValue: countdownValue ?? this.countdownValue,
      activeCardIndex: activeCardIndex ?? this.activeCardIndex,
      visibleCardsCount: visibleCardsCount ?? this.visibleCardsCount,
      flashFeedback: removeFlashFeedback ? null : (flashFeedback ?? this.flashFeedback),
      tick: tick ?? this.tick,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        challenge,
        currentRoundIndex,
        beatInBar,
        isCountingDown,
        countdownValue,
        activeCardIndex,
        visibleCardsCount,
        flashFeedback,
        tick,
      ];
}

