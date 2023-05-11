//
//  TabBar.swift
//  Briyut
//
//  Created by Egor Bubiryov on 05.05.2023.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case home = "house"
    case plus = "plus.square"
    case calendar = "calendar"
    case profile = "profile"
}

struct TabBar: View {
    
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                
                Spacer()
                
                Image(tab.rawValue)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(selectedTab == tab ? .white : .secondary)
                    .frame(width: ScreenSize.width / 15)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 15)
                    .background(selectedTab == tab ? Color.mainColor : nil)
                    .cornerRadius(20)
                    .onTapGesture {
                        selectedTab = tab
                    }

                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar(selectedTab: .constant(.home))
    }
}
