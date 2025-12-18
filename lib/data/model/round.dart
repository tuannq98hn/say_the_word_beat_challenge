import 'challenge_item.dart';

class Round {
  final int id;
  final List<ChallengeItem> items;

  Round({
    required this.id,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory Round.fromJson(Map<String, dynamic> json) => Round(
        id: json['id'] as int,
        items: (json['items'] as List)
            .map((e) => ChallengeItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
