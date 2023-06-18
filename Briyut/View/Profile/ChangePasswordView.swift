//
//  ChangePasswordView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 16.06.2023.
//

import SwiftUI

struct ChangePasswordView: View {
    
    @EnvironmentObject var vm: AuthenticationViewModel
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var repeatPassword: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 20) {
                
                BarTitle<BackButton, Text>(
                    text: "Change password",
                    leftButton: BackButton()
                )
                
                AuthInputField(
                    field: $currentPassword,
                    isSecureField: true,
                    title: "currentpassword123",
                    header: "Current password"
                )
                
                AuthInputField(
                    field: $newPassword,
                    isSecureField: true,
                    title: "newpassword123",
                    header: "New password"
                )
                
                AuthInputField(
                    field: $repeatPassword,
                    isSecureField: true,
                    title: "newpassword123",
                    header: "Repeat password"
                )
                
                Spacer()
                
                Button {
                    Task {
                        do {
                            try await vm.changePassword(
                                currentPassword: currentPassword,
                                newPassword: newPassword
                            )
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            currentPassword = ""
                            newPassword = ""
                            repeatPassword = ""
                            hideKeyboard()
                        }
                    }
                } label: {
                    AccentButton(
                        text: "Change password",
                        isButtonActive: vm.validatePassword(newPassword, repeatPassword: repeatPassword)
                    )
                }
            }
            .padding(.bottom)
            .navigationBarBackButtonHidden()
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.width > 100 {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
            )
            .onTapGesture {
                hideKeyboard()
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ChangePasswordView()
                .environmentObject(AuthenticationViewModel())
        }
        .padding(.horizontal, 20)
    }
}
