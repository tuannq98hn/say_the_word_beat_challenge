import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../base/base_bloc.dart';
import '../../../data/model/game_settings.dart';
import '../../../common/enums/difficulty.dart';
import '../../../services/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends BaseBloc<GameEvent, GameState> {
  Timer? _countdownTimer;
  GameSettings? _settings;
  final Set<String> _usedFeedbackWords = {};

  static const List<String> _feedbackWords = [
    "GOOD!",
    "PERFECT!",
    "NICE!",
    "FIRE!",
    "WOW!",
    "AMAZING!",
    "EXCELLENT!",
    "COOL!",
    "NEXT!",
    "GO!",
  ];

  GameBloc() : super(const GameState()) {
    on<GameInitialized>(_onGameInitialized);
    on<GameCountdownTick>(_onCountdownTick);
    on<GameBeatReceived>(_onBeatReceived);
    on<GameStopped>(_onGameStopped);
  }

  Future<void> _onGameInitialized(
    GameInitialized event,
    Emitter<GameState> emit,
  ) async {
    await _loadSettings();
    emit(state.copyWith(challenge: event.challenge));
    await Future.delayed(const Duration(milliseconds: 200));
    _startCountdown();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('game_settings');
    _settings = json != null
        ? GameSettings.fromJson(
            Map<String, dynamic>.from(
              jsonDecode(json),
            ),
          )
        : GameSettings();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(
      const Duration(milliseconds: 600),
      (timer) {
        add(const GameCountdownTick());
      },
    );
  }

  void _onCountdownTick(
    GameCountdownTick event,
    Emitter<GameState> emit,
  ) {
    if (state.countdownValue > 1) {
      emit(state.copyWith(countdownValue: state.countdownValue - 1));
    } else {
      _countdownTimer?.cancel();
      emit(state.copyWith(
        isCountingDown: false,
        countdownValue: 0,
      ));
      _startGame(emit);
    }
  }

  void _startGame(Emitter<GameState> emit) {
    final settings = _settings ?? GameSettings();
    audioService.setBpm(settings.difficulty.bpm);
    audioService.setMusicStyle(settings.musicStyle);
    audioService.setOnBeatCallback((beat) {
      add(GameBeatReceived(beat));
    });
    audioService.start();

    emit(state.copyWith(
      visibleCardsCount: 0,
      activeCardIndex: -1,
      flashFeedback: null,
      tick: 0,
      currentRoundIndex: 0,
    ));
  }

  void _onBeatReceived(
    GameBeatReceived event,
    Emitter<GameState> emit,
  ) {
    final currentTick = state.tick;

    int? newActiveCardIndex = state.activeCardIndex;
    int? newVisibleCardsCount = state.visibleCardsCount;
    String? newFlashFeedback;
    int? newRoundIndex = state.currentRoundIndex;
    int newTick = currentTick;

    if (currentTick < 4) {
      newActiveCardIndex = -1;
      newVisibleCardsCount = (currentTick + 1) * 2;
      newTick = currentTick + 1;
    } else if (currentTick >= 4 && currentTick < 12) {
      newVisibleCardsCount = 8;
      newActiveCardIndex = currentTick - 4;
      newTick = currentTick + 1;
    } else if (currentTick == 12) {
      newActiveCardIndex = -1;

      final availableWords = _feedbackWords
          .where((w) => !_usedFeedbackWords.contains(w))
          .toList();

      String word;
      if (availableWords.isNotEmpty) {
        word = availableWords[DateTime.now().millisecond % availableWords.length];
        _usedFeedbackWords.add(word);
      } else {
        _usedFeedbackWords.clear();
        word = _feedbackWords[DateTime.now().millisecond % _feedbackWords.length];
        _usedFeedbackWords.add(word);
      }

      newFlashFeedback = word;
      newTick = currentTick + 1;
    } else if (currentTick == 13) {
      newFlashFeedback = null;
      newTick = currentTick + 1;
    } else if (currentTick == 14) {
      newFlashFeedback = null;
      newTick = currentTick + 1;
    } else if (currentTick == 15) {
      final nextRound = state.currentRoundIndex + 1;
      if (nextRound >= (state.challenge?.rounds.length ?? 0)) {
        audioService.stop();
        emit(state.copyWith(
          isLoading: false,
          flashFeedback: null,
        ));
        return;
      } else {
        newRoundIndex = nextRound;
        newVisibleCardsCount = 0;
        newActiveCardIndex = -1;
        newFlashFeedback = null;
        newTick = 0;
        emit(state.copyWith(
          currentRoundIndex: newRoundIndex,
          tick: newTick,
          visibleCardsCount: newVisibleCardsCount,
          activeCardIndex: newActiveCardIndex,
          flashFeedback: null,
          removeFlashFeedback: true,
          beatInBar: event.beat,
        ));
        return;
      }
    }

    if (newFlashFeedback == null && state.flashFeedback != null) {
      emit(state.copyWith(
        beatInBar: event.beat,
        activeCardIndex: newActiveCardIndex,
        visibleCardsCount: newVisibleCardsCount,
        flashFeedback: null,
        removeFlashFeedback: true,
        tick: newTick,
      ));
    } else {
      emit(state.copyWith(
        beatInBar: event.beat,
        activeCardIndex: newActiveCardIndex,
        visibleCardsCount: newVisibleCardsCount,
        flashFeedback: newFlashFeedback,
        tick: newTick,
      ));
    }
  }

  void _onGameStopped(
    GameStopped event,
    Emitter<GameState> emit,
  ) {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    audioService.setOnBeatCallback((_) {});
    audioService.stop();
    emit(state.copyWith(
      isLoading: false,
      isCountingDown: false,
      countdownValue: 0,
      flashFeedback: null,
    ));
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    audioService.stop();
    return super.close();
  }
}

