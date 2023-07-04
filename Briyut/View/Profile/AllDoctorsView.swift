//
//  AddDoctorView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 08.05.2023.
//

import SwiftUI

struct AllDoctorsView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var futureDoctorID: String = ""
    @State private var loading = false
    @State private var showAlert = false
    @State private var tupleDoctors: [(DBUser, Bool)] = []
    var cornerRadius = ScreenSize.width / 30
    
    var body: some View {
        GeometryReader { _ in
            
            VStack(spacing: ScreenSize.height * 0.02) {
                
                TopBar<BackButton, Text>(
                    text: "specialists-string",
                    leftButton: BackButton()
                )
                
                if vm.user?.isDoctor ?? false {
                    AccentInputField(
                        promptText: vm.user?.userId ?? "",
                        title: "user-id-string",
                        spaceAllow: false,
                        input: $futureDoctorID
                    )
                }
                
                ScrollView {
                    ForEach(tupleDoctors, id: \.0.userId) { doctor in
                        UserRow(
                            vm: vm,
                            user: doctor.0,
                            showButtons: doctor.1 && doctor.0.userId != vm.user?.userId,
                            userStatus: .doctor
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                if let index = tupleDoctors.firstIndex(where: { $0.0.userId == doctor.0.userId }) {
                                    tupleDoctors[index].1.toggle()
                                }
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                
                if vm.user?.isDoctor ?? false {
                    Spacer()
                    
                    Button {
                        addDoctorAction()
                    } label: {
                        AccentButton(
                            text: "add-specialist-string",
                            isButtonActive: validateDoctor(),
                            animation: loading
                        )
                    }
                    .disabled(!validateDoctor() || loading)
                }
            }
            .padding(.bottom, 20)
            .background(Color.backgroundColor)
            .onChange(of: vm.doctors, perform: { _ in
                withAnimation {
                    tupleDoctors = vm.doctors.map {($0, false)}
                }
            })
            .navigationBarBackButtonHidden(true)
            .onAppear {
                tupleDoctors = vm.doctors.map {($0, false)}
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

struct AddDoctorView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AllDoctorsView()
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal, 20)
        .background(Color.backgroundColor)
    }
}

extension AllDoctorsView {
    func validateDoctor() -> Bool {
        guard !futureDoctorID.isEmpty else { return false }
        return true
    }
    
    private func addDoctorAction() {
        Haptics.shared.play(.light)
        Task {
            do {
                loading = true
                try await vm.addDoctor(userID: futureDoctorID)
                withAnimation {
                    futureDoctorID = ""
                }
                loading = false
            } catch {
                loading = false
                print("Can't add a doctor")
            }
        }
    }

}
