//
//  MillicastManager.swift
//  Millicast SDK Sample App in Swift
//
//  Created by CoSMo Software on 6/8/21.
//

import AVFoundation
import Foundation
import MillicastSDK

class MillicastManager: ObservableObject {
    @Published var alert = false
    var alertMsg = ""

    let queuePub = DispatchQueue(label: "mc-QPub", qos: .userInitiated)
    let queueSub = DispatchQueue(label: "mc-QSub", qos: .userInitiated)
    let queueLabelKey = DispatchSpecificKey<String>()

    static var instance: MillicastManager!

    @Published var capState: CaptureState = .notCaptured
    @Published var pubState: PublisherState = .disconnected
    @Published var subState: SubscriberState = .disconnected

    // Mute states of audio/video.
    @Published var pubAudioEnabled = false
    @Published var pubVideoEnabled = false
    @Published var subAudioEnabled = false
    @Published var subVideoEnabled = false
    var ndiOutputVideo = false
    var ndiOutputAudio = false

    var savedCreds: SavedCreds!
    var pubCreds: MCPublisherCredentials!
    var subCreds: MCSubscriberCredentials!

    var audioSourceList: [MCAudioSource]?
    let audioSourceIndexKey = "AUDIO_SOURCE_INDEX"
    var audioSourceIndexDefault = 0
    @Published var audioSourceIndex: Int
    var audioSource: MCAudioSource?

    var videoSourceList: [MCVideoSource]?
    let videoSourceIndexKey = "VIDEO_SOURCE_INDEX"
    var videoSourceIndexDefault = 0
    @Published var videoSourceIndex: Int
    var videoSource: MCVideoSource?

    var capabilityList: [MCVideoCapabilities]?
    let capabilityIndexKey = "CAPABILITY_INDEX"
    var capabilityIndexDefault = 0
    @Published var capabilityIndex: Int
    var capability: MCVideoCapabilities?

    var audioCodecList: [String]?
    let audioCodecIndexKey = "AUDIO_CODEC_INDEX"
    var audioCodecIndexDefault = 0
    @Published var audioCodecIndex: Int
    var defaultAudioCodec = "OPUS"
    var audioCodec: String?

    var videoCodecList: [String]?
    let videoCodecIndexKey = "VIDEO_CODEC_INDEX"
    var videoCodecIndexDefault = 0
    @Published var videoCodecIndex: Int
    var defaultVideoCodec = "H264"
    var videoCodec: String?

    /**
     * The list of AudioPlayback devices available for us to play subscribed audio.
     * The desired device must be selected and initiated (initPlayback)
     * before the AudioTrack is subscribed.
     */
    var audioPlaybackList: [MCAudioPlayback]?
    let audioPlaybackIndexKey = "AUDIO_PLAYBACK_INDEX"
    var audioPlaybackIndexDefault = 0
    @Published var audioPlaybackIndex: Int
    var audioPlayback: MCAudioPlayback?

    var pubAudioTrack: MCAudioTrack?
    var subAudioTrack: MCAudioTrack?
    var pubVideoTrack: MCVideoTrack?
    var subVideoTrack: MCVideoTrack?
    var pubRenderer: MCIosVideoRenderer?
    var subRenderer: MCIosVideoRenderer?

    var publisher: MCPublisher?
    var subscriber: MCSubscriber?

    // Options objects
    var optionsPub: MCClientOptions
    var optionsSub: MCClientOptions

    // View objects
    var pubListener: PubListener?
    var subListener: SubListener?

    private init() {
        // Set some preferences
        audioSourceIndex = Utils.getValue(tag: "[McMan][init][Audio][Source][Index]", key: audioSourceIndexKey, defaultValue: audioSourceIndexDefault)
        audioPlaybackIndex = audioPlaybackIndexDefault
        videoSourceIndex = Utils.getValue(tag: "[McMan][init][Video][Source][Index]", key: videoSourceIndexKey, defaultValue: videoSourceIndexDefault)
        capabilityIndex = Utils.getValue(tag: "[McMan][init][Capability][Index]", key: capabilityIndexKey, defaultValue: capabilityIndexDefault)
        audioCodecIndex = Utils.getValue(tag: "[McMan][init][Audio][Codec][Index]", key: audioCodecIndexKey, defaultValue: audioCodecIndexDefault)
        videoCodecIndex = Utils.getValue(tag: "[McMan][init][Video][Codec][Index]", key: videoCodecIndexKey, defaultValue: videoCodecIndexDefault)

        audioCodec = defaultAudioCodec
        videoCodec = defaultVideoCodec

        optionsPub = MCClientOptions()
        optionsPub.stereo = true
        optionsPub.videoCodec = defaultVideoCodec

        optionsSub = MCClientOptions()

        queuePub.setSpecific(key: queueLabelKey, value: queuePub.label)
        queueSub.setSpecific(key: queueLabelKey, value: queueSub.label)

        // Set credentials
        savedCreds = SavedCreds()
        // Publishing
        pubCreds = MCPublisherCredentials()
        // Subscribing
        subCreds = MCSubscriberCredentials()
        setCreds(using: savedCreds, save: false)

        // Set indices
        setAudioSourceIndex(audioSourceIndex)
        setVideoSourceIndex(videoSourceIndex, setCapIndex: true)
    }

    // *********************************************************************************************
    // APIs
    // *********************************************************************************************

    // *********************************************************************************************
    // Millicast platform
    // *********************************************************************************************

    static func getInstance()->MillicastManager {
        if instance == nil {
            instance = MillicastManager()
        }
        return instance
    }

    /**
     Read Millicast credentials and set into MillicastManager using CredentialSource.
     */
    public func setCreds(using credsSrc: CredentialSource, save: Bool) {
        print("[McMan][setCreds] Account ID: \(credsSrc.getAccountId())\nPublishing stream name: \(credsSrc.getPubStreamName())\nSubscribing stream name: \(credsSrc.getSubStreamName())\nPublishing token: \(credsSrc.getPubToken())\nPublishing API url: \(credsSrc.getPubApiUrl())\nSubscribing API url: \(credsSrc.getSubApiUrl())\n")

        // Publishing
        pubCreds.streamName = credsSrc.getPubStreamName()
        pubCreds.token = credsSrc.getPubToken()
        pubCreds.apiUrl = credsSrc.getPubApiUrl()
        // Subscribing
        subCreds.accountId = credsSrc.getAccountId()
        subCreds.streamName = credsSrc.getSubStreamName()
        subCreds.apiUrl = credsSrc.getSubApiUrl()

        if save {
            // Set new values into UserDefaults
            UserDefaults.standard.setValue(credsSrc.getAccountId(), forKey: savedCreds.accountId)
            UserDefaults.standard.setValue(credsSrc.getPubStreamName(), forKey: savedCreds.pubStreamName)
            UserDefaults.standard.setValue(credsSrc.getSubStreamName(), forKey: savedCreds.subStreamName)
            UserDefaults.standard.setValue(credsSrc.getPubToken(), forKey: savedCreds.pubToken)
            UserDefaults.standard.setValue(credsSrc.getPubApiUrl(), forKey: savedCreds.pubApiUrl)
            UserDefaults.standard.setValue(credsSrc.getSubApiUrl(), forKey: savedCreds.subApiUrl)
        }
    }

    // *********************************************************************************************
    // Select/Switch videoSource, capability.
    // *********************************************************************************************

    /**
     * Get or generate (if nil) the current list of AudioSources available.
     *
     */
    public func getAudioSourceList(refresh: Bool = false)->[MCAudioSource]? {
        var logTag = "[Audio][Source][List] "
        if audioSourceList == nil || refresh {
            print(logTag + "Getting new audioSourceList.")
            // Get new audioSources.
            audioSourceList = MCMedia.getAudioSources()
            if audioSourceList == nil {
                print(logTag + "No audioSource is available!")
                return nil
            }
        } else {
            print(logTag + "Using existing audioSources.")
        }

        // Print out list of audioSources.
        print(logTag + "Checking for audioSources...")
        var size = audioSourceList!.count
        if size < 1 {
            print(logTag + "No audioSource is available!")
            return nil
        } else {
            var log = logTag
            for (index, source) in audioSourceList!.enumerated() {
                log += "[\(index)]:" + getAudioSourceStr(source, longForm: true) + " "
            }
            print(log + ".")
        }

        return audioSourceList
    }

    public func getAudioSourceIndex()->Int {
        let log = "[Audio][Source][Index] \(audioSourceIndex)."
        print(log)
        return audioSourceIndex
    }

    /**
     * Set the selected audioSource index to the specified value and save to device memory,
     * unless currently capturing, in which case no change will be made.
     * If set, a new audioSource will be set using this value.
     *
     * @param newValue The new value to be set.
     * @return true if new index set, false otherwise.
     */
    public func setAudioSourceIndex(_ newValue: Int)->Bool {
        var logTag = "[Audio][Source][Index][Set] "

        // If currently capturing, do not set new audioSourceIndex.
        if isAudioCaptured() {
            var log = "NOT setting to \(newValue) as currently capturing.\n" +
                "Captured: \(getAudioSourceStr(audioSource, longForm: true)) Capturing: \(audioSource?.isCapturing())."
            print(logTag + log)
            return false
        }

        let task = { [self] in
            audioSourceIndex = newValue
            UserDefaults.standard.setValue(audioSourceIndex, forKey: audioSourceIndexKey)
        }
        runOnMain(logTag: logTag, log: "Set AudioSource Index", task)

        // Set new audioSource.
        setAudioSource()
        print("\(logTag) OK.")
        return true
    }

    /**
     * Get or generate (if nil) the current list of VideoSources available.
     *
     * @param refresh
     */
    public func getVideoSourceList(refresh: Bool = false)->[MCVideoSource]? {
        var logTag = "[Video][Source][List] "
        if videoSourceList == nil || refresh {
            print(logTag + "Getting new videoSources.")
            // Get new videoSources.
            videoSourceList = MCMedia.getVideoSources()
            if videoSourceList == nil {
                print(logTag + "No videoSource is available!")
                return nil
            }
        } else {
            print(logTag + "Using existing videoSources.")
        }

        // Print out list of videoSources.
        print(logTag + "Checking for videoSources...")
        let size = videoSourceList!.count
        if size < 1 {
            print(logTag + "No videoSource is available!")
            return nil
        } else {
            var log = logTag
            for (index, source) in videoSourceList!.enumerated() {
                log += "[\(index)]:" + getVideoSourceStr(source, longForm: true) + " "
            }
            print(log + ".")
        }

        return videoSourceList
    }

    public func getVideoSourceIndex()->Int {
        let log = "[Video][Source][Index] \(videoSourceIndex)."
        print(log)
        return videoSourceIndex
    }

    /**
     * Set the selected videoSource index to the specified value and save to device memory,
     * unless currently capturing, in which case no change will be made.
     * If set, a new videoSource will be set using this value.
     * New capabilityList and capability will also be set using the new videoSource.
     * This on its own will not start capturing on a new videoSource.
     *
     * @param newValue    The new value to be set.
     * @param setCapIndex If true, will setCapabilityIndex with current value to update capability.
     * @return nil if {@link #videoSourceIndex} could be set, else an error message might be returned.
     */
    public func setVideoSourceIndex(_ newValue: Int, setCapIndex: Bool)->String? {
        let logTag = "[Video][Source][Index][Set] "

        // If currently capturing, do not set new videoSourceIndex.
        if isVideoCaptured() {
            var log = "NOT setting to \(newValue) as currently capturing.\n" +
                "Captured: \(getVideoSourceStr(videoSource, longForm: true)) Capturing: \(videoSource?.isCapturing())."
            print(logTag + log)
            return log
        }

        let task = { [self] in
            videoSourceIndex = newValue
            UserDefaults.standard.setValue(videoSourceIndex, forKey: videoSourceIndexKey)
        }
        runOnMain(logTag: logTag, log: "Set VideoSource Index", task)

        // Set new videoSource or videoSourceSwitched.
        setVideoSource()

        // Set new capabilityList as it might have changed.
        print(logTag + "Setting new capabilityList again.")
        setCapabilityList()
        if setCapIndex {
            print(logTag + "Checking if capabilityIndex" +
                " needs to be reset by setting capability again with current value...")
            // Set capability again as videoSource has changed.
            setCapabilityIndex(capabilityIndex)
        } else {
            print(logTag + "Not setting capabilityIndex again.")
        }
        print(logTag + "OK.")
        return nil
    }

    public func getCapabilityList()->[MCVideoCapabilities]? {
        let logTag = "[Capability][List] "

        guard let list = capabilityList else {
            print(logTag + "No capability is available!")
            return nil
        }

        let size = (list.count)
        if size < 1 {
            print(logTag + "List is empty! Size: \(size)!")
        } else {
            var log = logTag
            for (index, cap) in list.enumerated() {
                log += "[\(index)]:" + getCapabilityStr(cap) + " "
            }
            print(log + ".")
        }
        return list
    }

    public func getCapabilityIndex()->Int {
        let log = "[Capability][Index] \(capabilityIndex)."
        print(log)
        return capabilityIndex
    }

    /**
     * Set the selected capability index to the specified value and save to device memory.
     * A new capability will be set using this value.
     * This capability will be set into the videoSource, if available.
     *
     * @param newValue The new value to be set.
     */
    public func setCapabilityIndex(_ newValue: Int) {
        // Set new value into SharePreferences.
        let logTag = "[Capability][Index][Set] "

        let task = { [self] in
            capabilityIndex = newValue
            UserDefaults.standard.setValue(capabilityIndex, forKey: capabilityIndexKey)
        }
        runOnMain(logTag: logTag, log: "Set Capability Index", task)

        // Set new capability
        setCapability()
        print(logTag + "OK.")
    }

    // *********************************************************************************************
    // Switch Media
    // *********************************************************************************************

    /**
     * Select the next available audioSource on device.
     * This will set the audioSource to be used when capturing starts.
     * If at end of range of audioSources, cycle to start of the other end.
     * If capturing, switching audioSource will not be allowed.
     *
     * @param ascending If true, cycle in the direction of increasing index,
     * otherwise cycle in opposite direction.
     * @return nil if {@link #audioSource} could be set, else an error message might be returned.
     */
    public func switchAudioSource(ascending: Bool)->String? {
        var logTag = "[Audio][Source][Switch] "
        var error: String
        var newValue: Int?

        // If videoSource is already capturing, switch to only non-NDI videoSource.
        if isAudioCaptured() {
            error = "Failed! Unable to switch audioSource when capturing."
            print(logTag + error)
            return error
        }

        newValue = audioSourceIndexNext(ascending: ascending)

        if newValue == nil {
            error = "FAILED! Unable to get next audioSource!"
            print(logTag + error)
            return error
        }

        // Set new audioSource
        print(logTag + "Setting audioSource index to:\(newValue).")
        setAudioSourceIndex(newValue!)

        print(logTag + "OK.")
        return nil
    }

    /**
     * Stop capturing on current videoSource and switch to the next available videoSource on device and starts capturing.
     * If currently publishing, this would first stop publishing and disconnect from Millicast. After the next available videoSource is capturing, reconnect to Millicast and start publishing.
     * This can only be done when currently capturing.
     * @param ascending If true, cycle in the direction of increasing index,
     * otherwise cycle in opposite direction.
     */
    public func switchVideoSource(ascending: Bool) {
        queuePub.async { [self] in
            let logTag = "[Video][Source][Switch] "
            // Do not allow switching if capturing or publishing are not in stable states.
            switch capState {
                case .notCaptured: break
                case .tryCapture:
                    print(logTag + "FAILED as camera is trying to capture.")
                    return
                case .isCaptured: break
            }

            switch pubState {
                case .disconnected: break
                case .connecting:
                    print(logTag + "FAILED as publisher is trying to connect.")
                    return
                case .connected:
                    print(logTag + "FAILED as publisher is trying to publish or unpublish.")
                    return
                case .publishing: break
            }

            // If already publishing stop and publish again after capturing.
            var wasPublishing = false
            if publisher != nil {
                if publisher!.isPublishing() {
                    wasPublishing = true
                    print(logTag + "Is publishing now so will stop publishing first...")
                    pubStop()
                }
            }

            // Stop current capture, if any.
            stopCaptureVideo()
            // Set new camera index.
            guard let next = videoSourceIndexNext(ascending: ascending)
            else {
                print(logTag + "Failed as unable to get next camera!")
                return
            }

            let task = { [self] in
                print(logTag + "Setting videoSourceIndex to:\(next) and updating Capability for new VideoSource.")
                setVideoSourceIndex(next, setCapIndex: true)
            }

            runOnMain(logTag: logTag, log: "Setting index", task)

            // Start capture with new camera.
            print(logTag + "Starting capture again with new index: \(next)...")
            startCaptureVideo()

            // Publish again if was previously publishing.
            if wasPublishing {
                print(logTag + "Was publishing so will try to connect and publish again...")
                pubConnect()
            }
        }
    }

    /**
     Select the next available camera.
     If at end of camera range, cycle back to start of range.
     This set the selection for the next capture, and can only be done when not actively capturing.
     */
    public func toggleVideoSource(ascending: Bool) {
        queuePub.async { [self] in
            let logTag = "[Video][Source][Toggle] "
            if let next = videoSourceIndexNext(ascending: ascending) {
                let task = { [self] in
                    print(logTag + "Setting videoSourceIndex to:\(next) and updating Capability for new VideoSource.")
                    setVideoSourceIndex(next, setCapIndex: true)
                }
                runOnMain(logTag: logTag, log: "Setting index", task)
                print(logTag + "Next videoSourceIndex set to \(next).")
            } else {
                print(logTag + "Failed as unable to get next camera!")
            }
        }
    }

    /**
     Select the next available resolution.
     If at end of resolution range, cycle back to start of range.
     This set the selection for the next capture, and can only be done when not actively capturing.
     */
    public func toggleCapability(ascending: Bool) {
        queuePub.async { [self] in
            let logTag = "[Capability][Toggle] "
            if let next = capabilityIndexNext(ascending: true) {
                let task = { [self] in
                    print(logTag + "Setting capabilityIndex to:\(next).")
                    capabilityIndex = next
                }
                runOnMain(logTag: logTag, log: "Setting index", task)
                print(logTag + "Next video capability index set to \(next).")
            } else {
                print(logTag + "Failed as unable to get next resolution!")
            }
        }
    }

    // *********************************************************************************************
    // Capture
    // *********************************************************************************************

    /**
     Start capturing both audio and video (based on selected videoSource).
     */
    public func startAudioVideoCapture() {
        queuePub.async { [self] in
            print("[Capture][Audio][Video][Start] Starting Capture...")
            startCaptureVideo()
            startCaptureAudio()
        }
    }

    /**
     Stop capturing both audio and video.
     */
    public func stopAudioVideoCapture() {
        queuePub.async { [self] in
            print("[Capture][Audio][Video][Stop] Stopping Capture...")
            stopCaptureVideo()
            stopCaptureAudio()
        }
    }

    /**
     Set the received videoTrack into MillicastManager.
     */
    public func setSubVideoTrack(track: MCVideoTrack) {
        subVideoTrack = track
    }

    /**
     Set the received audioTrack into MillicastManager.
     */
    public func setSubAudioTrack(track: MCAudioTrack) {
        subAudioTrack = track
    }

    // *********************************************************************************************
    // Mute / unmute audio / video.
    // *********************************************************************************************

    /**
     Toggle published/subscribed audio/video between enabled and disabled (i.e. muted) state.
     To do so for the publisher, set forPublisher to true, else it would be for the subscriber.
     To do so for audio, set isAudio to true, else it would be for video.
     */
    public func toggleMediaState(forPublisher isPub: Bool, forAudio isAudio: Bool) {
        var queue = queuePub
        if !isPub {
            queue = queueSub
        }

        var set: Bool?
        queue.async { [self] in
            if isPub {
                if isAudio {
                    set = enableTrack(track: pubAudioTrack, enable: !pubAudioEnabled)
                } else {
                    set = enableTrack(track: pubVideoTrack, enable: !pubVideoEnabled)
                }
            } else {
                if isAudio {
                    set = enableTrack(track: subAudioTrack, enable: !subAudioEnabled)
                } else {
                    set = enableTrack(track: subVideoTrack, enable: !subVideoEnabled)
                }
            }
            if set != nil {
                setMediaState(to: set!, forPublisher: isPub, forAudio: isAudio)
            }
        }
    }

    // *********************************************************************************************
    // Render
    // *********************************************************************************************

    public func getAudioPlaybackList()->[MCAudioPlayback]? {
        if audioPlaybackList == nil {
            audioPlaybackList = MCMedia.getPlaybackDevices()
        }
        var log = "[Audio][Playback][List] AudioPlaybackList is: \(audioPlaybackList)"
        print(log)
        return audioPlaybackList
    }

    public func getAudioPlaybackIndex()->Int {
        var log = "[Audio][Playback][Index]  \(audioPlaybackIndex)."
        print(log)
        return audioPlaybackIndex
    }

    /**
     * If not currently subscribed, this will set the selected audioPlaybackIndex
     * to the specified value and save to device memory.
     * A new audioPlayback will be set using this value.
     * If currently subscribed, no changes to the current audioPlayback will be made
     * as changes can only be made when there is no subscription on going.
     */
    public func setAudioPlaybackIndex(newValue: Int)->Bool {
        var logTag = "[Audio][Playback][Index][Set] "

        // If currently subscribing, do not set new audioSourceIndex.
        if isSubscribing() {
            print(logTag + "NOT setting to \(newValue) as currently subscribing.")
            print(logTag + "AudioPlayback:" +
                getAudioSourceStr(audioPlayback, longForm: true))
            return false
        }

        audioPlaybackIndex = newValue
        UserDefaults.standard.setValue(audioPlaybackIndex, forKey: audioPlaybackIndexKey)
        setAudioPlayback()
        return true
    }

    public func setRemoteAudioTrackVolume(volume: Double) {
        if isSubscribing(), subAudioTrack != nil {
            print("Setting audio track volume : \(volume)")
            subAudioTrack?.setVolume(volume)
        } else {
            print("Can't set audio volume")
        }
    }

    /**
     Get the VideoView that renders the published video.
     */
    public func getPubVideoView()->VideoView {
        let renderer = getPubRenderer()
        let videoView = VideoView(renderer: renderer)
        return videoView
    }

    /**
     Render again the video of the currently captured video (if any).
     */
    public func refreshPubVideo() {
        queuePub.async { [self] in
            if pubVideoTrack == nil {
                print("[refreshPubVideo] Unable to refresh as videoTrack does not exist.")
                return
            }
            pubVideoTrack!.remove(getPubRenderer())
            renderPubVideo()
            print("[refreshPubVideo] OK")
        }
    }

    /**
     Get the VideoView that renders the subscribed video.
     */
    public func getSubVideoView()->VideoView {
        let renderer = getSubRenderer()
        let videoView = VideoView(renderer: renderer)
        return videoView
    }

    /**
     Render the subscribed video.
     */
    public func renderSubVideo() {
        queueSub.async { [self] in
            let logTag = "[Video][Render][Sub] "
            if subVideoTrack == nil {
                showAlert(logTag + "Failed! videoTrack does not exist.")
                return
            }
            subVideoTrack?.add(getSubRenderer())
            print(logTag + "OK")
        }
    }

    // *********************************************************************************************
    // Publish - Codecs
    // *********************************************************************************************

    /**
     * Get or generate (if nil) the current list of Audio or Video Codec supported.
     *
     * @param forAudio
     * @return
     */
    public func getCodecList(forAudio: Bool)->[String]? {
        var logTag = "[Codec][List] "
        var log: String
        var codecList: [String]?
        if forAudio {
            logTag = "[Audio]" + logTag
            if audioCodecList == nil {
                audioCodecList = MCMedia.getSupportedAudioCodecs()
                log = logTag + "Getting new ones."
            } else {
                log = logTag + "Using existing."
            }
            codecList = audioCodecList
        } else {
            logTag = "[Video]" + logTag
            if videoCodecList == nil {
                videoCodecList = MCMedia.getSupportedVideoCodecs()
                log = logTag + "Getting new ones."
            } else {
                log = logTag + "Using existing."
            }
            codecList = videoCodecList
        }
        log += " Codecs are: \(codecList)"
        print(log)

        return codecList
    }

    public func getAudioCodecIndex()->Int? {
        return audioCodecIndex
    }

    public func getVideoCodecIndex()->Int? {
        return videoCodecIndex
    }

    /**
     * Set the selected codec index to the specified value and save to device memory.
     * A new videoCodec will be set using this value, unless the Publisher is publishing.
     * This videoCodec will be set into the Publisher, if it is available and not publishing.
     *
     * @param newValue The new value to be set.
     * @param forAudio
     * @return true if new index set, false otherwise.
     */
    public func setCodecIndex(newValue: Int, forAudio: Bool)->Bool {
        var logTag = "[Codec][Index][Set] "
        // Set new value into SharePreferences.
        var oldValue = videoCodecIndex
        var key = videoCodecIndexKey
        if forAudio {
            logTag = "[Audio]" + logTag
        } else {
            logTag = "[Video]" + logTag
        }
        if isPublishing() {
            print(logTag + "Failed! Unable to set new codec while publishing!")
            return false
        }

        if forAudio {
            oldValue = audioCodecIndex
            key = audioCodecIndexKey
            audioCodecIndex = newValue
        } else {
            videoCodecIndex = newValue
        }

        UserDefaults.standard.setValue(newValue, forKey: key)
        print(logTag + "Now: \(newValue) Was: \(oldValue)")

        // Set new codec
        setCodecs()
        return true
    }

    /**
     * Set the codec for publishing / subscribing to the next available codec.
     * This can only be done when not publishing / subscribing.
     * If at end of range of codec, cycle to start of the other end.
     *
     * @param ascending If true, "next" codec is defined in the direction of increasing index,
     *                  otherwise it is in the opposite direction.
     * @param forAudio
     */
    public func switchCodec(ascending: Bool, forAudio: Bool) {
        var logTag = "[Codec][Switch] "
        if forAudio {
            logTag = "[Audio]" + logTag
        } else {
            logTag = "[Video]" + logTag
        }

        var newValue = codecIndexNext(ascending: ascending, forAudio: forAudio)
        if newValue == nil {
            print(logTag + "FAILED! Unable to get next codec!")
            return
        }

        print(logTag + "Setting codec index to:\(newValue).")
        setCodecIndex(newValue: newValue!, forAudio: forAudio)

        print(logTag + "OK.")
    }

    // *********************************************************************************************
    // Connect
    // *********************************************************************************************

    /**
     Connect to Millicast for publishing.
     Publishing credentials required.
     Credentials specified in Constants.
     This uses the publishing dispatchQueue.
     */
    public func pubConnect() {
        var logTag = "[Pub][Con] "
        print(logTag + "Dispatching to queuePub...")
        let task = { [self] in
            // Create Publisher if not present
            guard let pub = getPublisher() else {
                print(logTag + "Failed! Publisher is not available!")
                return
            }

            if pub.isConnected() {
                print(logTag + "Not doing as we're already connected!")
                return
            }

            pub.setOptions(optionsPub)

            // Connect publiser.
            connectPublisher(pub: pub)
        }
        runOnQueue(logTag: logTag, log: "Connect Publisher", task, queuePub)
    }

    /**
     Connect to Millicast for subscribing.
     Subscribing credentials required.
     Credentials specified in Constants.
     */
    public func subConnect() {
        let logTag = "[Sub][Con] "
        let task = { [self] in
            // Create Subscriber if not present
            guard let sub = getSubscriber() else {
                print(logTag + "Failed as Subscriber is not available!")
                return
            }
            if sub.isSubscribed() {
                print(logTag + "Not subscribing as we're already subscribing!")
                return
            }

            if sub.isConnected() {
                print(logTag + "Not doing as we're already connected!")
                return
            }

            // Connect to Millicast
            print(logTag + "Connecting to Millicast...")
            connectSubscriber(sub: sub)
        }

        runOnQueue(logTag: logTag, log: "Connect Subscriber", task, queueSub)
    }

    // *********************************************************************************************
    // Publish
    // *********************************************************************************************

    /**
     * Add to Publisher the audio and video tracks that are already captured, and publish them.
     * Must first be connected to Millicast.
     * Stream name specified in Constants.
     */
    public func pubStart() {
        queuePub.async { [self] in
            let logTag = "[Pub][Start] "

            if isPublishing() {
                print(logTag + "Not publishing as we're already publishing!")
                return
            }

            if !(publisher?.isConnected() ?? false) {
                setPubState(to: .disconnected)
                print(logTag + "Failed! Publisher not connected!" +
                    " pubState is \(pubState).")
                return
            }

            if !isAudioVideoCaptured() {
                print(logTag + "Failed! Both audio & video are not captured.")
                return
            }

            if let audio = pubAudioTrack {
                publisher?.add(audio)
            }
            if let video = pubVideoTrack {
                publisher?.add(video)
            }

            setCodecs()

            publisher?.publish()
            print(logTag + "Trying...")
        }
    }

    /**
     Stop publishing and disconnect from Millicast.
     Does not affect capturing.
     This uses the publishing dispatchQueue.
     */
    public func pubStop() {
        let logTag = "[Pub][Stop] "
        print(logTag + "Dispatching to queuePub...")
        let task = { [self] in
            if !isPublishing() {
                print(logTag + "Not stopping as we are not publishing!")
                return
            }
            publisher?.unpublish()
            setPubState(to: .connected)
            print(logTag + " Stopped publish and going to disconnect...")

            disconnectPublisher(pub: publisher!)
            publisher = nil
        }
        runOnQueue(logTag: logTag, log: "Stop Publish", task, queuePub)
    }

    // *********************************************************************************************
    // Subscribe
    // *********************************************************************************************

    /**
     Subscribe to stream on Millicast.
     Must first be connected to Millicast.
     Stream name specified in Constants.
     */
    public func subStart() {
        queueSub.async { [self] in
            let logTag = "[Sub][Start] "

            if !(subscriber?.isConnected() ?? false) {
                setSubState(to: .disconnected)
                print(logTag + "Failed! Subscriber not connected!" +
                    " subState is \(subState).")
                return
            }

            // Subscribe to Millicast
            subscriber?.subscribe()
            print(logTag + "Trying...")
        }
    }

    /**
     Stop subscribing and disconnect from Millicast.
     Does not affect capturing.
     */
    public func subStop() {
        queueSub.async { [self] in
            let logTag = "[Sub][Stop] "

            if !isSubscribing() {
                print(logTag + "Not stopping as we are not publishing!")
                return
            }

            subscriber?.unsubscribe()
            setMediaState(to: false, forPublisher: false, forAudio: true)
            setMediaState(to: false, forPublisher: false, forAudio: false)
            setSubState(to: .connected)
            print(logTag + " Stopped subscribe and going to disconnect...")

            disconnectSubscriber(sub: subscriber!)
        }
    }

    // *********************************************************************************************
    // Utilities
    // *********************************************************************************************

    /**
     Show message as an alert on screen and print it on console as well.
     This will be run sync on the main thread.
     */
    public func showAlert(_ msg: String) {
        let logTag = "[Alert] "
        let task = { [self] in
            alertMsg = msg
            alert = true
            print(alertMsg)
        }
        runOnMain(logTag: logTag, task)
    }

    /**
     * Get the name of the currently selected audioSource, if any.
     *
     */
    public func getAudioSourceName()-> String {
        var name = "[\(audioSourceIndex)] "
        var log = "[Audio][Source][Name] Using "
        // Get audioSource name of selected index.
        name += getAudioSourceStr(getAudioSource(), longForm: true)
        log += "Selected: " + name
        print(log)
        return name
    }

    /**
     Get the name of the currently selected videoSource (camera name), if any.
     */
    public func getVideoSourceName()->String {
        var name = "[\(videoSourceIndex)] "
        var log = "[Video][Source][Name] Using "
        // Get videoSource name of selected index.
        name += getVideoSourceStr(getVideoSource(), longForm: true)
        log += "Selected: " + name
        print(log)
        return name
    }

    /**
     Get the currently selected capability (camera resolution) as a string, if any.
     */
    public func getCapabilityName()->String {
        var name = "[\(capabilityIndex)] "
        var log = "[Capability][Name] Using "
        // Get videoSource name of selected index.
        name += getCapabilityStr(getCapability())
        log += "Selected: " + name
        print(log)
        return name
    }

    /**
     * Get the name of the currently selected audio or video Codec.
     *
     * @param forAudio
     */
    public func getCodecName(forAudio: Bool)->String {
        var name = "[\(videoCodecIndex)] "
        var codec = videoCodec
        if forAudio {
            name = "[\(audioCodecIndex)] "
            codec = audioCodec
        }
        var log = "[Codec][Name] Using "
        // Get videoSource name of selected index.
        name += codec ?? "N.A"
        log += "Selected: " + name
        print(log)
        return name
    }

    // *********************************************************************************************
    // States
    // *********************************************************************************************

    public func setCapState(to newState: CaptureState, tag: String = "") {
        DispatchQueue.main.async { [self] in
            let oldState = capState
            capState = newState
            let logTag = "[setCapState]" + tag
            print("\(logTag) Now: \(self.capState)  Was: \(oldState)")
        }
    }

    public func setPubState(to newState: PublisherState, tag: String = "") {
        DispatchQueue.main.async {
            let oldState = self.pubState
            self.pubState = newState
            let logTag = "[setPubState]" + tag
            print("\(logTag) Now: \(self.pubState)  Was: \(oldState)")
        }
    }

    public func setSubState(to newState: SubscriberState, tag: String = "") {
        DispatchQueue.main.async {
            let oldState = self.subState
            self.subState = newState
            let logTag = "[setSubState]" + tag
            print("\(logTag) Now: \(self.subState)  Was: \(oldState)")
        }
    }

    public func setMediaState(to newState: Bool, forPublisher: Bool, forAudio: Bool) {
        DispatchQueue.main.async { [self] in
            var oldState: Bool
            var client = "Publisher"
            var media = "Audio"

            if forPublisher {
                if forAudio {
                    oldState = pubAudioEnabled
                    pubAudioEnabled = newState
                } else {
                    media = "Video"
                    oldState = pubVideoEnabled
                    pubVideoEnabled = newState
                }
            } else {
                client = "Subscriber"
                if forAudio {
                    oldState = subAudioEnabled
                    subAudioEnabled = newState
                } else {
                    media = "Video"
                    oldState = subVideoEnabled
                    subVideoEnabled = newState
                }
            }
            print("[setMediaState] \(client) \(media) Now: \(newState)  Was: \(oldState)")
        }
    }

    // *********************************************************************************************
    // Internal methods
    // *********************************************************************************************

    // *********************************************************************************************
    // Millicast platform
    // *********************************************************************************************

    // *********************************************************************************************
    // Select/Switch videoSource, capability.
    // *********************************************************************************************

    /**
     * Return the current audioSource.
     */
    private func getAudioSource()->MCAudioSource? {
        var logTag = "[Audio][Source][Get] "
        // Return audioSource.
        if audioSource == nil {
            print(logTag + "None.")
        } else {
            print(logTag + getAudioSourceStr(audioSource, longForm: true) + ".")
        }
        return audioSource
    }

    /**
     * Set the audioSource at the audioSourceIndex of the current audioSourceList
     * as the current audioSource, unless currently capturing.
     */
    private func setAudioSource() {
        var logTag = "[Audio][Source][Set] "

        // Create new audioSource based on index.
        var audioSourceNew: MCAudioSource?

        getAudioSourceList(refresh: false)
        if audioSourceList == nil {
            print(logTag + "Failed as no valid audioSource was available!")
            return
        }
        var size = audioSourceList!.count
        if size < 1 {
            print(logTag + "Failed as list size was \(size)!")
            return
        }

        // If the selected index is larger than size, set it to maximum size.
        // This might happen if the list of audioSources changed.
        if audioSourceIndex >= size {
            print(logTag + "Resetting index to \(size - 1) as it is greater than size of list (\(size))!")
            setAudioSourceIndex(size - 1)
            return
        }
        if audioSourceIndex < 0 {
            print(logTag + "Resetting index to 0 as it was negative!")
            setAudioSourceIndex(0)
            return
        }

        audioSourceNew = audioSourceList?[audioSourceIndex]

        var log: String
        if audioSourceNew != nil {
            log = getAudioSourceStr(audioSourceNew, longForm: true)
        } else {
            log = "None"
        }
        print(logTag + "New at index:\(audioSourceIndex) is: \(log).")

        // Set as new audioSource.
        audioSource = audioSourceNew
        print(logTag + "New at index:\(audioSourceIndex) is: \(log).")
    }

    private func getVideoSources()->[MCVideoSource]? {
        if videoSourceList == nil {
            print("[getVideoSources] Checking for videoSources...")
            videoSourceList = MCMedia.getVideoSources()
            let size = (videoSourceList!.count)
            if size < 1 {
                print("[getVideoSources] Failed as list size was \(size)!")
                return nil
            } else {
                var log = "[getVideoSources] "
                for index in 0 ..< size {
                    let vs = videoSourceList![index]
                    log += "[\(index)]:" + getVideoSourceStr(vs, longForm: true) + " "
                }
                print("\(log).")
            }
        } else {
            print("[getVideoSources] Using existing videoSources.")
        }
        return videoSourceList
    }

    /**
     * Return the current videoSource.
     */
    private func getVideoSource()->MCVideoSource? {
        var logTag = "[Video][Source][Get] "
        // Return videoSource.
        if videoSource == nil {
            print(logTag + "None.")
        } else {
            print(logTag + getVideoSourceStr(videoSource, longForm: true) + ".")
        }
        return videoSource
    }

    /**
     * Set the videoSource at the videoSourceIndex of the current videoSourceList
     * as the active videoSource.
     * The setting of active videoSource is defined as below:
     * If currently capturing: videoSourceSwitched.
     * Else: videoSource.
     */
    private func setVideoSource() {
        let logTag = "[Video][Source][Set] "

        // Create new videoSource based on index.
        var videoSourceNew: MCVideoSource?

        if getVideoSourceList(refresh: false) == nil {
            print(logTag + "Failed as no valid Source was available!")
            return
        }

        guard let size = getVideoSourceList(refresh: false)?.count else {
            print(logTag + "Failed as no valid Source List was available!")
            return
        }

        if size < 1 {
            print(logTag + "Failed as list size was \(size)!")
            return
        }

        // If the selected index is larger than size, set it to maximum size.
        // This might happen if the list of videoSources changed.
        if videoSourceIndex >= size {
            print(logTag + "Resetting index to \(size - 1) as it is greater than " +
                "size of list (\(size))!")
            setVideoSourceIndex(size - 1, setCapIndex: true)
            return
        }
        if videoSourceIndex < 0 {
            print(logTag + "Resetting index to 0 as it was negative!")
            setVideoSourceIndex(0, setCapIndex: true)
            return
        }

        videoSourceNew = getVideoSourceList()?[videoSourceIndex] ?? nil

        var log: String
        if videoSourceNew != nil {
            log = getVideoSourceStr(videoSourceNew, longForm: true)
        } else {
            log = "None"
        }

        // Set as new videoSource.
        videoSource = videoSourceNew
        print(logTag + "New at index:\(videoSourceIndex) is: \(log).")
    }

    /**
     * Set list of Capabilities supported by the active videoSource.
     * The active videoSource is selected as the first non-nil value (or nil if none is available)
     * in the following list:
     * videoSourceSwitched, videoSource.
     */
    private func setCapabilityList() {
        let logTag = "[Capability][List][Set] "
        var log = ""

        if capState != .notCaptured {
            print(logTag + "Failed! Only allowed to change resolution when not capturing. Capture state: \(capState). Current index: \(capabilityIndex)")
            return
        }

        guard let vs = videoSource else {
            log = "Failed! VideoSource does not exist."
            print(logTag + log)
            return
        }

        capabilityList = vs.getCapabilities()

        var size = 0
        if capabilityList != nil {
            size = capabilityList?.count ?? 0
        }

        if capabilityList == nil || size < 1 {
            print(logTag + "No capability is supported by selected videoSource (" +
                getVideoSourceStr(getVideoSource()) + ")!")
            return
        }

        print(logTag + "Checking for capabilities...")
        log = logTag + "VS(" + getVideoSourceStr(vs, longForm: true) + ") "
        for (index, cap) in capabilityList!.enumerated() {
            log += "[\(index)]:" + getCapabilityStr(cap) + " "
        }
        print(logTag + log + ".")
    }

    /**
     * Set the current capability at the capabilityIndex of the current capabilityList,
     * and in the videoSource if available.
     */
    private func setCapability() {
        let logTag = "[Capability][Set] "
        if capabilityList == nil {
            capability = nil
            print(logTag + "Failed as no list was available!")
            return
        }
        var size = capabilityList?.count ?? 0
        if size < 1 {
            capability = nil
            print(logTag + "Failed as list size was \(size)!")
            return
        }

        // If the selected index is larger than size, set it to maximum size.
        // This can happen when the videoSource has changed.
        if capabilityIndex >= size {
            print(logTag + "Resetting index to \(size - 1) as it is greater than " +
                "size of list (\(size)!")
            setCapabilityIndex(size - 1)
            return
        }
        if capabilityIndex < 0 {
            print(logTag + "Resetting index to 0 as it was negative!")
            setCapabilityIndex(0)
            return
        }

        capability = capabilityList?[capabilityIndex] ?? nil

        var log = ""
        if capability != nil {
            log = getCapabilityStr(capability)
        } else {
            log = "None"
        }
        print(logTag + "New at index:\(capabilityIndex) is: " + log + ".")

        if videoSource != nil {
            videoSource!.setCapability(capability)
            log = "OK. New set on videoSource to be captured (" +
                getVideoSourceStr(videoSource, longForm: true) + ")."
        } else {
            log = "Failed! VideoSource does not exist."
        }
        print(logTag + log)
    }

    /**
     Get selected Capability from VideoSource
     Some internal operation will be done sync on the main thread.
     */
    private func getCapability()->MCVideoCapabilities? {
        let logTag = "[Capability] "
        print("[getCapability]")

        // If not currently capturing, get a new one based on selected index.
        if capState != .isCaptured {
            print("[getCapability] Selecting a new one based on selected index.")

            if let caps = getCapabilityList() {
                let size = (caps.count)
                if size < 1 {
                    print("[getCapability] Failed as list size was \(size)!")
                    return nil
                }
                // If the selected index is larger than size, set it to maximum size.
                // This can happen when the videoSource has changed.
                if capabilityIndex >= size {
                    let task = { [self] in
                        print("[getCapability] Resetting capabilityIndex as it is greater than number of capabilities available (\(size))!")
                        capabilityIndex = size - 1
                    }
                    runOnMain(logTag: logTag, log: "Resetting index", task)
                }
                capability = caps[capabilityIndex]
            } else {
                print("[getCapability] Failed as no valid capability was available!")
                return nil
            }

            var log: String
            if let sc = capability {
                log = getCapabilityStr(sc)
            } else {
                log = "None"
            }
            print("[getCapability] Selected at index:\(capabilityIndex) is: \(log).")
            return capability
        }

        // If already capturing, return the existing one.
        if let cap = capability {
            print("[getCapability] Using existing capability: \(getCapabilityStr(cap)) as we only select a new one while capturing.")
        } else {
            print("[getCapability] FAILED! Unable to get new capability as current captureState is \(capState), and existing capability does not exist!")
        }
        return capability
    }

    // *********************************************************************************************
    // Switch Media
    // *********************************************************************************************

    /**
     * Gets the index of the next available audioSource.
     * If at end of audioSource range, cycle to start of the other end.
     * Returns nil if none available.
     *
     * @param ascending If true, cycle in the direction of increasing index,
     *                  otherwise cycle in opposite direction.
     */
    private func audioSourceIndexNext(ascending: Bool)->Int? {
        var logTag = "[Source][Index][Next][Audio] "
        let size = getAudioSourceList(refresh: false)?.count ?? 0
        if size < 1 {
            print(logTag + "Failed as the device does not have a audioSource!")
            return nil
        }
        var now = audioSourceIndex
        return Utils.indexNext(size: size, now: now, ascending: ascending, logTag: logTag)
    }

    /**
     * Gets the index of the next available camera.
     * If at end of camera range, cycle to start of the other end.
     * Returns nil if none available.
     *
     * @param ascending If true, cycle in the direction of increasing index,
     *                  otherwise cycle in opposite direction.
     */
    private func videoSourceIndexNext(ascending: Bool)->Int? {
        let logTag = "[Video][Source][Index][Next] "
        let size = getVideoSourceList(refresh: false)?.count ?? 0
        if size < 1 {
            print(logTag + "Failed as the device does not have a camera!")
            return nil
        }
        let now = videoSourceIndex
        return Utils.indexNext(size: size, now: now, ascending: ascending, logTag: logTag)
    }

    /**
     * Gets the index of the next available capability.
     * If at end of capability range, cycle to start of the other end.
     * Returns nil if none available.
     *
     * @param ascending If true, cycle in the direction of increasing index,
     *                  otherwise cycle in opposite direction.
     */
    private func capabilityIndexNext(ascending: Bool)->Int? {
        let logTag = "[Capability][Index][Next] "
        let size = getCapabilityList()?.count ?? 0
        if size < 1 {
            print(logTag + "Failed as the device does not have a capability!")
            return nil
        }
        let now = capabilityIndex
        return Utils.indexNext(size: size, now: now, ascending: ascending, logTag: logTag)
    }

    /**
     * Gets the index of the next available codec.
     * If at end of codec range, cycle to start of the other end.
     * Returns nil if none available.
     *
     * @param ascending If true, cycle in the direction of increasing index,
     *                  otherwise cycle in opposite direction.
     * @param forAudio  If true, this is for audio codecs, otherwise for video codecs.
     * @return
     */
    private func codecIndexNext(ascending: Bool, forAudio: Bool)->Int? {
        var logTag = "[Codec][Index][Next] "
        var now: Int

        if forAudio {
            logTag = "[Audio]" + logTag
            now = audioCodecIndex
        } else {
            logTag = "[Video]" + logTag
            now = videoCodecIndex
        }

        var size: Int
        var codecList = getCodecList(forAudio: forAudio)
        size = codecList?.count ?? 0
        if codecList == nil || size < 1 {
            print(logTag + "Failed as there is no codec!")
            return nil
        }

        return Utils.indexNext(size: size, now: now, ascending: ascending, logTag: logTag)
    }

    // *********************************************************************************************
    // Capture
    // *********************************************************************************************

    /**
     * Set  audioSource to nil.
     * If audioSource is currently capturing, stop capture first.
     * New audioSource and capability will be created again
     * based on audioSourceIndex.
     */
    private func removeAudioSource() {
        let logTag = "[Audio][Source][Remove] "

        // Remove all videoSource
        if isAudioCaptured() {
            audioSource?.stopCapture()
            print(logTag + "Capture stopped.")
        }
        audioSource = nil
        print(logTag + "Removed.")
        print(logTag + "Setting new...")
        setAudioSourceIndex(audioSourceIndex)
        print(logTag + "OK.")
    }

    /**
     Using the selected audioSource, capture audio into a pubAudioTrack.
     */
    private func startCaptureAudio() {
        queuePub.async { [self] in
            let logTag = "[Audio][Capture][Start] "
            if isAudioCaptured() {
                showAlert(logTag + "Source is already capturing!")
                return
            }

            guard let source = getAudioSource() else {
                showAlert(logTag + "Failed! Source does not exists.")
                return
            }

            // Capture AudioTrack for publishing.
            pubAudioTrack = source.startCapture() as! MCAudioTrack
            setMediaState(to: true, forPublisher: true, forAudio: true)
            print(logTag + "OK")
        }
    }

    /**
     Stop capturing audio, if audio is being captured.
     */
    private func stopCaptureAudio() {
        let logTag = "[Audio][Capture][Stop] "
        if !isAudioCaptured() {
            print(logTag + "Not stopping as not captured!")
            return
        }

        removeAudioSource()
        print(logTag + "OK.")

        // Remove Track.
        if pubAudioTrack != nil {
            pubAudioTrack = nil
            print(logTag + "Track removed.")
        }

        setMediaState(to: false, forPublisher: true, forAudio: true)
    }

    /**
     Check if audio is captured.
     */
    private func isAudioCaptured()->Bool {
        let logTag = "[Audio][Capture][?] "
        if audioSource == nil || !audioSource!.isCapturing() {
            print(logTag + "No.")
            return false
        }
        print(logTag + "Yes.")
        return true
    }

    /**
     * Set  videoSource to nil.
     * If videoSource is currently capturing, stop capture first.
     * New videoSource and capability will be created again
     * based on videoSourceIndex and capabilityIndex.
     */
    private func removeVideoSource() {
        let logTag = "[Video][Source][Remove] "

        // Remove all videoSource
        if isVideoCaptured() {
            videoSource!.stopCapture()
            print(logTag + "Capture stopped.")
        }
        videoSource = nil
        print(logTag + "Removed.")
        print(logTag + "Setting new...")
        setVideoSourceIndex(videoSourceIndex, setCapIndex: true)
        print(logTag + "OK.")
    }

    /**
     Using the selected videoSource and capability, capture video into a pubVideoTrack.
     */
    private func startCaptureVideo() {
        let logTag = "[Video][Capture][Start] "
        print(logTag)
        if isVideoCaptured() || capState != .notCaptured {
            showAlert(logTag + "Source is already capturing!")
            return
        }

        setCapState(to: .tryCapture, tag: logTag)

        guard let source = getVideoSource() else {
            setCapState(to: .notCaptured, tag: logTag)
            showAlert(logTag + "Failed! Source does not exists.")
            return
        }

        guard let cap = getCapability() else {
            setCapState(to: .notCaptured, tag: logTag)
            showAlert(logTag + "Failed as unable to get valid Capability for Source!")
            return
        }

        // Set selected Capability into selected VideoSource
        source.setCapability(cap)
        print(logTag + "Set \(getVideoSourceStr(source)) with Cap: \(getCapabilityStr(cap)).")

        // Capture VideoTrack for publishing.
        print(logTag + "Capturing with: \(getVideoSourceStr(videoSource!))...")
        pubVideoTrack = (videoSource!.startCapture() as! MCVideoTrack)

        // Check that capture has started.
        if isVideoCaptured() {
            print(logTag + "OK.")
        } else {
            // setCapState(to: .notCaptured)
            showAlert(logTag + "VS.isCapturing FALSE!!! Despite having valid videoSource!")
        }
        setCapState(to: .isCaptured, tag: logTag)
        setMediaState(to: true, forPublisher: true, forAudio: false)

        renderPubVideo()
    }

    /**
     Stop capturing video, if video is being captured.
     */
    private func stopCaptureVideo() {
        let logTag = "[Video][Capture][Stop] "
        if !isVideoCaptured() {
            print(logTag + "Not stopping as not captured!")
            return
        }

        removeVideoSource()
        print(logTag + "OK.")

        // Remove Renderer from Track and remove Track.
        if pubVideoTrack != nil {
            if pubRenderer != nil {
                pubVideoTrack!.remove(pubRenderer)
                print(logTag + "Publisher renderer removed from track.")
            }
            pubVideoTrack = nil
            print(logTag + "Track removed.")
        }
        setCapState(to: .notCaptured)
        setMediaState(to: false, forPublisher: true, forAudio: false)
    }

    /**
     Check if video is captured.
     */
    private func isVideoCaptured()->Bool {
        let logTag = "[Video][Capture][?] "
        if videoSource == nil || !videoSource!.isCapturing() {
            print(logTag + "No.")
            return false
        }
        print(logTag + "Yes.")
        return true
    }

    /**
     * Check if either audio or video is captured.
     */
    private func isAudioVideoCaptured()->Bool {
        let logTag = "[Audio][Video][Capture][?] "
        if !isAudioCaptured(), !isVideoCaptured() {
            print(logTag + " No.")
            return false
        }
        print(logTag + "Yes.")
        return true
    }

    // *********************************************************************************************
    // Mute / unmute audio / video.
    // *********************************************************************************************

    /**
     If track exist, set enable value as given and return it as well.
     Else, return nil.
     */
    private func enableTrack(track: MCTrack?, enable: Bool)->Bool? {
        if let t = track {
            t.enable(enable)
            print("[enableTrack] Set track enable to \(enable).")
            return enable
        }
        print("[enableTrack] Failed! Track was not available!")
        return nil
    }

    // *********************************************************************************************
    // Render
    // *********************************************************************************************

    /**
     * Sets the audioPlayback at the audioPlaybackIndex
     * of the audioPlaybackList.
     * To set the audioPlaybackIndex, use setAudioPlaybackIndex(int).
     */
    private func setAudioPlayback() {
        let logTag = "[Playback][Audio][Set] "

        // Create new audioPlayback based on index.
        var audioPlaybackNew: MCAudioPlayback?

        getAudioPlaybackList()
        if audioPlaybackList == nil {
            print(logTag + "Failed as no valid audioPlayback was available!")
            return
        }
        var size = audioPlaybackList?.count
        if size ?? 0 < 1 {
            print(logTag + "Failed as list size was \(size)!")
            return
        }

        // If the selected index is larger than size, set it to maximum size.
        // This might happen if the list of audioPlaybacks changed.
        if audioPlaybackIndex >= size! {
            print(logTag + "Resetting index to \(size! - 1) as it is greater than " +
                "size of list (\(size!))!")
            setAudioPlaybackIndex(newValue: size! - 1)
            return
        }
        if audioPlaybackIndex < 0 {
            print(logTag + "Resetting index to 0 as it was negative!")
            setAudioPlaybackIndex(newValue: 0)
            return
        }

        audioPlaybackNew = audioPlaybackList![audioPlaybackIndex]

        var log: String
        if audioPlaybackNew != nil {
            log = getAudioSourceStr(audioPlaybackNew, longForm: true)
        } else {
            log = "None"
        }

        // Set as new audioPlayback
        audioPlayback = audioPlaybackNew
        print(logTag + "New at index:\(audioPlaybackIndex) is: " + log + ".")
    }

    /**
     Get the renderer for the Publisher.
     Create one if none currently exists.
     */
    private func getPubRenderer()->MCIosVideoRenderer {
        let logTag = "[Video][Render][Er][Pub] "
        if pubRenderer == nil {
            print(logTag + "Creating...")
            pubRenderer = MCIosVideoRenderer()
        } else {
            print(logTag + "Using existing.")
        }
        print(logTag + "OK")
        return pubRenderer!
    }

    /**
     Render the local video
     */
    private func renderPubVideo() {
        let logTag = "[Video][Render][Pub] "
        if pubVideoTrack == nil {
            showAlert(logTag + "Failed! videoTrack does not exist.")
            return
        }
        pubVideoTrack?.add(getPubRenderer())
        print(logTag + "OK")
    }

    /**
     Get the renderer for the Subscriber.
     Create one if none currently exists.
     */
    private func getSubRenderer()->MCIosVideoRenderer {
        let logTag = "[Video][Render][Er][Sub] "
        if subRenderer == nil {
            print(logTag + "Creating...")
            subRenderer = MCIosVideoRenderer()
        } else {
            print(logTag + "Using existing.")
        }
        print(logTag + "OK")
        return subRenderer!
    }

    // *********************************************************************************************
    // Publish - Codecs
    // *********************************************************************************************

    /**
     * Set the current audio/videoCodec at the audio/videoCodecIndex of the current audio/videoCodecList,
     * and in the publisher as preferred codecs if available and not currently publishing.
     * The current videoCodec will NOT be set if the Publisher is publishing.
     */
    private func setCodecs() {
        let logTag = "[Codec][Set] "
        let none = "None"
        var ac = none
        var vc = none

        getCodecList(forAudio: true)
        getCodecList(forAudio: false)

        print(logTag + "Selecting a new one based on selected index.")

        if audioCodecList == nil || audioCodecList!.count < 1 {
            print(logTag + "Failed to set audio codec as none was available!")
        } else {
            var size = audioCodecList!.count

            // If the selected index is larger than size, set it to maximum size.
            if audioCodecIndex >= size {
                print(logTag + "Resetting audioCodecIndex to \(size - 1) as it is greater than " +
                    "size of list (\(size))!")
                setCodecIndex(newValue: size - 1, forAudio: true)
            }
            if audioCodecIndex < 0 {
                print(logTag + "Resetting audioCodecIndex to 0 as it was negative!")
                setCodecIndex(newValue: 0, forAudio: true)
                return
            }
            ac = audioCodecList![audioCodecIndex]
        }

        if videoCodecList == nil || videoCodecList!.count < 1 {
            print(logTag + "Failed to set video codec as none was available!")
        } else {
            var size = videoCodecList!.count

            // If the selected index is larger than size, set it to maximum size.
            if videoCodecIndex >= size {
                print(logTag + "Resetting videoCodecIndex to \(size - 1) as it is greater than " +
                    "size of list (\(size))!")
                setCodecIndex(newValue: size - 1, forAudio: false)
            }
            if videoCodecIndex < 0 {
                print(logTag + "Resetting videoCodecIndex to 0 as it was negative!")
                setCodecIndex(newValue: 0, forAudio: false)
                return
            }
            vc = videoCodecList![videoCodecIndex]
        }

        var log = "Selected at index:\(audioCodecIndex)/\(videoCodecIndex) "
        log += "is: \(ac)/\(vc)."
        print(logTag + log)

        log = logTag + "OK. "
        if publisher != nil {
            if !publisher!.isPublishing() {
                // Set the codecs into Publisher Options
                if none != ac {
                    audioCodec = ac
                    optionsPub.audioCodec = ac
                    log += "Set Audio:\(audioCodec) on Publisher. "
                } else {
                    log += "Audio NOT set on Publisher."
                }
                if none != vc {
                    videoCodec = vc
                    optionsPub.videoCodec = vc
                    log += "Set Video:\(videoCodec) on Publisher."
                } else {
                    log += "Video NOT set on Publisher."
                }

                // Make adjustment to videoCodec if needed:
                adjustCodec()

                // Set Options into Publisher
                publisher?.setOptions(optionsPub)

            } else {
                log += "NOT set, as publishing is ongoing: "
            }
        } else {
            log += "NOT set, as publisher does not exists: "
            audioCodec = ac
            videoCodec = vc
        }
        print(log)
    }

    /**
     Due to differences in implementation between different devices' H.264 hardware encoders and decoders, there may be a problem when publishing H.264 at higher resolutions (e.g. 1920x1440, 2592x1936, 3264x2448).
     However, these higher resolutions could be published by either VP8 or VP9 or even both.
     As such, this function adjusts the preferred video codec for higher resolutions if it was H.264.
     */
    private func adjustCodec() {
        let logTag = "[Codec][Adjust] "
        if optionsPub.videoCodec == "H264" {
            var log = logTag + " Selected video codec is H264."
            if let cap = getCapability() {
                if (cap.width < 1920) || (cap.height < 1440) {
                    log += " Setting it as preferred video codec as selected capability \(getCapabilityStr(cap)) is lower than "
                } else {
                    var codec = "VP8"
                    if cap.width == 1920, cap.height == 1440 {
                        codec = "VP9"
                    }
                    log += " NOT setting it but rather \(codec) as preferred video codec as selected capability \(getCapabilityStr(cap)) is higher than "
                    optionsPub.videoCodec = codec
                }
                log += "1920x1440."
                print(log)
            }
        } else {
            print(logTag + "Setting \(optionsPub.videoCodec!) as preferred video codec.")
        }
    }

    // *********************************************************************************************
    // Connect
    // *********************************************************************************************

    /**
     Connect to Millicast for publishing. Publishing credentials required.
     */
    private func connectPublisher(pub: MCPublisher) {
        let logTag = "[Pub][Con][Mc] "
        if pub.isConnected() {
            print(logTag + "Not doing as we're already connected!")
            return
        }
        pub.setCredentials(pubCreds)
        setPubState(to: .connecting)
        if !pub.connect() {
            setPubState(to: .disconnected)
            showAlert(logTag + "Failed! Could not connect to Millicast!")
        } else {
            print(logTag + "Connecting to Millicast...")
        }
    }

    /**
     Disconnect Publisher from Millicast.
     */
    private func disconnectPublisher(pub: MCPublisher) {
        let logTag = "[Pub][Con][X] "
        if !pub.isConnected() {
            print(logTag + "Not doing as we're not connected!")
            return
        }
        pub.disconnect()
        setPubState(to: .disconnected)
        // Reset videoCodec to default.
        optionsPub.videoCodec = defaultVideoCodec
        print(logTag + "OK.")
    }

    /**
     Connect to Millicast for subscribing. Subscribing credentials required.
     */
    private func connectSubscriber(sub: MCSubscriber) {
        let logTag = "[Sub][Con] "
        if sub.isConnected() {
            print(logTag + "Not doing as we're already connected!")
            return
        }
        setSubState(to: .connecting)
        print(logTag + "accountId:\(subCreds.accountId), streamName:\(subCreds.streamName), apiUrl:\(subCreds.apiUrl)")
        sub.setCredentials(subCreds)
        sub.connect()
    }

    /**
     Disconnect Subscriber from Millicast.
     */
    private func disconnectSubscriber(sub: MCSubscriber) {
        let logTag = "[Sub][Con][X] "
        if !sub.isConnected() {
            print(logTag + "Not doing as we're not connected!")
            return
        }
        sub.disconnect()
        setSubState(to: .disconnected)
        print(logTag + "OK.")
    }

    // *********************************************************************************************
    // Publish
    // *********************************************************************************************

    /**
     Get the PubListener.
     If none exist, create and return a new one.
     */
    private func getPubListener()->PubListener? {
        let logTag = "[Pub][Ltn] "

        guard let ltn = pubListener else {
            print(logTag + "Trying to create one...")
            pubListener = PubListener()
            print(logTag + "Created and returning a new one.")
            return pubListener
        }

        print(logTag + "Returning existing one.")
        return ltn
    }

    /**
     * Get the Publisher.
     * If none exist, create and return a new one.
     *
     * @return
     */
    private func getPublisher()->MCPublisher? {
        let logTag = "[Pub] "

        guard let pub = publisher else {
            print(logTag + "Trying to create one...")

            guard let ltn = getPubListener() else {
                print(logTag + "Failed! Listener is not available!")
                return nil
            }

            publisher = MCPublisher.create()
            guard let pub = publisher else {
                print(logTag + "Failed! Could not create Publisher.")
                return nil
            }

            pub.setListener(ltn)
            print(logTag + "Created and returning a new one.")
            return pub
        }

        print(logTag + "Returning existing one.")
        return pub
    }

    /**
     * Check if we are currently publishing.
     */
    private func isPublishing()->Bool {
        let logTag = "[Pub][?] "
        if publisher == nil || !(publisher?.isPublishing() ?? false) {
            print(logTag + "No.")
            return false
        }
        print(logTag + "Yes.")
        return true
    }

    // *********************************************************************************************
    // Subscribe
    // *********************************************************************************************

    /**
     Get the SubListener.
     If none exist, create and return a new one.
     */
    private func getSubListener()->SubListener? {
        let logTag = "[Sub][Ltn] "

        guard let ltn = subListener else {
            print(logTag + "Trying to create one...")
            subListener = SubListener()
            print(logTag + "Created and returning a new one.")
            return subListener
        }

        print(logTag + "Returning existing one.")
        return ltn
    }

    /**
     * Get the Subscriber.
     * If none exist, create one if a Subscribe View had been set.
     */
    private func getSubscriber() ->MCSubscriber? {
        let logTag = "[Sub] "
        guard let sub = subscriber else {
            print(logTag + "Trying to create one...")

            guard let ltn = getSubListener() else {
                print(logTag + "Failed! Listener is not available!")
                return nil
            }

            subscriber = MCSubscriber.create()
            guard let sub = subscriber else {
                print(logTag + "Failed! Could not create Subscriber.")
                return nil
            }

            sub.setListener(ltn)
            print(logTag + "Created and returning a new one.")
            return sub
        }

        print(logTag + "Returning existing one.")
        return sub
    }

    /**
     * Check if we are currently subscribing.
     */
    private func isSubscribing()->Bool {
        let logTag = "[Sub][?] "
        if subscriber == nil || !subscriber!.isSubscribed() {
            print(logTag + "No.")
            return false
        }
        print(logTag + "Yes.")
        return true
    }

    // *********************************************************************************************
    // Utilities
    // *********************************************************************************************

    /**
     * Get a String that describes a MCAudioSource.
     */
    private func getAudioSourceStr(_ source: MCSource?, longForm: Bool)->String {
        var name = "Audio:"
        guard let src = source else {
            name += "N.A."
            return name
        }

        name += src.getName()
        if longForm {
            name += " (" + src.getTypeAsString() + ") " + "id:" + src.getUniqueId()
        }
        return name
    }

    /**
     Get a String that describes a MCVideoSource.
     */
    private func getVideoSourceStr(_ source: MCVideoSource?, longForm: Bool = false)->String {
        var name = "Cam:"
        guard let src = source else {
            name += "N.A."
            return name
        }

        name += src.getName()
        if longForm {
            name += " (" + src.getTypeAsString() + ") " + "id:" + src.getUniqueId()
        }
        return name
    }

    /**
     Get a String that describes a MCVideoCapabilities.
     */
    private func getCapabilityStr(_ cap: MCVideoCapabilities?)->String {
        var name = "Cap:"
        guard let cap = cap else {
            name += "N.A."
            return name
        }

        // Get the pixel format for the video capture
        let pixelFormat = cap.formatAsString() ?? "N.A."

        name += "\(cap.width)x\(cap.height) fps:\(cap.fps) PixelFormat:\(pixelFormat)"
        return name
    }

    /**
     Run the given task sync on main thread.
     If currently on main thread, task will run immediately on current thread.
     */
    private func runOnMain(logTag: String, log: String = "", _ task: ()->()) {
        let tag = "[Q][Main]" + logTag
        if Thread.current.isMainThread {
            print(tag + "Running on the current (main) thread: " + log + "...")
            task()
        } else {
            DispatchQueue.main.sync {
                print(tag + "Dispatching sync on the main thread: " + log + "...")
                task()
            }
        }
    }

    /**
     Dispatch async the given task in the specified queue.
     If currently in the queue, task will run immediately in the current queue.
     */
    private func runOnQueue(logTag: String, log: String = "", _ task: @escaping ()->(), _ queue: DispatchQueue) {
        // Get label of requested queue.
        let labelReq = queue.label
        // Get label of current queue.
        let labelCur = DispatchQueue.getSpecific(key: queueLabelKey)

        let tag = "[Q][\(labelReq)]" + logTag
        print(tag + "Current queue is \(labelCur).")
        if labelReq == labelCur ?? "" {
            print(tag + "Running on the current \(labelReq) queue: " + log + "...")
            task()
        } else {
            queue.async {
                print(tag + "Dispatching async on \(labelReq) queue: " + log + "...")
                task()
            }
        }
    }
}
