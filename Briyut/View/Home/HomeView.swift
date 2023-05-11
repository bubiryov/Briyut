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
    
    var body: some View {
        VStack {
            BarTitle<MapButton, ProfileButton>(text: "Home", leftButton: MapButton(image: "pin"), rightButton: ProfileButton(selectedTab: $selectedTab, photo: vm.user?.photoUrl ?? ""))
                                    
            Spacer()
            
        }
        .onAppear {
            Task {
                try await vm.loadCurrentUser()
                try await vm.getProcedures()
                try await vm.getAllDoctors()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(selectedTab: .constant(.profile))
            .environmentObject(ProfileViewModel())
    }
}

struct ProfileButton: View {
    
    @Binding var selectedTab: Tab
    var photo: String
    
    var body: some View {
        Button {
            selectedTab = .profile
        } label: {
            ProfileImage(photoURL: photo, frame: ScreenSize.height * 0.06, color: Color.secondary.opacity(0.1))
        }
        .buttonStyle(.plain)
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
