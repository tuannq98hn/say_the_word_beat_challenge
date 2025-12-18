import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../data/local/database_service.dart';
import '../data/model/challenge.dart';

class StorageService {
  final DatabaseService _databaseService = DatabaseService();

  Future<String> compressImage(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image');

    const maxWidth = 500;
    const maxHeight = 500;

    int width = image.width;
    int height = image.height;

    if (width > height) {
      if (width > maxWidth) {
        height = (height * maxWidth / width).round();
        width = maxWidth;
      }
    } else {
      if (height > maxHeight) {
        width = (width * maxHeight / height).round();
        height = maxHeight;
      }
    }

    final resized = img.copyResize(image, width: width, height: height);
    final jpegBytes = img.encodeJpg(resized, quality: 70);
    final base64 = base64Encode(jpegBytes);
    return 'data:image/jpeg;base64,$base64';
  }

  Future<void> saveCustomChallenges(List<Challenge> challenges) async {
    try {
      for (final challenge in challenges) {
        await _databaseService.saveChallenge(challenge);
      }
    } catch (e) {
      throw Exception('Failed to save custom challenges: $e');
    }
  }

  Future<List<Challenge>> loadCustomChallenges() async {
    try {
      return await _databaseService.loadChallenges();
    } catch (e) {
      return [];
    }
  }

  Future<List<Challenge>> deleteCustomChallenge(String id) async {
    await _databaseService.deleteChallenge(id);
    return await loadCustomChallenges();
  }
}
