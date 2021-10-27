//
//  PublishView.swift
//  Millicast SDK Sample App in Swift
//
//  Created by CoSMo Software on 30/7/21.
//

import SwiftUI

struct SubscribeView: View {
    
    @ObservedObject var mcMan : MillicastManager
    @State private var volume = 0.5
    
    static let labelSubscribeNot = "Not Subscribing"
    static let labelSubscribeStart = "Start Subscribe"
    static let labelSubscribeTry = "Trying to Subscribe..."
    static let labelSubscribeStop = "Stop Subscribe"
    static let labelAudioNo = "No Audio"
    static let labelAudioMute = "Mute Audio"
    static let labelAudioUnmute = "Unmute Audio"
    static let labelVideoNo = "No Video"
    static let labelVideoMute = "Mute Video"
    static let labelVideoUnmute = "Unmute Video"
    
    var mcSA : MillicastSA = MillicastSA.getInstance()
    
    init(manager mcMan : MillicastManager){
        self.mcMan = mcMan
    }
    
    var body: some View {
        VStack{
            Spacer()
            mcSA.getSubVideoView()
            Spacer()
            
            #if os(iOS)
            VStack {
                    Slider(
                        value: $volume,
                        in: 0...1,
                        onEditingChanged: { editing in
                            print("Volume \(volume) \(editing)")
                            if(!editing) {
                                self.mcMan.setRemoteAudioTrackVolume(volume: volume)
                            }
                        }
                    )
                    Text("Volume")
            }
            #endif
            HStack{
                Text("Account: \(mcMan.subCreds.accountId)")
                Text("Stream: \(mcMan.subCreds.streamName)")
            }
            HStack{
                Spacer()
                Button(getLabelSubscribe()) {
                    print("[SubView] Subscribe.")
                    getActionSubscribe()()
                }.padding().disabled(!getEnableSubscribe())
                
                Spacer()
                
                Button(getLabelAudio()){
                    print("[SubView] Toggled Audio.")
                    mcSA.toggleMedia(forPublisher: false, forAudio: true)
                }.padding().disabled(!getEnableAudio())
                
                Spacer()
                
                Button(getLabelVideo()){
                    print("[SubView] Toggled Video.")
                    mcSA.toggleMedia(forPublisher: false, forAudio: false)
                }.padding().disabled(!getEnableVideo())
                
                Spacer()
            }
            Spacer()
        }.alert(isPresented: $mcMan.alert) {
            Alert(title: Text("Alert"), message: Text(mcMan.alertMsg), dismissButton: .default(Text("OK")))
        }
    }
    
    /**
     * Set the state of subscribe, audio and video buttons,
     * based on current subscribe and media states.
     */
    func getStates() -> (labelSubscribe : String,
                         actionSubscribe : () -> (),
                         enableSubscribe : Bool,
                         enableAudio : Bool,
                         enableVideo : Bool
    ) {
        var labelSubscribe : String = ""
        var actionSubscribe : (() -> ()) = {}
        var enableSubscribe : Bool = false
        // Whether to enable buttons for Audio/Video on the UI.
        var enableAudio : Bool = false
        var enableVideo : Bool = false
        
        switch mcMan.subState {
            case .disconnected:
                labelSubscribe = SubscribeView.labelSubscribeStart
                actionSubscribe = mcSA.startSubscribe
                enableSubscribe = true
            case .connecting, .connected:
                labelSubscribe = SubscribeView.labelSubscribeTry
                enableSubscribe = false
            case .subscribing:
                labelSubscribe = SubscribeView.labelSubscribeStop
                actionSubscribe = mcSA.stopSubscribe
                enableSubscribe = true
                // Only allow audio/video buttons to be enabled when subscribing.
                enableAudio = true
                enableVideo = true
        }
        
        return (labelSubscribe, actionSubscribe, enableSubscribe, enableAudio, enableVideo)
    }
    
    func getLabelSubscribe() -> String {
        return getStates().labelSubscribe
    }
    
    func getActionSubscribe() -> (()->()) {
        return getStates().actionSubscribe
    }
    
    func getEnableSubscribe() -> Bool {
        return getStates().enableSubscribe
    }
    
    func getLabelAudio() -> String {
        if(getEnableAudio()){
            if(mcMan.subAudioEnabled){
                return SubscribeView.labelAudioMute
            } else {
                return SubscribeView.labelAudioUnmute
            }
        }
        return SubscribeView.labelAudioNo
    }
    
    func getEnableAudio() -> Bool {
        return getStates().enableAudio
    }
    
    func getLabelVideo() -> String {
        if(getEnableVideo()){
            if(mcMan.subVideoEnabled){
                return SubscribeView.labelVideoMute
            } else {
                return SubscribeView.labelVideoUnmute
            }
        }
        return SubscribeView.labelVideoNo
    }
    
    func getEnableVideo() -> Bool {
        return getStates().enableVideo
    }
}

struct SubscribeView_Previews: PreviewProvider {
    static var previews: some View {
        SubscribeView(manager: MillicastManager.getInstance())
    }
}
