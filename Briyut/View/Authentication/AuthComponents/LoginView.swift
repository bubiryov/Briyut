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
            
            emailField
            
            passwordField
            
            mainLoginButton
            
            dividerErrorSpace
            
            googleLoginButton
            
            phoneLoginButton
            
            appleLoginButton
            
            registrationButton
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

// MARK: Components

extension LoginView {
    
    var emailField: some View {
        AuthInputField(field: $vm.email, showEye: false, isSecureField: false, title: "rubinko@gmail.com", header: "your-email-string")
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
    }
    
    var passwordField: some View {
        AuthInputField(field: $vm.password, isSecureField: true, title: "min-6-characters-string", header: "your-password-string")
    }
    
    var mainLoginButton: some View {
        Button {
            loginWithEmail()
        } label: {
            AccentButton(
                text: "login-to-Rubinko-string",
                isButtonActive: vm.validate(email: vm.email, password: vm.password, repeatPassword: nil),
                animation: loading)
        }
        .disabled(!vm.validate(email: vm.email, password: vm.password, repeatPassword: nil) || loading)
    }
    
    var dividerErrorSpace: some View {
        HStack {
            if let error = vm.errorText {
                Text(error)
                    .font(Mariupol.regular, 17)
                    .foregroundColor(.red)
            } else {
                LabelledDivider(label: "or-string")
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: ScreenSize.height * 0.02)
    }
    
    var googleLoginButton: some View {
        Button {
            loginWithGoogle()
        } label: {
            AccentButton(
                filled: false,
                text: "google-sign-in-string",
                isButtonActive: true,
                logo: "googleLogo"
            )
        }
    }
    
    var phoneLoginButton: some View {
        NavigationLink {
            PhoneAuthenticationView(notEntered: $notEntered)
        } label: {
            AccentButton(filled: false, text: "sign-in-with-number-string", isButtonActive: true, logo: "phoneLogo")
        }
    }
    
    var appleLoginButton: some View {
        Button {
            Task {
                try await vm.singInWithApple()
                notEntered = false
            }
        } label: {
            SignInWithAppleButton(type: .signIn, style: .whiteOutline)
        }
        .frame(height: ScreenSize.height * 0.06)
    }
    
    var registrationButton: some View {
        NavigationLink {
            RegistrationView(notEntered: $notEntered)
        } label: {
            Text("create-account-string")
                .font(Mariupol.medium, 17)
                .foregroundColor(.primary)
        }
    }
}

// MARK: Functions

extension LoginView {
    
    func loginWithEmail() {
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
    }
    
    func loginWithGoogle() {
        Task {
            do {
                try await vm.singInWithGoogle()
                notEntered = false
                return
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}
