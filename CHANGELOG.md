# Release Notes
This file documents the release notes for each version of the Millicast Objective C SDK iOS Sample App (SA) in Swift.
SA APIs refer to public methods provided by the SA class, MillicastManager.
## 1.0.1 (2022-02-16)
Upgraded to use SDK 1.1.3, added CocoaPods and Swift Package Manager installation of SDK, SA documentation and removed Objective C bridging header.
### Major changes
- Added support for CocoaPods and Swift Package Manager (SPM) installation of SDK.
    - All 3 methods (CocoaPods, SPM, manual framework addition) of SDK installation are supported.
    - Open project using SwiftSa.xcworkspace instead of SwiftSa.xcodeproj.
    - Refer to ***README.md*** for usage details.
- Upgraded to new SDK 1.1.3.
  - Removed Objective C bridging header as SDK headers are now exported via umbrella header that Swift can see by using ```import MillicastSDK```.
- Upgraded to new features of SDK 1.1:
  - New WebRTC Stats API
  - New Option for Client & Publisher classes.
- Added SA documentation under ***docs/iOS*** and ***docs/tvOS***
- Added volume control for iOS Subscribe view.
### Fixed
- N.A.
### Known issues
- As before.

## 1.0.0 (2021-09-30)
This is the first release of the Millicast Objective C SDK iOS Sample App (SA) in Swift.
### Known issues
- If H264 is set as preferred codec, higher resolutions (e.g. 1920x1440, 2592x1936, 3264x2448) may not be published.
  - This might be device dependent.
  - Publishing with VP8 and VP9 is possible.