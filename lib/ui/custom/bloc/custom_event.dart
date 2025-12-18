import 'package:equatable/equatable.dart';

abstract class CustomEvent extends Equatable {
  const CustomEvent();

  @override
  List<Object> get props => [];
}

class CustomInitialized extends CustomEvent {
  const CustomInitialized();
}

class CustomChallengeSelected extends CustomEvent {
  final String challengeId;

  const CustomChallengeSelected(this.challengeId);

  @override
  List<Object> get props => [challengeId];
}

