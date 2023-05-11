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
                    HomeView(selectedTab: $selectedTab)
                        .environmentObject(vm)
                case .plus:
                    AllProcedures()
                        .environmentObject(vm)
                case .calendar:
                    CalendarView()
                        .environmentObject(vm)
                case .profile:
                    ProfileView(notEntered: $notEntered)
                        .environmentObject(vm)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, topPadding())
            .padding(.bottom, tabBarHeight())
            
            VStack {
                Spacer()
                TabBar(selectedTab: $selectedTab)
                    .padding(.bottom, bottonPadding())
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
            }
            .ignoresSafeArea(.all)
        }
        .onAppear {
            Task {
                vm.getProvider()
            }
        }
    }    
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(notEntered: .constant(true))
            .environmentObject(AuthenticationViewModel())
    }
}
