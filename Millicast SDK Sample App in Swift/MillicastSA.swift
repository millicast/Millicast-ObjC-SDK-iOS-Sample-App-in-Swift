//
//  MillicastSA.swift
//  Millicast SDK Sample App in Swift
//
//  Created by CoSMo Software on 3/8/21.
//

import Foundation

class MillicastSA : ObservableObject {
    
    static var instance : MillicastSA!
    var mcManager : MillicastManager
    var savedCreds : SavedCreds
    
    
    private init() {
        mcManager = MillicastManager.getInstance()
        savedCreds = mcManager.savedCreds
        
    }
    
    static func getInstance()->MillicastSA{
        if(instance == nil){
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
    func setCreds(from sv: SettingsView, save : Bool) -> Void {
        print("[mcSA][setCreds] Saving: \(save) Account ID: \(sv.accountId)\nPublishing stream name: \(sv.pubStreamName)\nSubscribing stream name: \(sv.subStreamName)\nPublishing token: \(sv.pubToken)\nPublishing API url: \(sv.pubApiUrl)\nSubscribing API url: \(sv.subApiUrl)\n")
        
        // Read new values into MillicastManager
        mcManager.setCreds(using: sv, save: save)
    }
    
    func getSavedCreds() -> SavedCreds {
        return savedCreds
    }
    
    /**
     Remove credentials set from UI.
     */
    func removeUserCreds() -> Void {
        UserDefaults.standard.removeObject(forKey: savedCreds.accountId)
        UserDefaults.standard.removeObject(forKey: savedCreds.pubStreamName)
        UserDefaults.standard.removeObject(forKey: savedCreds.subStreamName)
        UserDefaults.standard.removeObject(forKey: savedCreds.pubToken)
        UserDefaults.standard.removeObject(forKey: savedCreds.pubApiUrl)
        UserDefaults.standard.removeObject(forKey: savedCreds.subApiUrl)
    }
    
    /*
     Capture
     */
    
    func startCapture()->Void {
        print("[mcSA][startCapture]")
        mcManager.startAudioVideoCapture()
    }
    
    func stopCapture()->Void {
        print("[mcSA][stopCapture]")
        mcManager.stopAudioVideoCapture()
    }
    
    func switchCamera()->Void {
        print("[mcSA][switchCamera]")
        mcManager.switchVideoSource()
    }
    
    /**
     Switch to next available camera.
     If at end of camera range, cycle back to start of range.
     */
    func toggleCamera()->Void {
        print("[mcSA][toggleCamera]")
        mcManager.toggleVideoSource()
    }
    
    /**
     Switch to next available resolution.
     If at end of resolution range, cycle back to start of range.
     */
    func toggleResolution()->Void {
        print("[mcSA][toggleResolution]")
        mcManager.toggleCapability()
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
    func toggleMedia(forPublisher isPublisher : Bool, forAudio isAudio: Bool){
        print("[mcSA][toggleMedia] forPublisher:\(isPublisher) forAudio:\(isAudio)")
        mcManager.toggleMediaState(forPublisher: isPublisher, forAudio: isAudio)
    }
    
    /*
     Publish
     */
    func startPublish()->Void {
        print("[mcSA][startPublish]")
        mcManager.pubConnect()
    }
    
    func stopPublish()->Void {
        print("[mcSA][stopPublish]")
        mcManager.stopPublish()
    }
    
    func stopPublishCapture()->Void {
        print("[mcSA][stopPublishCapture]")
        stopPublish()
        stopCapture()
    }
    
    /*
     Subscribe
     */
    
    func startSubscribe()->Void {
        print("[mcSA][startSubscribe]")
        mcManager.subscribe()
    }
    
    func stopSubscribe()->Void {
        print("[mcSA][stopSubscribe]")
        mcManager.stopSubscribe()
    }
    
    /*
     Get Views
     */
    
    func getPublishView() -> PublishView {
        print("[mcSA][getPublishView]")
        return PublishView(manager : mcManager)
    }
    
    func getSubscribeView() -> SubscribeView {
        print("[mcSA][getSubscribeView]")
        return SubscribeView(manager : mcManager)
    }
    
    func getSettingsView() -> SettingsView {
        print("[mcSA][getSettingsView]")
        return SettingsView(manager : mcManager)
    }
    
}
