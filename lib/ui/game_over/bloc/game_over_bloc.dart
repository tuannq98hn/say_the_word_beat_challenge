import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../base/base_bloc.dart';
import 'game_over_event.dart';
import 'game_over_state.dart';

class GameOverBloc extends BaseBloc<GameOverEvent, GameOverState> {
  GameOverBloc() : super(const GameOverState()) {
    on<GameOverInitialized>(_onGameOverInitialized);
  }

  Future<void> _onGameOverInitialized(
    GameOverInitialized event,
    Emitter<GameOverState> emit,
  ) async {
    // Initialize if needed
  }
}

