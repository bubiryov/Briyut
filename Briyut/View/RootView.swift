//
//  RootView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 05.05.2023.
//

import SwiftUI

struct RootView: View {
        
    @StateObject private var interfaceData: InterfaceData
    @StateObject var mainViewModel: MainViewModel
    @StateObject var articlesVM: ArticlesViewModel = ArticlesViewModel()
    
    @Binding var notEntered: Bool
    @Binding var splashView: Bool
    
    init(notEntered: Binding<Bool>, splashView: Binding<Bool>) {
        let interfaceData = InterfaceData()
        let mainViewModel = MainViewModel(data: interfaceData)
        _interfaceData = StateObject(wrappedValue: interfaceData)
        _mainViewModel = StateObject(wrappedValue: mainViewModel)
        
        _notEntered = notEntered
        _splashView = splashView
    }
    
    @State private var selectedTab: Tab = .home
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
                            .environmentObject(interfaceData)
                            .environmentObject(mainViewModel)
                            .environmentObject(articlesVM)
                    case .plus:
                        AllProcedures(notEntered: $notEntered, showSearch: $showSearch, selectedTab: $selectedTab)
                            .environmentObject(interfaceData)
                            .environmentObject(mainViewModel)

                    case .calendar:
                        CalendarView()
                            .environmentObject(interfaceData)
                            .environmentObject(mainViewModel)

                    case .profile:
                        ProfileView(notEntered: $notEntered)
                            .environmentObject(interfaceData)
                            .environmentObject(mainViewModel)

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
                mainViewModel.profileViewModel.getProvider()
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
