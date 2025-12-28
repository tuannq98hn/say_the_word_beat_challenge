abstract class AdData {
  final String adUnitId;

  AdData({required this.adUnitId});

  Map<String, dynamic> toJson();
}

enum AdBannerSize {
  LARGE_BANNER,
  BANNER,
  MEDIUM_RECTANGLE,
  FULL_BANNER,
  LEADERBOARD;

  double get adHeight => switch (this) {
    AdBannerSize.LARGE_BANNER => 100,
    AdBannerSize.BANNER => 50,
    AdBannerSize.MEDIUM_RECTANGLE => 250,
    AdBannerSize.FULL_BANNER => 60,
    AdBannerSize.LEADERBOARD => 90,
  };
}

enum AdNativeSize {
  FULL_SCREEN,
  NATIVE_MEDIUM_RECTANGLE,
  NATIVE_FULL_BANNER,
  NATIVE_LARGE;

  double get adHeight => switch (this) {
    AdNativeSize.FULL_SCREEN => double.infinity,
    AdNativeSize.NATIVE_MEDIUM_RECTANGLE => 270,
    AdNativeSize.NATIVE_FULL_BANNER => 80,
    AdNativeSize.NATIVE_LARGE => 120,
  };
}

class AdBannerData extends AdData {
  final AdBannerSize size;

  AdBannerData({required this.size, required super.adUnitId});

  @override
  Map<String, dynamic> toJson() {
    return {"size": size.name, "adUnitId": adUnitId};
  }
}

class AdNativeData extends AdData {
  final AdNativeSize size;

  AdNativeData({required super.adUnitId, required this.size});

  @override
  Map<String, dynamic> toJson() {
    return {"adUnitId": adUnitId, "size": size.name};
  }
}
