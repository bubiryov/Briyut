//
//  RootView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 05.05.2023.
//

import SwiftUI

struct RootView: View {
    
    @StateObject var vm = ProfileViewModel()
    @StateObject var articlesVM: ArticlesViewModel = ArticlesViewModel()
    @State private var selectedTab: Tab = .home
    @Binding var notEntered: Bool
    @Binding var splashView: Bool
    @State var justOpened: Bool = true
    @State var showSearch: Bool = false
        
    var body: some View {
        ZStack {
            
            Color.backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                VStack {
                    switch selectedTab {
                    case .home:
                        HomeView(selectedTab: $selectedTab, justOpened: $justOpened, showSearch: $showSearch, splashView: $splashView)
                            .environmentObject(vm)
                            .environmentObject(articlesVM)
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
        .background(Color.backgroundColor)
        .onAppear {
            Task {
                vm.getProvider()
            }
        }
    }    
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(notEntered: .constant(true), splashView: .constant(false))
            .environmentObject(AuthenticationViewModel())
    }
}
