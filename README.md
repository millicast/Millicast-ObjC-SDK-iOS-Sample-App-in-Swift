The Swift Sample App (SA) demonstrates how the Millicast Objective C SDK can be used in a Swift project to publish/subscribe to/from the Millicast Platform.

# Millicast SDK:
- To use this SA, download an appropriate Millicast SDK from our list of [releases](https://github.com/millicast/millicast-native-sdk/tags).
- The recommended SDK version for this SA version is: [1.0.0](https://github.com/millicast/millicast-native-sdk/releases/tag/v1.0.0)

# Build the SA
1. Open the SA in Xcode
    1. In Xcode -> File -> Open...
    1. Select the SA project file "Millicast SDK Sample App in Swift.xcodeproj"
1. Add the Millicast Objective C SDK
    - Drag and drop the Millicast SDK framework file into the project via the Project navigator
        - The Millicast SDK framework file resides in the "lib" folder of the SDK package.
        - It should look like "MillicastSDK.framework".
    - It can be at the same level as the SA source code files (e.g. MillicastSA.swift), i.e., in the "Millicast SDK Sample App in Swift" folder.
    - Copy items if needed.
        - This should end up copying the framework file into the project.
1. Embed and sign the framework
    1. Open the project settings.
        - In the Project navigator, click on the project name (at the top most level)
        - Under the list of TARGETS, select your desired target, for e.g. "Millicast SDK Sample App in Swift iOS" or "Millicast SDK Sample App in Swift tvOS".
    1. Go to the General tab
    1. Under "Frameworks, Libraries and Embedded content", you should see the Millicast SDK framework.
    1. Make sure the Embed value is "**Embed & Sign**".
1. Validate Workspace
    1. Open the project settings as before.
    1. In the Project navigator, click on the project name (at the top most level)
    1. Go to the Build Settings tab
    1. Under "Validate Workspace", make sure the value is "**Yes**".

# Run the SA
1. Before running the SA, it is recommended to populate the Millicast credentials in the Constants.swift file.
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
