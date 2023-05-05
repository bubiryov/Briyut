//
//  RootView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 05.05.2023.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var vm: AuthenticationViewModel
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        ZStack {
            VStack {
                if selectedTab == .home {
                    HomeView()
                } else {
                    
                }
            }
            .padding(.horizontal, 20)
            
            VStack {
                Spacer()
                TabBar(selectedTab: $selectedTab)
                    .padding(.bottom, 30)
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
            }
            .ignoresSafeArea(.all)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AuthenticationViewModel())
    }
}
