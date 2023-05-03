//
//  AppDelegate.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import Foundation
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
