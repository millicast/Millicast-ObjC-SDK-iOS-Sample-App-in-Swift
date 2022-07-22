//
//  MillicastSA.swift
//  Millicast SDK Sample App in Swift
//
//  Created by CoSMo Software on 3/8/21.
//

import Foundation

class MillicastSA: ObservableObject {
    @Published var accountId: String
    @Published var pubStreamName: String
    @Published var subStreamName: String
    @Published var pubToken: String
    @Published var pubApiUrl: String
    @Published var subApiUrl: String

    static var instance: MillicastSA!
    var mcManager: MillicastManager
    var fileCreds: FileCreds
    var savedCreds: SavedCreds
    var currentCreds: CurrentCreds
    var uiCreds: UiCreds
    
    private init() {
        mcManager = MillicastManager.getInstance()
        fileCreds = mcManager.fileCreds
        savedCreds = mcManager.savedCreds
        currentCreds = mcManager.currentCreds
        uiCreds = UiCreds()
        uiCreds.setCreds(using: savedCreds)
        
        accountId = savedCreds.getAccountId()
        pubStreamName = savedCreds.getPubStreamName()
        subStreamName = savedCreds.getPubStreamName()
        pubToken = savedCreds.getPubToken()
        pubApiUrl = savedCreds.getPubApiUrl()
        subApiUrl = savedCreds.getSubApiUrl()
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
     Read Millicast credentials from SettingsView and set them into App.
     If save is true, values will be saved into UserDefaults.
     */
    func setCreds(from sv: SettingsView, save: Bool) {
        print("[mcSA][setCreds] Saving: \(save) Account ID: \(sv.accountId)\nPublishing stream name: \(sv.pubStreamName)\nSubscribing stream name: \(sv.subStreamName)\nPublishing token: \(sv.pubToken)\nPublishing API url: \(sv.pubApiUrl)\nSubscribing API url: \(sv.subApiUrl)\n")
        
        // Read new values into MillicastManager
        mcManager.setCreds(using: sv, save: save)

        accountId = currentCreds.getAccountId()
        pubStreamName = currentCreds.getPubStreamName()
        subStreamName = currentCreds.getSubStreamName()
        pubToken = currentCreds.getPubToken()
        pubApiUrl = currentCreds.getPubApiUrl()
        subApiUrl = currentCreds.getSubApiUrl()
    }
    
    func getFileCreds() -> FileCreds {
        let logTag = "[SA][Creds] "
        print(logTag + "Type: \(fileCreds.credsType).")
        return fileCreds
    }
    
    func getSavedCreds() -> SavedCreds {
        let logTag = "[SA][Creds] "
        print(logTag + "Type: \(savedCreds.credsType).")
        return savedCreds
    }
    
    func getCurrentCreds() -> CurrentCreds {
        let logTag = "[SA][Creds] "
        print(logTag + "Type: \(currentCreds.credsType).")
        return currentCreds
    }
    
    func getUiCreds() -> UiCreds {
        let logTag = "[SA][Creds] "
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
        print("[mcSA][startCapture]")
        mcManager.startAudioVideoCapture()
    }
    
    func stopCapture() {
        print("[mcSA][stopCapture]")
        mcManager.stopAudioVideoCapture()
    }
    
    func switchCamera() {
        print("[mcSA][switchCamera]")
        mcManager.switchVideoSource(ascending: true)
    }
    
    /**
     Switch to next available camera.
     If at end of camera range, cycle back to start of range.
     */
    func toggleCamera() {
        print("[mcSA][toggleCamera]")
        mcManager.toggleVideoSource(ascending: true)
    }
    
    /**
     Switch to next available resolution.
     If at end of resolution range, cycle back to start of range.
     */
    func toggleResolution() {
        print("[mcSA][toggleResolution]")
        mcManager.toggleCapability(ascending: true)
    }
    
    /**
     Get the currently selected camera as a string, if any.
     */
    func getCameraName() -> String {
        let name = mcManager.getVideoSourceName()
        print("[mcSA][getCameraName] \(name)")
        return name
    }
    
    /**
     Get the currently selected resolution as a string, if any.
     */
    func getResolution() -> String {
        let name = mcManager.getCapabilityName()
        print("[mcSA][getResolution] \(name)")
        return name
    }
    
    /*
     Render
     */
    /**
     Get the VideoView that renders the published video.
     */
    func getPubVideoView() -> VideoView {
        print("[mcSA][getPubVideoView]")
        return mcManager.getPubVideoView()
    }
    
    /**
     Render again the video of the currently captured video (if any).
     */
    func refreshView() {
        print("[mcSA][refreshView]")
        mcManager.refreshPubVideo()
    }
    
    /**
     Get the VideoView that renders the subscribed video.
     */
    func getSubVideoView() -> VideoView {
        print("[mcSA][getSubVideoView]")
        return mcManager.getSubVideoView()
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
        print("[mcSA][toggleMedia] forPublisher:\(isPublisher) forAudio:\(isAudio)")
        mcManager.toggleMediaState(forPublisher: isPublisher, forAudio: isAudio)
    }
    
    /*
     Publish
     */
    func startPublish() {
        print("[mcSA][startPublish]")
        mcManager.pubConnect()
    }
    
    func stopPublish() {
        print("[mcSA][stopPublish]")
        mcManager.pubStop()
    }
    
    func stopPublishCapture() {
        print("[mcSA][stopPublishCapture]")
        stopPublish()
        stopCapture()
    }
    
    /*
     Subscribe
     */
    
    func startSubscribe() {
        print("[mcSA][startSubscribe]")
        mcManager.subConnect()
    }
    
    func stopSubscribe() {
        print("[mcSA][stopSubscribe]")
        mcManager.subStop()
    }
    
    /*
     Get Views
     */
    
    func getPublishView() -> PublishView {
        print("[mcSA][getPublishView]")
        return PublishView(manager: mcManager)
    }
    
    func getSubscribeView() -> SubscribeView {
        print("[mcSA][getSubscribeView]")
        return SubscribeView(manager: mcManager)
    }
    
    func getSettingsView() -> SettingsView {
        print("[mcSA][getSettingsView]")
        return SettingsView(manager: mcManager)
    }
}
