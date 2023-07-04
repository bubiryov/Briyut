//
//  SearchButton.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.07.2023.
//

import SwiftUI

struct SearchButton: View {
    
    @Binding var showSearch: Bool
    
    var body: some View {
        Button {
            Haptics.shared.play(.light)
            withAnimation(.easeInOut(duration: 0.15)) {
                if showSearch {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        hideKeyboard()
                    }
                }
                showSearch.toggle()
            }
        } label: {
            BarButtonView(image: "search")
        }
        .buttonStyle(.plain)
    }
}

struct SearchButton_Previews: PreviewProvider {
    static var previews: some View {
        SearchButton(showSearch: .constant(false))
    }
}
