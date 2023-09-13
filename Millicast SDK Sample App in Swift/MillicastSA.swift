//
//  MillicastSA.swift
//  Millicast SDK Sample App in Swift
//

import AVFoundation
import Foundation

/**
 * View Model of the Sample Application (SA) for the Millicast iOS SDK.
 * It publishes data from the MillicastManager to the various views.
 */
class MillicastSA: ObservableObject {
    static var instance: MillicastSA!
    var mcMan: MillicastManager
    var cat: AVAudioSession.Category?
    var catOpt: AVAudioSession.CategoryOptions?

    /**
     Creds currently in the UI.
     SettingsView will read from and update to this.
     */
    var uiCreds: UiCreds
    
    private init() {
        // Get an instance of MillicastManager to ensure it is initialized
        // before any of its properties are used.
        mcMan = MillicastManager.getInstance()
        uiCreds = UiCreds()
        // After App initializes, load UI creds using currently applied values.
        uiCreds.setCreds(using: mcMan.currentCreds)
        // Listen to iOS Notifications
        setupNotifications()
    }
    
    static func getInstance() -> MillicastSA {
        if instance == nil {
            instance = MillicastSA()
        }
        return instance
    }
    
    /*
     Millicast connections
     */

    func getUiCreds() -> UiCreds {
        let logTag = "[McSA][Creds] "
        print(logTag + "Type: \(uiCreds.credsType).")
        return uiCreds
    }
    
    func setUiCreds(_ creds: CredentialSource) {
        uiCreds.setCreds(using: creds)
    }
    
    /*
     Capture
     */
    
    func startCapture() {
        print("[McSA][startCapture]")
        mcMan.startAudioVideoCapture()
    }
    
    func stopCapture() {
        print("[McSA][stopCapture]")
        mcMan.stopAudioVideoCapture()
    }
    
    func switchCamera() {
        print("[McSA][switchCamera]")
        mcMan.switchVideoSource(ascending: true)
    }
    
    /**
     Switch to next available camera.
     If at end of camera range, cycle back to start of range.
     */
    func toggleCamera() {
        print("[McSA][toggleCamera]")
        mcMan.toggleVideoSource(ascending: true)
    }
    
    /**
     Switch to next available resolution.
     If at end of resolution range, cycle back to start of range.
     */
    func toggleResolution() {
        print("[McSA][toggleResolution]")
        mcMan.toggleCapability(ascending: true)
    }
    
    /**
     Get the currently selected camera as a string, if any.
     */
    func getCameraName() -> String {
        let name = mcMan.getVideoSourceName()
        print("[McSA][getCameraName] \(name)")
        return name
    }
    
    /**
     Get the currently selected resolution as a string, if any.
     */
    func getResolution() -> String {
        let name = mcMan.getCapabilityName()
        print("[McSA][getResolution] \(name)")
        return name
    }
    
    /*
     Render
     */

    /*
     Mute / unmute audio / video.
     */
    
    /**
     Toggle published/subscribed audio/video between unmuted and muted state.
     To do so for the publisher, set forPublisher to true, else it would be for the subscriber.
     To do so for audio, set isAudio to true, else it would be for video.
     */
    func toggleMedia(forPublisher isPublisher: Bool, forAudio isAudio: Bool) {
        print("[McSA][toggleMedia] forPublisher:\(isPublisher) forAudio:\(isAudio)")
        mcMan.toggleMediaState(forPublisher: isPublisher, forAudio: isAudio)
    }
    
    /*
     Publish
     */
    func startPublish() {
        print("[McSA][Pub][Start]")
        mcMan.connectPub()
    }
    
    func stopPublish() {
        print("[McSA][Pub][Stop]")
        mcMan.stopPub()
    }
    
    func stopPublishCapture() {
        print("[McSA][Pub][Capture][Stop]")
        stopPublish()
        stopCapture()
    }
    
    /*
     Subscribe
     */
    
    func startSubscribe() {
        print("[McSA][Sub][Start]")
        mcMan.connectSub()
    }
    
    func stopSubscribe() {
        print("[McSA][Sub][Stop]")
        mcMan.stopSub()
    }
    
    /*
     Get Views
     */
    
    func getPublishView() -> PublishView {
        print("[McSA][getPublishView]")
        return PublishView(manager: mcMan)
    }
    
    func getSubscribeView() -> SubscribeView {
        print("[McSA][getSubscribeView]")
        return SubscribeView(manager: mcMan)
    }
    
    func getSettingsView() -> SettingsMcView {
        print("[McSA][getSettingsView]")
        return SettingsMcView(manager: mcMan)
    }
    
    /*
     Utils
     */

    /**
     * Allows SA to receive and handle iOS notifications.
     * The main purpose here is to log the AVAudioSession for the settings applied.
     * By default, the SDK upon publishing will set the AVAudioSession to the playAndRecord category, with voiceChat mode and allowBluetooth option.
     * If desired, the App can configure the AVAudioSession with its own settings, as shown by the Utils.configureAudioSession() method. Refer to the method's description for more details.
     */
    private func setupNotifications() {
        let logTag = "[Notif][Setup] "

        // Get the default notification center instance.
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(routeChangeHandler),
                       name: AVAudioSession.routeChangeNotification,
                       object: nil)
        print(logTag + "Added Observer for Audio Route Change.")
        nc.addObserver(self,
                       selector: #selector(handleInterruption),
                       name: AVAudioSession.interruptionNotification,
                       object: AVAudioSession.sharedInstance())
        print(logTag + "Added Observer for Audio Interruption.")
    }
    
    /**
     * Handles interruptions of AVAudioSession and logs them.
     */
    @objc func handleInterruption(notification: Notification) {
        let logTag = "[Interrupt][Notif][Audio][Session] "
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else {
            return
        }

        // Switch over the interruption type.
        switch type {
        case .began:
            // An interruption began.
            print(logTag + "Began.")

        case .ended:
            // An interruption ended.
            print(logTag + "Ended.")

            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                print(logTag + "Ended. No interrruption option.")
                return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                print(logTag + "Ended. Option: Should resume.")
            } else {
                print(logTag + "Ended. Option: No resume option.")
            }

        default:
            print(logTag + "Unknown type!")
        }
    }
    
    /**
     * Handles notification for Audio route change and logs them.
     */
    @objc private func routeChangeHandler(notification: Notification) {
        let logTag = "[Route][Notif][Audio][Session] "
        var log = ""
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue)
        else {
            return
        }
        
        // Log the audio route change reason.
        let session = AVAudioSession.sharedInstance()
        switch reason {
        case .newDeviceAvailable:
            print(logTag + "New device added.")
            print(Utils.timeStr() + logTag + Utils.audioOutputLog(userInfo: userInfo))

        case .oldDeviceUnavailable:
            print(logTag + "Old device removed.")
            print(Utils.timeStr() + logTag + Utils.audioOutputLog(userInfo: userInfo))

        case .unknown:
            print(logTag + "Unknown reason!")
            
        case .categoryChange:
            let catOld = String(describing: cat?.rawValue ?? "None")
            let catOptOld = Utils.audioCatOptStr(value: catOpt?.rawValue ?? 0)
            log = ", Old:\(catOld)\(catOptOld)"

            cat = session.category
            catOpt = session.categoryOptions
            
            let catNow = String(describing: cat?.rawValue ?? "None")
            let catOptNow = Utils.audioCatOptStr(value: catOpt?.rawValue ?? 0)
            log = "Category Changed! Now:\(catNow)\(catOptNow)" + log
            print(logTag + log)

        case .override:
            print(logTag + "Route Overriden!")
        case .wakeFromSleep:
            print(logTag + "Device woke from sleep.")
        case .noSuitableRouteForCategory:
            let catNow = String(describing: cat?.rawValue ?? "None")
            print(logTag + "There is no Suitable Route For Category \(catNow)!")
            
        case .routeConfigurationChange:
            print(logTag + "Route configuration changed! Input and output ports has not changed, but some of their configuration has changed, for e.g. selected data source.")
            
        @unknown default:
            print(logTag + "Default case for Reason! Unknown switch error!")
        }
        print(logTag + "OK.")
    }
}
