class ChallengeItem {
  final String word;
  final String emoji;
  final String? image;

  ChallengeItem({
    required this.word,
    required this.emoji,
    this.image,
  });

  Map<String, dynamic> toJson() => {
        'word': word,
        'emoji': emoji,
        'image': image,
      };

  factory ChallengeItem.fromJson(Map<String, dynamic> json) => ChallengeItem(
        word: json['word'] as String,
        emoji: json['emoji'] as String,
        image: json['image'] as String?,
      );
}
