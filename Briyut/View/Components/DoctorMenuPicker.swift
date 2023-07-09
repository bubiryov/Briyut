//
//  DoctorMenuPicker.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.07.2023.
//

import SwiftUI

struct DoctorMenuPicker: View {
    
    let interfaceData: InterfaceData
    let doctors: [DoctorOption]
    @Binding var selectedDoctor: DBUser?
    
    var body: some View {
        Menu {
            ForEach(doctors, id: \.self) { doctorOption in
                switch doctorOption {
                case .allDoctors:
                    Button("all-specialists-string") {
                        selectedDoctor = nil
                    }
                case .user(let doctor):
                    Button("\(doctor.name ?? "") \(doctor.lastName ?? "")") {
                        selectedDoctor = doctor
                    }
                }
            }
        } label: {
            let doctor = selectedDoctor ?? interfaceData.user
            ProfileImage(
                photoURL: doctor == selectedDoctor ? doctor?.photoUrl ?? "" : "",
                frame: ScreenSize.height * 0.06,
                color: Color.secondary.opacity(0.1),
                padding: 16
            )
            .buttonStyle(.plain)
            .cornerRadius(ScreenSize.width / 30)
        }
    }
}

struct DoctorMenuPicker_Previews: PreviewProvider {
    static var previews: some View {
        DoctorMenuPicker(interfaceData: InterfaceData(), doctors: [], selectedDoctor: .constant(nil))
    }
}
