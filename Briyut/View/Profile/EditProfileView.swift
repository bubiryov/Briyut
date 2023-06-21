//
//  EditProfileView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 09.05.2023.
//

import SwiftUI
import PhotosUI
import UIKit

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
        
        GeometryReader { _ in
            VStack {
                BarTitle<BackButton, DeleteAccountButton>(
                    text: "Edit",
                    leftButton: BackButton(),
                    rightButton: DeleteAccountButton(showAlert: $showAlert)
                )
                .padding(.bottom)
                
                VStack(spacing: ScreenSize.height * 0.02) {
                    
                    Button {
                        showActionSheet = true
                    } label: {
                        VStack {
                            if selectedPhoto == nil {
                                ProfileImage(
                                    photoURL: vm.user?.photoUrl,
                                    frame: ScreenSize.height * 0.12,
                                    color: Color.secondary.opacity(0.1),
                                    padding: 16
                                )
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
//                    .overlay {
//                        VStack {
//                            Spacer()
//                            Image("pencil")
//                                .resizable()
//                                .foregroundColor(.white)
//                                .scaledToFit()
//                                .frame(width: ScreenSize.height * 0.02)
//                                .padding(7)
//                                .background(Color.mainColor)
//                                .cornerRadius(ScreenSize.width / 50)
//                                .offset(x: 5, y: 5)
//                        }
//                        .frame(maxWidth: .infinity, alignment: .trailing)
//                    }
                    ScrollView {
                        AccentInputField(
                            promptText: "Maria",
                            title: "Name",
                            input: $name
                        )
                        
                        AccentInputField(
                            promptText: "Shevchenko",
                            title: "Last name",
                            input: $lastName
                        )
                        
                        if !vm.authProviders.contains(.phone) {
                            AccentInputField(promptText: "+38 (099)-999-99-99", title: "Phone number", input: $phoneNumber)
                                .keyboardType(.phonePad)
                        }
                    }
                                                                        
                    Button {
                        guard let user = vm.user else { return }
                        Task {
                            var url: String = user.photoUrl ?? ""
                            if let selectedPhoto {
                                try await vm.deleteStorageFolderContents(userId: user.userId)
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
                .photosPicker(
                    isPresented: $showPhotosPicker,
                    selection: $selectedPhoto,
                    matching: .images,
                    photoLibrary: .shared())
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
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Are you sure you want to delete your account?"),
                    message: Text("All your data will be permanently deleted"),
                    primaryButton: .destructive(Text("Yes, I am sure"), action: {
                        Task {
                            do {
                                try await vm.deleteAccount()
                                notEntered = true
                            } catch {
                                print("Something went wrong")
                            }
                        }
                    }),
                    secondaryButton: .default(Text("Cancel"), action: { })
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
                    .onEnded { gesture in
                        if gesture.translation.height > 100 {
                            hideKeyboard()
                        }
                    }
            )
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EditProfileView(notEntered: .constant(false))
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal)
    }
}

struct DeleteAccountButton: View {
    
    @Binding var showAlert: Bool
    
    var body: some View {
        Button {
            showAlert = true
        } label: {
            BarButtonView(image: "trash", textColor: .white, backgroundColor: Color.destructiveColor)
        }
        .buttonStyle(.plain)
    }
}
