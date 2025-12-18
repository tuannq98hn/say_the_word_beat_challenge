import '../../common/enums/difficulty.dart';
import '../../common/enums/music_style.dart';

class GameSettings {
  final bool showWordText;
  final Difficulty difficulty;
  final MusicStyle musicStyle;

  GameSettings({
    this.showWordText = true,
    this.difficulty = Difficulty.medium,
    this.musicStyle = MusicStyle.funk,
  });

  GameSettings copyWith({
    bool? showWordText,
    Difficulty? difficulty,
    MusicStyle? musicStyle,
  }) {
    return GameSettings(
      showWordText: showWordText ?? this.showWordText,
      difficulty: difficulty ?? this.difficulty,
      musicStyle: musicStyle ?? this.musicStyle,
    );
  }

  Map<String, dynamic> toJson() => {
        'showWordText': showWordText,
        'difficulty': difficulty.name,
        'musicStyle': musicStyle.name,
      };

  factory GameSettings.fromJson(Map<String, dynamic> json) => GameSettings(
        showWordText: json['showWordText'] as bool? ?? true,
        difficulty: Difficulty.values.firstWhere(
          (e) => e.name == json['difficulty'],
          orElse: () => Difficulty.medium,
        ),
        musicStyle: MusicStyle.values.firstWhere(
          (e) => e.name == json['musicStyle'],
          orElse: () => MusicStyle.funk,
        ),
      );
}
