//
//  EditProfileView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 09.05.2023.
//

import SwiftUI

struct EditProfileView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var lastName: String = ""
    @State private var phoneNumber: String = "+38"
    
    var body: some View {
        VStack {
            BarTitle<BackButton, Text>(text: "Edit", leftButton: BackButton())
                .padding(.bottom)
            
            VStack(spacing: ScreenSize.height * 0.02) {
                                
                InputField(field: $name, isSecureField: false, title: "Name", header: "Your name")
                
                InputField(field: $lastName, isSecureField: false, title: "Last name", header: "Your last name (optional)")
                
                if !vm.authProviders.contains(.phone) {
                    InputField(field: $phoneNumber, isSecureField: false, title: "+38 (099)-999-99-99", header: "Phone number")
                        .keyboardType(.numberPad)
                }
                
                Button {
                    guard let user = vm.user else { return }
                    Task {
                        do {
                            try await vm.editProfile(
                                userID: user.userId,
                                name: name != "" ? name : nil,
                                lastName: lastName != "" ? lastName : nil,
                                phoneNumber: phoneNumber.count > 5 ? phoneNumber : nil)
                            try await vm.loadCurrentUser()
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            
                        }
                    }
                } label: {
                    AccentButton(text: "Edit", isButtonActive: true)
                }
            }
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let user = vm.user {
                name = user.name ?? ""
                lastName = user.lastName ?? ""
                phoneNumber = user.phoneNumber ?? ""
            }
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
            .environmentObject(ProfileViewModel())
    }
}
