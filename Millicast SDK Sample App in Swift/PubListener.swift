//
//  PubListener.swift
//  Millicast SDK Sample App in Swift
//

import Foundation
import MillicastSDK

/**
 * Implementation of Publisher's Listener.
 * This handles events sent to the Publisher being listened to.
 */
class PubListener: MCPublisherListener {
    private var mcMan: MillicastManager
    private let tag = "[Pub][Ltn]"

    init() {
        let logTag = "\(tag) "
        mcMan = MillicastManager.getInstance()
        print(logTag + "PubListener created.")
    }
    
    func onPublishing() {
        let logTag = "\(tag)[On] "
        mcMan.setPubState(to: .publishing)
        print(logTag + "Publishing to Millicast.")
    }
    
    func onPublishingError(_ error: String!) {
        let logTag = "\(tag)[Error] "
        print(logTag + "\(String(describing: error)).")
    }

    func onConnected() {
        mcMan.setPubState(to: .connected)
        let logTag = "\(tag)[Con] "
        print(logTag + "Connected to Millicast.")
        mcMan.startPub()
        print(logTag + "Trying to publish to Millicast.")
    }
    
    func onConnectionError(_ status: Int32, withReason reason: String) {
        let logTag = "\(tag)[Con][Error] "
        mcMan.setPubState(to: .disconnected)
        mcMan.showAlert(logTag + "Failed to connect as \(reason)! Status: \(status)")
    }
    
    func onDisconnected() {
        let logTag = "\(tag)[Con][X] "
        print(logTag + "OK.")
    }
    
    func onSignalingError(_ error: String) {
        let logTag = "\(tag)[Error][Sig] "
        print(logTag + "\(error).")
    }
    
    func onStatsReport(_ report: MCStatsReport) {
        let logTag = "\(tag)[Stat] "
        print(logTag + mcMan.getStatsStr(MCOutboundRtpStreamStats.self, report: report))
        print(logTag + mcMan.getStatsStr(MCRemoteInboundRtpStreamStats.self, report: report))
    }
    
    func onViewerCount(_ count: Int32) {
        let logTag = "\(tag)[Viewer] "
        print(logTag + "Count: \(count).")
    }
    
    func onActive() {
        let logTag = "\(tag)[Viewer][Active] "
        print(logTag + "A viewer has subscribed to our stream.")
    }
    
    func onInactive() {
        let logTag = "\(tag)[Viewer][Active][In] "
        print(logTag + "No viewers are currently subscribed to our stream.")
    }
}
