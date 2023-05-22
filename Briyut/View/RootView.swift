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
    @State var doneAnimation: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    switch selectedTab {
                    case .home:
                        HomeView(selectedTab: $selectedTab, justOpened: $justOpened)
                            .environmentObject(vm)
                    case .plus:
                        AllProcedures(notEntered: $notEntered, selectedTab: $selectedTab, doneAnimation: $doneAnimation)
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
                
                Spacer()
                
                TabBar(selectedTab: $selectedTab)
                                
            }
            .edgesIgnoringSafeArea(.bottom)
            .blur(radius: doneAnimation ? 20 : 0)
            
            if doneAnimation {
                DoneAnimation()
                    .frame(width: 250)
            }
            
        }
        .onAppear {
            print("Appear root view")
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
