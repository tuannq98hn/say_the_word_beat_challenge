class TikTokVideo {
  final String id;
  final String author;
  final String description;
  final List<String> tags;
  final String thumbnailUrl;

  TikTokVideo({
    required this.id,
    required this.author,
    required this.description,
    required this.tags,
    required this.thumbnailUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author,
        'description': description,
        'tags': tags,
        'thumbnailUrl': thumbnailUrl,
      };

  factory TikTokVideo.fromJson(Map<String, dynamic> json) => TikTokVideo(
        id: json['id'] as String,
        author: json['author'] as String,
        description: json['description'] as String,
        tags: (json['tags'] as List).map((e) => e as String).toList(),
        thumbnailUrl: json['thumbnailUrl'] as String,
      );
}
