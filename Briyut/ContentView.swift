//
//  ContentView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var vm: AuthenticationViewModel
    @AppStorage("notEntered") var notEntered2 = true
    @State private var notEntered = true
    @State private var splashView: Bool = true

    var body: some View {
        
        ZStack {
            if !notEntered2 {
                RootView(notEntered: $notEntered)
            }
            
            AuthenticationView(notEntered: $notEntered)
                .offset(y: notEntered2 ? 0 : -ScreenSize.height * 1.2)
                .animation(.easeInOut, value: notEntered2)
            
            if splashView {
                SplashView()
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            notEntered = authUser == nil
            Task {
                try await Task.sleep(nanoseconds: 2_000_000_000)
                withAnimation {
                    splashView = false
                }
            }
        }
        .onChange(of: notEntered) { newValue in
            notEntered2 = newValue
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationViewModel())
    }
}
