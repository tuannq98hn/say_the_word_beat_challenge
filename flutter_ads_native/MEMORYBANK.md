# Flutter Ads Native - Memory Bank

## Tổng quan

`flutter_ads_native` là một Flutter plugin hỗ trợ nhiều loại quảng cáo native cho Android (và iOS). Module được thiết kế với kiến trúc modular, tách biệt các loại ads và sử dụng pattern platform interface để dễ mở rộng và bảo trì.

**Module Structure:**
- Mỗi loại ads có folder riêng trong `lib/` với 3 files: platform_interface, method_channel, và main class
- Tất cả modules sử dụng cùng pattern: EventChannel cho events, MethodChannel cho method calls
- Native side sử dụng Handler pattern với factory functions để tạo handlers

## Kiến trúc tổng thể

### 1. Cấu trúc thư mục

```
flutter_ads_native/
├── lib/                          # Flutter/Dart code
│   ├── interstitial_ads/         # Interstitial ads module
│   ├── rewarded_ads/             # Rewarded ads module
│   ├── rewarded_interstitial_ads/ # Rewarded interstitial ads module
│   ├── ad_data.dart              # Data models cho banner/native ads
│   ├── banner_ad_widget.dart     # Banner widget
│   ├── native_ad_widget.dart     # Native ad widget
│   └── ad_custom_view_widget.dart # Legacy wrapper widget
│
└── android/src/main/kotlin/com/example/flutter_ads_native/
    ├── AdNativeManager.kt        # Quản lý tất cả plugins
    ├── FlutterAdsNativePlugin.kt # Main plugin entry point
    ├── AdsEventStreamHandler.kt  # Event handler cho EventChannel
    ├── banner_native/            # Banner & Native ads
    │   ├── banner/
    │   │   ├── BannerView.kt
    │   │   └── BannerViewFactory.kt
    │   └── native/
    │       ├── NativeCardView.kt
    │       └── NativeCardViewFactory.kt
    └── inter_reward/             # Interstitial & Rewarded ads
        ├── admob/                # AdMob providers
        ├── InterstitialAdHandler.kt
        ├── RewardedAdHandler.kt
        ├── RewardedInterstitialAdHandler.kt
        ├── BannerAdHandler.kt
        ├── NativeAdHandler.kt
        └── MyCustomAdManager.kt  # Quản lý ad providers
```

## 2. Các loại Ads được hỗ trợ

Module hỗ trợ 5 loại ads:

1. **NATIVE** - Native ads (hiển thị như content)
2. **BANNER** - Banner ads (hiển thị ở top/bottom)
3. **INTERSTITIAL** - Full-screen ads giữa các màn hình
4. **REWARDED** - Rewarded video ads (người dùng nhận thưởng)
5. **REWARDED_INTERSTITIAL** - Rewarded interstitial ads

## 3. Channel Names

### Method Channels

| Ad Type | Method Channel |
|---------|---------------|
| Native | `com.example.flutter_native_ad.native_method_channel` |
| Banner | `com.example.flutter_native_ad.banner_method_channel` |
| Interstitial | `com.example.flutter_native_ad.interstitial_method_channel` |
| Rewarded | `com.example.flutter_native_ad.rewarded_method_channel` |
| Rewarded Interstitial | `com.example.flutter_native_ad.rewarded_interstitial_method_channel` |

### Method Names (cho MethodChannel.invokeMethod)

**Interstitial Ads:**
- `ads_init` - Initialize và preload ads (args: `interstitialAdUnitIds`)
- `ads_load_interstitial` - Load ad manually
- `ads_is_interstitial_ready` - Check ready status (returns bool)
- `ads_show_interstitial` - Show ad (returns bool)

**Rewarded Ads:**
- `ads_init` - Initialize và preload ads (args: `rewardedAdUnitIds`)
- `ads_load_rewarded` - Load ad manually
- `ads_is_rewarded_ready` - Check ready status (returns bool)
- `ads_show_rewarded` - Show ad (returns bool)

**Rewarded Interstitial Ads:**
- `ads_init` - Initialize và preload ads (args: `rewardedInterstitialAdUnitIds`)
- `ads_load_rewarded_interstitial` - Load ad manually
- `ads_is_rewarded_interstitial_ready` - Check ready status (returns bool)
- `ads_show_rewarded_interstitial` - Show ad (returns bool)

### Event Channels

| Ad Type | Event Channel |
|---------|--------------|
| Native | `com.example.flutter_native_ad.native_event_channel` |
| Banner | `com.example.flutter_native_ad.banner_event_channel` |
| Interstitial | `com.example.flutter_native_ad.interstitial_event_channel` |
| Rewarded | `com.example.flutter_native_ad.rewarded_event_channel` |
| Rewarded Interstitial | `com.example.flutter_native_ad.rewarded_interstitial_event_channel` |

### Platform View Types

| Ad Type | View Type |
|---------|-----------|
| Banner | `ads_banner_view` |
| Native | `ads_native_view` |

## 4. Kiến trúc Android (Kotlin)

### AdNativeManager

Quản lý trung tâm tất cả các plugins. Sử dụng `adsMap` để map từ `AdNativeAdsType` đến các plugin tương ứng.

**Chức năng chính:**
- `attachToEngine()` - Attach tất cả plugins vào Flutter engine
- `onDetachedFromEngine()` - Detach tất cả plugins
- `setActivity()` - Set Activity cho tất cả plugins (từ ActivityAware)
- `getAdNativeInterface()` - Lấy plugin theo loại ads

### AdNativeInterface (Abstract Class)

Base class cho tất cả plugins:
- `methodChannelName` - Tên method channel
- `eventChannelName` - Tên event channel
- `activity` - Activity hiện tại (nullable)
- Lifecycle methods: `onAttachedToEngine()`, `onDetachedFromEngine()`, `onAttachedToActivity()`, `onDetachedFromActivity()`

### AdHandlerPlugin<T> (Generic Abstract Class)

Base class cho các plugins sử dụng handler:
- Generic type `T : MethodChannel.MethodCallHandler`
- Sử dụng factory function để tạo handler
- Tự động quản lý MethodChannel, EventChannel, và Handler lifecycle
- Được sử dụng bởi: `AdInterstitialPlugin`, `AdRewardPlugin`, `AdRewardInterstitialPlugin`

**Lifecycle:**
1. `onAttachedToEngine`: Setup MethodChannel, EventChannel, và AdsEventStreamHandler
2. `onAttachedToActivity`: Tạo handler instance và gắn vào MethodChannel
3. `onDetachedFromActivity`: Xóa handler và clear MethodChannel handler
4. `onDetachedFromEngine`: Cleanup tất cả resources

### FlutterAdsNativePlugin

Main plugin class implement `FlutterPlugin` và `ActivityAware`:
- `onAttachedToEngine()` - Gọi `AdNativeManager.attachToEngine()`
- `onAttachedToActivity()` - Gọi `AdNativeManager.setActivity()`
- Xử lý Activity lifecycle changes (config changes, detach, reattach)

### Handler Classes

Mỗi loại ads có handler riêng xử lý method calls:

#### InterstitialAdHandler
**Methods:**
- `ads_init` - Khởi tạo và preload interstitial ads
- `ads_load_interstitial` - Load interstitial ad
- `ads_is_interstitial_ready` - Kiểm tra ad đã sẵn sàng
- `ads_show_interstitial` - Hiển thị interstitial ad
- `ads_record_action` - Ghi nhận action (cho điều kiện hiển thị)
- `ads_can_show_interstitial` - Kiểm tra có thể hiển thị
- `ads_record_interstitial_shown` - Ghi nhận đã hiển thị
- `ads_reset_interstitial_session` - Reset session

#### RewardedAdHandler
**Methods:**
- `ads_init` - Khởi tạo và preload rewarded ads
- `ads_load_rewarded` - Load rewarded ad
- `ads_is_rewarded_ready` - Kiểm tra ad đã sẵn sàng
- `ads_show_rewarded` - Hiển thị rewarded ad

#### RewardedInterstitialAdHandler
**Methods:**
- `ads_init` - Khởi tạo và preload rewarded interstitial ads
- `ads_load_rewarded_interstitial` - Load rewarded interstitial ad
- `ads_is_rewarded_interstitial_ready` - Kiểm tra ad đã sẵn sàng
- `ads_show_rewarded_interstitial` - Hiển thị rewarded interstitial ad

#### BannerAdHandler & NativeAdHandler
Hiện tại chỉ implement `result.notImplemented()` - chờ implement trong tương lai.

### MyCustomAdManager

Singleton object quản lý ad providers. Ẩn đi:
- Platform mediation nào được sử dụng (AdMob, MAX, etc.)
- Implementation chi tiết của mỗi loại ad

**Providers:**
- `interstitialProvider: InterstitialAdProvider`
- `rewardedProvider: RewardedAdProvider`
- `rewardedInterstitialProvider: RewardedInterstitialAdProvider`

**Chức năng:**
- `setInterstitialAdUnitIds()` - Set ad unit IDs với rotation support
- `setRewardedAdUnitIds()` - Set rewarded ad unit IDs
- `setRewardedInterstitialAdUnitIds()` - Set rewarded interstitial ad unit IDs
- `preloadInterstitial()`, `preloadRewarded()`, `preloadRewardedInterstitial()` - Preload ads
- `showInterstitial()`, `showRewarded()`, `showRewardedInterstitial()` - Show ads
- `isInterstitialReady()`, `isRewardedReady()`, `isRewardedInterstitialReady()` - Check ready status

### AdsEventStreamHandler

Xử lý EventChannel để gửi events từ native về Flutter:

**Events:**
- `interstitial_loaded`, `interstitial_shown`, `interstitial_closed`, `interstitial_failed`
- `rewarded_loaded`, `rewarded_shown`, `rewarded_closed`, `rewarded_failed`, `rewarded_earned`
- `rewarded_interstitial_loaded`, `rewarded_interstitial_shown`, `rewarded_interstitial_closed`, `rewarded_interstitial_failed`, `rewarded_interstitial_earned`

**Method:**
- `sendEvent(eventType: String, data: Map<String, Any?>?)` - Gửi event với data tùy chọn

### Banner & Native Ads

#### BannerViewFactory & NativeCardViewFactory
Tạo PlatformView instances cho banner và native ads.

#### BannerView
PlatformView hiển thị banner ads:
- Sử dụng Google AdMob `AdView`
- Hỗ trợ các kích thước: BANNER, LARGE_BANNER, MEDIUM_RECTANGLE, FULL_BANNER, LEADERBOARD
- Gửi events qua MethodChannel: `ads_custom_view_failed`, `ads_custom_view_clicked`

#### NativeCardView
PlatformView hiển thị native ads:
- Sử dụng Google AdMob `NativeAd`
- Hiển thị custom layout với image, text, button
- Gửi events qua MethodChannel tương tự BannerView

## 5. Kiến trúc Flutter (Dart)

### Platform Interface Pattern

Mỗi loại ads có 3 file trong folder riêng:
1. `*_platform_interface.dart` - Abstract class với singleton pattern, delegate methods đến `_instance`
2. `*_method_channel.dart` - MethodChannel implementation extends platform interface
3. `*_ads.dart` - Public API class với static methods, EventChannel listener, và callbacks

**Pattern nhất quán:**
- Tất cả modules sử dụng EventChannel riêng cho events
- Tất cả modules có init() method để setup callbacks và load ads
- Tất cả modules có load*, isReady*, show*, reload* methods
- Tất cả modules có stopListening() để cleanup

### InterstitialAds Module

**File:** `lib/interstitial_ads/interstitial_ads.dart`

**API:**
- `init()` - Khởi tạo với ad unit IDs và callbacks
- `loadInterstitial()` - Load ad manually
- `isInterstitialReady()` - Check ready status
- `showInterstitial()` - Show ad (trả về bool, xử lý AD_NOT_READY exception)
- `reloadInterstitialIfNeeded()` - Reload nếu chưa ready
- `stopListening()` - Stop listening to events

**Callbacks:**
- `onInterstitialLoaded`
- `onInterstitialShown`
- `onInterstitialClosed`
- `onInterstitialFailed(String error)`

**Platform Interface Methods:**
- `initAds(List<String> interstitialAdUnitIds)`
- `loadInterstitial()`
- `isInterstitialReady()`
- `showInterstitial()`

### RewardedAds Module

**File:** `lib/rewarded_ads/rewarded_ads.dart`

**API:**
- `init()` - Khởi tạo với ad unit IDs và callbacks
- `loadRewarded()` - Load ad manually
- `isRewardedReady()` - Check ready status
- `showRewarded()` - Show ad (trả về bool, xử lý AD_NOT_READY exception)
- `reloadRewardedIfNeeded()` - Reload nếu chưa ready
- `stopListening()` - Stop listening to events
- `setUnlockingWallpaper(bool value)` - Set flag để track nếu rewarded ad là để unlock wallpaper
- `isUnlockingWallpaper()` - Check flag

**Callbacks:**
- `onRewardedLoaded`
- `onRewardedShown`
- `onRewardedClosed`
- `onRewardedFailed(String error)`
- `onRewardedEarned(String rewardType, int rewardAmount)` - Callback khi user nhận reward

**Platform Interface Methods:**
- `initAds(List<String> rewardedAdUnitIds)`
- `loadRewarded()`
- `isRewardedReady()`
- `showRewarded()`

**Events:**
- `rewarded_loaded`
- `rewarded_shown`
- `rewarded_closed`
- `rewarded_failed`
- `rewarded_earned` (với data: rewardType, rewardAmount)

### RewardedInterstitialAds Module

**File:** `lib/rewarded_interstitial_ads/rewarded_interstitial_ads.dart`

**API:**
- `init()` - Khởi tạo với ad unit IDs và callbacks
- `loadRewardedInterstitial()` - Load ad manually
- `isRewardedInterstitialReady()` - Check ready status
- `showRewardedInterstitial()` - Show ad (trả về bool, xử lý AD_NOT_READY exception)
- `reloadRewardedInterstitialIfNeeded()` - Reload nếu chưa ready
- `stopListening()` - Stop listening to events

**Callbacks:**
- `onRewardedInterstitialLoaded`
- `onRewardedInterstitialShown`
- `onRewardedInterstitialClosed`
- `onRewardedInterstitialFailed(String error)`
- `onRewardedInterstitialEarned(String rewardType, int rewardAmount)` - Callback khi user nhận reward

**Platform Interface Methods:**
- `initAds(List<String> rewardedInterstitialAdUnitIds)`
- `loadRewardedInterstitial()`
- `isRewardedInterstitialReady()`
- `showRewardedInterstitial()`

**Events:**
- `rewarded_interstitial_loaded`
- `rewarded_interstitial_shown`
- `rewarded_interstitial_closed`
- `rewarded_interstitial_failed`
- `rewarded_interstitial_earned` (với data: rewardType, rewardAmount)

### Banner & Native Widgets

#### BannerAdWidget
StatefulWidget hiển thị banner ads:
- Sử dụng `AndroidView` với viewType `"ads_banner_view"`
- Lắng nghe EventChannel `com.example.flutter_native_ad.banner_event_channel`
- Tự động ẩn nếu ad failed to load

#### NativeAdWidget
StatefulWidget hiển thị native ads:
- Sử dụng `AndroidView` với viewType `"ads_native_view"`
- Lắng nghe EventChannel `com.example.flutter_native_ad.native_event_channel`
- Tự động ẩn nếu ad failed to load

#### AdData Models

**AdBannerSize enum:**
- LARGE_BANNER (100px height)
- BANNER (50px height)
- MEDIUM_RECTANGLE (250px height)
- FULL_BANNER (60px height)
- LEADERBOARD (90px height)

**AdBannerData:**
- `adUnitId: String`
- `size: AdBannerSize`
- `toJson()` - Convert to Map cho PlatformView

**AdNativeData:**
- `adUnitId: String`
- `size: AdBannerSize`
- `toJson()` - Convert to Map cho PlatformView

## 6. Flow hoạt động

### Initialization Flow

1. Flutter app khởi động
2. `FlutterAdsNativePlugin.onAttachedToEngine()` được gọi
3. `AdNativeManager.attachToEngine()` setup tất cả plugins
4. Mỗi plugin setup MethodChannel và EventChannel
5. `FlutterAdsNativePlugin.onAttachedToActivity()` được gọi
6. `AdNativeManager.setActivity()` được gọi
7. Mỗi plugin tạo Handler instance với Activity, Context, và EventHandler
8. Handler được gắn vào MethodChannel

### Interstitial Ad Flow

1. Flutter gọi `InterstitialAds.init()` với ad unit IDs
2. Flutter gọi `InterstitialAdsPlatform.instance.initAds()`
3. MethodChannel gửi `ads_init` với `interstitialAdUnitIds` argument
4. `InterstitialAdHandler` nhận call, set ad unit IDs vào `MyCustomAdManager`
5. `MyCustomAdManager.preloadInterstitial()` được gọi
6. AdProvider load ad và gọi callback khi done
7. Event được gửi qua EventChannel về Flutter
8. Flutter nhận event và gọi callback tương ứng

### Rewarded Ad Flow

1. Flutter gọi `RewardedAds.init()` với ad unit IDs và callbacks
2. Flutter gọi `RewardedAdsPlatform.instance.initAds()`
3. MethodChannel gửi `ads_init` với `rewardedAdUnitIds` argument
4. `RewardedAdHandler` nhận call, set ad unit IDs vào `MyCustomAdManager`
5. `MyCustomAdManager.preloadRewarded()` được gọi
6. AdProvider load ad và gọi callback khi done
7. Event `rewarded_loaded` được gửi qua EventChannel về Flutter
8. Flutter nhận event và gọi `onRewardedLoaded` callback
9. Khi user xem ad và earn reward, event `rewarded_earned` được gửi với rewardType và rewardAmount
10. Flutter nhận event và gọi `onRewardedEarned` callback với reward info

### Rewarded Interstitial Ad Flow

Tương tự Rewarded Ad Flow nhưng:
- Sử dụng `RewardedInterstitialAds.init()`
- MethodChannel: `ads_init` với `rewardedInterstitialAdUnitIds`
- Handler: `RewardedInterstitialAdHandler`
- Manager method: `MyCustomAdManager.preloadRewardedInterstitial()`
- Events: `rewarded_interstitial_*` events

### Show Ad Flow

1. Flutter gọi `InterstitialAds.showInterstitial()` / `RewardedAds.showRewarded()` / `RewardedInterstitialAds.showRewardedInterstitial()`
2. MethodChannel gửi method tương ứng (`ads_show_interstitial`, `ads_show_rewarded`, `ads_show_rewarded_interstitial`)
3. Handler gọi `MyCustomAdManager` method tương ứng
4. Provider hiển thị ad
5. Provider gọi callbacks (onShown, onClosed, onFailed, onEarned cho rewarded ads)
6. Events được gửi về Flutter qua EventChannel tương ứng
7. Flutter nhận events và gọi callbacks

### Banner/Native Ad Flow

1. Flutter tạo `BannerAdWidget` hoặc `NativeAdWidget` với `AdData`
2. Widget tạo `AndroidView` với viewType tương ứng
3. Native side `BannerViewFactory` hoặc `NativeCardViewFactory` tạo PlatformView
4. PlatformView load ad và hiển thị
5. Events được gửi qua MethodChannel (ads_custom_view_failed, ads_custom_view_clicked)
6. Widget lắng nghe EventChannel và update UI

## 7. Ad Mediation Platform

### AdsMediationPlatform enum

- `ADMOB` - Google AdMob (hiện tại)
- Có thể mở rộng: `MAX`, `LEVELPLAY`

### Ad Providers

Mỗi loại ad có provider interface:
- `InterstitialAdProvider`
- `RewardedAdProvider`
- `RewardedInterstitialAdProvider`

**AdMob Implementation:**
- `AdMobInterstitialProvider`
- `AdMobRewardedProvider`
- `AdMobRewardedInterstitialProvider`

Providers hỗ trợ:
- Ad unit ID rotation
- Loading ads
- Showing ads
- Status checking

## 8. Dependencies

### Flutter/Dart
- `plugin_platform_interface: ^2.0.2`
- `flutter: >=3.3.0`
- `sdk: ^3.10.1`

### Android (Implied từ code)
- Google Play Services Ads (AdMob)
- Flutter Embedding V2

## 9. Các điểm quan trọng

### Activity Management
- Activity được lấy từ `ActivityAware` interface
- Activity có thể null trong một số lifecycle states
- Handler chỉ được tạo khi Activity available
- Handler được cleanup khi Activity detached

### Thread Safety
- `@Volatile` không được sử dụng (có thể cần thêm nếu có multi-threading issues)
- Các operations chủ yếu trên main thread

### Error Handling
- MethodChannel exceptions được propagate lên Flutter
- `PlatformException` với code `AD_NOT_READY` được xử lý đặc biệt
- Events có error callback riêng

### Resource Management
- MethodChannel và EventChannel được cleanup đúng cách
- StreamSubscription được cancel khi dispose
- Handler instances được nullify khi không dùng

## 10. Extension Points

### Thêm loại ads mới

1. Thêm enum value vào `AdNativeAdsType`
2. Tạo handler class trong `inter_reward/`
3. Tạo plugin class extends `AdHandlerPlugin<HandlerClass>`
4. Thêm vào `adsMap` trong `AdNativeManager`
5. Tạo Flutter module tương ứng trong `lib/`

### Thêm mediation platform

1. Thêm enum value vào `AdsMediationPlatform`
2. Tạo provider classes trong folder mới (ví dụ: `max/`)
3. Update `MyCustomAdManager` để sử dụng provider mới
4. Implement tất cả provider interfaces

### Thêm method mới

1. Thêm method vào Handler class
2. Thêm method vào Platform Interface
3. Implement trong Method Channel class
4. Thêm public method vào main class

## 11. Best Practices

1. **Luôn check Activity availability** trước khi show ads
2. **Handle exceptions** đúng cách, đặc biệt `AD_NOT_READY`
3. **Preload ads** trước khi cần show
4. **Cleanup resources** khi dispose widgets
5. **Sử dụng EventChannel** cho events thay vì callback trong method channel
6. **Test với different Activity states** (config changes, etc.)

## 12. Module Status

### ✅ Hoàn thiện

- **InterstitialAds Module**: Đã implement đầy đủ
  - Platform interface với tất cả methods
  - MethodChannel implementation
  - Public API với init, load, show, check ready
  - Event handling đầy đủ

- **RewardedAds Module**: Đã implement đầy đủ
  - Platform interface với tất cả methods
  - MethodChannel implementation
  - Public API với init, load, show, check ready
  - Event handling đầy đủ (bao gồm rewarded_earned event)
  - Flag `_isUnlockingWallpaper` để track special use case

- **RewardedInterstitialAds Module**: Đã implement đầy đủ
  - Platform interface với tất cả methods
  - MethodChannel implementation
  - Public API với init, load, show, check ready
  - Event handling đầy đủ (bao gồm rewarded_interstitial_earned event)

### ⚠️ Chưa hoàn thiện

- **BannerAdHandler và NativeAdHandler**: Chưa implement methods (chỉ `notImplemented()`)
- **iOS implementation**: Chưa có implementation cho nhiều features
- **Unit tests**: Chưa có unit tests cho một số components

## 13. Known Issues / TODOs

- BannerAdHandler và NativeAdHandler chưa implement methods (chỉ `notImplemented()`)
- Chưa có iOS implementation cho nhiều features
- Chưa có unit tests cho một số components

## 14. Version Info

- Plugin version: `0.0.1`
- Flutter SDK: `>=3.3.0`
- Dart SDK: `^3.10.1`

---

*Document được tạo tự động dựa trên codebase hiện tại. Cập nhật khi có thay đổi quan trọng.*
