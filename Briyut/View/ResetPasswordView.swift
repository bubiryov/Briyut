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
    
    var body: some View {
        NavigationView {
            VStack(spacing: ScreenHeight.main * 0.02) {
                InputField(field: $vm.email, isSecureField: false, title: "briyut@gmail.com", header: "Your email address")
                
                Button {
                    Task {
                        try await vm.resetPassword()
                    }
                } label: {
                    AccentButton(text: "Reset password", isButtonActive: vm.validate(email: vm.email, password: nil, repeatPassword: nil))
                }
                Spacer()
            }
            .navigationTitle("Reset password")
            .padding(.top)
            .padding(.horizontal, 30)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
//        NavigationView {
            ResetPasswordView()
                .environmentObject(AuthenticationViewModel())
//        }
    }
}
