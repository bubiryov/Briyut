//
//  HomeView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Binding var selectedTab: Tab
    @Binding var justOpened: Bool
    
    var body: some View {
        VStack {
            BarTitle<MapButton, ProfileButton>(text: "Home", leftButton: MapButton(image: "pin"), rightButton: ProfileButton(selectedTab: $selectedTab, photo: vm.user?.photoUrl ?? ""))
                                                                                    
            Spacer()
                        
        }
        .onAppear {
            Task {
                try await vm.loadCurrentUser()
                try await vm.getAllProcedures()
                try await vm.getAllDoctors()
                if justOpened {
                    try await vm.updateOrdersStatus()
                    justOpened = false
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(selectedTab: .constant(.profile), justOpened: .constant(false))
            .environmentObject(ProfileViewModel())
    }
}

struct ProfileButton: View {
    
    @Binding var selectedTab: Tab
    var photo: String
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedTab = .profile
            }
        } label: {
            ProfileImage(photoURL: photo, frame: ScreenSize.height * 0.06, color: Color.secondary.opacity(0.1))
        }
        .buttonStyle(.plain)
        .cornerRadius(ScreenSize.width / 30)
    }
}

struct MapButton: View {

    var image: String

    var body: some View {
        Button {
            //
        } label: {
            BarButtonView(image: image)
        }
        .buttonStyle(.plain)

    }
}
