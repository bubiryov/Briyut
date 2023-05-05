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
    @Binding var showResetPasswordView: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: ScreenSize.height * 0.02) {
                BarTitle<Text, Text>(text: "Reset password")
                    .padding(.top)
                
                InputField(field: $vm.email, isSecureField: false, title: "briyut@gmail.com", header: "Your email address")
                
                Button {
                    Task {
                        try await vm.resetPassword()
                        showInfoAlert = true
                    }
                } label: {
                    AccentButton(text: "Reset password", isButtonActive: vm.validate(email: vm.email, password: nil, repeatPassword: nil))
                }
                Spacer()
            }
            .padding(.top)
            .padding(.horizontal, 20)
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
//        NavigationView {
        ResetPasswordView(showResetPasswordView: .constant(true))
                .environmentObject(AuthenticationViewModel())
//        }
    }
}
