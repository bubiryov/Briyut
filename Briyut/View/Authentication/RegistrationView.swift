//
//  RegistrationView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct RegistrationView: View {
    
    @EnvironmentObject var vm: AuthenticationViewModel
    @State private var repeatPassword: String = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                BarTitle<BackButton, Text>(text: "New account", leftButton: BackButton(presentationMode: _presentationMode))
                            
                InputField(field: $vm.email, isSecureField: false, title: "briyut@gmail.com", header: "Your email address")
                
                InputField(field: $vm.password, isSecureField: true, title: "min. 6 characters", header: "Choose your password")
                
                InputField(field: $repeatPassword, isSecureField: true, title: "min. 6 characters", header: "Repeat password")
                
                Button {
                    Task {
                        try await vm.createUserWithEmail()
                    }
                } label: {
                    AccentButton(text: "Create an account", isButtonActive: vm.validate(email: vm.email, password: vm.password, repeatPassword: repeatPassword))
                    
                }
                .disabled(!vm.validate(email: vm.email, password: vm.password, repeatPassword: repeatPassword))
                
                Spacer()
            }
            .padding(.top)
            .padding(.horizontal, 20)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RegistrationView()
                .environmentObject(AuthenticationViewModel())
        }
    }
}

