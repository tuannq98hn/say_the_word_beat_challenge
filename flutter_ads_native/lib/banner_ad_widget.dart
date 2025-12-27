import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ad_data.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key, required this.data});

  final AdBannerData data;

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  static const _methodChannel = MethodChannel(
    "com.example.flutter_native_ad.banner_method_channel",
  );
  static const _eventChannel = EventChannel(
    "com.example.flutter_native_ad.banner_event_channel",
  );
  StreamSubscription<dynamic>? _eventSubscription;
  bool _adFailed = false;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _startListening() {
    _eventSubscription?.cancel();
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is Map) {
          final eventType = event['event'] as String?;
          final data = event['data'] as Map<dynamic, dynamic>?;

          if (eventType == "ads_custom_view_failed") {
            if (mounted) {
              setState(() {
                _adFailed = true;
              });
            }
          }
        }
      },
      onError: (error) {
        debugPrint('BannerAdWidget event stream error: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // If ad failed to load, return container with height 0
    if (_adFailed) {
      return const SizedBox(height: 0);
    }

    double adHeight = widget.data.size.adHeight;
    return Container(
      constraints: BoxConstraints(maxHeight: adHeight.toDouble()),
      child: AndroidView(
        viewType: "ads_banner_view",
        layoutDirection: TextDirection.ltr,
        creationParams: widget.data.toJson(),
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }
}
