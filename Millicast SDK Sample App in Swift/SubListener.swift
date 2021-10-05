//
//  SubListener.swift
//  Millicast SDK Sample App in Swift
//
//  Created by CoSMo Software on 16/8/21.
//

import Foundation

class SubListener : MCSubscriberListener {
    
    var mcMan : MillicastManager
    var subscriber : MCSubscriber
    
    init(sub: MCSubscriber){
        mcMan = MillicastManager.getInstance()
        subscriber = sub
        print("[SubLtn] SubListener created.")
    }
    
    func onSubscribed() {
        mcMan.setSubState(to: .subscribing)
        print("[SubLtn] Subscribing to Millicast.")
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
    
    func onStatsReport(_ report: MCStatsTree!) {
        print("[SubLtn] Stats: \(report)")
    }
    
}
