//
//  SubListener.swift
//  Millicast SDK Sample App in Swift
//
//  Created by CoSMo Software on 16/8/21.
//

import AVFAudio
import Foundation
import MillicastSDK
import UIKit

class SubListener: MCSubscriberListener {
    var mcMan: MillicastManager
    
    init() {
        let logTag = "[Sub][Ltn] "
        mcMan = MillicastManager.getInstance()
        print(logTag + "SubListener created.")
    }
    
    func onSubscribed() {
        let logTag = "[Sub][Ltn][On] "
        mcMan.setSubState(to: .subscribing)
        print(logTag + "Subscribing to Millicast.")
    }
    
    func onSubscribedError(_ error: String) {
        let logTag = "[Sub][Ltn][Error] "
        print(logTag + "\(error).")
    }
    
    func onConnected() {
        let logTag = "[Sub][Ltn][Con] "
        mcMan.setSubState(to: .connected)
        print(logTag + "Connected to Millicast.")
        mcMan.subStart()
        print(logTag + "Trying to subscribe to Millicast.")
    }
    
    func onConnectionError(_ status: Int32, withReason reason: String!) {
        let logTag = "[Sub][Ltn][Con][Error] "
        mcMan.setSubState(to: .disconnected)
        mcMan.showAlert(logTag + "Failed to connect as \(reason!)! Status: \(status)")
    }
    
    func onStopped() {
        let logTag = "[Sub][Ltn][Stop] "
        print(logTag + "OK.")
    }
    
    func onSignalingError(_ error: String) {
        let logTag = "[Sub][Ltn][Error][Sig] "
        print(logTag + "\(error).")
    }
    
    func onStatsReport(_ report: MCStatsReport!) {
        let logTag = "[Sub][Ltn][Stat] "
        print(logTag + "\(report).")
    }
    
    func onAudioTrack(_ track: MCAudioTrack!, withMid: String) {
        let logTag = "[Sub][Ltn][Track][Audio] "
        let trackId = track.getId()
        print(logTag + "Name: \(trackId), TransceiverId: \(withMid) has been negotiated.")
        mcMan.subRenderAudio(track: track)
    }
    
    func onVideoTrack(_ track: MCVideoTrack!, withMid: String) {
        let logTag = "[Sub][Ltn][Track][Video] "
        let trackId = track.getId()
        print(logTag + "Name: \(trackId), TransceiverId: \(withMid) has been negotiated.")
        mcMan.subRenderVideo(track: track)
    }
    
    func onActive(_ _: String!, tracks: [String]!, sourceId: String!) {
        let logTag = "[Sub][Ltn][Active][Source][Id] "
        print(logTag + "OK.")
    }
    
    func onInactive(_ streamId: String!, sourceId: String!) {
        let logTag = "[Sub][Ltn][Active][In][Source][Id] "
        print(logTag + "OK.")
    }
    
    func onLayers(_ mid: String!, activeLayers: [MCLayerData]!, inactiveLayers: [MCLayerData]!) {
        let logTag = "[Sub][Ltn][Layer] "
        print(logTag + "OK.")
    }

    func onVad(_ mid: String!, sourceId: String!) {
        let logTag = "[Sub][Ltn][Vad][Source][Id] "
        print(logTag + "OK.")
    }
    
    func onViewerCount(_ count: Int32) {
        let logTag = "[Sub][Ltn][Viewer] "
        print(logTag + "Count: \(count).")
    }
}
