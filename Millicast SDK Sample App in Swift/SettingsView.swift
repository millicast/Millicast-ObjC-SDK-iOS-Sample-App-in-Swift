//
//  PublishView.swift
//  Millicast SDK Sample App in Swift
//
//  Created by CoSMo Software on 30/7/21.
//

import SwiftUI

struct SettingsView: View, CredentialSource {
    
    @State var accountId = ""
    @State var pubStreamName = ""
    @State var subStreamName = ""
    @State var pubToken = ""
    @State var pubApiUrl = ""
    @State var subApiUrl = ""
    
    @ObservedObject var mcMan : MillicastManager
    var mcSA : MillicastSA
    var savedCreds : SavedCreds
    
    init(manager mcMan : MillicastManager){
        self.mcMan = mcMan
        mcSA = MillicastSA.getInstance()
        savedCreds = mcSA.getSavedCreds()
        _accountId = State.init(initialValue: mcMan.subCreds.accountId)
        _pubStreamName = State.init(initialValue: mcMan.pubCreds.streamName)
        _subStreamName = State.init(initialValue: mcMan.subCreds.streamName)
        _pubToken = State.init(initialValue: mcMan.pubCreds.token)
        _pubApiUrl = State.init(initialValue: mcMan.pubCreds.apiUrl)
        _subApiUrl = State.init(initialValue: mcMan.subCreds.apiUrl)
        
        print("[SetView][init] Account ID: \(accountId)\nPublishing stream name: \(pubStreamName)\nSubscribing stream name: \(subStreamName)\nPublishing token: \(pubToken)\nPublishing API url: \(pubApiUrl)\nSubscribing API url: \(subApiUrl)\n")
    }
    
    var body: some View {
        VStack {
            HStack{
                Text("Account ID:")
                TextField("Account ID", text: $accountId).background(Color.yellow)
            }
            HStack{
                Text("Publishing stream name:")
                TextField("Publishing stream name", text: $pubStreamName).background(Color.yellow)
            }
            HStack{
                Text("Subscribing stream name:")
                TextField("Subscribing stream name", text: $subStreamName).background(Color.yellow)
            }
            HStack{
                Text("Publishing token:")
                TextField("Publishing token", text: $pubToken).background(Color.yellow)
            }
            HStack{
                Text("Publishing API url:")
                TextField("Publishing API url", text: $pubApiUrl).background(Color.yellow)
            }
            HStack{
                Text("Subscribing API url:")
                TextField("Subscribing API url", text: $subApiUrl).background(Color.yellow)
            }
            HStack {
                Spacer()
                Button("Apply file values"){
                    resetStates(useFile: true)
                    mcSA.setCreds(from: self,save: false)
                }
                Spacer()
                Button("Apply saved values"){
                    resetStates(useFile: false)
                    mcSA.setCreds(from: self,save: false)
                }
                Spacer()
                Button("Apply UI values"){
                    mcSA.setCreds(from: self,save: false)
                }
                Spacer()
                Button("Apply & save UI values") {
                    mcSA.setCreds(from: self, save: true)
                }
                Spacer()
            }
        }.alert(isPresented: $mcMan.alert) {
            Alert(title: Text("Alert"), message: Text(mcMan.alertMsg), dismissButton: .default(Text("OK")))
        }.onAppear(){
            accountId = mcMan.subCreds.accountId
            pubStreamName = mcMan.pubCreds.streamName
            subStreamName = mcMan.subCreds.streamName
            pubToken = mcMan.pubCreds.token
            pubApiUrl = mcMan.pubCreds.apiUrl
            subApiUrl = mcMan.subCreds.apiUrl
            print("[SetView] Loading settings. Account ID: \(accountId)\nPublishing stream name: \(pubStreamName)\nSubscribing stream name: \(subStreamName)\nPublishing token: \(pubToken)\nPublishing API url: \(pubApiUrl)\nSubscribing API url: \(subApiUrl)\n")
        }
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
    
    /**
     Reset the UI values using either file values or saved values.
     If saved values not present, file values would be used.
     */
    func resetStates(useFile: Bool) -> Void {
        accountId = savedCreds.getAccountId(useFile: useFile)
        pubStreamName = savedCreds.getPubStreamName(useFile: useFile)
        subStreamName = savedCreds.getSubStreamName(useFile: useFile)
        pubToken = savedCreds.getPubToken(useFile: useFile)
        pubApiUrl = savedCreds.getPubApiUrl(useFile: useFile)
        subApiUrl = savedCreds.getSubApiUrl(useFile: useFile)
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(manager: MillicastManager.getInstance())
    }
}
