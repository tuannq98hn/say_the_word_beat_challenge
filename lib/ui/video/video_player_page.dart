import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../../data/model/tiktok_video.dart';
import '../../services/tiktok_service.dart';

class VideoPlayerPage extends StatefulWidget {
  final TikTokVideo video;
  final VoidCallback onBack;

  const VideoPlayerPage({
    super.key,
    required this.video,
    required this.onBack,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final WebViewController _webViewController;
  final TikTokService _tiktokService = tiktokService;
  bool _isLoading = true;
  bool _showWebView = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    final embedUrl = _tiktokService.getEmbedUrl(widget.video.tiktokUrl, autoplay: true);
    
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
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
                _showWebView = true;
              });
              // Thử trigger play sau khi page load
              _tryAutoPlay();
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

    // Cấu hình cho Android platform
    if (_webViewController.platform is AndroidWebViewController) {
      (_webViewController.platform as AndroidWebViewController)
        ..setMediaPlaybackRequiresUserGesture(false)
        ..setOnShowFileSelector((params) async {
          return [];
        });
    }

    if (embedUrl != null) {
      _webViewController.loadRequest(Uri.parse(embedUrl));
    }
  }

  /// Thử tự động play video
  Future<void> _tryAutoPlay() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    
    try {
      await _webViewController.runJavaScript('''
        (function() {
          try {
            var iframe = document.querySelector('iframe');
            if (iframe && iframe.contentWindow) {
              iframe.contentWindow.postMessage('{"type":"play"}', '*');
            }
            var video = document.querySelector('video');
            if (video) {
              video.play().catch(function(e) {
                console.log('Play prevented:', e);
              });
            }
          } catch(e) {
            console.log('Auto-play error:', e);
          }
        })();
      ''');
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _openTikTok() async {
    // Khi click play button, hiển thị WebView trong app
    setState(() {
      _showWebView = true;
      _isLoading = true;
    });
    
    // Reload WebView nếu cần
    final embedUrl = _tiktokService.getEmbedUrl(widget.video.tiktokUrl, autoplay: true);
    if (embedUrl != null) {
      _webViewController.loadRequest(Uri.parse(embedUrl));
    }
  }

  Future<void> _openTikTokInBrowser() async {
    // Mở video TikTok trong trình duyệt ngoài
    try {
      final url = Uri.parse(widget.video.tiktokUrl);
      
      // Thử mở TikTok app trước (nếu có)
      final tiktokAppUrl = url.toString().replaceFirst('https://www.tiktok.com', 'tiktok://');
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
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
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
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: widget.onBack,
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
                          // WebView để play video TikTok
                          if (_showWebView)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: WebViewWidget(controller: _webViewController),
                            )
                          else
                            // Thumbnail background (hiển thị trước khi play)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                widget.video.thumbnailUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey.shade900,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
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
                          // Play button overlay (chỉ hiển thị khi chưa show WebView)
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
                                      color: Colors.pink.shade600.withOpacity(0.95),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.pink.shade600.withOpacity(0.6),
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
                      top: BorderSide(
                        color: Colors.grey.shade800,
                        width: 1,
                      ),
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _openTikTokInBrowser,
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
                              Icon(Icons.open_in_new, color: Colors.white, size: 24),
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
                          'Tap the play button above to watch',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
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
}
