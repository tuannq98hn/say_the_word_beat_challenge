import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ad_data.dart';

class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({super.key, required this.data, this.onCloseAd});

  final AdNativeData data;
  final void Function()? onCloseAd;

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  static const _methodChannel = MethodChannel(
    "com.example.flutter_native_ad.native_method_channel",
  );
  static const _eventChannel = EventChannel(
    "com.example.flutter_native_ad.native_event_channel",
  );
  StreamSubscription<dynamic>? _eventSubscription;
  bool _adFailed = false;

  @override
  void initState() {
    super.initState();
    _methodChannel.setMethodCallHandler(_methodHandler);
    _startListening();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _methodChannel.setMethodCallHandler(null);
    super.dispose();
  }

  void _startListening() {
    _eventSubscription?.cancel();
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is Map) {
          final eventType = event['event'] as String?;

          if (eventType == "ads_custom_view_failed") {
            if (mounted) {
              setState(() {
                _adFailed = true;
              });
            }
          } else if (eventType == "ads_custom_view_closed") {
            widget.onCloseAd?.call();
          }
        }
      },
      onError: (error) {
        debugPrint('NativeAdWidget event stream error: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // If ad failed to load or closed, return container with height 0
    if (_adFailed) {
      return const SizedBox(height: 0);
    }

    return Container(
      color: widget.data.size == AdNativeSize.FULL_SCREEN
          ? Color(0xFF353535)
          : null,
      padding: widget.data.size == AdNativeSize.FULL_SCREEN
          ? EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              bottom: MediaQuery.of(context).padding.bottom,
            )
          : null,
      constraints: BoxConstraints(
        maxHeight: widget.data.size.adHeight.toDouble(),
      ),
      child: AndroidView(
        viewType: "ads_native_view",
        layoutDirection: TextDirection.ltr,
        creationParams: widget.data.toJson(),
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }

  Future<dynamic> _methodHandler(MethodCall call) async {
    print("_methodHandler");
  }
}
