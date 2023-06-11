//
//  StatsView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 11.06.2023.
//

import SwiftUI
import SwiftUICharts

struct StatsView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    
    var body: some View {
        VStack {
            BarTitle<Text, Text>(text: "Statistics")
            Spacer()
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            StatsView()
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal, 20)
    }
}
