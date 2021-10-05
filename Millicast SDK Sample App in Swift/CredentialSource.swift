//
//  CredentialSource.swift
//  Millicast SDK Sample App in Swift
//
//  Created by CoSMo Software on 17/8/21.
//

import Foundation

/**
 Provides Millicast credentials.
 */
protocol CredentialSource {
    
    func getAccountId() -> String
    func getPubStreamName() -> String
    func getPubToken() -> String
    func getSubStreamName() -> String
    func getPubApiUrl() -> String
    func getSubApiUrl() -> String
}
