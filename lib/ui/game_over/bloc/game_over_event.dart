import 'package:equatable/equatable.dart';

abstract class GameOverEvent extends Equatable {
  const GameOverEvent();

  @override
  List<Object> get props => [];
}

class GameOverInitialized extends GameOverEvent {
  const GameOverInitialized();
}

