//
//  MCSwiftVideoRenderer.swift
//  Millicast SDK Sample App in Swift
//

import AVKit
import Foundation
import MillicastSDK
import SwiftUI

/**
 * Swift version of the MCIosVideoRenderer that can be used in Swift UI.
 * It renders video frames in a UI view and also provides an API to mirror the view.
 */
final class MCSwiftVideoRenderer: MCIosVideoRenderer, UIViewRepresentable {
    var mcMan: MillicastManager?
    var uiView: UIView?
    var isMirrored = false
    
    init(mcMan: MillicastManager) {
        super.init(colorRangeExpansion: false)
        self.mcMan = mcMan
        uiView = getView()
    }
    
    func makeUIView(context: Context) -> UIView {
        guard let view = getView() else {
            return UIView()
        }
        uiView?.contentMode = .scaleAspectFit
        return uiView!
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    /**
     * Sets the UIView to be mirrored or not based on the parameter.
     * Runs on main thread.
     *
     * @return True if mirrored state changed, false otherwise.
     */
    public func setMirror(_ mirror: Bool) -> Bool {
        let logTag = "[Video][Render][er][Mirror]:\(mirror). "
        if isMirrored == mirror {
            print(logTag + "Not setting as current mirrored state is already \(isMirrored).")
            return false
        }
        if let view = uiView {
            var task = { [self] in
                var log = "Set current mirrored state to "
                if mirror {
                    view.transform = CGAffineTransformMakeScale(-1, 1)
                    log += "true."
                } else {
                    view.transform = .identity
                    log += "false."
                }
                isMirrored = mirror
                print(logTag + log + " isMirrored:\(isMirrored).")
            }
            mcMan?.runOnMain(logTag: logTag, log: "Mirror view", task)
            return true
        }
        return false
    }
}
