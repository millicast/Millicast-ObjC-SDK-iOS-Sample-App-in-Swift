//
//  ContentView.swift
//  Millicast SDK Sample App in Swift
//
//  Created by CoSMo Software on 29/7/21.
//

import SwiftUI

struct ContentView: View {
    
    var mcSA = MillicastSA.getInstance()
    
    var body: some View {
        NavigationView {
            VStack {
#if os(iOS)
                Spacer()
                NavigationLink(destination: mcSA.getPublishView()) {
                    Text("Publish")
                }
#endif
                Spacer()
                NavigationLink(destination: mcSA.getSubscribeView()) {
                    Text("Subscribe")
                }
                Spacer()
                NavigationLink(destination: mcSA.getSettingsView()) {
                    Text("Settings")
                }
                Spacer()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
