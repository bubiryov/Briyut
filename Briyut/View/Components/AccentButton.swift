//
//  AccentButton.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct AccentButton: View {
    
    var buttonColor: Color {
        isButtonActive ? Color.mainColor : Color.secondary.opacity(0.1)
    }
    
    var textColor: Color {
        if isButtonActive && filled {
            return .white
        } else if isButtonActive && !filled {
            return .black
        } else {
            return .secondary
        }
    }
    
    var bold: Bool {
        isButtonActive ? true : false
    }
    
    var height: CGFloat = ScreenSize.height * 0.06
    var filled: Bool = true
    var text: String
    var isButtonActive: Bool
    var logo: String? = nil
    var cornerRadius = ScreenSize.width / 30
    
    var body: some View {
        
        if filled {
            Text(text)
                .foregroundColor(textColor)
                .bold(bold)
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .background(buttonColor)
                .cornerRadius(cornerRadius)
        } else {
            HStack {
                Image(logo ?? "")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 17)
                Text(text)
                    .foregroundColor(textColor)
                    .bold(bold)
            }
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.secondary, lineWidth: 1)
            }
        }
    }
}

struct AccentButton_Previews: PreviewProvider {
    static var previews: some View {
        AccentButton(filled: false, text: "Continue", isButtonActive: true, logo: "googleLogo")
    }
}
