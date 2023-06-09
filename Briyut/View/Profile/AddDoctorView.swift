//
//  AddDoctorView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 08.05.2023.
//

import SwiftUI

struct AddDoctorView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var futureDoctorID: String = ""
    @State private var isEditing = false
    @State private var showAlert = false
    var cornerRadius = ScreenSize.width / 30
    
    var body: some View {
        VStack(spacing: ScreenSize.height * 0.02) {
            BarTitle<BackButton, Text>(text: "Add a doctor", leftButton: BackButton())
            
            AccentInputField(promptText: vm.user?.userId ?? "", title: "UserID", input: $futureDoctorID)
            
            ScrollView {
                ForEach(vm.doctors, id: \.userId) { doctor in
                    UserRow(user: doctor, showCallButton: doctor.userId != vm.user?.userId)
//                    HStack {
//
//                        ProfileImage(photoURL: doctor.photoUrl, frame: ScreenSize.height * 0.06, color: .lightBlueColor)
//                            .cornerRadius(ScreenSize.width / 30)
//
//                        Text("\(doctor.name ?? doctor.userId) \(doctor.lastName ?? "")")
//                            .bold()
//                            .padding(.leading, 8)
//                            .lineLimit(1)
//                    }
//                    .padding(.horizontal)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .frame(height: ScreenSize.height * 0.09)
//                    .background(Color.secondaryColor)
//                    .cornerRadius(cornerRadius)
                    .contextMenu {
                        Button(role: .destructive) {
                            Task {
                                try await vm.removeDoctor(userID: doctor.userId)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            
            Spacer()
            
            Button {
                Task {
                    try await vm.addDoctor(userID: futureDoctorID)
                    try await vm.getAllDoctors()
                    futureDoctorID = ""
                }
            } label: {
                AccentButton(text: "Add a doctor", isButtonActive: validateDoctor())
            }

        }
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            isEditing = false
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

struct AddDoctorView_Previews: PreviewProvider {
    static var previews: some View {
        AddDoctorView()
            .environmentObject(ProfileViewModel())
    }
}

extension AddDoctorView {
    func validateDoctor() -> Bool {
        guard !futureDoctorID.isEmpty else { return false }
        return true
    }
}
