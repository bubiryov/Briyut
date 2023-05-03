//
//  AuthenticationView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct AuthenticationView: View {
    
    @EnvironmentObject var vm: AuthenticationViewModel
    @State private var showTipsAlert: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Briyut")
                    .font(.custom("Alokary", size: 20))
                                
                LoginView(email: $vm.email, password: $vm.password)
                
                Button {
                    Task {
                        try await vm.logInWithEmail()
                    }
                } label: {
                    AccentButton(text: "Continue", isButtonActive: vm.validate(email: vm.email, password: vm.password, repeatPassword: nil))
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
                .frame(height: 20)
                
                Button {
                    Task {
                        //
                    }
                } label: {
                    AccentButton(text: "Sign in with Google", isButtonActive: false)
                }

                Button {
                    Task {
                        //
                    }
                } label: {
                    AccentButton(text: "Sign in with Apple", isButtonActive: false)
                }

                Button {
                    Task {
                        //
                    }
                } label: {
                    AccentButton(text: "Sign in with phone", isButtonActive: false)
                }

                
                Spacer()
                
                NavigationLink {
                    RegistrationView()
                } label: {
                    Text("Create an account")
                        .font(.subheadline)
                }
            }
            .padding(.horizontal, 30)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showTipsAlert = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .bold()
                            .foregroundColor(.secondary)
                    }
                }
            }
            .alert(isPresented: $showTipsAlert) {
                Alert(
                    title: Text("Prompt"),
                    message: Text("Email must have \"@\" and \".\" and no uppercase characters. \n Password must be at least 6 characters long, and have numbers and letters."),
                    dismissButton: .default(Text("Got it!")){
                    showTipsAlert = false
                })
            }
        }
    }
}
struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AuthenticationViewModel())
        
    }
}
