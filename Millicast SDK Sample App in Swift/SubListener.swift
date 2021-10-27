//
//  SubListener.swift
//  Millicast SDK Sample App in Swift
//
//  Created by CoSMo Software on 16/8/21.
//

import Foundation
import UIKit
import AVFAudio

class SubListener : MCSubscriberListener {
    
    var mcMan : MillicastManager
    var subscriber : MCSubscriber
    
    init(sub: MCSubscriber){
        mcMan = MillicastManager.getInstance()
        subscriber = sub
        subscriber.enableStats(true)
        print("[SubLtn] SubListener created.")
    }
    
    func onSubscribed() {
        mcMan.setSubState(to: .subscribing)
        print("[SubLtn] Subscribing to Millicast.")
        #if os(iOS)
        let inst = AVAudioSession.sharedInstance()
        do {
            try inst.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch _ {
            print("Could not set speakers")
        }
        #endif
    }
    
    func onVideoTrack(_ track: MCVideoTrack!) {
        mcMan.setSubVideoTrack(track: track)
        mcMan.setMediaState(to: true, forPublisher: false, forAudio: false)
        
        print("[SubLtn] Received VideoTrack from Millicast.")
        mcMan.renderSubVideo()
    }
    
    func onAudioTrack(_ track: MCAudioTrack!) {
        mcMan.setSubAudioTrack(track: track)
        mcMan.setMediaState(to: true, forPublisher: false, forAudio: true)
        
        print("[SubLtn] Received AudioTrack from Millicast.")
    }
    
    func onConnected() {
        mcMan.setSubState(to: .connected)
        print("[SubLtn] Connected to Millicast.")
        subscriber.subscribe()
        print("[SubLtn] Trying to subscribe to Millicast.")
    }
    
    func onConnectionError(_ status: Int32, withReason reason: String!) {
        mcMan.setSubState(to: .disconnected)
        mcMan.showAlert("[SubLtn] Failed to connect as \(reason!)! Status: \(status)")
    }
    
    func onActive(_ streamId: String!, tracks: [Any]!, sourceId: String!) {
        
    }
    
    func onInactive(_ streamId: String!, sourceId: String!) {
        
    }
    
    func onStopped() {
        
    }
    
    func onVad(_ mid: String!, sourceId: String!) {
        
    }
    
    func onStatsReport(_ report: MCStatsReport!) {
        // print("[SubLtn] Stats: \(report)")
    }
    
}
