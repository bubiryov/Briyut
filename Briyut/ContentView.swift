//
//  ContentView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var vm: AuthenticationViewModel
    @AppStorage("notEntered") var localNotEntered = true
    @State private var notEntered = true
    @State private var splashView: Bool = true

    var body: some View {
        
        ZStack {
            if !localNotEntered {
                RootView(notEntered: $notEntered, splashView: $splashView)
            }
            
            AuthenticationView(notEntered: $notEntered)
                .offset(y: localNotEntered ? 0 : -ScreenSize.height * 1.2)
                .animation(.easeInOut, value: localNotEntered)
                        
            if splashView {
                SplashView()
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            notEntered = authUser == nil
            localNotEntered = authUser == nil
//            Task {
//                try await Task.sleep(nanoseconds: 3_000_000_000)
//                splashView = false
//            }
        }
        .onChange(of: notEntered) { newValue in
            localNotEntered = newValue
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationViewModel())
    }
}
