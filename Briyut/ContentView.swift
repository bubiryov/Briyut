//
//  ContentView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var vm: AuthenticationViewModel
    @AppStorage("notEntered") var notEntered = true

    var body: some View {
        
        ZStack {
            if !vm.notEntered {
                HomeView()
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            vm.notEntered = authUser == nil
        }
        .fullScreenCover(isPresented: $notEntered) {
            AuthenticationView()
        }
        .onChange(of: vm.notEntered) { newValue in
            notEntered = newValue
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationViewModel())
    }
}
