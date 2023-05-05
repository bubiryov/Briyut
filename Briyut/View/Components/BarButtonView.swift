//
//  BarButton.swift
//  Briyut
//
//  Created by Egor Bubiryov on 05.05.2023.
//

import SwiftUI

struct BarButtonView: View {
    
    var cornerRadius = ScreenSize.width / 30
    var frame: CGFloat = ScreenSize.height * 0.06
    var image: String
    
    var body: some View {
        Image(systemName: image)
            .aspectRatio(contentMode: .fit)
            .frame(width: frame, height: frame)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(cornerRadius)
            .foregroundColor(.black)
            .bold()
    }
}

struct BarButton_Previews: PreviewProvider {
    static var previews: some View {
        BarButtonView(image: "chevron.backward")
    }
}
