//
//  BarTitle.swift
//  Briyut
//
//  Created by Egor Bubiryov on 05.05.2023.
//

import SwiftUI

struct BarTitle<V1: View, V2: View>: View {
    
    var text: String
    var leftButton: V1? = nil
    var rightButton: V2? = nil
    var frame: CGFloat = ScreenSize.height * 0.06

    
    var body: some View {
        ZStack {
            HStack {
                if let leftButton {
                    leftButton
                }
                
                Spacer()
                
                if let rightButton {
                    rightButton
                }
            }
            
            HStack {
                Text(text)
                    .font(.title)
                    .bold()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: frame)
    }
}

struct BarTittle_Previews: PreviewProvider {
    static var previews: some View {
        BarTitle<Text, Text>(text: "Title")
    }
}
