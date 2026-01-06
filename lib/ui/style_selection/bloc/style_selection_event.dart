import 'package:equatable/equatable.dart';

import '../../../common/enums/difficulty.dart';
import '../../../common/enums/music_style.dart';

abstract class StyleSelectionEvent extends Equatable {
  const StyleSelectionEvent();

  @override
  List<Object?> get props => [];
}

class StyleSelectionInitialized extends StyleSelectionEvent {
  const StyleSelectionInitialized();
}

class StyleSelected extends StyleSelectionEvent {
  final MusicStyle style;
  final Difficulty difficulty;

  const StyleSelected({
    required this.style,
    required this.difficulty,
  });

  @override
  List<Object?> get props => [style, difficulty];
}

