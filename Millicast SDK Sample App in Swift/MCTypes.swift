//
//  MCTypes.swift
//  Millicast SDK Sample App in Swift
//

import Foundation
import MillicastSDK
/**
 * Enums for types used in the Sample App.
 */

/**
 * The type of BitrateSettings referred to.
 */
enum Bitrate {
    /**
     * startBitrateKbps
     */
    case START
    /**
     * minBitrateKbps
     */
    case MIN
    /**
     * maxBitrateKbps
     */
    case MAX
}




struct VideoSourceWrapper : Identifiable{
    let source: MCVideoSource
    let id :Int
}

struct AudioSourceWrapper: Identifiable{
    let source: MCAudioSource
    let id: Int
}

struct CapabilityWrapper: Identifiable{
    let capability: MCVideoCapabilities
    let id : Int
}

struct CodecWrapper:Identifiable{
    let codec:String
    let id: Int
}

struct AudioPlaybackWrapper: Identifiable{
    let audioPlayback: MCAudioPlayback
    let id: Int
}
