import '../../data/model/challenge.dart';
import '../../data/model/challenge_item.dart';
import '../../data/model/round.dart';

List<ChallengeItem> expandItems(List<ChallengeItem> items) {
  if (items.length < 3) return items;
  const pattern = [0, 1, 2, 0, 2, 1, 0, 1];
  return pattern.map((i) => items[i]).toList();
}

Challenge makeChallenge(
  String id,
  String topic,
  String icon,
  List<List<Map<String, String>>> wordSets,
) {
  return Challenge(
    id: id,
    topic: topic,
    icon: icon,
    isCustom: false,
    rounds: wordSets.asMap().entries.map((entry) {
      final idx = entry.key;
      final set = entry.value;
      return Round(
        id: idx + 1,
        items: expandItems(
          set.map((s) => ChallengeItem(word: s['w']!, emoji: s['e']!)).toList(),
        ),
      );
    }).toList(),
  );
}
