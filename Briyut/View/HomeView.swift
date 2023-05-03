//
//  HomeView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var vm: AuthenticationViewModel
    
    var body: some View {
        Button {
            Task {
                try vm.signOut()
            }
        } label: {
            Text("Log out")
        }

    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthenticationViewModel())
    }
}
