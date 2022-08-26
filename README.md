The Swift Sample App (SA) demonstrates how the Millicast Objective C SDK can be used in a Swift project to publish/subscribe to/from the Millicast Platform.

# Millicast SDK:
- To use this SA, select an appropriate Millicast SDK from our list of [releases](https://github.com/millicast/millicast-native-sdk/releases).

# Opening the SA
1. The SA can be opened with Xcode.
1. In Xcode -> File -> Open...
1. Select the SA project file ***SwiftSa.xcworkspace***.

# Install the Millicast Objective C SDK
## Ways to add the SDK
- There are currently three ways to add the Millicast Objective C SDK, as shown below.
- Proceed with **only one** of these ways at any one time.

### Add SDK framework file manually.
1. Download the selected version of SDK file from the list of release indicated above.
   - After uncompressing the archive, the SDK framework can usually be found as a package named ***MillicastSDK.xcframework***.
1. Open the SA in Xcode as detailed in the earlier section (**Opening the SA**).
1. Add the Millicast SDK framework file into the project via the project editor
    1. Open the project editor settings.
        - In the Project navigator, click on the project name (at the top most level)
    1. Under the list of TARGETS, select your desired target, for e.g. "***SwiftSa iOS***" or "***SwiftSa tvOS***".
    1. Go to General -> Frameworks, Libraries, and Embedded Content.
    1. Add the new MillicastSDK framework:
       1. Click the "+" icon, which will pop up a window to select the new framework.
       1. Click "Add Other..." at the bottom, and then "Add Files...".
       1. Navigate to where the new ***MillicastSDK.xcframework*** is and select to "Open" this file.
       1. ***MillicastSDK.xcframework*** should now appear in the list of "Frameworks, Libraries, and Embedded Content".
    1. Repeat the steps above for any other target(s), that needs to add the new MillicastSDK.
1. Embed and sign the framework (for each target)
    1. Open the project editor and select the desired target.
    1. Go to General -> Frameworks, Libraries, and Embedded Content.
    1. Ensure the Millicast SDK framework's Embed value is "**Embed & Sign**".
1. Validate Workspace (for each target)
    1. Open the project editor and select the desired target.
    1. Go to the Build Settings -> Validate Workspace
    2. Ensure the value is "**Yes**".

### Add SDK via CocoaPods.
#### SA usage
- The required CocoaPods settings listed below are mainly for reference, as they have already been set up in the SA.
- The only action required to use the SA is as follows:
    1. Ensure CocoaPods is installed on your system.
        - [CocoaPods installation](https://guides.cocoapods.org/using/getting-started.html)
    1. Close the SA if it is opened in Xcode.
    1. On the command line, at the level of the ***Podfile***, perform:
        1. For first time installation of SDK via CocoaPods:
            ```
            pod install
            ```
        1. For upgrade of SDK previously installed via CocoaPods:
            ``` 
            pod update
            ```
    1. Open the SA in Xcode as detailed in the earlier section (**Opening the SA**).

#### CocoaPods settings
- The following have already been set up in the SA.
- If you wish to add the SDK to your own app, you can follow the following steps.
- CocoaPods details:
    - pod name: ```MillicastSDK```
- To create an iOS target:
    - In ***Podfile***, add:

        ``` ruby  
            target 'SwiftSa iOS' do
              platform :ios, '14.5'
              # Comment the next line if you don't want to use dynamic frameworks
              use_frameworks!
              # Pods for SwiftSa iOS
              pod 'MillicastSDK'
            end
        ```
- To create a tvOS target:
    - In ***Podfile***, add:

        ``` ruby  
            target 'SwiftSa tvOS' do
              platform :tvos, '14.5'
              # Comment the next line if you don't want to use dynamic frameworks
              use_frameworks!
              # Pods for SwiftSa tvOS
              pod 'MillicastSDK'
            end
        ```
- Where for all types of targets:
    - The pod line `pod 'MillicastSDK'` targets the latest version of SDK available on CocoaPods.
    - The platform line `platform :ios, '14.5'` or `platform :tvos, '14.5'` targets iOS or tvOS version 14.5. This version may be adjusted upwards according to needs.
    - To target a specific version of the SDK, change the pod line by following the instructions [here](https://guides.cocoapods.org/using/the-podfile.html#specifying-pod-versions).
        - For example, to use version 1.1.3 or higher, but lower than 1.2.0, you can change the pod line to:
            ``` ruby
                  pod 'MillicastSDK', '~> 1.1.3'
            ```
- Continue with the steps in the previous section (**SA usage**) to install the SDK via CocoaPods.

### Add SDK via Swift Package Manager (SPM).
1. Open the SA in Xcode as detailed in the earlier section (**Opening the SA**).
2. For adding the SDK via SPM, please follow the instructions [here](https://github.com/millicast/millicast-sdk-swift-package).

# Run the SA
1. Before running the SA, it is recommended to populate the Millicast credentials in the ***Constants.swift*** file.
1. It is also possible to enter or change the credentials when the SA is running, at the Settings page.
1. On Xcode, click on the Run button to run the SA on the device of your choice.

# To publish using the SA
1. To publish video, a device with a camera is required. Simulators will therefore not be able to publish video.
1. Ensure the publishing credentials are populated.
1. Go to the Publish page.
1. If desired, tap on the camera description and/or resolution description to cycle through the available cameras and resolutions.
1. Click "Capture" to start capturing on the selected camera, at the selected resolution.
    - If capturing is successful, the local video can be seen on the screen.
1. If desired to switch to another camera, click on "Switch Camera".
1. To mute/unmute audio or video, toggle the respective buttons.
    - This affects both the captured/published media, as well as the subscribed media on Subscriber(s).
1. Click "Publish" to publish the captured video to Millicast.
1. To stop publishing, click "Stop Publish".

# To subscribe using the SA
1. Ensure the subscribing credentials are populated.
1. Go to the Subscribe page.
1. Click "Subscribe" to start subscribing to the Millicast stream specified at Settings page.
1. To mute/unmute audio or video, toggle the respective buttons.
    - This affects only the subscribed media on this Subscriber, and not on other Subscriber(s) or the Publisher.
1. To stop subscribing, click "Stop Subscribe".

# Settings page
- Account setting changes on the UI are not applied until the apply button is tapped.
  - Setting fields change color to alert user when UI values differ from applied values.
- Subscribe Token
  - If the publisher settings requires a secure viewer, a valid Subscribe Token has to be set.
  - If a secure viewer is **not** required:
    - The following values for the Subscriber Token field are acceptable:
      - Completely blank (no white spaces).
      - A valid Subscriber Token.
    - Any other values may result in failure to connect.
  - More details on Subscribe Token [here](https://docs.millicast.com/docs/secure-the-millicast-viewer-api#create-a-subscribe-token).

# Miscellaneous
- The SA enables Background Mode for "[Audio, AirPlay, and Picture in Picture](https://developer.apple.com/documentation/avfoundation/media_playback/creating_a_basic_video_player_ios_and_tvos/enabling_background_audio)".
  - This allows the SA to continue subscribing and not lose its connection to the Millicast backend when it is moved to the background for any reason.