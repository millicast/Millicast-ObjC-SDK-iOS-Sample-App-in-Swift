//
//  RecListener.swift
//  Millicast SDK Sample App in Swift
//

import Foundation
import MillicastSDK

/**
 * Implementation of Publisher's Recording Listener.
 * This handles events sent to the Publisher regarding recording events.
 */
class RecListener: MCRecordingListener {
    
    
    private var mcMan: MillicastManager
    private let tag = "[Pub][RecLtn]"
    
    init() {
        let logTag = "\(tag) "
        mcMan = MillicastManager.getInstance()
        print(logTag + "RecListener created.")
    }
    
    func ownRecordingStarted() {
        print(tag + "Started recording the active stream")
        mcMan.setRecordingEnabled(enabled: true)
    }
    
    func ownRecordingStopped() {
        print(tag + "Stopped recording the active stream")
        mcMan.setRecordingEnabled(enabled: false)
    }
    
    func failedToStartRecording() {
        print(tag + "Failed to start recording the active stream")
    }
    
    func failedToStopRecording() {
        print(tag + "Failed to stop recording the active stream")
    }
}
