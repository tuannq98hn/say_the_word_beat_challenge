import 'package:flutter_ads_native/index.dart';
import 'package:say_word_challenge/common/logger/app_logger.dart';
import 'package:say_word_challenge/common/utils/share_pref_utils.dart';
import 'package:say_word_challenge/services/remote_config_service.dart';

/// Controller for managing rewarded interstitial ads.
/// All reward handling is done in native code via callbacks.
final _showRewardInterCountPerDay = "_showRewardInterCountPerDay";

class RewardedInterstitialAdsController {
  RewardedInterstitialAdsController._();

  static int _showRewardInterCountSession =
      0; // Số lần show reward inter trong session
  static int _showRewardInterCount =
      0; // Số lần show reward inter trong ngày hôm nay
  static final RewardedInterstitialAdsController instance =
      RewardedInterstitialAdsController._();

  /// Shows a rewarded interstitial ad.
  /// Returns true if ad was shown, false otherwise.
  /// Reward handling is done via NativeAds callbacks set up in main.dart
  ///
  /// Kiểm tra điều kiện trước khi show:
  /// 1. Đã show hết số lần cho phép trong session hiện tại của app hay chưa
  /// 2. Đã show hết số lần cho phép trong ngày hay chưa
  Future<bool> showRewardedInterstitialAd({
    String? screenClass,
    String? callerFunction,
  }) async {
    try {
      // Lấy thông tin từ local với format: timestamp-count
      final _localShowRewardInterPerday = await PrefUtils().getDataString(
        _showRewardInterCountPerDay,
      );
      int _localTimeStamp = 0;
      int _localRewardInterCount = 0;

      if (_localShowRewardInterPerday?.isNotEmpty == true) {
        try {
          final split = _localShowRewardInterPerday!.split("-");
          if (split.length == 2) {
            _localTimeStamp = int.parse(split[0]);
            _localRewardInterCount = int.parse(split[1]);
          }
        } catch (e) {
          AppLogger.w('Error parsing local show reward inter data: $e');
        }
      }

      // Kiểm tra xem timestamp có phải là hôm nay không
      if (_localTimeStamp > 0) {
        final lastestShow = DateTime.fromMillisecondsSinceEpoch(
          _localTimeStamp,
        );
        if (_isToDay(lastestShow)) {
          // Nếu là hôm nay, dùng số lần đã show
          _showRewardInterCount = _localRewardInterCount;
        } else {
          // Nếu không phải hôm nay, reset về 0
          _showRewardInterCount = 0;
        }
      } else {
        // Nếu không có dữ liệu, reset về 0
        _showRewardInterCount = 0;
      }

      // Kiểm tra điều kiện show
      // 1. Kiểm tra số lần show trong session
      final isMaxedInSession =
          _showRewardInterCountSession >=
          RemoteConfigService.instance.rewardInterMaxPerSession;
      // 2. Kiểm tra số lần show trong ngày
      final isMaxedInDay =
          _showRewardInterCount >=
          RemoteConfigService.instance.rewardInterMaxPerDay;

      if (isMaxedInSession) {
        AppLogger.w(
          'Rewarded interstitial ad maxed in session: $_showRewardInterCountSession/${RemoteConfigService.instance.rewardInterMaxPerSession}',
        );
        return false;
      }

      if (isMaxedInDay) {
        AppLogger.w(
          'Rewarded interstitial ad maxed in day: $_showRewardInterCount/${RemoteConfigService.instance.rewardInterMaxPerDay}',
        );
        return false;
      }

      // Check if ad is ready
      final isReady =
          await RewardedInterstitialAds.isRewardedInterstitialReady();
      if (!isReady) {
        AppLogger.w(
          'Rewarded interstitial ad is not ready, attempting to load...',
        );
        // Try to load it
        await RewardedInterstitialAds.loadRewardedInterstitial();
        return false;
      }

      // Show the ad
      final shown = await RewardedInterstitialAds.showRewardedInterstitial(
        screenClass: screenClass,
        callerFunction: callerFunction,
      );
      if (!shown) {
        AppLogger.w('Failed to show rewarded interstitial ad');
        return false;
      }

      // Update session count
      _showRewardInterCountSession++;

      // Update daily count và lưu vào local với format: timestamp-count
      _showRewardInterCount++;
      final now = DateTime.now().millisecondsSinceEpoch;
      final savedValue = "$now-$_showRewardInterCount";
      await PrefUtils().saveString(_showRewardInterCountPerDay, savedValue);

      AppLogger.i(
        'Rewarded interstitial ad shown successfully. Session count: $_showRewardInterCountSession, Daily count: $_showRewardInterCount',
      );
      return true;
    } catch (e) {
      AppLogger.e('Error showing rewarded interstitial ad', error: e);
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
