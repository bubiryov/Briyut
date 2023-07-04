//
//  AddButton.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.07.2023.
//

import SwiftUI

struct AddButton: View {
    
    @Binding var showSheet: Bool
    
    var body: some View {
        Button {
            showSheet = true
        } label: {
            BarButtonView(image: "plus", scale: 0.35)
        }
        .buttonStyle(.plain)
    }
}

struct AddButton_Previews: PreviewProvider {
    static var previews: some View {
        AddButton(showSheet: .constant(false))
    }
}
