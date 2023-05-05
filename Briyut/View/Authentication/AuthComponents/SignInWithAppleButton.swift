//
//  SignInWithAppleButton.swift
//  Briyut
//
//  Created by Egor Bubiryov on 04.05.2023.
//

import SwiftUI
import AuthenticationServices

struct SignInWithAppleButton: UIViewRepresentable {
    
    var cornerRadius: CGFloat = ScreenSize.width / 30
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(
            authorizationButtonType: type,
            authorizationButtonStyle: style)
        button.cornerRadius = cornerRadius
        return button
    }
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        //
    }
}

struct SignInWithAppleButton_Previews: PreviewProvider {
    static var previews: some View {
        SignInWithAppleButton(
            type: .signIn,
            style: .whiteOutline)
    }
}
