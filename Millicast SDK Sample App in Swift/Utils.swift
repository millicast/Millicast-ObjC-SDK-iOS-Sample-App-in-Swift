//
//  Utils.swift
//  Millicast SDK Sample App in Swift
//

import Foundation

/**
 * Utility methods used in the SA.
 */
class Utils {
    /**
     Get a String representing the specified CredentialSource.
     */
    public static func getCredStr(creds: CredentialSource) -> String {
        let str = "Account ID: \(creds.getAccountId())\n\t" +
            "Publishing stream name: \(creds.getStreamNamePub())\n\t" +
            "Subscribing stream name: \(creds.getStreamNameSub())\n\t" +
            "Publishing token: \(creds.getTokenPub())\n\t" +
            "Subscribing token: \(creds.getTokenSub())\n\t" +
            "Publishing API url: \(creds.getApiUrlPub())\n\t" +
            "Subscribing API url: \(creds.getApiUrlSub())\n\t"
        return str
    }

    /**
     Get a String value from UserDefaults, if available.
     If not, return the specified defaultValue.
     */
    public static func getValue(tag: String, key: String, defaultValue: String) -> String {
        var value: String
        var log = ""

        if let savedValue = UserDefaults.standard.string(forKey: key) {
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
    public static func getValue(tag: String, key: String, defaultValue: Int) -> Int {
        var value: Int
        var log = ""

        if let savedValue = UserDefaults.standard.object(forKey: key) {
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

    /**
     * Given a list of specified size and the current index, gets the next index.
     * If at end of list, cycle to start of the other end.
     * Returns null if none available.
     *
     * @param size      Size of the list.
     * @param now       Current index of the list.
     * @param ascending If true, cycle in the direction of increasing index,
     *                  otherwise cycle in opposite direction.
     * @param logTag
     * @return
     */
    public static func indexNext(size: Int, now: Int, ascending: Bool, logTag: String) -> Int {
        var next: Int
        if ascending {
            if now >= (size - 1) {
                next = 0
                print(logTag + "\(next) (Cycling back to start)")
            } else {
                next = now + 1
                print(logTag + "\(next) Incrementing index.")
            }
        } else {
            if now <= 0 {
                next = size - 1
                print(logTag + "\(next) (Cycling back to end)")
            } else {
                next = now - 1
                print(logTag + "\(next) Decrementing index.")
            }
        }
        print(logTag + "Next: " + "\(next) Now: \(now)")
        return next
    }
}
