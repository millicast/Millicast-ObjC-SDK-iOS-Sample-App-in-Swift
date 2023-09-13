//
//  Constants.swift
//  Millicast SDK Sample App in Swift
//
//  Created by CoSMo Software on 11/8/21.
//

import Foundation

/**
 * Values for Millicast related constants.
 * Fill in the desired values for these constants as required.
 * These values can be edited in the Millicast Settings UI.
 * The UI also provides a way to reload the file values here.
 */
struct Constants {
    
    // Set the following as default values if desired.
    
    //Set Millicast account ID here.
    static let ACCOUNT_ID = "k9Mwad"
    // Set publishing stream name here. Optional if not publishing.
    static let STREAM_NAME_PUB = "l7az5uxm"
    // Set subscribing stream name here. Optional if not subscribing.
    static let STREAM_NAME_SUB = "multiview"
    // Set publishing token here. Optional if not publishing.
    static let TOKEN_PUB = "d5fe0fc8355cc9a34ac6d44f184079be038ae21f0fd203595dbaa40489fe390c"
    // Set the publish API url here.
    static let URL_PUB = "https://director.millicast.com/api/director/publish"
    // Set the subscribe API url here.
    static let URL_SUB = "https://director.millicast.com/api/director/subscribe"
    // Set subscribing token here. Optional if not subscribing or not using subscribe token.
    static let TOKEN_SUB = ""
    
}
