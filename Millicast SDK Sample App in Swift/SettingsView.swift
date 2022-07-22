//
//  PublishView.swift
//  Millicast SDK Sample App in Swift
//
//  Created by CoSMo Software on 30/7/21.
//

import AVFoundation
import SwiftUI

struct SettingsView: View, CredentialSource {
    @State var accountId = ""
    @State var pubStreamName = ""
    @State var subStreamName = ""
    @State var pubToken = ""
    @State var pubApiUrl = ""
    @State var subApiUrl = ""
    
    /**
     Creds TextField background color to use if UI value has been applied.
     */
    let colorApplied = Color.yellow.opacity(0.2)
    /**
     Creds TextField background color to use if UI value differs from that applied.
     */
    let colorChanged = Color.black.opacity(0.2)
    
    @ObservedObject var mcMan: MillicastManager
    @ObservedObject var mcSA: MillicastSA
    var credsType = SourceType.ui
    
    init(manager mcMan: MillicastManager) {
        self.mcMan = mcMan
        mcSA = MillicastSA.getInstance()
                
        print("[SetView][init] Account ID: \(accountId)\nPublishing stream name: \(pubStreamName)\nSubscribing stream name: \(subStreamName)\nPublishing token: \(pubToken)\nPublishing API url: \(pubApiUrl)\nSubscribing API url: \(subApiUrl)\n")
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Account ID:")
                TextField("Account ID", text: $accountId).background(useColor(ui: accountId, applied: mcSA.accountId))
            }
            HStack {
                Text("Publishing stream name:")
                TextField("Publishing stream name", text: $pubStreamName).background(useColor(ui: pubStreamName, applied: mcSA.pubStreamName))
            }
            HStack {
                Text("Subscribing stream name:")
                TextField("Subscribing stream name", text: $subStreamName).background(useColor(ui: subStreamName, applied: mcSA.subStreamName))
            }
            HStack {
                Text("Publishing token:")
                TextField("Publishing token", text: $pubToken).background(useColor(ui: pubToken, applied: mcSA.pubToken))
            }
            HStack {
                Text("Publishing API url:")
                TextField("Publishing API url", text: $pubApiUrl).background(useColor(ui: pubApiUrl, applied: mcSA.pubApiUrl))
            }
            HStack {
                Text("Subscribing API url:")
                TextField("Subscribing API url", text: $subApiUrl).background(useColor(ui: subApiUrl, applied: mcSA.subApiUrl))
            }
            HStack {
                VStack {
                    Spacer()
                    Text("Load values using:").padding()
                    
                    Button("APPLIED") {
                        setUiCreds(creds: mcSA.getCurrentCreds())
                    }
                    Spacer()
                    Button("MEMORY") {
                        setUiCreds(creds: mcSA.getSavedCreds())
                    }
                    Spacer()
                    Button("FILE") {
                        setUiCreds(creds: mcSA.getFileCreds())
                    }
                    Spacer()
                }
                VStack {
                    Spacer()
                    Text("Changes only apply after clicking:").padding()
                    Button("Apply UI values") {
                        mcSA.setCreds(from: self, save: false)
                    }
                    Spacer()
                    Button("Apply & save UI values") {
                        mcSA.setCreds(from: self, save: true)
                    }
                    Spacer()
                }
            }
            Spacer()
        }.padding()
            .alert(isPresented: $mcMan.alert) {
                Alert(title: Text("Alert"), message: Text(mcMan.alertMsg), dismissButton: .default(Text("OK")))
            }.onAppear {
                setUiCreds(creds: mcSA.getUiCreds())
                print("[SetView] Loading settings. Account ID: \(accountId)\nPublishing stream name: \(pubStreamName)\nSubscribing stream name: \(subStreamName)\nPublishing token: \(pubToken)\nPublishing API url: \(pubApiUrl)\nSubscribing API url: \(subApiUrl)\n")
            }.onDisappear {
                mcSA.setUiCreds(self)
            }
    }
    
    /**
     Return the background color for a creds entry.
     If the current UI value of the creds has been applied, colorApplied will be returned.
     If the current UI value of the creds differs from the creds applied, colorChanged will be returned.
     */
    private func useColor(ui: String, applied: String) -> Color {
        if ui == applied {
            return colorApplied
        } else {
            return colorChanged
        }
    }
    
    /**
     Load the UI credentials values using the specified CredentialSource.
     */
    private func setUiCreds(creds: CredentialSource) {
        let logTag = "[Creds][Ui][Set] "
        let log = "Setting Creds of type \(creds.credsType) to UI."
        print(logTag + log)
        
        accountId = creds.getAccountId()
        pubStreamName = creds.getPubStreamName()
        subStreamName = creds.getSubStreamName()
        pubToken = creds.getPubToken()
        pubApiUrl = creds.getPubApiUrl()
        subApiUrl = creds.getSubApiUrl()
    }

    func getAccountId() -> String {
        return accountId
    }

    func getPubStreamName() -> String {
        return pubStreamName
    }
    
    func getPubToken() -> String {
        return pubToken
    }
    
    func getSubStreamName() -> String {
        return subStreamName
    }
    
    func getPubApiUrl() -> String {
        return pubApiUrl
    }
    
    func getSubApiUrl() -> String {
        return subApiUrl
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(manager: MillicastManager.getInstance())
    }
}
