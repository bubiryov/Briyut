//
//  AuthenticationView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct AuthenticationView: View {
    
    @EnvironmentObject var vm: AuthenticationViewModel
    @State private var showTipsAlert: Bool = false
    @State private var showResetPasswordView: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Text("Briyut")
                        .font(.custom("Alokary", size: 25))
                        .padding(.top, ScreenHeight.main * 0.075)
                    Spacer()
                }
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea(.keyboard)
                
                VStack(spacing: ScreenHeight.main * 0.02) {
                    
                    LoginView(email: $vm.email, password: $vm.password)
                    
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
                    .frame(height: ScreenHeight.main * 0.02)
                    
                    Button {
                        Task {
                            try await vm.singInWithGoogle()
                        }
                    } label: {
                        AccentButton(filled: false, text: "Sign in with Google", isButtonActive: true, logo: "googleLogo")
                    }
                    
                    Button {
                        Task {
                            //
                        }
                    } label: {
                        AccentButton(filled: false, text: "Sign in with Apple", isButtonActive: true, logo: "appleLogo")
                    }
                    
                    NavigationLink {
                        PhoneAuthenticationView()
                    } label: {
                        AccentButton(filled: false, text: "Sign in with phone", isButtonActive: true)
                    }
                    
                    NavigationLink {
                        RegistrationView()
                    } label: {
                        Text("Create an account")
                            .font(.subheadline)
                    }
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.top, ScreenHeight.main * 0.03)
                .background(Color.white)
                .cornerRadius(30)
                .shadow(radius: 10, y: -10)
                .offset(y: ScreenHeight.main / 3.5)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea(.keyboard)
            }
            .background(Color.blue.opacity(0.3))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showResetPasswordView = true
                        } label: {
                            Text("Reset password")
                        }
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                }
            }
        }
        
        .sheet(isPresented: $showResetPasswordView) {
            ResetPasswordView()
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(21)
        }
    }
}
struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AuthenticationViewModel())
        
    }
}
