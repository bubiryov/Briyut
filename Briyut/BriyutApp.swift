//
//  BriyutApp.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI
import Firebase

@main
struct BriyutApp: App {

    @StateObject var vm = AuthenticationViewModel()
    @UIApplicationDelegateAdaptor (AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
        }
    }
}
