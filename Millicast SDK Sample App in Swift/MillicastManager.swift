//
//  MillicastManager.swift
//  Millicast SDK Sample App in Swift
//
//  Created by CoSMo Software on 6/8/21.
//

import Foundation
import MillicastSDK

class MillicastManager : ObservableObject {
    @Published var capState : CaptureState = .notCaptured
    @Published var pubState : PublisherState = .disconnected
    @Published var subState : SubscriberState = .disconnected
    @Published var pubAudioEnabled = false
    @Published var pubVideoEnabled = false
    @Published var subAudioEnabled = false
    @Published var subVideoEnabled = false
    
    @Published var alert = false
    
    static var instance : MillicastManager!
    let queuePub = DispatchQueue(label:"mc-pub", qos: .userInitiated)
    let queueSub = DispatchQueue(label:"mc-sub", qos: .userInitiated)
    var alertMsg = ""
    
    var savedCreds : SavedCreds!
    var pubCreds : MCPublisherCredentials!
    var subCreds : MCSubscriberCredentials!
    
    var selectedAudioSourceIndex : Int
    var audioSources : Array<MCAudioSource>?
    var audioSource : MCAudioSource?
    var audioPlaybackList : Array<MCAudioPlayback>?
    var audioPlayback : MCAudioPlayback?
    var audioCodecs : Array<String>?
    
    var videoSources : Array<MCVideoSource>?
    let videoSourceIndexStr = "VIDEO_SOURCE_INDEX"
    @Published var videoSourceIndex : Int?
    var videoSourceIndexDefault = 0
    let capabilityIndexStr = "CAPABILITY_INDEX"
    @Published var capabilityIndex : Int?
    var capabilityIndexDefault = 0
    var videoSource : MCVideoSource?
    var capabilities : Array<MCVideoCapabilities>?
    var capability : MCVideoCapabilities?
    var videoCodecs : Array<String>?
    var defaultVideoCodec = "H264"
    var selectedVideoCodec : String?
    
    var pubOptions : MCClientOptions
    
    var pubRenderer : MCIosVideoRenderer?
    var subRenderer : MCIosVideoRenderer?
    var publisher : MCPublisher?
    var pubListener: PubListener?
    var subscriber : MCSubscriber?
    var subListener: MCSubscriberListener?
    
    var pubVideoTrack : MCVideoTrack?
    var pubAudioTrack : MCAudioTrack?
    var subVideoTrack : MCVideoTrack?
    var subAudioTrack : MCAudioTrack?
    var ndiVideo = false
    var ndiAudio = false
    
    private init() {
        // Set some preferences
        videoSourceIndex = Utils.getValue(tag: "[McMan][init:videoSourceIndex]", key: videoSourceIndexStr, defaultValue: videoSourceIndexDefault)
        capabilityIndex = Utils.getValue(tag: "[McMan][init:capabilityIndex]", key: capabilityIndexStr, defaultValue: capabilityIndexDefault)
        
        selectedVideoCodec = defaultVideoCodec
        selectedAudioSourceIndex = 0
        
        pubOptions = MCClientOptions()
        pubOptions.stereo = true
        pubOptions.videoCodec = defaultVideoCodec
        
        // Set credentials
        savedCreds = SavedCreds()
        // Publishing
        pubCreds = MCPublisherCredentials()
        // Subscribing
        subCreds = MCSubscriberCredentials()
        setCreds(using: savedCreds, save: false)
    }
    
    //**********************************************************************************************
    // APIs
    //**********************************************************************************************
    
    static func getInstance() -> MillicastManager {
        if instance == nil {
            instance = MillicastManager()
        }
        return instance
    }
    
    /*
     Millicast connections
     */
    
    /**
     Read Millicast credentials and set into MillicastManager using CredentialSource.
     */
    func setCreds(using credsSrc : CredentialSource, save : Bool) -> Void {
        
        print("[McMan][setCreds] Account ID: \(credsSrc.getAccountId())\nPublishing stream name: \(credsSrc.getPubStreamName())\nSubscribing stream name: \(credsSrc.getSubStreamName())\nPublishing token: \(credsSrc.getPubToken())\nPublishing API url: \(credsSrc.getPubApiUrl())\nSubscribing API url: \(credsSrc.getSubApiUrl())\n")
        
        // Publishing
        pubCreds.streamName = credsSrc.getPubStreamName()
        pubCreds.token = credsSrc.getPubToken()
        pubCreds.apiUrl = credsSrc.getPubApiUrl()
        // Subscribing
        subCreds.accountId = credsSrc.getAccountId()
        subCreds.streamName = credsSrc.getSubStreamName()
        subCreds.apiUrl = credsSrc.getSubApiUrl()
        
        if(save){
            // Set new values into UserDefaults
            UserDefaults.standard.setValue(credsSrc.getAccountId(), forKey: savedCreds.accountId)
            UserDefaults.standard.setValue(credsSrc.getPubStreamName(), forKey: savedCreds.pubStreamName)
            UserDefaults.standard.setValue(credsSrc.getSubStreamName(), forKey: savedCreds.subStreamName)
            UserDefaults.standard.setValue(credsSrc.getPubToken(), forKey: savedCreds.pubToken)
            UserDefaults.standard.setValue(credsSrc.getPubApiUrl(), forKey: savedCreds.pubApiUrl)
            UserDefaults.standard.setValue(credsSrc.getSubApiUrl(), forKey: savedCreds.subApiUrl)
        }
    }
    
    /**
     Select the next available camera.
     If at end of camera range, cycle back to start of range.
     This set the selection for the next capture, and can only be done when not actively capturing.
     */
    func toggleVideoSource()->Void {
        queuePub.async { [self] in
            if let next = videoSourceIndexNext(){
                DispatchQueue.main.sync {
                    videoSourceIndexSelected = next
                }
                print("[toggleVideoSource] Next videoSourceIndex set to \(next).")
            } else {
                print("[toggleVideoSource] Failed as unable to get next camera!")
            }
        }
    }
    
    /**
     Select the next available resolution.
     If at end of resolution range, cycle back to start of range.
     This set the selection for the next capture, and can only be done when not actively capturing.
     */
    func toggleCapability()->Void {
        queuePub.async { [self] in
            if let next = capabilityIndexNext(){
                DispatchQueue.main.sync {
                    capabilityIndexSelected = next
                }
                print("[toggleCapability] Next video capability set to \(next).")
            } else {
                print("[toggleCapability] Failed as unable to get next resolution!")
            }
        }
    }
    
    /**
     Start capturing both audio and video (based on selected videoSource).
     */
    func startAudioVideoCapture()->Void {
        queuePub.async { [self] in
            print("[startAudioVideoCapture] Starting Capture...")
            startCaptureVideo()
            startCaptureAudio()
        }
    }
    
    /**
     Stop capturing both audio and video.
     */
    func stopAudioVideoCapture()->Void {
        queuePub.async { [self] in
            print("[stopAudioVideoCapture] Stopping Capture...")
            stopCaptureVideo()
            stopCaptureAudio()
        }
    }
    
    /**
     Get the VideoView that renders the published video.
     */
    func getPubVideoView() -> VideoView {
        let renderer = getPubRenderer()
        let videoView = VideoView(renderer: renderer)
        return videoView
    }
    
    /**
     Render again the video of the currently captured video (if any).
     */
    func refreshPubVideo()->Void {
        queuePub.async { [self] in
            if(pubVideoTrack == nil){
                print("[refreshPubVideo] Unable to refresh as videoTrack does not exist.")
                return
            }
            pubVideoTrack!.remove(getPubRenderer())
            renderPubVideo()
            print("[refreshPubVideo] OK")
        }
    }
    
    /**
     Stop capturing on current videoSource and switch to the next available videoSource on device and starts capturing.
     If currently publishing, this would first stop publishing and disconnect from Millicast. After the next available videoSource is capturing, reconnect to Millicast and start publishing.
     This can only be done when currently capturing.
     */
    func switchVideoSource()->Void {
        queuePub.async { [self] in
            // Do not allow switching if capturing or publishing are not in stable states.
            switch capState {
                    
                case .notCaptured: break
                case .tryCapture:
                    print("[switchCamera] FAILED as camera is trying to capture.")
                    return
                case .isCaptured: break
            }
            
            switch pubState {
                    
                case .disconnected: break
                case .connecting:
                    print("[switchCamera] FAILED as publisher is trying to connect.")
                    return
                case .connected:
                    print("[switchCamera] FAILED as publisher is trying to publish or unpublish.")
                    return
                case .publishing: break
            }
            
            // If already publishing stop and publish again after capturing.
            var wasPublishing = false
            if(publisher != nil){
                if(publisher!.isPublishing()){
                    wasPublishing = true
                    print("[switchCamera] Is publishing now so will stop publishing first...")
                    stopPublish(useQ: false)
                }
            }
            
            // Stop current capture, if any.
            stopCaptureVideo()
            // Set new camera index.
            guard let next = videoSourceIndexNext() else {
                print("[switchCamera] Failed as unable to get next camera!")
                return
            }
            
            DispatchQueue.main.sync {
                videoSourceIndexSelected = next
            }
            
            // Start capture with new camera.
            print("[switchCamera] Starting capture again with new index: \(next)...")
            startCaptureVideo()
            
            // Publish again if was previously publishing.
            if(wasPublishing){
                print("[switchCamera] Was publishing so will try to connect and publish again...")
                pubConnect(useQ: false)
            }
        }
    }
    
    /**
     Render the subscribed video.
     */
    func renderSubVideo()->Void {
        queueSub.async { [self] in
            if(subVideoTrack == nil){
                print("[renderSubVideo] FAILED to render as videoTrack does not exist.")
                return
            }
            subVideoTrack?.add(getSubRenderer())
            print("[renderSubVideo] OK")
        }
    }
    
    /**
     Get the VideoView that renders the subscribed video.
     */
    func getSubVideoView() -> VideoView {
        let renderer = getSubRenderer()
        let videoView = VideoView(renderer: renderer)
        return videoView
    }
    
    /**
     Toggle published/subscribed audio/video between enabled and disabled (i.e. muted) state.
     To do so for the publisher, set forPublisher to true, else it would be for the subscriber.
     To do so for audio, set isAudio to true, else it would be for video.
     */
    func toggleMediaState(forPublisher isPub : Bool, forAudio isAudio: Bool){
        var queue = queuePub
        if(!isPub){
            queue = queueSub
        }
        
        var set : Bool?
        queue.async { [self] in
            if(isPub) {
                if(isAudio) {
                    set = enableTrack(track: pubAudioTrack, enable: !pubAudioEnabled)
                } else {
                    set = enableTrack(track: pubVideoTrack, enable: !pubVideoEnabled)
                }
            } else {
                if(isAudio) {
                    set = enableTrack(track: subAudioTrack, enable: !subAudioEnabled)
                } else {
                    set = enableTrack(track: subVideoTrack, enable: !subVideoEnabled)
                }
            }
            if(set != nil){
                setMediaState(to: set!, forPublisher: isPub, forAudio: isAudio)
            }
        }
    }
    
    /**
     Publish audio and video tracks that are already captured.
     By default this uses the publishing dispatchQueue.
     If no dispatchQueue is desired, set useQ to false.
     */
    func pubConnect(useQ: Bool = true)->Void {
        var logTag = "[pubConnect]"
        if(useQ){
            print(logTag + "Dispatching to queuePub...")
            logTag += "(queuePub)"
            queuePub.async { [self] in
                pubConnectNQ(logTag: logTag)
            }
        } else {
            pubConnectNQ(logTag: logTag)
        }
    }
    
    /**
     Start publishing if video has been captured.
     */
    func startPublish() {
        queuePub.async { [self] in
            if(!isVideoCaptured()){
                var log = "[startPublish] VS.isCapturing FALSE!!!"
                if (capState == .isCaptured) {
                    log += " Continueing as capState showed that video is captured."
                    showAlert(log)
                } else {
                    log += " Not publishing as video has not been captured!."
                    showAlert(log)
                    return
                }
            }
            if let pub = publisher {
                pub.publish()
            } else {
                showAlert("[startPublish] Not publishing as Publisher is not available!")
            }
        }
    }
    
    /**
     Stop publishing and disconnect from Millicast.
     Does not affect capturing.
     By default this uses the publishing dispatchQueue.
     If no dispatchQueue is desired, set useQ to false.
     */
    func stopPublish(useQ: Bool = true)->Void {
        var logTag = "[stopPublish]"
        if(useQ){
            print(logTag + "Dispatching to queuePub...")
            logTag += "(queuePub)"
            queuePub.async { [self] in
                stopPublishNQ(logTag: logTag)
            }
        } else {
            stopPublishNQ(logTag: logTag)
        }
    }
    
    /**
     Subscribe to specified stream on Millicast.
     */
    func subscribe()->Void {
        queueSub.async { [self] in
            print("[subscribe]")
            // Create Subscriber if not present
            if subscriber == nil {
                print("[subscribe] Creating new Subscriber...")
                subscriber = MCSubscriber.create();
                subListener = SubListener(sub: subscriber!)
                subscriber!.setListener(subListener)
            } else {
                if(subscriber!.isSubscribed() ){
                    print("[subscribe] Not subscribing as is already subscribing!")
                    return
                }
            }
            
            // Connect to Millicast
            if !(subscriber!.isConnected()){
                print("[subscribe] Connecting to Millicast...")
                connectSubscriber(sub: subscriber!)
            }
        }
    }
    
    /**
     Set the received videoTrack into MillicastManager.
     */
    func setSubVideoTrack(track : MCVideoTrack) -> Void {
        subVideoTrack = track
    }
    
    func setSubAudioTrack(track : MCAudioTrack) -> Void {
        subAudioTrack = track
    }
    
    /**
     Stop subscribing and disconnect from Millicast.
     Does not affect capturing.
     */
    func stopSubscribe()->Void {
        queueSub.async { [self] in
            print("[stopSubscribe]")
            if(subscriber == nil || !subscriber!.isSubscribed()){
                print("[stopSubscribe] Failed as we are not subscribing!")
                return
            } else {
                subscriber!.unsubscribe()
                setMediaState(to: false, forPublisher: false, forAudio: true)
                setMediaState(to: false, forPublisher: false, forAudio: false)
                setSubState(to: .connected)
            }
            disconnectSubscriber(sub: subscriber!)
        }
    }
    
    /**
     Get the currently selected videoSource (camera name) as a string, if any.
     */
    func getVideoSourceName() -> String {
        if let vs = getVideoSource(useMain: false) {
            return getVideoSourceStr(vs)
        } else {
            return "None"
        }
    }
    
    /**
     Get the currently selected capability (camera resolution) as a string, if any.
     */
    func getCapabilityName() -> String {
        if let cap = getCapability(useMain: false) {
            return getCapabilityStr(cap)
        } else {
            return "None"
        }
    }
    
    /**
     Show message as an alert on screen and print it on console as well.
     By default some internal operation will be dispatched to the main thread.
     If this is not desired (for e.g. already on main thread), set useMain to false.
     */
    func showAlert(_ msg:String, useMain: Bool = true){
        let task = { [self] in
            alertMsg = msg
            alert = true
            print(alertMsg)
        }
        if useMain {
            DispatchQueue.main.async { [self] in
                task()
            }
        } else {
            task()
        }
    }
    
    /*
     Set states.
     */
    
    func setCapState(to newState:CaptureState, tag:String = ""){
        DispatchQueue.main.async { [self] in
            let oldState = capState
            capState = newState
            let logTag = "[setCapState]" + tag
            print("\(logTag) Now: \(self.capState)  Was: \(oldState)")
        }
    }
    
    func setPubState(to newState:PublisherState, tag:String = ""){
        DispatchQueue.main.async {
            let oldState = self.pubState
            self.pubState = newState
            let logTag = "[setPubState]" + tag
            print("\(logTag) Now: \(self.pubState)  Was: \(oldState)")
        }
    }
    
    func setSubState(to newState:SubscriberState, tag:String = ""){
        DispatchQueue.main.async {
            let oldState = self.subState
            self.subState = newState
            let logTag = "[setSubState]" + tag
            print("\(logTag) Now: \(self.subState)  Was: \(oldState)")
        }
    }
    
    func setMediaState(to newState:Bool, forPublisher : Bool, forAudio : Bool){
        DispatchQueue.main.async { [self] in
            var oldState : Bool
            var client = "Publisher"
            var media = "Audio"
            
            if(forPublisher) {
                if(forAudio) {
                    oldState = pubAudioEnabled
                    pubAudioEnabled = newState
                } else {
                    media = "Video"
                    oldState = pubVideoEnabled
                    pubVideoEnabled = newState
                }
            } else {
                client = "Subscriber"
                if(forAudio) {
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
    
    //**********************************************************************************************
    // Internal methods
    //**********************************************************************************************
    
    /**
     Connect to Millicast for publishing. Publishing credentials required.
     */
    func connectPublisher(pub : MCPublisher)->Void {
        print("[connectPublisher]")
        if(pub.isConnected()){
            print("[connectPublisher] Not doing as we're already connected!")
            return
        }
        pub.setCredentials(pubCreds)
        setPubState(to: .connecting)
        if(!pub.connect()){
            setPubState(to: .disconnected)
            showAlert("[connectPublisher] Failed to connect to Millicast!")
        } else {
            print("[connectPublisher] Connecting to Millicast...")
        }
    }
    
    /**
     Disconnect from Millicast.
     */
    func disconnectPublisher(pub : MCPublisher)->Void {
        print("[disconnectPublisher]")
        if(!pub.isConnected()){
            print("[disconnectPublisher] Not doing as we're not connected!")
            return
        }
        pub.disconnect()
        setPubState(to: .disconnected)
        print("[disconnectPublisher] Disconnected!")
    }
    
    /**
     Connect to Millicast for subscribing. Subscribing credentials required.
     */
    func connectSubscriber(sub : MCSubscriber)->Void {
        print("[connectSubscriber]")
        if(sub.isConnected()){
            print("[connectSubscriber] Not doing as we're already connected!")
            return
        }
        setSubState(to: .connecting)
        print("[connectSubscriber] accountId:\(subCreds.accountId), streamName:\(subCreds.streamName), apiUrl:\(subCreds.apiUrl)")
        sub.setCredentials(subCreds)
        sub.connect()
    }
    
    /**
     Disconnect Subscriber from Millicast.
     */
    func disconnectSubscriber(sub : MCSubscriber)->Void {
        print("[disconnectSubscriber]")
        if(!sub.isConnected()){
            print("[disconnectSubscriber] Not doing as we're not connected!")
            return
        }
        sub.disconnect()
        setSubState(to: .disconnected)
        print("[disconnectSubscriber] Disconnected!")
    }
    
    /*
     Capture
     */
    
    /**
     Setter: Must on main thread.
     */
    var videoSourceIndexSelected : Int {
        get {
            print("[selectedVideoSourceIndex][get] \(videoSourceIndex!)")
            return videoSourceIndex!
        }
        set {
            // Only allowed to change resolution when not capturing.
            if(capState != .notCaptured){
                print("[videoSourceIndexSelected][set] Failed! Only allowed to change camera when not capturing. Capture state: \(capState). Current index: \(videoSourceIndex)")
                return
            }
            
            // Set new value into UserDefaults
            var oldValue : String
            if(videoSourceIndex == nil){
                oldValue = "nil"
            } else {
                oldValue = "\(videoSourceIndex!)"
            }
            
            videoSourceIndex = newValue
            UserDefaults.standard.setValue(videoSourceIndex, forKey: videoSourceIndexStr)
            print("[selectedVideoSourceIndex][set] Now: \(newValue) Was: \(oldValue)")
            // Must see if capabilityIndex needs to be reset as videoSource has changed.
            print("[selectedVideoSourceIndex][set] Checking if capabilityIndex needs to be reset by setting it again with current value...")
            capabilityIndexSelected = capabilityIndexSelected
        }
    }
    
    func getVideoSources() -> Array<MCVideoSource>? {
        if (videoSources == nil) {
            print("[getVideoSources] Checking for videoSources...")
            videoSources = MCMedia.getVideoSources();
            let size = (videoSources!.count)
            if(size < 1){
                print("[getVideoSources] Failed as list size was \(size)!")
                return nil
            } else {
                var log = "[getVideoSources] "
                for index in 0..<size {
                    let vs = videoSources![index]
                    log += "[\(index)]:" + getVideoSourceStr(vs, long: true) + " "
                }
                print("\(log).")
            }
        } else {
            print("[getVideoSources] Using existing videoSources.")
        }
        return videoSources;
    }
    
    /**
     If currently not capturing, create a videoSource based on videoSourceIndexSelected.
     Else, return the current videoSource.
     By default some internal operation has to be done sync on the main thread.
     If this is not desired (for e.g. already on main thread), set useMain to false.
     */
    func getVideoSource(useMain: Bool = true) -> MCVideoSource? {
        
        // If not currently capturing, get a new one based on selected index.
        if (capState != .isCaptured) {
            print("[getVideoSource] Selecting a new one based on selected index.")
            
            if let vss = getVideoSources() {
                let size = vss.count
                if(size < 1) {
                    print("[getVideoSource] Failed as list size was \(size)!")
                    return nil
                }
                
                // If the selected index is larger than size, set it to maximum size.
                // This might happen if the list of videoSources changed.
                if(videoSourceIndexSelected >= size){
                    let task = { [self] in
                        print("[getVideoSource] Resetting selectedVideoSourceIndex as it is greater than number of videoSources available (\(size))!")
                        videoSourceIndex = size - 1
                    }
                    if (useMain) {
                        DispatchQueue.main.sync {
                            task()
                        }
                    } else {
                        task()
                    }
                }
                videoSource = vss[videoSourceIndexSelected]
            } else {
                print("[getVideoSource] Failed as no valid videoSource was available!")
                return nil
            }
            
            var log : String
            if let vs = videoSource {
                log = getVideoSourceStr(vs, long: true)
            } else {
                log = "None"
            }
            print("[getVideoSource] Selected at index:\(videoSourceIndexSelected) is: \(log).")
            return videoSource
        }
        
        // If already capturing, return the existing one.
        if let vs = videoSource {
            print("[getVideoSource] Using existing videoSource: \(getVideoSourceStr(vs)) as we only select a new one while capturing.")
        } else {
            print("[getVideoSource] FAILED! Unable to get new videoSource as current captureState is \(capState), and existing videoSource does not exist!")
        }
        return videoSource
    }
    
    /**
     Setter: Must on main thread.
     */
    var capabilityIndexSelected : Int {
        get {
            print("[capabilityIndexSelected][get] \(capabilityIndex!)")
            return capabilityIndex!
        }
        set {
            if(capState != .notCaptured){
                print("[capabilityIndexSelected][set] Failed! Only allowed to change resolution when not capturing. Capture state: \(capState). Current index: \(capabilityIndex)")
                return
            }
            
            // Set new value into UserDefaults
            var oldValue : String
            if(capabilityIndex == nil){
                oldValue = "nil"
            } else {
                oldValue = "\(capabilityIndex!)"
            }
            capabilityIndex = newValue
            UserDefaults.standard.setValue(capabilityIndex, forKey: capabilityIndexStr)
            print("[capabilityIndexSelected][set] Now: \(newValue) Was: \(oldValue)")
        }
    }
    
    func getCapabilities() -> Array<MCVideoCapabilities>? {
        print("[getCapabilities]")
        print("[getCapabilities] Checking for capabilities...")
        capabilities = getVideoSource()?.getCapabilities();
        if(capabilities == nil){
            print("[getCapabilities] No capability is available!")
            return nil
        }
        let size = (capabilities!.count)
        if(size < 1){
            print("[getCapabilities] Failed as list size was \(size)!")
            return nil
        } else {
            var log = "[getCapabilities] "
            for index in 0..<size {
                let cap = capabilities![index]
                log += "[\(index)]:" + getCapabilityStr(cap) + " "
            }
            print("\(log).")
        }
        return capabilities;
    }
    
    /**
     Get selected Capability from VideoSource
     By default some internal operation has to be done sync on the main thread.
     If this is not desired (for e.g. already on main thread), set useMain to false.
     */
    func getCapability(useMain: Bool = true)->MCVideoCapabilities? {
        print("[getCapability]")
        
        // If not currently capturing, get a new one based on selected index.
        if (capState != .isCaptured) {
            print("[getCapability] Selecting a new one based on selected index.")
            
            if let caps = getCapabilities(){
                let size = (caps.count)
                if (size < 1){
                    print("[getCapability] Failed as list size was \(size)!");
                    return nil
                }
                // If the selected index is larger than size, set it to maximum size.
                // This can happen when the videoSource has changed.
                if(capabilityIndexSelected >= size){
                    let task = { [self] in
                        print("[getCapability] Resetting capabilityIndexSelected as it is greater than number of capabilities available (\(size))!")
                        capabilityIndex = size - 1
                    }
                    if (useMain) {
                        DispatchQueue.main.sync {
                            task()
                        }
                    } else {
                        task()
                    }
                }
                capability = caps[capabilityIndexSelected]
            } else {
                print("[getCapability] Failed as no valid capability was available!")
                return nil
            }
            
            var log : String
            if let sc = capability {
                log = getCapabilityStr(sc)
            } else {
                log = "None"
            }
            print("[getCapability] Selected at index:\(capabilityIndexSelected) is: \(log).")
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
    
    /**
     Using the selected videoSource and capability, capture video into a pubVideoTrack.
     */
    func startCaptureVideo()->Void {
        let logTag = "[captureVideo]"
        print(logTag)
        if(videoSource != nil && videoSource!.isCapturing() ||
           capState != .notCaptured ){
            showAlert("[captureVideo] VideoSource is already capturing!")
            //                return
        }
        
        setCapState(to: .tryCapture, tag: logTag)
        
        // Set selected Capability into selected VideoSource
        if let vs = getVideoSource() {
            if let cap = getCapability() {
                vs.setCapability(cap)
                print("[captureVideo] Set \(getVideoSourceStr(vs)) with Cap: \(getCapabilityStr(cap)).")
            } else {
                setCapState(to: .notCaptured, tag: logTag)
                showAlert("[captureVideo] Failed as unable to get valid Capability for videoSource!")
                return
            }
        } else {
            setCapState(to: .notCaptured, tag: logTag)
            showAlert("[captureVideo] Failed as unable to get valid videoSource!")
            return
        }
        
        // Capture VideoTrack for publishing.
        print("[captureVideo] Capture with: \(getVideoSourceStr(videoSource!)).")
        
        pubVideoTrack = videoSource!.startCapture() as! MCVideoTrack
        if(videoSource!.isCapturing()){
            print("[captureVideo] OK.")
        } else {
            // setCapState(to: .notCaptured)
            showAlert("[captureVideo] VS.isCapturing FALSE!!! Despite having valid videoSource!")
        }
        setCapState(to: .isCaptured, tag: logTag)
        setMediaState(to: true, forPublisher: true, forAudio: false)
        renderPubVideo()
    }
    
    /**
     Check if video is captured.
     */
    func isVideoCaptured()->Bool{
        if(videoSource == nil || !videoSource!.isCapturing()){
            print("[isVideoCaptured] Video has not been captured!")
            return false
        }
        return true
    }
    
    func getAudioSources() -> Array<MCAudioSource>? {
        if (audioSources == nil) {
            print("[getAudioSources] Checking for audioSources...")
            audioSources = MCMedia.getAudioSources();
            let size = (audioSources!.count)
            if(size < 1){
                print("[getAudioSources] Failed as list size was \(size)!")
            } else {
                for index in 0..<size {
                    let vs = audioSources![index]
                    let log = "Type:\(vs.getTypeAsString()) Name:\(vs.getName()) id:\(vs.getUniqueId())"
                    print("[getAudioSources] audioSources[\(index)] is: \(log)")
                }
            }
        } else {
            print("[getAudioSources] Using existing audioSources.")
        }
        return audioSources;
    }
    
    func getAudioSource() -> MCAudioSource? {
        if (audioSource == nil) {
            print("[getAudioSource] Selecting audioSource.")
            if let asrcs = getAudioSources() {
                var size = asrcs.count
                if (size < 1){
                    print("[getAudioSource] Failed as list size was \(size)!")
                    return nil
                }
                // If the selected index is larger than size, set it to maximum size.
                // This might happen if the list of audioSources changed.
                if(selectedAudioSourceIndex + 1 > size){
                    print("[getAudioSource] Resetting selectedAudioSourceIndex as it is greater than number of audioSources available (\(size))!")
                    selectedAudioSourceIndex = size - 1
                }
                audioSource = asrcs[selectedAudioSourceIndex];
            } else {
                print("[getAudioSource] Failed as no valid audioSource was available!")
                return nil
            }
        }
        let log = "Type:\(audioSource?.getTypeAsString()) Name:\(audioSource?.getName()) id:\(audioSource?.getUniqueId())"
        print("[getAudioSource] Selected at index:\(selectedAudioSourceIndex) is: \(log).")
        return audioSource;
    }
    
    /**
     Using the selected audioSource, capture audio into a pubAudioTrack.
     */
    func startCaptureAudio()->Void {
        queuePub.async { [self] in
            if(audioSource != nil && audioSource!.isCapturing()){
                print("[captureAudio] AudioSource is already capturing!")
                return
            }
            
            if let asrc = getAudioSource() {
                // Capture AudioTrack for publishing.
                pubAudioTrack = asrc.startCapture() as! MCAudioTrack
                setMediaState(to: true, forPublisher: true, forAudio: true)
                print("[captureAudio] OK")
            } else {
                print("[captureAudio] Failed as unable to get valid audioSource!")
                return
            }
        }
    }
    
    /**
     Check if video is captured.
     */
    func isAudioCaptured()->Bool{
        if(audioSource == nil || !audioSource!.isCapturing()){
            print("[isAudioCaptured] Audio has not been captured!")
            return false
        }
        return true
    }
    
    /**
     Stop capturing video, if video is being captured.
     */
    func stopCaptureVideo()->Void {
        print("[stopCaptureVideo]")
        if(videoSource != nil){
            print("[stopCaptureVideo] videoSource is present.")
            if(videoSource!.isCapturing()){
                print("[stopCaptureVideo] videoSource is capturing.")
                videoSource!.stopCapture()
                setCapState(to: .notCaptured)
                setMediaState(to: false, forPublisher: true, forAudio: false)
                print("[stopCaptureVideo] videoSource stopped capturing.")
            }
            videoSource = nil
        }
        if pubVideoTrack != nil {
            pubVideoTrack!.remove(getPubRenderer())
            pubVideoTrack = nil
        }
    }
    
    /**
     Stop capturing audio, if audio is being captured.
     */
    func stopCaptureAudio()->Void {
        print("[stopCaptureAudio]")
        if(audioSource != nil){
            print("[stopCaptureAudio] audioSource is present.")
            if(audioSource!.isCapturing()){
                print("[stopCaptureAudio] audioSource is capturing.")
                audioSource!.stopCapture()
                setMediaState(to: false, forPublisher: true, forAudio: true)
                print("[stopCaptureAudio] audioSource stopped capturing.")
            }
            audioSource = nil
        }
        pubAudioTrack = nil
    }
    
    /*
     Render
     */
    
    /**
     Render the local video
     */
    func renderPubVideo()->Void {
        if(pubVideoTrack == nil){
            showAlert("[renderPubVideo] Unable to render as videoTrack does not exist.")
            return
        }
        pubVideoTrack!.add(getPubRenderer())
        print("[renderPubVideo] OK")
    }
    
    func getPubRenderer() -> MCIosVideoRenderer {
        if pubRenderer == nil {
            print("[getPubRenderer] Creating pub videoRenderer.")
            pubRenderer = MCIosVideoRenderer()
        }
        print("[getPubRenderer] OK")
        return pubRenderer!
    }
    
    /**
     Get the renderer for the Subscriber.
     Create one if none currently exists.
     */
    func getSubRenderer() -> MCIosVideoRenderer {
        print("[getSubRenderer]")
        if subRenderer == nil {
            print("Creating sub videoRenderer.")
            subRenderer = MCIosVideoRenderer()
        }
        return subRenderer!
    }
    
    /*
     Mute / unmute audio / video.
     */
    
    /**
     If track exist, set enable value as given and return it as well.
     Else, return nil.
     */
    func enableTrack(track : MCTrack?, enable : Bool) -> Bool? {
        if let t = track {
            t.enable(enable)
            print("[enableTrack] Set track enable to \(enable).")
            return enable
        }
        print("[enableTrack] Failed! Track was not available!")
        return nil
    }
    
    /*
     Select/Switch videoSource and capability
     */
    
    /**
     Gets the index of the next available camera.
     Returns nil if none available.
     */
    func videoSourceIndexNext()->Int?{
        let logTag = "[videoSourceIndexNext] "
        if(getVideoSources() == nil){
            print(logTag + "Failed as VideoSources not created!")
            return nil
        }
        let size = videoSources!.count
        if (size < 1){
            print(logTag + "Failed as list size was \(size)! This device does not have a camera.");
            return nil
        }
        let next : Int
        let now = videoSourceIndexSelected
        if( now >= (size - 1)){
            next = 0
            print(logTag + "\(next) (Cycling back to start)")
        } else {
            next = now + 1
            print(logTag + "\(next) Incrementing index.")
        }
        return next
    }
    
    /**
     Gets the index of the next available video capability.
     Returns nil if none available.
     */
    func capabilityIndexNext()->Int?{
        let logTag = "[capabilityIndexNext] "
        if let capabilities = getVideoSource()?.getCapabilities() {
            let size = capabilities.count
            if (size < 1){
                print(logTag + "Failed as list size was \(size)!");
                return nil
            }
            var next : Int
            if(capabilityIndexSelected >= (size - 1)){
                next = 0
                print(logTag + "\(next) (Cycling back to start)")
            } else {
                next = capabilityIndexSelected + 1
                print(logTag + "\(next) Incrementing index.")
            }
            return next
        } else {
            print(logTag + "Failed as videoSource or capability not available!")
            return nil
        }
    }
    
    /*
     Publish
     */
    
    /**
     The actual code for pubConnect.
     */
    private func pubConnectNQ(logTag: String)->Void {
        
        // Create Publisher if not present
        if publisher == nil {
            print(logTag + " Creating new Publisher...")
            publisher = MCPublisher.create();
            pubListener = getPubListener(for: publisher!)
            publisher!.setListener(pubListener)
        } else {
            if(publisher!.isPublishing()){
                showAlert(logTag + " Not publishing as is already publishing!")
                return
            }
            print(logTag + " Using existing Publisher...")
        }
        
        if(!isVideoCaptured()){
            var log = logTag + " VS.isCapturing FALSE!!!"
            if (capState == .isCaptured) {
                log += " Continueing as capState showed that video is captured."
                showAlert(log)
            } else {
                log += " Not publishing as video has not been captured!"
                showAlert(log)
                return
            }
        }
        // Add tracks to be published.
        if(pubVideoTrack == nil) {
            showAlert("FAIL! VideoTrack is NOT available!!!")
        }
        
        /**
         There seems to be a problem in libWebRTC when using H264 for higher iOS resolutions (e.g. 1920x1440, 2592x1936, 3264x2448).
         Currently working around this issue by not setting preferred video codec as H264 for higher resolutions.
         */
        if(pubOptions.videoCodec == "H264"){
            if let cap = getCapability() {
                var log = logTag + " Selectd video codec is H264."
                if((cap.width < 1920) || (cap.height < 1440)) {
                    log += " Setting it as preferred video codec as selected capability \(getCapabilityStr(cap)) is lower than "
                } else {
                    log += " NOT setting it as preferred video codec as selected capability \(getCapabilityStr(cap)) is higher than "
                    pubOptions.videoCodec = "VP8"
                }
                log += "1920x1440."
                print(log)
            }
        } else {
            print(logTag + " Set \(selectedVideoCodec!) as preferred video codec.")
        }
        
        publisher!.setOptions(pubOptions)
        publisher!.add(pubVideoTrack)
        publisher!.add(pubAudioTrack)
        
        // Connect Publisher.
        connectPublisher(pub: publisher!)
    }
    
    /**
     Get a PubListener if one exists, and set it's publisher to the provided one.
     Else, create and return a new one using the provided publisher.
     */
    func getPubListener(for pub: MCPublisher) -> PubListener {
        if let ltn = pubListener {
            ltn.publisher = pub
        } else {
            pubListener = PubListener(pub: pub)
        }
        return pubListener!
    }
    
    /**
     The actual code for stopPublish.
     */
    func stopPublishNQ(logTag: String)->Void {
        if(publisher == nil || !publisher!.isPublishing()){
            print(logTag + " Failed as we are not publishing!")
            return
        } else {
            publisher!.unpublish()
            setPubState(to: .connected)
        }
        print(logTag + " Stopped publish and going to disconnect...")
        disconnectPublisher(pub: publisher!)
        publisher = nil
    }
    
    func setRemoteAudioTrackVolume(volume: Double) -> Void {
        if(subscriber != nil && subscriber!.isSubscribed() && subAudioTrack != nil) {
            print("Setting audio track volume : \(volume)")
            subAudioTrack?.setVolume(volume)
        } else {
            print("Can't set audio volume")
        }
    }
    
    /**
     Utilities
     */
    
    /**
     Get a String that describes a MCVideoCapabilities.
     */
    func getCapabilityStr(_ cap : MCVideoCapabilities)->String{
        return "\(cap.width)x\(cap.height) fps:\(cap.fps)"
    }
    
    /**
     Get a String that describes a MCVideoSource.
     */
    func getVideoSourceStr(_ vs : MCVideoSource, long : Bool = false) -> String {
        let name = "Name:\(vs.getName() ?? "No name")"
        if(!long) {
            return name
        }
        return "Type:\(vs.getTypeAsString()) \(name) id:\(vs.getUniqueId())"
    }
    
}
