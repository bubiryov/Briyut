//
//  EditButton.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.07.2023.
//

import SwiftUI

struct EditButton: View {
    
    @Binding var isEditing: Bool
    
    var body: some View {
        Button {
            Haptics.shared.play(.light)
            withAnimation(.easeInOut(duration: 0.15)) {
                isEditing.toggle()
            }
        } label: {
            BarButtonView(
                image: "pencil",
                textColor: isEditing ? .white : nil,
                backgroundColor: isEditing ? .mainColor : nil
            )
        }
        .buttonStyle(.plain)
    }
}

struct EditButton_Previews: PreviewProvider {
    static var previews: some View {
        EditButton(isEditing: .constant(false))
    }
}
