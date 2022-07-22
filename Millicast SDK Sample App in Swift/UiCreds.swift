//
//  UiCreds.swift
//  SwiftSa
//
//  Created by Liang, Xiangrong on 24/7/22.
//

import Foundation
import MillicastSDK

/**
 Serve as a source of Millicast Credentials.
 Read from UI values in SettingsView.
 Values will be empty Strings ("") if no values were applied in SettingsView.
 */
class UiCreds: CredentialSource {
    var credsType = SourceType.ui
    var streamNamePub = ""
    var tokenPub = ""
    var apiUrlPub = ""
    var accountId = ""
    var streamNameSub = ""
    var apiUrlSub = ""
   
    /**
     Read Millicast credentials and set into MillicastManager using CredentialSource.
     */
    public func setCreds(using creds: CredentialSource) {
        print("[Creds][Ui][Set] Account ID: \(creds.getAccountId())\nPublishing stream name: \(creds.getPubStreamName())\nSubscribing stream name: \(creds.getSubStreamName())\nPublishing token: \(creds.getPubToken())\nPublishing API url: \(creds.getPubApiUrl())\nSubscribing API url: \(creds.getSubApiUrl())\n")

        // Publishing
        streamNamePub = creds.getPubStreamName()
        tokenPub = creds.getPubToken()
        apiUrlPub = creds.getPubApiUrl()
        // Subscribing
        accountId = creds.getAccountId()
        streamNameSub = creds.getSubStreamName()
        apiUrlSub = creds.getSubApiUrl()
    }

    func getAccountId() -> String {
        let logTag = "[Creds][Cur][Account][Id] "
        let value = accountId
        print(logTag + value)
        return value
    }
    
    func setAccountId(value: String) {
        let logTag = "[Creds][Cur][Account][Id][Set] "
        accountId = value
        print(logTag + value)
    }
    
    func getPubStreamName() -> String {
        let logTag = "[Creds][Cur][Pub][Stream][Name] "
        let value = streamNamePub
        print(logTag + value)
        return value
    }
    
    func setPubStreamName(value: String) {
        let logTag = "[Creds][Cur][Pub][Stream][Name][Set] "
        streamNamePub = value
        print(logTag + value)
    }
    
    func getSubStreamName() -> String {
        let logTag = "[Creds][Cur][Sub][Stream][Name] "
        let value = streamNameSub
        print(logTag + value)
        return value
    }
    
    func setSubStreamName(value: String) {
        let logTag = "[Creds][Cur][Sub][Stream][Name][Set] "
        streamNameSub = value
        print(logTag + value)
    }
    
    func getPubToken() -> String {
        let logTag = "[Creds][Cur][Pub][Token] "
        let value = tokenPub
        print(logTag + value)
        return value
    }
    
    func setPubToken(value: String) {
        let logTag = "[Creds][Cur][Pub][Token][Set] "
        tokenPub = value
        print(logTag + value)
    }
    
    func getPubApiUrl() -> String {
        let logTag = "[Creds][Cur][Pub][Api][Url] "
        let value = apiUrlPub
        print(logTag + value)
        return value
    }
    
    func setPubApiUrl(value: String) {
        let logTag = "[Creds][Cur][Pub][Api][Url][Set] "
        apiUrlPub = value
        print(logTag + value)
    }
    
    func getSubApiUrl() -> String {
        let logTag = "[Creds][Cur][Sub][Api][Url] "
        let value = apiUrlSub
        print(logTag + value)
        return value
    }
    
    func setSubApiUrl(value: String) {
        let logTag = "[Creds][Cur][Sub][Api][Url][Set] "
        apiUrlSub = value
        print(logTag + value)
    }
}
