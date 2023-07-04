//
//  MapButton.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.07.2023.
//

import SwiftUI

struct MapButton: View {

    var image: String
    @Binding var showMap: Bool

    var body: some View {
                
        Button {
            showMap = true
        } label: {
            BarButtonView(image: image)
        }
        .buttonStyle(.plain)
    }
}

struct MapButton_Previews: PreviewProvider {
    static var previews: some View {
        MapButton(image: "", showMap: .constant(false))
    }
}
