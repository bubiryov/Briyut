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
            return .green.opacity(0.7)
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
    
    var text: String
    var isButtonActive: Bool
    
    var body: some View {
        Text(text)
            .foregroundColor(textColor)
            .bold(bold)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(buttonColor)
            .cornerRadius(30)
    }
}

struct AccentButton_Previews: PreviewProvider {
    static var previews: some View {
        AccentButton(text: "Continue", isButtonActive: true)
    }
}
