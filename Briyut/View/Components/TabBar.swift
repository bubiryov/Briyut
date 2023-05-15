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
    @Namespace private var animationNamespace

    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                
                Spacer()
                
                ZStack {
                    if selectedTab == tab {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(maxWidth: .infinity)
                            .frame(height: UIScreen.main.bounds.height / 15)
                            .foregroundColor(Color.mainColor)
                            .matchedGeometryEffect(id: "selectedTab", in: animationNamespace)
                    }
                    
                    Image(tab.rawValue)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(selectedTab == tab ? .white : .secondary)
                        .padding(.horizontal, 25)
                        .cornerRadius(20)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedTab = tab
                            }
                        }
                }
                .frame(width: UIScreen.main.bounds.width / 15 + 50)
                .padding(.top, 10)
                .padding(.bottom, bottomPadding())

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
