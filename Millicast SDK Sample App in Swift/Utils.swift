//
//  Utils.swift
//  Millicast SDK Sample App in Swift
//

import AVFAudio
import Foundation

/**
 * Utility methods used in the SA.
 */
class Utils {
    static var dateFormatter: DateFormatter?

    public static func getDateFormatter() -> DateFormatter? {
        if dateFormatter == nil {
            dateFormatter = DateFormatter()
            dateFormatter!.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        }
        return dateFormatter
    }

    public static func timeStr() -> String {
        guard let df = getDateFormatter() else {
            return "No-time"
        }
        return df.string(from: Date())
    }

    /**
     * Gets a String representing the specified CredentialSource.
     */
    public static func getCredStr(creds: CredentialSource) -> String {
        let str = "Account ID: \(creds.getAccountId())\n\t" +
            "Publishing stream name: \(creds.getStreamNamePub())\n\t" +
            "Subscribing stream name: \(creds.getStreamNameSub())\n\t" +
            "Publishing token: \(creds.getTokenPub())\n\t" +
            "Subscribing token: \(creds.getTokenSub())\n\t" +
            "Publishing API url: \(creds.getApiUrlPub())\n\t" +
            "Subscribing API url: \(creds.getApiUrlSub())\n\t"
        return str
    }

    /**
     * Configures the AVAudioSession to use, based on whether audio capture is required:
     * When audio recording is not required:
     * - Category: playback; Category Option: mixWithOthers.
     *  - This will allow:
     *   - Playback with Bluetooth A2DP device, which has better audio quality than Bluetooth Hands-Free Profile (HFP), and also supports stereo.
     * When audio recording is required:
     * - Category: playAndRecord; Category Option: mixWithOthers, allowBluetooth, allowBluetoothA2DP.
     *  - This will allow:
     *   - Audio recording where needed on iOS.
     *   - Playback with Bluetooth A2DP on paired device that only supports A2DP - if the device supports both HFP and A2DP, HFP will be preferred by iOS.
     * - Mode videoChat, which will optimise the audio for voice and allow Bluetooth Hands-Free Profile (HFP) device as input and output.
     * In all cases:
     * - Audio will default to the device's speakers when no other audio route is connected.
     * - Audio can playback in the backgroud, and even when the screen is locked.
     * - Audio can mix with audio from other apps that also allow mixing.
     * For full control of the AVAudioSession, this method should be called:
     * - When starting audio capture, for e.g. at MillicastManager.startCaptureAudio().
     * - When stopping audio capture, for e.g. at MillicastManager.stopCaptureAudio().
     * - When the Subscriber's audioTrack is rendered, for e.g. at MillicastManager.subRenderAudio(track: MCAudioTrack?).
     */
    public static func configureAudioSession(isCapturing: Bool) {
        let logTag = "[Configure][Audio][Session][SDK] "
        var task = { [] in
            let session = AVAudioSession.sharedInstance()
            print(timeStr() + logTag + "Now: " + Utils.audioSessionStr(session: session))
            do {
                if isCapturing {
                    #if os(iOS)
                    print(logTag + "Audio is capturing.")
                    // videoChat mode automatically enables allowBluetooth option.
                    try session.setCategory(AVAudioSession.Category.playAndRecord, mode: .videoChat, options: [.mixWithOthers, .allowBluetooth, .allowBluetoothA2DP])
                    print(logTag + "Category set: playAndRecord.")
                    #endif
                } else {
                    print(logTag + "Audio NOT capturing.")

                    // iOS automatically routes to A2DP ports in playback category.
                    try session.setCategory(AVAudioSession.Category.playback, options: [.mixWithOthers])
                    print(logTag + "Category set: playback.")
                }
            } catch {
                print(logTag + "Failed! Error: \(error)")
                return
            }
            do {
                try session.setActive(true)
                print(logTag + "Session set to active.")
            } catch {
                print(logTag + "Failed! Could not activate session. Error: \(error)")
                return
            }
            print(logTag + "OK. " + Utils.audioSessionStr(session: session))
        }
        MillicastManager.getInstance().runOnMain(logTag: logTag, log: "Configure AudioSession", task)
    }

    /**
     * Sets the AVAudioSession to active or not active as indicated by the parameter.
     */
    public static func setAudioSession(active: Bool) {
        #if os(iOS)
        let logTag = "[Configure][Audio][Session][Active] "
        let session = AVAudioSession.sharedInstance()
        do {
            if active {
                try session.setActive(true)
            } else {
                try session.setActive(false, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
            }
        } catch {
            print(logTag + "Failed! Error: \(error)")
            return
        }
        print(logTag + "OK. SetActive \(active).")
        #endif
    }

    /**
     * Gets a String representing characteristics of the current AVAudioSession.
     */
    public static func audioSessionStr(session: AVAudioSession) -> String {
        let cat = String(describing: session.category.rawValue)
        let catOpts = audioCatOptStr(value: session.categoryOptions.rawValue)
        let mode = String(describing: session.mode.rawValue)
        let gain = session.inputGain
        let vol = session.outputVolume
        let channelNumIn = session.inputNumberOfChannels
        let channelNumOut = session.outputNumberOfChannels
        let portsIn = inputAudioStr(route: session.currentRoute)
        let portsOut = outputAudioStr(route: session.currentRoute)
        var oriIn = "-"
        #if os(iOS)
        oriIn = String(describing: session.inputOrientation.rawValue)
        #endif

        let str = "AVAudioSession: Category:\(cat) options:\(catOpts) Mode:\(mode) Gain:\(gain) Vol:\(vol) Channels in:\(channelNumIn) out:\(channelNumOut) Ports in:\(portsIn) out:\(portsOut) orientation:\(oriIn)."
        return str
    }

    /**
     * Gets a String representing the specified AVAudioSession.CategoryOptions.
     */
    public static func audioCatOptStr(value: UInt) -> String {
        var opt = AVAudioSession.CategoryOptions(rawValue: value)
        var str = ""

        addOptToStr(catOpt: .mixWithOthers, desc: "mixWithOthers")
        addOptToStr(catOpt: .duckOthers, desc: "duckOthers")
        #if os(iOS)
        addOptToStr(catOpt: .allowBluetooth, desc: "allowBluetooth")
        addOptToStr(catOpt: .defaultToSpeaker, desc: "defaultToSpeaker")
        #endif
        addOptToStr(catOpt: .interruptSpokenAudioAndMixWithOthers, desc: "interruptSpokenAudioAndMixWithOthers")
        addOptToStr(catOpt: .allowBluetoothA2DP, desc: "allowBluetoothA2DP")
        addOptToStr(catOpt: .allowAirPlay, desc: "allowAirPlay")
        #if os(iOS)
        addOptToStr(catOpt: .overrideMutedMicrophoneInterruption, desc: "overrideMutedMicrophoneInterruption")
        #endif

        if str.isEmpty {
            str = "-"
        } else {
            str = String(str.dropFirst(1))
        }
        str = "[\(str)]"

        func addOptToStr(catOpt: AVAudioSession.CategoryOptions, desc: String) {
            if !opt.contains(catOpt) {
                return
            }
            str += "," + desc
        }

        return str
    }

    /**
     Logs the current and previous audio output device.
     */
    public static func audioOutputLog(userInfo: [AnyHashable: Any]) -> String {
        var log = ""
        // Get current
        let session = AVAudioSession.sharedInstance()
        let routeCur = session.currentRoute
        let routeCurStr = outputAudioStr(route: routeCur)
        log += "Cur: \(routeCurStr), Old: "

        // Get previous
        guard let routePrev =
            userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription
        else {
            log += "None!"
            return log
        }

        let routePrevStr = outputAudioStr(route: routePrev)
        log += "\(routePrevStr)"

        return log
    }

    /**
     * Gets a String representation of the audio input port(s) in the given AVAudioSessionRouteDescription.
     */
    public static func inputAudioStr(route routeDescription: AVAudioSessionRouteDescription) -> String {
        var ports = portStr(ports: routeDescription.inputs)
        return ports
    }

    /**
     * Gets a String representation of the audio output port(s) in the given AVAudioSessionRouteDescription.
     */
    public static func outputAudioStr(route routeDescription: AVAudioSessionRouteDescription) -> String {
        var ports = portStr(ports: routeDescription.outputs)
        return ports
    }

    /**
     * Gets a String representation of the given list of AVAudioSessionPortDescription.
     */
    public static func portStr(ports: [AVAudioSessionPortDescription]) -> String {
        var portStr = ""
        for port in ports {
            portStr += "\(port.portType.rawValue),"
        }
        if portStr != "" {
            portStr.removeLast()
        }
        return portStr
    }

    /**
     * Gets a String value from UserDefaults, if available.
     * If not, return the specified defaultValue.
     */
    public static func getValue(tag: String, key: String, defaultValue: String) -> String {
        var value: String
        var log = ""

        if let savedValue = UserDefaults.standard.string(forKey: key) {
            log = "Used saved UserDefaults."
            value = savedValue
        } else {
            value = defaultValue
            log = "No UserDefaults, used default value."
        }
        log = "\(tag) \(value) - \(log)"
        print(log)
        return value
    }

    /**
     * Gets an integer value from UserDefaults, if available.
     * If not, return the specified defaultValue.
     */
    public static func getValue(tag: String, key: String, defaultValue: Int) -> Int {
        var value: Int
        var log = ""

        if let savedValue = UserDefaults.standard.object(forKey: key) {
            log = "Used saved UserDefaults."
            value = savedValue as! Int
        } else {
            value = defaultValue
            log = "No UserDefaults, used default value."
        }
        log = "\(tag) \(value) - \(log)"
        print(log)
        return value
    }

    /**
     * Given a list of specified size and the current index, gets the next index.
     * If at end of list, cycle to start of the other end.
     * Returns null if none available.
     *
     * @param size      Size of the list.
     * @param now       Current index of the list.
     * @param ascending If true, cycle in the direction of increasing index,
     *                  otherwise cycle in opposite direction.
     * @param logTag
     * @return
     */
    public static func indexNext(size: Int, now: Int, ascending: Bool, logTag: String) -> Int {
        var next: Int
        if ascending {
            if now >= (size - 1) {
                next = 0
                print(logTag + "\(next) (Cycling back to start)")
            } else {
                next = now + 1
                print(logTag + "\(next) Incrementing index.")
            }
        } else {
            if now <= 0 {
                next = size - 1
                print(logTag + "\(next) (Cycling back to end)")
            } else {
                next = now - 1
                print(logTag + "\(next) Decrementing index.")
            }
        }
        print(logTag + "Next: " + "\(next) Now: \(now)")
        return next
    }
}
