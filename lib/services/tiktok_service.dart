import 'package:dio/dio.dart';

class TikTokService {
  final Dio _dio = Dio();

  /// Lấy thumbnail URL từ TikTok URL thông qua oEmbed API
  Future<String?> getThumbnailFromUrl(String tiktokUrl) async {
    try {
      final response = await _dio.get(
        'https://www.tiktok.com/oembed',
        queryParameters: {
          'url': tiktokUrl,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final thumbnailUrl = response.data['thumbnail_url'] as String?;
        return thumbnailUrl;
      }
    } catch (e) {
      // Nếu oEmbed API không hoạt động, trả về null để dùng fallback
      return null;
    }
    return null;
  }

  /// Extract video ID từ TikTok URL
  String? extractVideoId(String tiktokUrl) {
    try {
      final uri = Uri.parse(tiktokUrl);
      final pathSegments = uri.pathSegments;
      final videoIndex = pathSegments.indexOf('video');
      if (videoIndex != -1 && videoIndex + 1 < pathSegments.length) {
        return pathSegments[videoIndex + 1].split('?').first;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Tạo embed URL từ TikTok URL với autoplay
  String? getEmbedUrl(String tiktokUrl, {bool autoplay = true}) {
    final videoId = extractVideoId(tiktokUrl);
    if (videoId != null) {
      final baseUrl = 'https://www.tiktok.com/embed/v2/$videoId';
      if (autoplay) {
        return '$baseUrl?autoplay=1';
      }
      return baseUrl;
    }
    return null;
  }

  /// Tạo HTML wrapper với iframe để tự động play
  String? getEmbedHtml(String tiktokUrl) {
    final embedUrl = getEmbedUrl(tiktokUrl, autoplay: true);
    if (embedUrl != null) {
      return '''
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            background: #000;
            overflow: hidden;
            width: 100vw;
            height: 100vh;
        }
        iframe {
            width: 100%;
            height: 100%;
            border: none;
        }
    </style>
</head>
<body>
    <iframe 
        src="$embedUrl" 
        allow="autoplay; encrypted-media; fullscreen"
        allowfullscreen
        scrolling="no"
        frameborder="0">
    </iframe>
    <script>
        // Auto play video after iframe loads
        window.addEventListener('load', function() {
            setTimeout(function() {
                var iframe = document.querySelector('iframe');
                if (iframe) {
                    // Try to trigger play
                    try {
                        iframe.contentWindow.postMessage('{"type":"play"}', '*');
                    } catch(e) {
                        console.log('Cannot post message:', e);
                    }
                }
            }, 1000);
        });
    </script>
</body>
</html>
      ''';
    }
    return null;
  }
}

final tiktokService = TikTokService();

