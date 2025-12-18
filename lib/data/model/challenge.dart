import 'round.dart';

class Challenge {
  final String id;
  final String topic;
  final String? icon;
  final List<Round> rounds;
  final bool isCustom;

  Challenge({
    required this.id,
    required this.topic,
    this.icon,
    required this.rounds,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'icon': icon,
        'rounds': rounds.map((e) => e.toJson()).toList(),
        'isCustom': isCustom,
      };

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
        id: json['id'] as String,
        topic: json['topic'] as String,
        icon: json['icon'] as String?,
        rounds: (json['rounds'] as List)
            .map((e) => Round.fromJson(e as Map<String, dynamic>))
            .toList(),
        isCustom: json['isCustom'] as bool? ?? false,
      );
}
