import 'package:flutter/material.dart';
import 'ad_data.dart';
import 'banner_ad_widget.dart';
import 'native_ad_widget.dart';

/// Widget tổng hợp để hiển thị banner hoặc native ads
/// @deprecated Sử dụng [BannerAdWidget] hoặc [NativeAdWidget] thay thế
class AdsCustomViewWidget extends StatelessWidget {
  const AdsCustomViewWidget({super.key, required this.data});

  final AdData data;

  @override
  Widget build(BuildContext context) {
    if (data is AdBannerData) {
      return BannerAdWidget(data: data as AdBannerData);
    }
    if (data is AdNativeData) {
      return NativeAdWidget(data: data as AdNativeData);
    }
    return const SizedBox.shrink();
  }
}

