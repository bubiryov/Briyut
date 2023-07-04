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
    @State private var loading: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { _ in
            ZStack {
                
                Color.backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    
                    TopBar<BackButton, Text>(
                        text: "change-password-string",
                        leftButton: BackButton()
                    )
                    
                    AuthInputField(
                        field: $currentPassword,
                        isSecureField: true,
                        title: "currentpassword123",
                        header: "current-password-string"
                    )
                    
                    AuthInputField(
                        field: $newPassword,
                        isSecureField: true,
                        title: "newpassword123",
                        header: "new-password-string"
                    )
                    
                    AuthInputField(
                        field: $repeatPassword,
                        isSecureField: true,
                        title: "newpassword123",
                        header: "repeat-password-string"
                    )
                    
                    Spacer()
                    
                    Button {
                        Task {
                            Haptics.shared.play(.light)
                            do {
                                loading = true
                                try await vm.changePassword(
                                    currentPassword: currentPassword,
                                    newPassword: newPassword
                                )
                                loading = false
                                presentationMode.wrappedValue.dismiss()
                            } catch {
                                currentPassword = ""
                                newPassword = ""
                                repeatPassword = ""
                                loading = false
                                hideKeyboard()
                            }
                        }
                    } label: {
                        AccentButton(
                            text: "change-password-string",
                            isButtonActive: vm.validatePassword(newPassword, repeatPassword: repeatPassword),
                            animation: loading
                        )
                    }
                    .disabled(!vm.validatePassword(newPassword, repeatPassword: repeatPassword) || loading)
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
                        .onEnded { gesture in
                            if gesture.translation.height > 100 {
                                hideKeyboard()
                            }
                        }
            )
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
        .background(Color.backgroundColor)
    }
}
