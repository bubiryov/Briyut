//
//  DeleteButton.swift
//  Briyut
//
//  Created by Egor Bubiryov on 02.07.2023.
//

import SwiftUI

struct DeleteButton: View {
    
    @Binding var showAlert: Bool
    
    var body: some View {
        Button {
            showAlert = true
            Haptics.shared.notify(.warning)
        } label: {
            BarButtonView(image: "trash", textColor: .white, backgroundColor: Color.destructiveColor)
        }
        .buttonStyle(.plain)
    }
}

struct DeleteButton_Previews: PreviewProvider {
    static var previews: some View {
        DeleteButton(showAlert: .constant(false))
    }
}
