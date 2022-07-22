//
//  FileCreds.swift
//  SwiftSa iOS
//
//  Created by Liang, Xiangrong on 22/7/22.
//

import Foundation

/**
 Serve as a source of Millicast Credentials.
 Read from Constants.swift.
 */
class FileCreds: CredentialSource {
    var credsType = SourceType.file
    func getAccountId() -> String {
        let logTag = "[Creds][File][Account][Id] "
        let value = Constants.ACCOUNT_ID
        print(logTag + value)
        return value
    }
    
    func getPubStreamName() -> String {
        let logTag = "[Creds][File][Pub][Stream][Name] "
        let value = Constants.PUB_STREAM_NAME
        print(logTag + value)
        return value
    }
    
    func getSubStreamName() -> String {
        let logTag = "[Creds][File][Sub][Stream][Name] "
        let value = Constants.SUB_STREAM_NAME
        print(logTag + value)
        return value
    }
    
    func getPubToken() -> String {
        let logTag = "[Creds][File][Pub][Token] "
        let value = Constants.PUBLISH_TOKEN
        print(logTag + value)
        return value
    }
    
    func getPubApiUrl() -> String {
        let logTag = "[Creds][File][Pub][Api][Url] "
        let value = Constants.PUBLISH_URL
        print(logTag + value)
        return value
    }
    
    func getSubApiUrl() -> String {
        let logTag = "[Creds][File][Sub][Api][Url] "
        let value = Constants.SUBSCRIBE_URL
        print(logTag + value)
        return value
    }
}
