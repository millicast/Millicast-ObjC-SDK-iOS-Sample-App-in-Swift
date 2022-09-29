//
//  VideoView.swift
//  Millicast SDK Sample App in Swift
//

import AVKit
import Foundation
import MillicastSDK
import SwiftUI

/**
 * Swift Video view based on the Objective C UIView provided by the SDK's MCIosVideoRenderer.
 */
struct VideoView: UIViewRepresentable {
    let renderer: MCIosVideoRenderer

    func makeUIView(context: Context) -> UIView {
        let uiView = renderer.getView()!
        return uiView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
