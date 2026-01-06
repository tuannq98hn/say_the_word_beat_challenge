import 'package:equatable/equatable.dart';

abstract class GuideEvent extends Equatable {
  const GuideEvent();

  @override
  List<Object?> get props => [];
}

class GuideInitialized extends GuideEvent {
  const GuideInitialized();
}

class GuideNextPressed extends GuideEvent {
  const GuideNextPressed();
}

class GuideSkipPressed extends GuideEvent {
  const GuideSkipPressed();
}

