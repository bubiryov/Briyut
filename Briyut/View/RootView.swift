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
    @State var justOpened: Bool = true
    @State var showSearch: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                VStack {
                    switch selectedTab {
                    case .home:
                        HomeView(selectedTab: $selectedTab, justOpened: $justOpened, showSearch: $showSearch)
                            .environmentObject(vm)
                    case .plus:
                        AllProcedures(notEntered: $notEntered, showSearch: $showSearch, selectedTab: $selectedTab)
                            .environmentObject(vm)
                    case .calendar:
                        CalendarView()
                            .environmentObject(vm)
                    case .profile:
                        ProfileView(notEntered: $notEntered)
                            .environmentObject(vm)
                    }
                }
                .padding(.top, topPadding())
                .padding(.horizontal, 20)
                .animation(nil, value: selectedTab)
                                
                TabBar(selectedTab: $selectedTab)
                                
            }
            .edgesIgnoringSafeArea(.bottom)
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
