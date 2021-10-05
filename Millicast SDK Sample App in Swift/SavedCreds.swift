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
class SavedCreds : CredentialSource {
    
    let accountId = "ACCOUNT_ID"
    let pubStreamName = "PUB_STREAM_NAME"
    let subStreamName = "SUB_STREAM_NAME"
    let pubToken = "PUBLISH_TOKEN"
    let pubApiUrl = "PUBLISH_URL"
    let subApiUrl = "SUBSCRIBE_URL"
    
    func getAccountId() -> String {
        let tag = "[CredsManager][getAccountId]"
        return Utils.getValue(tag: tag, key: accountId, defaultValue: Constants.ACCOUNT_ID)
    }
    
    func getAccountId(useFile : Bool) -> String {
        if(useFile) {
            return Constants.ACCOUNT_ID
        }
        return getAccountId()
    }
    
    func getPubStreamName() -> String {
        let tag = "[CredsManager][getPubStreamName]"
        return Utils.getValue(tag: tag, key: pubStreamName, defaultValue: Constants.PUB_STREAM_NAME)
    }
    
    func getPubStreamName(useFile : Bool) -> String {
        if(useFile){
            return Constants.PUB_STREAM_NAME
        }
        return getPubStreamName()
    }
    
    func getSubStreamName() -> String {
        let tag = "[CredsManager][getSubStreamName]"
        return Utils.getValue(tag: tag, key: subStreamName, defaultValue: Constants.SUB_STREAM_NAME)
    }
    
    func getSubStreamName(useFile : Bool) -> String {
        if(useFile){
            return Constants.SUB_STREAM_NAME
        }
        return getSubStreamName()
    }
    
    func getPubToken() -> String {
        let tag = "[CredsManager][getPubToken]"
        return Utils.getValue(tag: tag, key: pubToken, defaultValue: Constants.PUBLISH_TOKEN)
    }
    
    func getPubToken(useFile : Bool) -> String {
        if(useFile){
            return Constants.PUBLISH_TOKEN
        }
        return getPubToken()
    }
    
    func getPubApiUrl() -> String {
        let tag = "[CredsManager][getPubApiUrl]"
        return Utils.getValue(tag: tag, key: pubApiUrl, defaultValue: Constants.PUBLISH_URL)
    }
    
    func getPubApiUrl(useFile : Bool) -> String {
        if(useFile){
            return Constants.PUBLISH_URL
        }
        return getPubApiUrl()
    }
    
    func getSubApiUrl() -> String {
        let tag = "[CredsManager][getSubApiUrl]"
        return Utils.getValue(tag: tag, key: subApiUrl, defaultValue: Constants.SUBSCRIBE_URL)
    }
    
    func getSubApiUrl(useFile : Bool) -> String {
        if(useFile){
            return Constants.SUBSCRIBE_URL
        }
        return getSubApiUrl()
    }
    
}
