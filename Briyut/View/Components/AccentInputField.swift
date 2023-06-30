//
//  AccentInputField.swift
//  Briyut
//
//  Created by Egor Bubiryov on 20.06.2023.
//

import SwiftUI

struct AccentInputField: View {
    
    var promptText: String
    var title: String?
    var spaceAllow: Bool? = nil
    @Binding var input: String
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title {
                Text(title)
                    .font(Mariupol.medium, 17)
            }
            
            TextField("", text: $input, prompt: Text(promptText))
                .font(Mariupol.medium, 17)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .frame(height: ScreenSize.height * 0.06)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(ScreenSize.width / 30)
                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification)) { _ in
                    if spaceAllow == false && input.last == " " {
                        input = String(input.dropLast())
                    }
                }

        }
    }
}

struct AccentInputField_Previews: PreviewProvider {
    static var previews: some View {
        AccentInputField(promptText: "Your text", title: "Your title", input: .constant("Some entered text"))
            .padding(.horizontal, 20)
    }
}
