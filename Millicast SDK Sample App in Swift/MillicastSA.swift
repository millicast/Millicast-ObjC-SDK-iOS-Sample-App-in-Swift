//
//  MillicastSA.swift
//  Millicast SDK Sample App in Swift
//
//  Created by CoSMo Software on 3/8/21.
//

import Foundation

class MillicastSA: ObservableObject {
    @Published var accountId: String
    @Published var streamNamePub: String
    @Published var streamNameSub: String
    @Published var tokenPub: String
    @Published var tokenSub: String
    @Published var apiUrlPub: String
    @Published var apiUrlSub: String

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
        streamNamePub = savedCreds.getStreamNamePub()
        streamNameSub = savedCreds.getStreamNamePub()
        tokenPub = savedCreds.getTokenPub()
        tokenSub = savedCreds.getTokenSub()
        apiUrlPub = savedCreds.getApiUrlPub()
        apiUrlSub = savedCreds.getApiUrlSub()
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
        return mcManager.getPubVideoView()
    }
    
    /**
     Render again the video of the currently captured video (if any).
     */
    func refreshView() {
        print("[McSA][refreshView]")
        mcManager.refreshPubVideo()
    }
    
    /**
     Get the VideoView that renders the subscribed video.
     */
    func getSubVideoView() -> VideoView {
        print("[McSA][getSubVideoView]")
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
        print("[McSA][toggleMedia] forPublisher:\(isPublisher) forAudio:\(isAudio)")
        mcManager.toggleMediaState(forPublisher: isPublisher, forAudio: isAudio)
    }
    
    /*
     Publish
     */
    func startPublish() {
        print("[McSA][startPublish]")
        mcManager.pubConnect()
    }
    
    func stopPublish() {
        print("[McSA][stopPublish]")
        mcManager.pubStop()
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
        mcManager.subConnect()
    }
    
    func stopSubscribe() {
        print("[McSA][stopSubscribe]")
        mcManager.subStop()
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
    
    func getSettingsView() -> SettingsView {
        print("[McSA][getSettingsView]")
        return SettingsView(manager: mcManager)
    }
}
