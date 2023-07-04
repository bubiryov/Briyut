//
//  ResetPasswordView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.05.2023.
//

import SwiftUI

struct ResetPasswordView: View {
    
    @EnvironmentObject var vm: AuthenticationViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showInfoAlert: Bool = false
    @State private var loading: Bool = false
    @Binding var showResetPasswordView: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: ScreenSize.height * 0.02) {
                TopBar<Text, Text>(text: "reset-password-string")
                    .padding(.top)
                
                AuthInputField(
                    field: $vm.email,
                    isSecureField: false,
                    title: "rubinko@gmail.com",
                    header: "your-email-string"
                )
                
                Button {
                    resetPassword()
                } label: {
                    AccentButton(
                        text: "reset-password-string",
                        isButtonActive: vm.validate(email: vm.email, password: nil, repeatPassword: nil),
                        animation: loading
                    )
                }
                .disabled(!vm.validate(email: vm.email, password: nil, repeatPassword: nil) || loading)
                
                Spacer()
            }
            .padding(.top)
            .padding(.horizontal, 20)
            .background(Color.backgroundColor)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.large)
        }
        .alert(isPresented: $showInfoAlert) {
            Alert(
                title: Text("Check your email box"),
                message: Text("Reset password link has been sent"),
                dismissButton: .default(Text("Got it")) {
                    showResetPasswordView = false
                }
            )
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView(showResetPasswordView: .constant(true))
            .environmentObject(AuthenticationViewModel())
    }
}

extension ResetPasswordView {
    func resetPassword() {
        Task {
            do {
                loading = true
                try await vm.resetPassword()
                loading = false
                showInfoAlert = true
            } catch {
                loading = false
                print("Reset password error")
            }
        }

    }
}
