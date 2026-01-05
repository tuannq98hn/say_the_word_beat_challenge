import 'package:flutter/material.dart';
import 'package:flutter_ads_native/index.dart';
import 'package:say_word_challenge/services/interstitial_ads_controller.dart';
import 'package:say_word_challenge/services/remote_config_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../data/model/tiktok_video.dart';
import '../../services/tiktok_service.dart';

class VideoPlayerPage extends StatefulWidget {
  final TikTokVideo video;
  final VoidCallback onBack;

  const VideoPlayerPage({super.key, required this.video, required this.onBack});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  WebViewController? _webViewController;
  final TikTokService _tiktokService = tiktokService;
  bool _showWebView = false;
  bool _isLoading = false;

  /// Hiển thị video TikTok trong WebView
  Future<void> _openTikTok() async {
    if (_showWebView) return; // Đã hiển thị rồi thì không làm gì

    setState(() {
      _showWebView = true;
      _isLoading = true;
    });

    // Khởi tạo WebView nếu chưa có
    if (_webViewController == null) {
      await _initializeWebView();
    }
  }

  Future<void> _initializeWebView() async {
    // Tạo WebViewController
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      // Dùng user-agent iPhone Safari để TikTok trả về player tương thích hơn
      ..setUserAgent(
        'Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      );

    // Cấu hình cho Android
    if (_webViewController!.platform is AndroidWebViewController) {
      final androidController =
          _webViewController!.platform as AndroidWebViewController;
      androidController
        ..setMediaPlaybackRequiresUserGesture(false)
        ..setOnShowFileSelector((params) async {
          return [];
        });
    }

    // Ưu tiên load URL gốc với tham số webapp để TikTok trả về player
    final primaryUrl =
        '${widget.video.tiktokUrl}'
        '${widget.video.tiktokUrl.contains('?') ? '&' : '?'}is_copy_url=1&is_from_webapp=v1';

    // Fallback: embed URL
    final fallbackUrl = _tiktokService.getEmbedUrl(
      widget.video.tiktokUrl,
      autoplay: false,
    );

    // Thử URL gốc trước, nếu lỗi sẽ tự chuyển sang embed
    _webViewController!.loadRequest(Uri.parse(primaryUrl)).catchError((
      _,
    ) async {
      if (fallbackUrl != null) {
        await _webViewController!.loadRequest(Uri.parse(fallbackUrl));
      }
    });
  }

  Future<void> _openTikTokInBrowser() async {
    // Mở video TikTok trong trình duyệt ngoài
    try {
      final url = Uri.parse(widget.video.tiktokUrl);

      // Thử mở TikTok app trước (nếu có)
      final tiktokAppUrl = url.toString().replaceFirst(
        'https://www.tiktok.com',
        'tiktok://',
      );
      final tiktokAppUri = Uri.tryParse(tiktokAppUrl);

      if (tiktokAppUri != null) {
        try {
          if (await canLaunchUrl(tiktokAppUri)) {
            await launchUrl(tiktokAppUri, mode: LaunchMode.externalApplication);
            return;
          }
        } catch (e) {
          // Nếu không mở được TikTok app, tiếp tục mở browser
        }
      }

      // Fallback: mở trong browser
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Nếu không mở được, thử mở với platformDefault
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      // Nếu có lỗi, thử mở với mode đơn giản nhất
      try {
        final url = Uri.parse(widget.video.tiktokUrl);
        await launchUrl(url);
      } catch (e2) {
        // Hiển thị thông báo lỗi nếu cần
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot open TikTok video: ${e2.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.video.thumbnailUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(
              top: MediaQuery.of(context).padding.top,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => _handleShowInter(onDone: widget.onBack),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.arrow_back, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'BACK',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.video.author,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Anton',
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 400,
                      height: 700,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade800,
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // WebView để hiển thị video TikTok
                          if (_showWebView && _webViewController != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: WebViewWidget(
                                controller: _webViewController!,
                              ),
                            )
                          else
                            // Thumbnail background (trước khi mở video)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                widget.video.thumbnailUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey.shade900,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                            color: Colors.pink,
                                          ),
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade900,
                                    child: const Center(
                                      child: Icon(
                                        Icons.video_library,
                                        color: Colors.grey,
                                        size: 64,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          // Loading indicator
                          if (_isLoading)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.pink,
                                ),
                              ),
                            ),
                          // Play button overlay (chỉ hiển thị khi chưa mở WebView)
                          if (!_showWebView)
                            GestureDetector(
                              onTap: _openTikTok,
                              child: Container(
                                color: Colors.transparent,
                                child: Center(
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.pink.shade600.withOpacity(
                                        0.95,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.pink.shade600
                                              .withOpacity(0.6),
                                          blurRadius: 30,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 56,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade800, width: 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.video.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: widget.video.tags.map((tag) {
                          return Text(
                            '#$tag',
                            style: TextStyle(
                              color: Colors.pink.shade500,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      if (RemoteConfigService.instance.configAdsDataByScreen(
                            "VideoPlayerPage",
                          ) !=
                          null)
                        RemoteConfigService.instance.configAdsByScreen(
                          "VideoPlayerPage",
                        )!,
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              _handleShowInter(onDone: _openTikTokInBrowser),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 8,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.open_in_new,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'WATCH ON TIKTOK',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          _showWebView
                              ? 'Tap play button on video to start'
                              : 'Tap the play button above to watch in-app',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).padding.bottom),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _handleShowInter({
    required void Function() onDone,
  }) async {
    final origin_onInterstitialClosed = InterstitialAds.onInterstitialClosed;
    final origin_onInterstitialFailed = InterstitialAds.onInterstitialFailed;
    final origin_onInterstitialShown = InterstitialAds.onInterstitialShown;
    InterstitialAds.onInterstitialClosed = () {
      InterstitialAds.onInterstitialClosed = origin_onInterstitialClosed;
      onDone();
    };
    InterstitialAds.onInterstitialFailed = (_) {
      InterstitialAds.onInterstitialFailed = origin_onInterstitialFailed;
      onDone();
    };
    InterstitialAds.onInterstitialShown = () {
      InterstitialAds.onInterstitialShown = origin_onInterstitialShown;
      // todo show native full screen ==> check policy
    };
    if (!await InterstitialAdsController.instance.showInterstitialAd(
      screenClass: 'VideoPlayerPage',
      callerFunction: 'VideoPlayerPage._handleShowInter',
    )) {
      InterstitialAds.onInterstitialClosed = origin_onInterstitialClosed;
      InterstitialAds.onInterstitialFailed = origin_onInterstitialFailed;
      InterstitialAds.onInterstitialShown = origin_onInterstitialShown;
      onDone();
    }
  }
}
