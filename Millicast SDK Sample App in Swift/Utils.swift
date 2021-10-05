//
//  Utils.swift
//  Millicast SDK Sample App in Swift
//
//  Created by CoSMo Software on 13/9/21.
//

import Foundation

class Utils {
    
    /**
     Get a String value from UserDefaults, if available.
     If not, return the specified defaultValue.
     */
    static func getValue(tag:String, key:String, defaultValue:String) -> String {
        
        var value : String
        var log = ""
        
        if let savedValue = UserDefaults.standard.string(forKey:key){
            log = "Used saved UserDefaults."
            value = savedValue
        } else {
            value = defaultValue
            log = "No UserDefaults, used default value."
        }
        log = "\(tag) \(value) - \(log)"
        print(log)
        return value
    }
    
    /**
     Get an integer value from UserDefaults, if available.
     If not, return the specified defaultValue.
     */
    static func getValue(tag:String, key:String, defaultValue:Int) -> Int {
        
        var value : Int
        var log = ""
        
        if let savedValue = UserDefaults.standard.object(forKey: key){
            log = "Used saved UserDefaults."
            value = savedValue as! Int
        } else {
            value = defaultValue
            log = "No UserDefaults, used default value."
        }
        log = "\(tag) \(value) - \(log)"
        print(log)
        return value
    }
}
