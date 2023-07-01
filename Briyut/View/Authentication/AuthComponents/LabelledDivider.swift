//
//  LabelledDivider.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct LabelledDivider: View {

    let label: String
    let horizontalPadding: CGFloat
    let color: Color

    init(label: String, horizontalPadding: CGFloat = 20, color: Color = .secondary) {
        self.label = label
        self.horizontalPadding = horizontalPadding
        self.color = color
    }

    var body: some View {
        HStack {
            line
            Text(label.localized)
                .font(Mariupol.regular, 17)
                .foregroundColor(color)
                .padding(.horizontal)
            line
        }
    }
    
    var line: some View {
        VStack {
            Divider().background(color)
        }
    }
}

struct LabelledDivider_Previews: PreviewProvider {
    static var previews: some View {
        LabelledDivider(label: "or")
    }
}
