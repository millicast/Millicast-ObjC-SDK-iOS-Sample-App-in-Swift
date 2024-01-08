//
//  SettingsMediaView.swift
//  SwiftSa iOS
//
//  Created by Szymczak, Marcin on 28/12/2023.
//

import Foundation


import AVFoundation
import SwiftUI
import MillicastSDK

/**
 * UI for Millicast platform settings.
 */
struct MediaSettingsView: View {
    
    @ObservedObject var mcMan: MillicastManager
    
    init(manager mcMan: MillicastManager) {
        self.mcMan = mcMan
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0.0) {
            VStack(){
                HStack {
                    Text("Media Capture Settings")
                        .font(.title3)
                    .fontWeight(.bold)
                }.frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    alignment: .center
                  )
                List {
                    Picker("Video Source", selection: $mcMan.videoSourceIndex) {
                        ForEach(mcMan.getWrappedVideoSourceList()){src in
                            Text("\(src.source.getName()) [\(src.id)]").tag(src.id)
                        }
                    }
                    .onChange(of: mcMan.videoSourceIndex){tag in mcMan.setVideoSourceIndex(tag, setCapIndex: true)}
                    .disabled(mcMan.capState == .isCaptured)
                    
                    Picker("Video Capability", selection: $mcMan.capabilityIndex) {
                        ForEach(mcMan.getWrappedCapabilityList()){cap in
                            Text("\(cap.capability.width)x\(cap.capability.height)x\(cap.capability.fps) [\(cap.id)]").tag(cap.id)
                        }
                    }
                    .onChange(of: mcMan.capabilityIndex){tag in mcMan.setCapabilityIndex(tag)}
                    
                    
                    Picker("Audio Source", selection: $mcMan.audioSourceIndex) {
                        ForEach(mcMan.getWrappedAudioSourceList()){src in
                            Text(src.source.getName()).tag(src.id)
                        }
                    }
                    .onChange(of: mcMan.audioSourceIndex){tag in mcMan.setAudioSourceIndex(tag)}
                    
                    
                    Toggle(isOn: $mcMan.audioOnly, label: {
                        Text("Audio only")
                    })
                    
                }.listStyle(PlainListStyle())
            }
            
            Spacer()
            VStack(){
                    Text("Publish Settings")
                        .font(.title3)
                        .fontWeight(.bold)
                    List {
                        Picker("Audio Codecs", selection: $mcMan.audioCodecIndex) {
                            ForEach(mcMan.getWrappedCodecList(forAudio: true)){wrapped in
                                Text(wrapped.codec).tag(wrapped.id)
                            }
                        }
                        .onChange(of: mcMan.audioCodecIndex){tag in mcMan.setCodecIndex(newValue: tag, forAudio: true)}
                        
                        Picker("Video Codecs", selection: $mcMan.videoCodecIndex) {
                            ForEach(mcMan.getWrappedCodecList(forAudio: false)){wrapped in
                                Text(wrapped.codec).tag(wrapped.id)
                            }
                        }
                        .onChange(of: mcMan.videoCodecIndex){tag in mcMan.setCodecIndex(newValue: tag, forAudio: false)}
                    }.listStyle(PlainListStyle())
            }
            Spacer()
            VStack(){
                Text("Subscribe Settings")
                    .font(.title3)
                    .fontWeight(.bold)
                List {
                    Picker("Audio Playback Device", selection: $mcMan.audioPlaybackIndex) {
                        ForEach(mcMan.getWrappedAudioPlaybackList()){wrapped in
                            Text(wrapped.audioPlayback.getName()).tag(wrapped.id)
                        }
                    }
                    .onChange(of: mcMan.audioPlaybackIndex){tag in mcMan.setAudioPlaybackIndex(newValue: tag)}
                }.listStyle(PlainListStyle())
                Spacer()
            }
        }
    }
}

struct MediaSettingsView_Previev: PreviewProvider {
    static var previews: some View {
        MediaSettingsView(manager: MillicastManager.getInstance())
    }
}
