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
        NavigationView {
            VStack(spacing: 30) {
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
            .padding(.horizontal, 30)
//            .navigationTitle("Create an account")
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: btnBack)
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
            .environmentObject(AuthenticationViewModel())
    }
}

extension RegistrationView {
    var btnBack : some View {
        Button {
            self.presentationMode.wrappedValue.dismiss()
        } label: {
            Image(systemName: "chevron.backward")
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.black)
                .bold()
        }
    }
}
