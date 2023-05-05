//
//  InputField.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct InputField: View {
    
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
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(Color.secondary, lineWidth: 0.5)
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
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(Color.secondary, lineWidth: 0.5)
                        )
                }
            } else {
                TextField(title, text: $field)
                    .padding()
                    .frame(height: heightFrame)
                    .textInputAutocapitalization(.never)
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.secondary, lineWidth: 0.5)
                    )
            }
        }
    }
}

extension InputField {
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
        InputField(field: .constant(""), showEye: false, isSecureField: true, title: "briyut@gmail.com", header: "Your email address")
    }
}
