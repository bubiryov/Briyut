//
//  AccentButton.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct AccentButton: View {
    
    var buttonColor: Color {
        if isButtonActive {
            return .blue.opacity(0.2)
        } else {
            return .gray.opacity(0.3)
        }
    }
    var textColor: Color {
        if isButtonActive {
            return .black
        } else {
            return .secondary
        }
    }
    
    var bold: Bool {
        if isButtonActive {
            return true
        } else {
            return false
        }
    }
    
    var filled: Bool = true
    var text: String
    var isButtonActive: Bool
    var logo: String? = nil
    
    var body: some View {
        
        if filled {
            Text(text)
                .foregroundColor(textColor)
                .bold(bold)
                .frame(height: ScreenHeight.main * 0.06)
                .frame(maxWidth: .infinity)
                .background(buttonColor)
                .cornerRadius(30)
        } else {
            HStack {
                Image(logo ?? "")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
                Text(text)
                    .foregroundColor(textColor)
                    .bold(bold)
            }
            .frame(height: ScreenHeight.main * 0.06)
            .frame(maxWidth: .infinity)
            .overlay {
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.secondary, lineWidth: 0.5)
        }

        }
    }
}

struct AccentButton_Previews: PreviewProvider {
    static var previews: some View {
        AccentButton(filled: false, text: "Continue", isButtonActive: true, logo: "googleLogo")
    }
}
