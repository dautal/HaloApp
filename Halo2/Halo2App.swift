//
//  Halo2App.swift
//  Halo2
//
//  Created by Team 23 Halo on 2/23/23.
//

import SwiftUI

@main
struct Halo2App: App {
    @State var isConnected = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            HomeView(isConnected: $isConnected)
        }
    }
}
