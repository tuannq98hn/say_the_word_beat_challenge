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
import '../config/game_timing_config.dart';

class GameBloc extends BaseBloc<GameEvent, GameState> {
  Timer? _countdownTimer;
  Timer? _gameTickTimer;
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
    on<GameToggleShowText>(_onToggleShowText);
    on<GameTickEvent>(_onGameTick);
  }

  Future<void> _onGameInitialized(
    GameInitialized event,
    Emitter<GameState> emit,
  ) async {
    await _loadSettings();
    emit(state.copyWith(challenge: event.challenge));
    if (GameTimingConfig.preCountdownDelay.inMilliseconds > 0) {
      await Future.delayed(GameTimingConfig.preCountdownDelay);
    }
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
      GameTimingConfig.countdownInterval,
      (timer) {
        add(const GameCountdownTick());
      },
    );
  }

  Future<void> _onCountdownTick(
    GameCountdownTick event,
    Emitter<GameState> emit,
  ) async {
    if (state.countdownValue > 1) {
      emit(state.copyWith(countdownValue: state.countdownValue - 1));
    } else {
      _countdownTimer?.cancel();
      _countdownTimer = null;
      emit(state.copyWith(
        isCountingDown: false,
        countdownValue: 0,
      ));
      await _startGame(emit);
    }
  }

  Future<void> _startGame(Emitter<GameState> emit) async {
    final settings = _settings ?? GameSettings();
    
    if (state.challenge != null && state.challenge!.rounds.isNotEmpty) {
      final allUniqueWords = <String>{};
      for (final round in state.challenge!.rounds) {
        for (final item in round.items) {
          allUniqueWords.add(item.word);
        }
      }
      final uniqueWordsList = allUniqueWords.toList();
      
      emit(state.copyWith(
        visibleCardsCount: GameTimingConfig.initialVisibleCardsCount,
        activeCardIndex: GameTimingConfig.noActiveCardIndex,
        flashFeedback: null,
        previewWords: uniqueWordsList,
        tick: GameTimingConfig.levelStartTick,
        currentRoundIndex: 0,
      ));

      await Future.delayed(GameTimingConfig.previewWordsDisplayDuration);

      emit(state.copyWith(
        previewWords: null,
        removePreviewWords: true,
      ));
    }

    emit(state.copyWith(
      visibleCardsCount: GameTimingConfig.initialVisibleCardsCount,
      activeCardIndex: GameTimingConfig.noActiveCardIndex,
      flashFeedback: null,
      tick: GameTimingConfig.levelStartTick,
      currentRoundIndex: 0,
    ));
    
    audioService.setBpm(settings.difficulty.bpm);
    audioService.setMusicStyle(settings.musicStyle);
    audioService.setOnBeatCallback((beat) {
      add(GameBeatReceived(beat));
    });
    audioService.start(GameTimingConfig.musicStartDelay);
    
    _startGameTickTimer();
  }
  
  void _startGameTickTimer() {
    _gameTickTimer?.cancel();
    
    _gameTickTimer = Timer.periodic(
      GameTimingConfig.gameTickInterval,
      (timer) {
        // Kiểm tra bloc chưa bị close trước khi add event
        if (!isClosed) {
          add(const GameTickEvent());
        } else {
          timer.cancel();
        }
      },
    );
  }
  
  Future<void> _onGameTick(
    GameTickEvent event,
    Emitter<GameState> emit,
  ) async {
    final currentTick = state.tick;

    int? newActiveCardIndex = state.activeCardIndex;
    int? newVisibleCardsCount = state.visibleCardsCount;
    String? newFlashFeedback;
    int? newRoundIndex = state.currentRoundIndex;
    int newTick = currentTick + 1;
    int beatInBar = (currentTick % 4);

    if (currentTick < GameTimingConfig.cardsRevealEndTick) {
      newActiveCardIndex = GameTimingConfig.noActiveCardIndex;
      newVisibleCardsCount = (currentTick + 1) * 2;
      
      if (currentTick == GameTimingConfig.cardsRevealEndTick - 1) {
        emit(state.copyWith(
          beatInBar: beatInBar,
          activeCardIndex: newActiveCardIndex,
          visibleCardsCount: newVisibleCardsCount,
          flashFeedback: newFlashFeedback,
          tick: newTick,
        ));
        
        _gameTickTimer?.cancel();
        await Future.delayed(GameTimingConfig.revealToFocusDelay);
        // Kiểm tra bloc chưa bị close trước khi add event
        if (!isClosed) {
          add(const GameTickEvent());
          _startGameTickTimer();
        }
        return;
      }
    } else if (currentTick >= GameTimingConfig.cardHighlightStartTick && currentTick < GameTimingConfig.cardHighlightEndTick) {
      newVisibleCardsCount = 8;
      newActiveCardIndex = currentTick - GameTimingConfig.cardsRevealEndTick;
    } else if (currentTick == GameTimingConfig.feedbackWordStartTick) {
      newActiveCardIndex = -1;
      newFlashFeedback = null;
      
      final totalRounds = state.challenge?.rounds.length ?? 0;
      final isLastRound = state.currentRoundIndex >= totalRounds - 1;
      
      if (isLastRound) {
        _gameTickTimer?.cancel();
        _gameTickTimer = null;
        audioService.stop();
        emit(state.copyWith(
          isLoading: false,
          flashFeedback: null,
          activeCardIndex: GameTimingConfig.noActiveCardIndex,
          visibleCardsCount: 8,
          tick: GameTimingConfig.feedbackWordStartTick,
          isGameComplete: true,
        ));
        return;
      }
      
      newRoundIndex = state.currentRoundIndex + 1;
      newVisibleCardsCount = GameTimingConfig.initialVisibleCardsCount;
      newActiveCardIndex = GameTimingConfig.noActiveCardIndex;
      newFlashFeedback = null;
      newTick = GameTimingConfig.levelStartTick;
      emit(state.copyWith(
        currentRoundIndex: newRoundIndex,
        tick: newTick,
        visibleCardsCount: newVisibleCardsCount,
        activeCardIndex: newActiveCardIndex,
        flashFeedback: null,
        removeFlashFeedback: true,
        beatInBar: beatInBar,
      ));
      return;
    }

    emit(state.copyWith(
      beatInBar: beatInBar,
      activeCardIndex: newActiveCardIndex,
      visibleCardsCount: newVisibleCardsCount,
      flashFeedback: newFlashFeedback,
      tick: newTick,
    ));
  }

  void _onBeatReceived(
    GameBeatReceived event,
    Emitter<GameState> emit,
  ) {
    emit(state.copyWith(beatInBar: event.beat));
  }

  Future<void> _onGameStopped(
    GameStopped event,
    Emitter<GameState> emit,
  ) async {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _gameTickTimer?.cancel();
    _gameTickTimer = null;
    audioService.setOnBeatCallback((_) {});
    await audioService.stop();
    emit(state.copyWith(
      isLoading: false,
      isCountingDown: false,
      countdownValue: 0,
      flashFeedback: null,
    ));
  }

  Future<void> _onToggleShowText(
    GameToggleShowText event,
    Emitter<GameState> emit,
  ) async {
    if (_settings != null) {
      _settings = _settings!.copyWith(showWordText: !_settings!.showWordText);
      await _saveSettings();
    }
  }

  Future<void> _saveSettings() async {
    if (_settings != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('game_settings', jsonEncode(_settings!.toJson()));
    }
  }

  @override
  Future<void> close() async {
    _countdownTimer?.cancel();
    _gameTickTimer?.cancel();
    await audioService.stop();
    return super.close();
  }
}

