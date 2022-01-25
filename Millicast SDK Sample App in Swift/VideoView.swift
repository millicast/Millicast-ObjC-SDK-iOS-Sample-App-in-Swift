//
//  VideoView.swift
//  Millicast SDK Sample App in Swift
//
//  Created by CoSMo Software on 5/8/21.
//

import Foundation
import SwiftUI
import AVKit
import MillicastSDK

struct VideoView : UIViewRepresentable {
    let renderer: MCIosVideoRenderer
    
    func makeUIView(context: Context) -> UIView {
        let uiView = renderer.getView()!
        return uiView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
