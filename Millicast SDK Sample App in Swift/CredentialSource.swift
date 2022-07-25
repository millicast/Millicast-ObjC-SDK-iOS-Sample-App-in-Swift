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
    var credsType: SourceType { get }

    func getAccountId() -> String
    func getStreamNamePub() -> String
    func getTokenPub() -> String
    func getTokenSub() -> String
    func getStreamNameSub() -> String
    func getApiUrlPub() -> String
    func getApiUrlSub() -> String
}

enum SourceType {
    case file
    case saved
    case current
    case ui
}
