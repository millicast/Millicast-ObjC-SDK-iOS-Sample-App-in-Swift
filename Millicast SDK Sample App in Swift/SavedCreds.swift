//
//  CredsManager.swift
//  Millicast SDK Sample App in Swift
//
//  Created by CoSMo Software on 17/8/21.
//

import Foundation

/**
 Serve as a source of Millicast Credentials.
 Read from UserDefaults, if present.
 Otherwise, read from Constants file.
 */
class SavedCreds: CredentialSource {
    var credsType = SourceType.saved
    let accountId = "ACCOUNT_ID"
    let pubStreamName = "PUB_STREAM_NAME"
    let subStreamName = "SUB_STREAM_NAME"
    let pubToken = "PUBLISH_TOKEN"
    let pubApiUrl = "PUBLISH_URL"
    let subApiUrl = "SUBSCRIBE_URL"
    
    func getAccountId() -> String {
        let logTag = "[Creds][Saved][Account][Id] "
        return Utils.getValue(tag: logTag, key: accountId, defaultValue: Constants.ACCOUNT_ID)
    }
    
    func getPubStreamName() -> String {
        let logTag = "[Creds][Saved][Pub][Stream][Name] "
        return Utils.getValue(tag: logTag, key: pubStreamName, defaultValue: Constants.PUB_STREAM_NAME)
    }
    
    func getSubStreamName() -> String {
        let logTag = "[Creds][Saved][Sub][Stream][Name] "
        return Utils.getValue(tag: logTag, key: subStreamName, defaultValue: Constants.SUB_STREAM_NAME)
    }
    
    func getPubToken() -> String {
        let logTag = "[Creds][Saved][Pub][Token] "
        return Utils.getValue(tag: logTag, key: pubToken, defaultValue: Constants.PUBLISH_TOKEN)
    }
    
    func getPubApiUrl() -> String {
        let logTag = "[Creds][Saved][Pub][Api][Url] "
        return Utils.getValue(tag: logTag, key: pubApiUrl, defaultValue: Constants.PUBLISH_URL)
    }
    
    func getSubApiUrl() -> String {
        let logTag = "[Creds][Saved][Sub][Api][Url] "
        return Utils.getValue(tag: logTag, key: subApiUrl, defaultValue: Constants.SUBSCRIBE_URL)
    }
}
