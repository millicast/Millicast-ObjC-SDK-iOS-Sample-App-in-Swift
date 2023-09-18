//
//  SubListener.swift
//  Millicast SDK Sample App in Swift
//

import AVFAudio
import Foundation
import MillicastSDK
import UIKit

/**
 * Implementation of Subscriber's Listener.
 * This handles events sent to the Subscriber being listened to.
 */
class SubListener: MCSubscriberListener {
    private var mcMan: MillicastManager
    private let tag = "[Sub][Ltn]"
    
    init() {
        let logTag = "\(tag) "
        mcMan = MillicastManager.getInstance()
        print(logTag + "SubListener created.")
    }
    
    func onSubscribed() {
        let logTag = "\(tag)[On] "
        mcMan.setSubState(to: .subscribing)
        print(logTag + "Subscribing to Millicast.")
    }
    
    func onSubscribedError(_ error: String) {
        let logTag = "\(tag)[Error] "
        print(logTag + "\(error).")
    }
    
    func onConnected() {
        let logTag = "\(tag)[Con] "
        mcMan.setSubState(to: .connected)
        print(logTag + "Connected to Millicast.")
        mcMan.startSub()
        print(logTag + "Trying to subscribe to Millicast.")
    }
    
    func onConnectionError(_ status: Int32, withReason reason: String) {
        let logTag = "\(tag)[Con][Error] "
        mcMan.setSubState(to: .disconnected)
        mcMan.showAlert(logTag + "Failed to connect as \(reason)! Status: \(status)")
    }
    
    func onDisconnected() {
        let logTag = "\(tag)[Con][X] "
        print(logTag + "OK.")
    }
    
    func onStopped() {
        let logTag = "\(tag)[Stop] "
        print(logTag + "OK.")
    }
    
    func onSignalingError(_ error: String) {
        let logTag = "\(tag)[Error][Sig] "
        print(logTag + "\(error).")
    }
    
    func onStatsReport(_ report: MCStatsReport) {
        let logTag = "\(tag)[Stat] "
        print(logTag + mcMan.getStatsStr(MCInboundRtpStreamStats.self, report: report))
        print(logTag + mcMan.getStatsStr(MCRemoteOutboundRtpStreamStats.self, report: report))
    }
    
    func onAudioTrack(_ track: MCAudioTrack, withMid: String) {
        let logTag = "\(tag)[Track][Audio] "
        let trackId = track.getId()
        print(logTag + "Name: \(String(describing: trackId)), TransceiverId: \(withMid) has been negotiated.")
        mcMan.subRenderAudio(track: track)
    }
    
    func onVideoTrack(_ track: MCVideoTrack, withMid: String) {
        let logTag = "\(tag)[Track][Video] "
        let trackId = track.getId()
        print(logTag + "Name: \(String(describing: trackId)), TransceiverId: \(withMid) has been negotiated.")
        mcMan.renderVideoSub(track: track)
    }
    
    func onActive(_ _: String, tracks: [String], sourceId: String) {
        let logTag = "\(tag)[Active][Source][Id]"
        for track in tracks {
            let split = track.split(separator: "/")
            let type = String(split[0])
            let trackId = String(split[1])
            
            if type == "audio" {
                print(logTag + "[Audio] TrackId: \(trackId)")
            } else {
                print(logTag + "[Video] TrackId: \(trackId)")
            }
        }
        print(logTag + "OK.")
    }
    
    func onInactive(_ streamId: String, sourceId: String) {
        let logTag = "\(tag)[Active][In][Source][Id] "
        print(logTag + "OK.")
    }
    
    func onLayers(_ mid: String, activeLayers: [MCLayerData], inactiveLayers: [MCLayerData]) {
        let logTag = "\(tag)[Layer] "
        print(logTag + "OK.")
    }

    func onVad(_ mid: String, sourceId: String) {
        let logTag = "\(tag)[Vad][Source][Id] "
        print(logTag + "OK.")
    }
    
    func onViewerCount(_ count: Int32) {
        let logTag = "\(tag)[Viewer] "
        print(logTag + "Count: \(count).")
    }
}
