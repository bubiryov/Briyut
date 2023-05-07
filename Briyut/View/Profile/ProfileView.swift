//
//  ProfileView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 06.05.2023.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    func signOut() throws {
        do {
            try AuthenticationManager.shared.signOut()
        } catch  {
            print("Log out error: \(error)")
        }
    }

}

struct ProfileView: View {
    @EnvironmentObject var vm: ProfileViewModel
//    @StateObject var vm = ProfileViewModel()
    @Binding var notEntered: Bool
    
    var body: some View {
        List {
            Button {
                Task {
                    try vm.signOut()
                    notEntered = true
                }
            } label: {
                Text("Log out")
            }

        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(notEntered: .constant(false))
    }
}
