//
//  MCStates.swift
//  Millicast SDK Sample App in Swift
//
//  Created by CoSMo Software on 26/8/21.
//

import Foundation

enum CaptureState {
    case notCaptured
    case tryCapture
    case isCaptured
}

enum PublisherState {
    case disconnected
    case connecting
    case connected
    case publishing
}

enum SubscriberState {
    case disconnected
    case connecting
    case connected
    case subscribing
}
