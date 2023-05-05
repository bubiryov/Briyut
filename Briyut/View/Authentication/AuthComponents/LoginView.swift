//
//  LoginView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var vm: AuthenticationViewModel
    
    var body: some View {
        VStack(spacing: ScreenSize.height * 0.02) {
            InputField(field: $vm.email, showEye: false, isSecureField: false, title: "briyut@gmail.com", header: "Your email address")
            
            InputField(field: $vm.password, isSecureField: true, title: "min. 6 characters", header: "Choose your password")
            
            Button {
                Task {
                    try await vm.logInWithEmail()
                }
            } label: {
                AccentButton(text: "Login to Briyut", isButtonActive: vm.validate(email: vm.email, password: vm.password, repeatPassword: nil))
            }
            .disabled(!vm.validate(email: vm.email, password: vm.password, repeatPassword: nil))
            
            HStack {
                if let error = vm.errorText {
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.red)
                } else {
                    LabelledDivider(label: "or")
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: ScreenSize.height * 0.02)
            
            Button {
                Task {
                    try await vm.singInWithGoogle()
                }
            } label: {
                AccentButton(filled: false, text: "Sign in with Google", isButtonActive: true, logo: "googleLogo")
            }
            
            NavigationLink {
                PhoneAuthenticationView()
            } label: {
                AccentButton(filled: false, text: "Sign in with number", isButtonActive: true, logo: "phoneLogo")
            }
            
            Button {
                Task {
                    try await vm.singInWithApple()
                }
            } label: {
                SignInWithAppleButton(type: .signIn, style: .whiteOutline)
            }
            .frame(height: ScreenSize.height * 0.06)
            
            NavigationLink {
                RegistrationView()
            } label: {
                Text("Create an account")
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .bold()
            }

        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthenticationViewModel())
    }
}
