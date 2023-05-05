//
//  HomeView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var vm: AuthenticationViewModel
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        VStack {
            Text("Home")
                .onTapGesture {
                    Task {
                        try vm.signOut()
                    }
                }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthenticationViewModel())
    }
}
