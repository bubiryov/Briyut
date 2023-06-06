//
//  EditProfileView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 09.05.2023.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var lastName: String = ""
    @State private var phoneNumber: String = "+38"
    @State private var showAlert: Bool = false
    @Binding var notEntered: Bool
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var data: Data? = nil
    @State private var showActionSheet: Bool = false
    @State private var showPhotosPicker: Bool = false
    
    var body: some View {
        VStack {
            BarTitle<BackButton, DeleteAccountButton>(text: "Edit", leftButton: BackButton(), rightButton: DeleteAccountButton())
                .padding(.bottom)
                        
            VStack(spacing: ScreenSize.height * 0.02) {
                
                Button {
                    showActionSheet = true
                } label: {
                    if selectedPhoto == nil {
                        ProfileImage(photoURL: vm.user?.photoUrl, frame: ScreenSize.height * 0.12, color: Color.secondary.opacity(0.1))
                    } else {
                        if let data = data, let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: ScreenSize.height * 0.12, height: ScreenSize.height * 0.12, alignment: .center)
                                .clipped()
                        }
                    }
                }
                .frame(height: ScreenSize.height * 0.12)
                .cornerRadius(ScreenSize.width / 20)
                .onChange(of: selectedPhoto) { _ in
                    guard let item = selectedPhoto else { return }
                    Task {
                        guard let data = try await item.loadTransferable(type: Data.self) else { return }
                        self.data = data
                    }
                }
                .overlay {
                    VStack {
                        Spacer()
                        Image("pencil")
                            .resizable()
                            .foregroundColor(.white)
                            .scaledToFit()
                            .frame(width: ScreenSize.height * 0.02)
                            .padding(7)
                            .background(Color.mainColor)
                            .cornerRadius(ScreenSize.width / 50)
                            .offset(x: 5, y: 5)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                AccentInputField(promptText: "Maria", title: "Name", input: $name)
                
                AccentInputField(promptText: "Shevchenko", title: "Last name", input: $lastName)
                
                if !vm.authProviders.contains(.phone) {
                    AccentInputField(promptText: "+38 (099)-999-99-99", title: "Phone number", input: $phoneNumber)
                        .keyboardType(.phonePad)
                }
                                                
                Spacer()
                
                Button {
                    guard let user = vm.user else { return }
                    Task {
                        var url: String = user.photoUrl ?? ""
                        if let selectedPhoto {
                            if url != "" {
                                try await vm.deletePreviousPhoto(url: url)
                            }
                            let path = try await vm.saveProfilePhoto(item: selectedPhoto)
                            url = try await vm.getUrlForImage(path: path)
                        }
                        try await vm.editProfile(
                            userID: user.userId,
                            name: name != "" ? name : nil,
                            lastName: lastName != "" ? lastName : nil,
                            phoneNumber: phoneNumber.count > 5 ? phoneNumber : nil,
                            photoURL: url)
                        try await vm.loadCurrentUser()
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    AccentButton(text: "Save", isButtonActive: true)
                }
            }
            .ignoresSafeArea(.keyboard)
            .confirmationDialog("Choose action", isPresented: $showActionSheet) {
                Button("Choose new photo") {
                    showPhotosPicker = true
                }
                
                if let url = vm.user?.photoUrl {
                    Button("Delete current photo", role: .destructive) {
                        guard let user = vm.user else { return }
                        Task {
                            try await vm.deletePreviousPhoto(url: url)
                            try await vm.editProfile(
                                userID: user.userId,
                                name: name != "" ? name : nil,
                                lastName: lastName != "" ? lastName : nil,
                                phoneNumber: phoneNumber.count > 5 ? phoneNumber : nil,
                                photoURL: nil)
                            try await vm.loadCurrentUser()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhoto, matching: .images, photoLibrary: .shared())
        }
        .padding(.bottom, 20)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let user = vm.user {
                name = user.name ?? ""
                lastName = user.lastName ?? ""
                phoneNumber = user.phoneNumber ?? ""
            }
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
        .onTapGesture {
            hideKeyboard()
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(notEntered: .constant(false))
            .environmentObject(ProfileViewModel())
    }
}

struct DeleteAccountButton: View {
    var body: some View {
        Button {
            //
        } label: {
            BarButtonView(image: "trash", textColor: .white, backgroundColor: .mainColor)
        }
        .buttonStyle(.plain)
    }
}
