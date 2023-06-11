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
    @State private var tupleDoctors: [(DBUser, Bool)] = []
    var cornerRadius = ScreenSize.width / 30
    
    var body: some View {
        VStack(spacing: ScreenSize.height * 0.02) {
            BarTitle<BackButton, Text>(text: "Add a doctor", leftButton: BackButton())
            
            AccentInputField(promptText: vm.user?.userId ?? "", title: "UserID", input: $futureDoctorID)
            
            ScrollView {
                ForEach(tupleDoctors, id: \.0.userId) { doctor in
                    UserRow(
                        vm: vm,
                        user: doctor.0,
                        showButtons: doctor.1 && doctor.0.userId != vm.user?.userId,
                        userStatus: .doctor
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if let index = tupleDoctors.firstIndex(where: { $0.0.userId == doctor.0.userId }) {
                                tupleDoctors[index].1.toggle()
                            }
                        }
                    }

//                    .contextMenu {
//                        Button(role: .destructive) {
//                            Task {
//                                try await vm.removeDoctor(userID: doctor.userId)
//                            }
//                        } label: {
//                            Label("Delete", systemImage: "trash")
//                        }
//                    }
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
        .onAppear {
            tupleDoctors = vm.doctors.map {($0, false)}
        }
//        .onDisappear {
//            isEditing = false
//        }
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
