//
//  CurrentCreds.swift
//  Millicast SDK Sample App in Swift
//

import Foundation
import MillicastSDK

/**
 Serves as the currently applied source of Millicast Credentials.
 MillicastManager reads and writes the currently applied values to this.
 Publishes to the UI the currently applied creds.
 Values will be empty Strings ("") if no values were applied.
 */
class CurrentCreds: CredentialSource, ObservableObject {
    var credsType = SourceType.current
    
    var mcMan: MillicastManager
    var credsPub: MCPublisherCredentials
    var credsSub: MCSubscriberCredentials

    @Published var streamNamePub = ""
    @Published var tokenPub = ""
    @Published var apiUrlPub = ""
    @Published var accountId = ""
    @Published var streamNameSub = ""
    @Published var apiUrlSub = ""
    @Published var tokenSub = ""

    init(mcMan: MillicastManager) {
        self.mcMan = mcMan
        credsPub = MCPublisherCredentials()
        credsSub = MCSubscriberCredentials()
    }
    
    func getCredsPub() -> MCPublisherCredentials {
        return credsPub
    }
    
    func getCredsSub() -> MCSubscriberCredentials {
        return credsSub
    }
    
    func getAccountId() -> String {
        let logTag = "[Creds][Cur][Account][Id] "
        let value = credsSub.accountId
        print(logTag + value)
        return value
    }
    
    func setAccountId(_ value: String) {
        let logTag = "[Creds][Cur][Account][Id][Set] "
        credsSub.accountId = value
        accountId = value
        print(logTag + value)
    }
    
    func getStreamNamePub() -> String {
        let logTag = "[Creds][Cur][Pub][Stream][Name] "
        let value = credsPub.streamName ?? ""
        print(logTag + value)
        return value
    }
    
    func setStreamNamePub(_ value: String) {
        let logTag = "[Creds][Cur][Pub][Stream][Name][Set] "
        credsPub.streamName = value
        streamNamePub = value
        print(logTag + value)
    }
    
    func getStreamNameSub() -> String {
        let logTag = "[Creds][Cur][Sub][Stream][Name] "
        let value = credsSub.streamName
        print(logTag + value)
        return value
    }
    
    func setStreamNameSub(_ value: String) {
        let logTag = "[Creds][Cur][Sub][Stream][Name][Set] "
        credsSub.streamName = value
        streamNameSub = value
        print(logTag + value)
    }

    func getTokenPub() -> String {
        let logTag = "[Creds][Cur][Pub][Token] "
        let value = credsPub.token ?? ""
        print(logTag + value)
        return value
    }
    
    func setTokenPub(_ value: String) {
        let logTag = "[Creds][Cur][Pub][Token][Set] "
        credsPub.token = value
        tokenPub = value
        print(logTag + value)
    }

    func getTokenSub() -> String {
        let logTag = "[Creds][Cur][Sub][Token] "
        let value = credsSub.token
        print(logTag + value)
        return value
    }
    
    func setTokenSub(_ value: String) {
        let logTag = "[Creds][Cur][Sub][Token][Set] "
        credsSub.token = value
        tokenSub = value
        print(logTag + value)
    }

    func getApiUrlPub() -> String {
        let logTag = "[Creds][Cur][Pub][Api][Url] "
        let value = credsPub.apiUrl ?? ""
        print(logTag + value)
        return value
    }
    
    func setApiUrlPub(_ value: String) {
        let logTag = "[Creds][Cur][Pub][Api][Url][Set] "
        credsPub.apiUrl = value
        apiUrlPub = value
        print(logTag + value)
    }

    func getApiUrlSub() -> String {
        let logTag = "[Creds][Cur][Sub][Api][Url] "
        let value = credsSub.apiUrl
        print(logTag + value)
        return value
    }

    func setApiUrlSub(_ value: String) {
        let logTag = "[Creds][Cur][Sub][Api][Url][Set] "
        credsSub.apiUrl = value
        apiUrlSub = value
        print(logTag + value)
    }
}
