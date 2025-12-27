import 'package:flutter_ads_native/rewarded_ads/rewarded_ads.dart';
import 'package:say_word_challenge/common/utils/share_pref_utils.dart';
import 'package:say_word_challenge/services/remote_config_service.dart';

import '../common/logger/app_logger.dart' show AppLogger;
/// Controller for managing rewarded ads.
/// All reward handling is done in native code via callbacks.
final _showRewardCountPerDay = "_showRewardCountPerDay";

class RewardedAdsController {
  RewardedAdsController._();

  static int _showRewardCountSession = 0; // Số lần show reward trong session
  static int _showRewardCount = 0; // Số lần show reward trong ngày hôm nay
  static final RewardedAdsController instance = RewardedAdsController._();

  /// Shows a rewarded ad.
  /// Returns true if ad was shown, false otherwise.
  /// Reward handling is done via NativeAds callbacks set up in main.dart
  /// 
  /// Kiểm tra điều kiện trước khi show:
  /// 1. Đã show hết số lần cho phép trong session hiện tại của app hay chưa
  /// 2. Đã show hết số lần cho phép trong ngày hay chưa
  Future<bool> showRewardedAd() async {
    try {
      // Lấy thông tin từ local với format: timestamp-count
      final _localShowRewardPerday =
          await PrefUtils().getDataString(_showRewardCountPerDay);
      int _localTimeStamp = 0;
      int _localRewardCount = 0;

      if (_localShowRewardPerday?.isNotEmpty == true) {
        try {
          final split = _localShowRewardPerday!.split("-");
          if (split.length == 2) {
            _localTimeStamp = int.parse(split[0]);
            _localRewardCount = int.parse(split[1]);
          }
        } catch (e) {
          AppLogger.w('Error parsing local show reward data: $e');
        }
      }

      // Kiểm tra xem timestamp có phải là hôm nay không
      if (_localTimeStamp > 0) {
        final lastestShow =
            DateTime.fromMillisecondsSinceEpoch(_localTimeStamp);
        if (_isToDay(lastestShow)) {
          // Nếu là hôm nay, dùng số lần đã show
          _showRewardCount = _localRewardCount;
        } else {
          // Nếu không phải hôm nay, reset về 0
          _showRewardCount = 0;
        }
      } else {
        // Nếu không có dữ liệu, reset về 0
        _showRewardCount = 0;
      }

      // Kiểm tra điều kiện show
      // 1. Kiểm tra số lần show trong session
      final isMaxedInSession = _showRewardCountSession >=
          RemoteConfigService.instance.rewardMaxPerSession;
      // 2. Kiểm tra số lần show trong ngày
      final isMaxedInDay =
          _showRewardCount >= RemoteConfigService.instance.rewardMaxPerDay;

      if (isMaxedInSession) {
        AppLogger.w(
            'Rewarded ad maxed in session: $_showRewardCountSession/${RemoteConfigService.instance.rewardMaxPerSession}');
        return false;
      }

      if (isMaxedInDay) {
        AppLogger.w(
            'Rewarded ad maxed in day: $_showRewardCount/${RemoteConfigService.instance.rewardMaxPerDay}');
        return false;
      }

      // Check if ad is ready
      final isReady = await RewardedAds.isRewardedReady();
      if (!isReady) {
        AppLogger.w('Rewarded ad is not ready, attempting to load...');
        // Try to load it
        await RewardedAds.loadRewarded();
        return false;
      }

      // Show the ad
      final shown = await RewardedAds.showRewarded();
      if (!shown) {
        AppLogger.w('Failed to show rewarded ad');
        return false;
      }

      // Update session count
      _showRewardCountSession++;

      // Update daily count và lưu vào local với format: timestamp-count
      _showRewardCount++;
      final now = DateTime.now().millisecondsSinceEpoch;
      final savedValue = "$now-$_showRewardCount";
      await PrefUtils().saveString(_showRewardCountPerDay, savedValue);

      AppLogger.i(
          'Rewarded ad shown successfully. Session count: $_showRewardCountSession, Daily count: $_showRewardCount');
      return true;
    } catch (e) {
      AppLogger.e('Error showing rewarded ad', error: e);
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

