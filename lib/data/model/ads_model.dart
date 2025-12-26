import 'package:flutter_ads_native/ad_data.dart';

class AdsModel {
  List<BannerModel>? banner;
  List<NativeModel>? native;
  Inter? inter;
  Reward? reward;
  RewardInter? rewardInter;
  bool? shouldShowRewardInter;

  AdsModel(
      {this.banner,
      this.native,
      this.inter,
      this.reward,
      this.rewardInter,
      this.shouldShowRewardInter});

  AdsModel.fromJson(Map<String, dynamic> json) {
    if (json['banner'] != null) {
      banner = <BannerModel>[];
      json['banner'].forEach((v) {
        banner!.add(BannerModel.fromJson(v));
      });
    }
    if (json['native'] != null) {
      native = <NativeModel>[];
      json['native'].forEach((v) {
        native!.add(NativeModel.fromJson(v));
      });
    }
    inter = json['inter'] != null ? Inter.fromJson(json['inter']) : null;
    reward = json['reward'] != null ? Reward.fromJson(json['reward']) : null;
    shouldShowRewardInter = json['shouldShowRewardInter'] == true;
    rewardInter = json['rewardInter'] != null
        ? RewardInter.fromJson(json['rewardInter'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (banner != null) {
      data['banner'] = banner!.map((v) => v.toJson()).toList();
    }
    if (native != null) {
      data['native'] = native!.map((v) => v.toJson()).toList();
    }
    if (inter != null) {
      data['inter'] = inter!.toJson();
    }
    if (reward != null) {
      data['reward'] = reward!.toJson();
    }
    if (rewardInter != null) {
      data['rewardInter'] = rewardInter!.toJson();
    }
    if (shouldShowRewardInter != null) {
      data["shouldShowRewardInter"] = shouldShowRewardInter;
    }
    return data;
  }
}

class BannerNativeModel {
  String? screenName;
  String? adUnitId;
  bool? isShow;

  BannerNativeModel({this.screenName, this.adUnitId, this.isShow});
}

class BannerModel extends BannerNativeModel {
  AdBannerSize? size;

  BannerModel({super.screenName, super.adUnitId, super.isShow, this.size});

  BannerModel.fromJson(Map<String, dynamic> json) {
    screenName = json['screenName'];
    adUnitId = json['adUnitId'];
    isShow = json['isShow'];
    final sizeValue = json['size'];
    if (sizeValue != null) {
      size = AdBannerSize.values.firstWhere(
        (e) => e.name == sizeValue,
        orElse: () => AdBannerSize.BANNER, // default an toàn
      );
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['screenName'] = screenName;
    data['adUnitId'] = adUnitId;
    data['isShow'] = isShow;
    data['size'] = size?.name;
    return data;
  }
}

class NativeModel extends BannerNativeModel {
  AdNativeSize? size;

  NativeModel({super.screenName, super.adUnitId, super.isShow, this.size});

  NativeModel.fromJson(Map<String, dynamic> json) {
    screenName = json['screenName'];
    adUnitId = json['adUnitId'];
    isShow = json['isShow'];
    final sizeValue = json['size'];
    if (sizeValue != null) {
      size = AdNativeSize.values.firstWhere(
        (e) => e.name == sizeValue,
        orElse: () => AdNativeSize.NATIVE_FULL_BANNER, // default an toàn
      );
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['screenName'] = screenName;
    data['adUnitId'] = adUnitId;
    data['isShow'] = isShow;
    data['size'] = size?.name;
    return data;
  }
}

class Inter {
  List<String>? adUnitIds;
  int? showRateTime;
  int? interMaxPerSession;
  int? interMinSecondsBetween;
  int? interMaxPerDay;
  int? interMinActionBetween;

  Inter(
      {this.adUnitIds,
      this.showRateTime,
      this.interMaxPerSession,
      this.interMinSecondsBetween,
      this.interMaxPerDay,
      this.interMinActionBetween});

  Inter.fromJson(Map<String, dynamic> json) {
    adUnitIds = json['adUnitIds'].cast<String>();
    showRateTime = json['showRateTime'];
    interMaxPerSession = json['interMaxPerSession'];
    interMinSecondsBetween = json['interMinSecondsBetween'];
    interMaxPerDay = json['interMaxPerDay'];
    interMinActionBetween = json['interMinActionBetween'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['adUnitIds'] = adUnitIds;
    data['showRateTime'] = showRateTime;
    data['interMaxPerSession'] = interMaxPerSession;
    data['interMinSecondsBetween'] = interMinSecondsBetween;
    data['interMaxPerDay'] = interMaxPerDay;
    data['interMinActionBetween'] = interMinActionBetween;
    return data;
  }
}

class Reward {
  List<String>? adUnitIds;
  int? rewardMaxPerSession;
  int? rewardMaxPerDay;

  Reward({this.adUnitIds, this.rewardMaxPerSession, this.rewardMaxPerDay});

  Reward.fromJson(Map<String, dynamic> json) {
    adUnitIds = json['adUnitIds'].cast<String>();
    rewardMaxPerSession = json['rewardMaxPerSession'];
    rewardMaxPerDay = json['rewardMaxPerDay'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['adUnitIds'] = this.adUnitIds;
    data['rewardMaxPerSession'] = this.rewardMaxPerSession;
    data['rewardMaxPerDay'] = this.rewardMaxPerDay;
    return data;
  }
}

class RewardInter {
  List<String>? adUnitIds;
  int? rewardInterMaxPerSession;
  int? rewardInterMaxPerDay;

  RewardInter(
      {this.adUnitIds,
      this.rewardInterMaxPerSession,
      this.rewardInterMaxPerDay});

  RewardInter.fromJson(Map<String, dynamic> json) {
    adUnitIds = json['adUnitIds'].cast<String>();
    rewardInterMaxPerSession = json['rewardInterMaxPerSession'];
    rewardInterMaxPerDay = json['rewardInterMaxPerDay'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['adUnitIds'] = this.adUnitIds;
    data['rewardInterMaxPerSession'] = this.rewardInterMaxPerSession;
    data['rewardInterMaxPerDay'] = this.rewardInterMaxPerDay;
    return data;
  }
}
