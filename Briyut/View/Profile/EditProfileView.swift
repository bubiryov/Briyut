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
    @State private var showAlert: Bool = false
    @Binding var notEntered: Bool
    
    var body: some View {
        VStack {
            BarTitle<BackButton, LogOutButton>(text: "Edit", leftButton: BackButton(), rightButton: LogOutButton(showAlert: $showAlert))
                .padding(.bottom)
            
            VStack(spacing: ScreenSize.height * 0.02) {
                
                InputField(field: $name, isSecureField: false, title: "Name", header: "Your name")
                
                InputField(field: $lastName, isSecureField: false, title: "Last name", header: "Your last name (optional)")
                
                if !vm.authProviders.contains(.phone) {
                    InputField(field: $phoneNumber, isSecureField: false, title: "+38 (099)-999-99-99", header: "Phone number")
                        .keyboardType(.numberPad)
                }
                
                Spacer()
                
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
                            try await vm.getAllDoctors()
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            
                        }
                    }
                } label: {
                    AccentButton(text: "Save", isButtonActive: true)
                }
            }
            .ignoresSafeArea(.keyboard)
            .onTapGesture {
                hideKeyboard()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let user = vm.user {
                name = user.name ?? ""
                lastName = user.lastName ?? ""
                phoneNumber = user.phoneNumber ?? ""
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Are you sure you want to log out?"),
                primaryButton: .destructive(Text("Log out"), action: {
                    Task {
                        try vm.signOut()
                        notEntered = true
                    }
                }),
                secondaryButton: .default(Text("Cancel"), action: {
                    
                })
            )
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onEnded { gesture in
                if gesture.translation.width > 100 {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        )
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(notEntered: .constant(false))
            .environmentObject(ProfileViewModel())
    }
}

struct LogOutButton: View {
    
    @Binding var showAlert: Bool
    
    var body: some View {
        Button {
            showAlert = true
        } label: {
            BarButtonView(image: "exit")
        }
        .buttonStyle(.plain)
    }
}
