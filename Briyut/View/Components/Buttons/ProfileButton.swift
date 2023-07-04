//
//  ProfileButton.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.07.2023.
//

import SwiftUI

struct ProfileButton: View {
    
    @Binding var selectedTab: Tab
    var photo: String
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedTab = .profile
            }
        } label: {
            ProfileImage(photoURL: photo, frame: ScreenSize.height * 0.06, color: Color.secondary.opacity(0.1), padding: 16)
        }
        .buttonStyle(.plain)
        .cornerRadius(ScreenSize.width / 30)
    }
}

struct ProfileButton_Previews: PreviewProvider {
    static var previews: some View {
        ProfileButton(selectedTab: .constant(.home), photo: "")
    }
}
