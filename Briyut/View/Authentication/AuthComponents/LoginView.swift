//
//  LoginView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var vm: AuthenticationViewModel
    @Binding var notEntered: Bool
    @State private var loading: Bool = false
    
    var body: some View {
        VStack(spacing: ScreenSize.height * 0.02) {
            AuthInputField(field: $vm.email, showEye: false, isSecureField: false, title: "rubinko@gmail.com", header: "Your email address")
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
            
            AuthInputField(field: $vm.password, isSecureField: true, title: "min. 6 characters", header: "Choose your password")
            
            Button {
                Task {
                    do {
                        loading = true
                        hideKeyboard()
                        try await vm.logInWithEmail()
                        notEntered = false
                        loading = false
                    } catch let error {
                        loading = false
                        print(error.localizedDescription)
                    }
                }
            } label: {
                AccentButton(
                    text: "Login to Rubinko",
                    isButtonActive: vm.validate(email: vm.email, password: vm.password, repeatPassword: nil),
                    animation: loading)
            }
            .disabled(!vm.validate(email: vm.email, password: vm.password, repeatPassword: nil) || loading)
            
            HStack {
                if let error = vm.errorText {
                    Text(error)
                        .font(Mariupol.regular, 17)
                        .foregroundColor(.red)
                } else {
                    LabelledDivider(label: "or")
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: ScreenSize.height * 0.02)
            
            Button {
                Task {
                    do {
                        try await vm.singInWithGoogle()
                        notEntered = false
                        return
                    } catch {
                        
                    }
                }
            } label: {
                AccentButton(
                    filled: false,
                    text: "Sign in with Google",
                    isButtonActive: true,
                    logo: "googleLogo"
                )
            }
            
            NavigationLink {
                PhoneAuthenticationView(notEntered: $notEntered)
            } label: {
                AccentButton(filled: false, text: "Sign in with number", isButtonActive: true, logo: "phoneLogo")
            }
            
            Button {
                Task {
                    try await vm.singInWithApple()
                    notEntered = false
                }
            } label: {
                SignInWithAppleButton(type: .signIn, style: .whiteOutline)
            }
            .frame(height: ScreenSize.height * 0.06)
            
            NavigationLink {
                RegistrationView(notEntered: $notEntered)
            } label: {
                Text("Create an account")
                    .font(Mariupol.medium, 17)
//                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
            }

        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            LoginView(notEntered: .constant(true))
                .environmentObject(AuthenticationViewModel())
        }
        .padding(.horizontal, 20)
    }
}
