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
    /**
     These values publishes to UI the currently applied creds.
     */
    @Published var accountId: String = ""
    @Published var streamNamePub: String = ""
    @Published var streamNameSub: String = ""
    @Published var tokenPub: String = ""
    @Published var tokenSub: String = ""
    @Published var apiUrlPub: String = ""
    @Published var apiUrlSub: String = ""

    static var instance: MillicastSA!
    var mcManager: MillicastManager
    var cat: AVAudioSession.Category?
    var catOpt: AVAudioSession.CategoryOptions?

    /**
     Creds from Constants file.
     */
    var fileCreds: FileCreds {
        return mcManager.fileCreds
    }

    /**
     Creds saved in device memory
     */
    var savedCreds: SavedCreds {
        return mcManager.savedCreds
    }

    /**
     Creds currently applied in MillicastManager
     */
    var currentCreds: CurrentCreds {
        return mcManager.currentCreds
    }

    /**
     Creds currently in the UI.
     SettingsView will read from and update to this.
     */
    var uiCreds: UiCreds
    
    private init() {
        mcManager = MillicastManager.getInstance()
        uiCreds = UiCreds()
        accountId = currentCreds.getAccountId()
        streamNamePub = currentCreds.getStreamNamePub()
        streamNameSub = currentCreds.getStreamNameSub()
        tokenPub = currentCreds.getTokenPub()
        tokenSub = currentCreds.getTokenSub()
        apiUrlPub = currentCreds.getApiUrlPub()
        apiUrlSub = currentCreds.getApiUrlSub()
        // When App initializes, load UI creds using currently applied values.
        uiCreds.setCreds(using: currentCreds)
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
    /**
     Read Millicast credentials from a CredentialSource like SettingsView and set them into App.
     If save is true, values will be saved into UserDefaults.
     */
    func setCreds(from creds: CredentialSource, save: Bool) {
        let logTag = "[McSA][Creds][Set] "
        print(logTag + Utils.getCredStr(creds: creds))
        
        // Set new values into MillicastManager
        mcManager.setCreds(using: creds, save: save)

        // Update Published values based on currently applied creds in McMan.
        accountId = currentCreds.getAccountId()
        streamNamePub = currentCreds.getStreamNamePub()
        streamNameSub = currentCreds.getStreamNameSub()
        tokenPub = currentCreds.getTokenPub()
        tokenSub = currentCreds.getTokenSub()
        apiUrlPub = currentCreds.getApiUrlPub()
        apiUrlSub = currentCreds.getApiUrlSub()
    }
    
    func getFileCreds() -> FileCreds {
        let logTag = "[McSA][Creds] "
        print(logTag + "Type: \(fileCreds.credsType).")
        return fileCreds
    }
    
    func getSavedCreds() -> SavedCreds {
        let logTag = "[McSA][Creds] "
        print(logTag + "Type: \(savedCreds.credsType).")
        return savedCreds
    }
    
    func getCurrentCreds() -> CurrentCreds {
        let logTag = "[McSA][Creds] "
        print(logTag + "Type: \(currentCreds.credsType).")
        return currentCreds
    }
    
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
        mcManager.startAudioVideoCapture()
    }
    
    func stopCapture() {
        print("[McSA][stopCapture]")
        mcManager.stopAudioVideoCapture()
    }
    
    func switchCamera() {
        print("[McSA][switchCamera]")
        mcManager.switchVideoSource(ascending: true)
    }
    
    /**
     Switch to next available camera.
     If at end of camera range, cycle back to start of range.
     */
    func toggleCamera() {
        print("[McSA][toggleCamera]")
        mcManager.toggleVideoSource(ascending: true)
    }
    
    /**
     Switch to next available resolution.
     If at end of resolution range, cycle back to start of range.
     */
    func toggleResolution() {
        print("[McSA][toggleResolution]")
        mcManager.toggleCapability(ascending: true)
    }
    
    /**
     Get the currently selected camera as a string, if any.
     */
    func getCameraName() -> String {
        let name = mcManager.getVideoSourceName()
        print("[McSA][getCameraName] \(name)")
        return name
    }
    
    /**
     Get the currently selected resolution as a string, if any.
     */
    func getResolution() -> String {
        let name = mcManager.getCapabilityName()
        print("[McSA][getResolution] \(name)")
        return name
    }
    
    /*
     Render
     */
    /**
     Get the VideoView that renders the published video.
     */
    func getPubVideoView() -> VideoView {
        print("[McSA][getPubVideoView]")
        return mcManager.getVideoViewPub()
    }
    
    /**
     Get the VideoView that renders the subscribed video.
     */
    func getSubVideoView() -> VideoView {
        print("[McSA][getSubVideoView]")
        return mcManager.getVideoViewSub()
    }
    
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
        mcManager.toggleMediaState(forPublisher: isPublisher, forAudio: isAudio)
    }
    
    /*
     Publish
     */
    func startPublish() {
        print("[McSA][startPublish]")
        mcManager.connectPub()
    }
    
    func stopPublish() {
        print("[McSA][stopPublish]")
        mcManager.stopPub()
    }
    
    func stopPublishCapture() {
        print("[McSA][stopPublishCapture]")
        stopPublish()
        stopCapture()
    }
    
    /*
     Subscribe
     */
    
    func startSubscribe() {
        print("[McSA][startSubscribe]")
        mcManager.connectSub()
    }
    
    func stopSubscribe() {
        print("[McSA][stopSubscribe]")
        mcManager.stopSub()
    }
    
    /*
     Get Views
     */
    
    func getPublishView() -> PublishView {
        print("[McSA][getPublishView]")
        return PublishView(manager: mcManager)
    }
    
    func getSubscribeView() -> SubscribeView {
        print("[McSA][getSubscribeView]")
        return SubscribeView(manager: mcManager)
    }
    
    func getSettingsView() -> SettingsMcView {
        print("[McSA][getSettingsView]")
        return SettingsMcView(manager: mcManager)
    }
    
    /*
     Utils
     */

    /**
     Configure the AVAudioSession to use videoChat mode, which will allow Bluetooth and default to the device's speakers when no other audio route is connected.
     */
    private func configureAudioSession() {
        #if os(iOS)
        let logTag = "[Route][Configure][Audio] "
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .videoChat)
        } catch {
            print(logTag + "Failed!")
            return
        }
        print(logTag + "OK. VideoChat mode set: Will allow Bluetooth and default to device's speakers when no other audio route is connected.")
        #endif
    }

    /**
     Allow SA to receive and handle iOS notifications.
     */
    private func setupNotifications() {
        let logTag = "[Notif][Route] "

        // Get the default notification center instance.
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(routeChangeHandler),
                       name: AVAudioSession.routeChangeNotification,
                       object: nil)
        print(logTag + "Added Observer for Route Change.")
        configureAudioSession()
    }
    
    /**
     Handle notification for Audio route change and log them.
     Configures AVAudioSession for videoChat each time the Audio route changes.
     */
    @objc private func routeChangeHandler(notification: Notification) {
        let logTag = "[Route][Notif][Audio] "
        var log = ""
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue)
        else {
            return
        }
        
        print(logTag + String(describing: userInfo))
        
        // Log the audio route change reason.
        var session = AVAudioSession.sharedInstance()
        switch reason {
        case .newDeviceAvailable:
            print(logTag + "New device added.")

        case .oldDeviceUnavailable:
            print(logTag + "Old device removed.")

        case .unknown:
            print(logTag + "Unknown reason!")
            
        case .categoryChange:
            var catOld = String(describing: cat?.rawValue ?? "None")
            var catOptOld = String(describing: catOpt?.rawValue ?? 0)
            log = ", Old:\(catOld)[\(catOptOld)]"

            cat = session.category
            catOpt = session.categoryOptions
            
            var catNow = String(describing: cat?.rawValue ?? "None")
            var catOptNow = String(describing: catOpt?.rawValue ?? 0)
            log = "Category Changed! Now:\(catNow)[\(catOptNow)]" + log
            print(logTag + log)
            
        case .override:
            print(logTag + "Route Overriden!")
        case .wakeFromSleep:
            print(logTag + "Device woke from sleep.")
        case .noSuitableRouteForCategory:
            var catNow = String(describing: cat?.rawValue ?? "None")
            print(logTag + "There is no Suitable Route For Category \(catNow)!")
            
        case .routeConfigurationChange:
            print(logTag + "Route configuration changed! Input and output ports has not changed, but some of their configuration has changed, for e.g. selected data source.")
            
        @unknown default:
            print(logTag + "Default case for Reason! Unknown switch error!")
        }
        
        outputAudioLog(userInfo: userInfo)
        configureAudioSession()
    }
    
    /**
     Logs the current and previous audio output device.
     */
    private func outputAudioLog(userInfo: [AnyHashable: Any]) {
        let logTag = "[Route][Output][Audio] "
        var log = ""
        // Get current
        let session = AVAudioSession.sharedInstance()
        let routeCur = session.currentRoute
        let routeCurStr = outputAudioStr(route: routeCur)
        log += "Cur: \(routeCurStr), Old: "
        
        // Get previous
        guard let routePrev =
            userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription
        else {
            log += "None!"
            return
        }
        
        let routePrevStr = outputAudioStr(route: routePrev)
        log += "\(routePrevStr)"

        print(logTag + log)
    }
    
    /**
     Get a String representation of the audio output port(s) in the given AVAudioSessionRouteDescription.
     */
    private func outputAudioStr(route routeDescription: AVAudioSessionRouteDescription) -> String {
        var outputs = routeDescription.outputs
        
        var ports = ""
        for port in outputs {
            ports += "\(port.portType.rawValue),"
        }
        if ports != "" {
            ports.removeLast()
        }
        return ports
    }
}
