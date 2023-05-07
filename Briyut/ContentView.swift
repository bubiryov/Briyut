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

    var body: some View {
        
        ZStack {
            if !notEntered2 {
                RootView(notEntered: $notEntered)
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            notEntered = authUser == nil
        }
        .fullScreenCover(isPresented: $notEntered2) {
            AuthenticationView(notEntered: $notEntered)
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
