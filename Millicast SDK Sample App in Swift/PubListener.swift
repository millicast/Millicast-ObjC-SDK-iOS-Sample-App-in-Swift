//
//  PubListener.swift
//  Millicast SDK Sample App in Swift
//
//  Created by CoSMo Software on 4/8/21.
//

import Foundation

class PubListener : MCPublisherListener {
    
    var mcMan : MillicastManager
    var publisher : MCPublisher
    
    init(pub: MCPublisher){
        mcMan = MillicastManager.getInstance()
        publisher = pub
        print("[PubLtn] PubListener created.")
    }
    
    func onPublishing() {
        mcMan.setPubState(to: .publishing)
        print("[PubLtn] Publishing to Millicast.")
    }
    
    func onConnected() {
        mcMan.setPubState(to: .connected)
        print("[PubLtn] Connected to Millicast.")
        mcMan.startPublish()
        print("[PubLtn] Trying to publish to Millicast.")
    }
    
    func onConnectionError(_ status: Int32, withReason reason: String!) {
        mcMan.setPubState(to: .disconnected)
        mcMan.showAlert("[PubLtn] Failed to connect as \(reason!)! Status: \(status)")
    }
    
    func onStatsReport(_ report: MCStatsReport!) {
        // print("[PubLtn] Stats: \(report)")
    }
    
    func onActive(_ streamId: String!, tracks: [Any]!, sourceId: String!) {
        
    }
    
    func onInactive(_ streamId: String!, sourceId: String!) {
        
    }
    
    func onStopped() {
        
    }
    
    func onVad(_ mid: String!, sourceId: String!) {
        
    }
}
