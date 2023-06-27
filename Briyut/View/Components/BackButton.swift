//
//  BackButton.swift
//  Briyut
//
//  Created by Egor Bubiryov on 05.05.2023.
//

import SwiftUI

struct BackButton: View {
    
    @Environment(\.presentationMode) var presentationMode
    var backgorundColor: Color? = nil

    var body : some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            BarButtonView(image: "back", scale: 0.35, backgroundColor: backgorundColor)
        }
        .buttonStyle(.plain)

    }
}

struct BackButton_Previews: PreviewProvider {
    static var previews: some View {
        BackButton()
    }
}
