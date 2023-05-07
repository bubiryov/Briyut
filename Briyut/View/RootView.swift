//
//  RootView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 05.05.2023.
//

import SwiftUI

struct RootView: View {
    
    @StateObject var vm = ProfileViewModel()
    @State private var selectedTab: Tab = .home
    @Binding var notEntered: Bool
    
    var body: some View {
        ZStack {
            VStack {
                switch selectedTab {
                case .home:
                    HomeView()
                        .environmentObject(vm)
                case .plus:
                    HomeView()
                case .calendar:
                    HomeView()
                case .profile:
                    ProfileView(notEntered: $notEntered)
                        .environmentObject(vm)
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
        RootView(notEntered: .constant(true))
            .environmentObject(AuthenticationViewModel())
    }
}
