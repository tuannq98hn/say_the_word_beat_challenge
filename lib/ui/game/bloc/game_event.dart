import 'package:equatable/equatable.dart';
import '../../../data/model/challenge.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object> get props => [];
}

class GameInitialized extends GameEvent {
  final Challenge challenge;

  const GameInitialized(this.challenge);

  @override
  List<Object> get props => [challenge];
}

class GameCountdownTick extends GameEvent {
  const GameCountdownTick();
}

class GameBeatReceived extends GameEvent {
  final int beat;

  const GameBeatReceived(this.beat);

  @override
  List<Object> get props => [beat];
}

class GameStopped extends GameEvent {
  const GameStopped();
}

class GameToggleShowText extends GameEvent {
  const GameToggleShowText();
}

class GameTickEvent extends GameEvent {
  const GameTickEvent();
}

