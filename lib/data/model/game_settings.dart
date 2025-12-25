import '../../common/enums/difficulty.dart';
import '../../common/enums/music_style.dart';

class GameSettings {
  final bool showWordText;
  final Difficulty difficulty;
  final MusicStyle musicStyle;
  final bool enableRecording;
  final bool enableCamera;

  GameSettings({
    this.showWordText = false,
    this.difficulty = Difficulty.medium,
    this.musicStyle = MusicStyle.funk,
    this.enableRecording = false,
    this.enableCamera = false,
  });

  GameSettings copyWith({
    bool? showWordText,
    Difficulty? difficulty,
    MusicStyle? musicStyle,
    bool? enableRecording,
    bool? enableCamera,
  }) {
    return GameSettings(
      showWordText: showWordText ?? this.showWordText,
      difficulty: difficulty ?? this.difficulty,
      musicStyle: musicStyle ?? this.musicStyle,
      enableRecording: enableRecording ?? this.enableRecording,
      enableCamera: enableCamera ?? this.enableCamera,
    );
  }

  Map<String, dynamic> toJson() => {
        'showWordText': showWordText,
        'difficulty': difficulty.name,
        'musicStyle': musicStyle.name,
        'enableRecording': enableRecording,
        'enableCamera': enableCamera,
      };

  factory GameSettings.fromJson(Map<String, dynamic> json) => GameSettings(
        showWordText: json['showWordText'] as bool? ?? false,
        difficulty: Difficulty.values.firstWhere(
          (e) => e.name == json['difficulty'],
          orElse: () => Difficulty.medium,
        ),
        musicStyle: MusicStyle.values.firstWhere(
          (e) => e.name == json['musicStyle'],
          orElse: () => MusicStyle.funk,
        ),
        enableRecording: json['enableRecording'] as bool? ?? false,
        enableCamera: json['enableCamera'] as bool? ?? false,
      );
}
