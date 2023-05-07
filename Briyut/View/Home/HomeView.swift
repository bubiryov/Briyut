//
//  HomeView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

//@MainActor
//class ProfileViewModel: ObservableObject {
//
//    @Published var user: DBUser? = nil
//
//    func loadCurrentUser() async throws {
//        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
//        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
//    }
//
//    func signOut() throws {
//        let vm = AuthenticationViewModel()
//        try vm.signOut()
//    }
//}

struct HomeView: View {

//    @State private var selectedTab: Tab = .home
    
    var body: some View {
        VStack {
            Text("Home")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
