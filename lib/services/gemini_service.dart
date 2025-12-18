import '../data/model/challenge.dart';
import '../data/model/topic_metadata.dart';
import 'data/trending_data.dart';
import 'data/featured_data.dart';

class GeminiService {
  static final List<TopicMetadata> trendingTopicsList = trendingMetadata;
  static final List<TopicMetadata> featuredTopicsList = featuredMetadata;
  static final Map<String, Challenge> predefinedChallenges = {
    ...trendingData,
    ...featuredData,
  };

  Future<Challenge> generateWordChallenge(
    String topicId,
    String promptTopic,
  ) async {
    if (predefinedChallenges.containsKey(topicId)) {
      return predefinedChallenges[topicId]!;
    }

    await Future.delayed(const Duration(seconds: 1));

    return predefinedChallenges['classic']!;
  }
}

final geminiService = GeminiService();
