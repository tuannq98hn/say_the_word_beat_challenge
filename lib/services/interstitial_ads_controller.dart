import 'package:flutter_ads_native/interstitial_ads/interstitial_ads.dart';
import 'package:say_word_challenge/common/logger/app_logger.dart';
import 'package:say_word_challenge/common/utils/share_pref_utils.dart';
import 'package:say_word_challenge/services/remote_config_service.dart';

/// Controller for managing interstitial ads.
/// All ad event handling is done in native code via callbacks.
final _showInterCountPerDay = "_showInterCountPerDay";

class InterstitialAdsController {
  InterstitialAdsController._();

  static int _showInterCountSession = 0;
  static int _lastestTimeShowSession = 0;
  static int _showInterCount = 0; // Số lần show inter trong ngày hôm nay
  static final InterstitialAdsController instance =
      InterstitialAdsController._();

  /// Shows an interstitial ad.
  /// Returns true if ad was shown, false otherwise.
  /// Ad event handling is done via NativeAds callbacks set up in main.dart
  Future<bool> showInterstitialAd({
    String? screenClass,
    String? callerFunction,
  }) async {
    try {
      // Check conditions in Kotlin
      // 1. đã đạt đến số lượng max trong session chưa?
      // 2. Đã đạt đến số lượng max trong ngày chưa?
      // 3. Thời gian từ lần show inter trước đến bây giờ đã đủ thời gian ( remote config là 90s) chưa?
      // 4. Số lần gọi inter đến lần thứ 3 chưa? Ví dụ: lần bấm end call gọi inter đã show 1 lần. lần 2 , lần 3 gọi sẽ không show, lần thứ 4 mới show.

      // Lấy thông tin từ local với format: timestamp-count
      final _localShowInterPerday = await PrefUtils().getDataString(
        _showInterCountPerDay,
      );
      int _localTimeStamp = 0;
      int _localInterCount = 0;

      if (_localShowInterPerday?.isNotEmpty == true) {
        try {
          final split = _localShowInterPerday!.split("-");
          if (split.length == 2) {
            _localTimeStamp = int.parse(split[0]);
            _localInterCount = int.parse(split[1]);
          }
        } catch (e) {
          AppLogger.w('Error parsing local show inter data: $e');
        }
      }

      // Kiểm tra xem timestamp có phải là hôm nay không
      if (_localTimeStamp > 0) {
        final lastestShow = DateTime.fromMillisecondsSinceEpoch(
          _localTimeStamp,
        );
        if (_isToDay(lastestShow)) {
          // Nếu là hôm nay, dùng số lần đã show
          _showInterCount = _localInterCount;
        } else {
          // Nếu không phải hôm nay, reset về 0
          _showInterCount = 0;
        }
      } else {
        // Nếu không có dữ liệu, reset về 0
        _showInterCount = 0;
      }

      final isMaxedInSession =
          _showInterCountSession >=
          RemoteConfigService.instance.maxInterShowInSession;
      final isMaxedInDay =
          _showInterCount >= RemoteConfigService.instance.interMaxPerDay;
      final isTimePassed =
          DateTime.now().millisecondsSinceEpoch - _lastestTimeShowSession >=
          RemoteConfigService.instance.interMinSecondsBetween * 1000;
      final isMinActionBetween =
          _showInterCountSession %
              RemoteConfigService.instance.interMinActionBetween !=
          0;
      final isCanShow =
          !isMaxedInSession &&
          !isMaxedInDay &&
          isTimePassed &&
          !isMinActionBetween;
      // Check if ad is ready
      final isReady = await InterstitialAds.isInterstitialReady();
      if (!isReady) {
        AppLogger.w('Interstitial ad is not ready, attempting to load...');
        // Try to load it
        if (!isReady) {
          await InterstitialAds.loadInterstitial();
        }
        return false;
      }
      if(!isCanShow){
        return false;
      }
      // Show the ad
      final shown = await InterstitialAds.showInterstitial(
        screenClass: screenClass,
        callerFunction: callerFunction,
      );
      if (!shown) {
        AppLogger.w('Failed to show interstitial ad');
        return false;
      }

      // Update session count và timestamp
      _showInterCountSession++;
      _lastestTimeShowSession = DateTime.now().millisecondsSinceEpoch;

      // Update daily count và lưu vào local với format: timestamp-count
      _showInterCount++;
      final now = DateTime.now().millisecondsSinceEpoch;
      final savedValue = "$now-$_showInterCount";
      await PrefUtils().saveString(_showInterCountPerDay, savedValue);

      AppLogger.i(
        'Interstitial ad shown successfully. Daily count: $_showInterCount',
      );
      return true;
    } catch (e) {
      AppLogger.e('Error showing interstitial ad', error: e);
      return false;
    }
  }

  bool _isToDay(DateTime time) {
    final now = DateTime.now();
    return time.year == now.year &&
        time.month == now.month &&
        time.day == now.day;
  }
}
