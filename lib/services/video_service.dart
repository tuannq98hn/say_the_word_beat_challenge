import 'dart:async';
import '../data/model/tiktok_video.dart';
import '../data/tiktok_videos_data.dart';
import 'tiktok_service.dart';

class VideoService {
  final TikTokService _tiktokService = tiktokService;

  Future<List<TikTokVideo>> fetchTikTokVideos() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Lấy danh sách video từ file tiktok_videos_data.dart
    final videos = TikTokVideosData.videos;
    
    // Fetch thumbnail cho mỗi video nếu chưa có
    final updatedVideos = await Future.wait(
      videos.map((video) async {
        // Nếu thumbnail là default, thử fetch từ TikTok
        if (video.thumbnailUrl.contains('unsplash.com')) {
          final thumbnail = await _tiktokService.getThumbnailFromUrl(video.tiktokUrl);
          if (thumbnail != null) {
            return TikTokVideo(
              id: video.id,
              author: video.author,
              description: video.description,
              tags: video.tags,
              thumbnailUrl: thumbnail,
              tiktokUrl: video.tiktokUrl,
            );
          }
        }
        return video;
      }),
    );
    
    return updatedVideos;
  }
}

final videoService = VideoService();
