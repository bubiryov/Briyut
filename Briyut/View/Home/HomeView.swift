//
//  HomeView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    
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
