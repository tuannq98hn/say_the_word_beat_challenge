import Foundation

// Centralized analytics event names for the local ads plugin (iOS side).
// Note: iOS ads implementation isn't wired in this repo yet; these constants
// exist to keep event naming consistent across platforms.
enum AnalyticsEventNames {
  static let adLoad = "swc_ad_load"
  static let adShowCall = "swc_ad_show_call"
  static let adImpression = "swc_ad_impression"
  static let adShowFail = "swc_ad_show_fail"
}


