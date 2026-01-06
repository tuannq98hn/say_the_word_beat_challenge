import 'dart:async';

import 'package:flutter/services.dart';

import 'ads_session_tracker.dart';

/// Listens directly to the plugin EventChannels (broadcast) so we can track ads
/// without interfering with existing callback overrides in UI code.
class AdsEventListener {
  AdsEventListener._();

  static const EventChannel _interstitialEvents = EventChannel(
    'com.example.flutter_native_ad.interstitial_event_channel',
  );
  static const EventChannel _rewardedEvents = EventChannel(
    'com.example.flutter_native_ad.rewarded_event_channel',
  );
  static const EventChannel _rewardedInterstitialEvents = EventChannel(
    'com.example.flutter_native_ad.rewarded_interstitial_event_channel',
  );
  static const EventChannel _nativeEvents = EventChannel(
    'com.example.flutter_native_ad.native_event_channel',
  );
  static const EventChannel _bannerEvents = EventChannel(
    'com.example.flutter_native_ad.banner_event_channel',
  );

  static StreamSubscription<dynamic>? _s1;
  static StreamSubscription<dynamic>? _s2;
  static StreamSubscription<dynamic>? _s3;
  static StreamSubscription<dynamic>? _s4;
  static StreamSubscription<dynamic>? _s5;

  static bool _started = false;

  static void start() {
    if (_started) return;
    _started = true;

    _s1 = _interstitialEvents.receiveBroadcastStream().listen(_handleEvent);
    _s2 = _rewardedEvents.receiveBroadcastStream().listen(_handleEvent);
    _s3 = _rewardedInterstitialEvents.receiveBroadcastStream().listen(_handleEvent);
    _s4 = _nativeEvents.receiveBroadcastStream().listen(_handleEvent);
    _s5 = _bannerEvents.receiveBroadcastStream().listen(_handleEvent);
  }

  static void stop() {
    _s1?.cancel();
    _s2?.cancel();
    _s3?.cancel();
    _s4?.cancel();
    _s5?.cancel();
    _s1 = null;
    _s2 = null;
    _s3 = null;
    _s4 = null;
    _s5 = null;
    _started = false;
  }

  static void _handleEvent(dynamic event) {
    if (event is! Map) return;
    final eventType = event['event'] as String?;
    if (eventType == null) return;

    switch (eventType) {
      case 'interstitial_shown':
        AdsSessionTracker.onInterstitialShown();
        break;
      case 'rewarded_shown':
        AdsSessionTracker.onRewardedShown();
        break;
      case 'rewarded_interstitial_shown':
        AdsSessionTracker.onRewardedInterstitialShown();
        break;
      case 'banner_impression':
        AdsSessionTracker.onBannerImpression();
        break;
      case 'native_impression':
        AdsSessionTracker.onNativeImpression();
        break;
    }
  }
}


