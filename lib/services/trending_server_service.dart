import '../data/model/challenge.dart';
import 'data/trending_server_data.dart';

class TrendingServerService {
  static final Map<String, Challenge> _challenges = trendingServerData;

  Future<Challenge?> getChallenge(String topicId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _challenges[topicId];
  }

  Future<List<Challenge>> getAllChallenges() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _challenges.values.toList();
  }

  Future<Map<String, Challenge>> getAllChallengesMap() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return Map<String, Challenge>.from(_challenges);
  }
}

final trendingServerService = TrendingServerService();

