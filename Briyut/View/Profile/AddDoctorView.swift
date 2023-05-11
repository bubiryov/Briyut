//
//  AddDoctorView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 08.05.2023.
//

import SwiftUI

struct AddDoctorView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @State private var futureDoctorID: String = ""
    @State private var isEditing = false
    var cornerRadius = ScreenSize.width / 30
    
    var body: some View {
        VStack(spacing: ScreenSize.height * 0.02) {
            BarTitle<BackButton, EditButton>(text: "Add a doctor", leftButton: BackButton(), rightButton: EditButton(isEditing: $isEditing))
            
            
            InputField(field: $futureDoctorID, isSecureField: false, title: "UserID")
            
            Button {
                Task {
                    try await vm.addDoctor(userID: futureDoctorID)
                    try await vm.getAllDoctors()
                    futureDoctorID = ""
                }
            } label: {
                AccentButton(text: "Add a doctor", isButtonActive: validateDoctor())
            }
                        
            ScrollView {
                if let doctors = vm.doctors {
                    ForEach(doctors, id: \.userId) { doctor in
                        HStack {
                            Text("\(doctor.name ?? doctor.userId) \(doctor.lastName ?? "")")
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: ScreenSize.height * 0.06)
                        .background(Color.secondaryColor)
                        .cornerRadius(cornerRadius)
                        .overlay {
                            if isEditing {
                                DeleteButton(deleteFunction:  {
                                    removeDoctor(at: IndexSet([vm.doctors?.firstIndex(where: { $0.userId == doctor.userId }) ?? 0]))
                                })
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.inset)
            .scrollIndicators(.hidden)

            Spacer()
            
        }
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            isEditing = false
        }
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
    
    func removeDoctor(at offsets: IndexSet) {
        guard vm.doctors?.count ?? 0 > 1 else { return }
        for index in offsets {
            if let userID = vm.doctors?[index].userId {
                guard userID != vm.user?.userId else { return }
                Task {
                    do {
                        try await vm.removeDoctor(userID: userID)
                        try await vm.getAllDoctors()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}

struct DeleteButton: View {
    
    var deleteFunction: () -> ()
    
    var body: some View {
        HStack(alignment: .top) {
            Spacer()
            Button {
                deleteFunction()
            } label: {
                Image(systemName: "x.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: ScreenSize.height * 0.03)
                    .foregroundColor(Color.mainColor)
            }
            .padding(.trailing)
        }
    }
}

struct EditButton: View {
    
    @Binding var isEditing: Bool
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isEditing.toggle()
            }
        } label: {
            BarButtonView(image: "pencil", scale: 0.35)
        }
        .buttonStyle(.plain)
    }
}
