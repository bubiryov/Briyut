//
//  AuthInputField.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct AuthInputField: View {
    
    @Binding var field: String
    @State var showEye: Bool = false
    var isSecureField: Bool
    var title: String
    var header: String?
    var heightFrame: CGFloat = ScreenSize.height * 0.06
    var cornerRadius = ScreenSize.width / 30
    
    var body: some View {
        VStack(alignment: .leading) {
            if let header {
                Text(header)
                    .font(.headline)
            }
            if isSecureField {
                if showEye {
                    TextField(title, text: $field)
                        .padding()
                        .frame(height: heightFrame)
                        .textInputAutocapitalization(.never)
                        .overlay {
                            HStack {
                                Spacer()
                                Button {
                                    showEye.toggle()
                                } label: {
                                    eye(image: "eye")
                                }
                            }
                        }
                        .cornerRadius(cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .strokeBorder(Color.secondary, lineWidth: 0.5)
                        )
                } else {
                    SecureField(title, text: $field)
                        .padding()
                        .frame(height: heightFrame)
                        .textInputAutocapitalization(.never)
                        .overlay {
                            HStack {
                                Spacer()
                                Button {
                                    showEye.toggle()
                                } label: {
                                    eye(image: "eye.slash")
                                }
                            }
                        }
                        .cornerRadius(cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .strokeBorder(Color.secondary, lineWidth: 1)
                        )
                }
            } else {
                TextField(title, text: $field)
                    .padding()
                    .frame(height: heightFrame)
                    .textInputAutocapitalization(.never)
                    .cornerRadius(cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(Color.secondary, lineWidth: 1)
                    )
            }
        }
    }
}

extension AuthInputField {
    private func eye(image: String) -> some View {
        Image(systemName: image)
            .resizable()
            .frame(width: 25, height: 18)
            .scaledToFit()
            .bold()
            .foregroundColor(.secondary)
            .padding(.trailing, 20)
    }
}

struct InputField_Previews: PreviewProvider {
    static var previews: some View {
        AuthInputField(field: .constant(""), showEye: false, isSecureField: false, title: "briyut@gmail.com", header: "Your email address")
    }
}
