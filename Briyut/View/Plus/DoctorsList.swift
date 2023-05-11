//
//  DoctorsList.swift
//  Briyut
//
//  Created by Egor Bubiryov on 08.05.2023.
//

import SwiftUI

struct DoctorsList: View {
    
    @Binding var choosenDoctors: [String]
    @EnvironmentObject var vm: ProfileViewModel
    var cornerRadius = ScreenSize.width / 30
    
    var body: some View {
        VStack {
            BarTitle<BackButton, Text>(text: "Doctors", leftButton: BackButton())
            
            ScrollView {
                if let doctors = vm.doctors {
                    ForEach(doctors, id: \.userId) { doctor in
                        HStack {
                            Text("\(doctor.name ?? doctor.userId) \(doctor.lastName ?? "")")
                                .foregroundColor(choosenDoctors.contains(doctor.userId) ? .white : .black)
                                .bold()
                        }
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: ScreenSize.height * 0.06)
                        .background(choosenDoctors.contains(doctor.userId) ? Color.mainColor : Color.secondaryColor)
                        .cornerRadius(cornerRadius)
                        .onTapGesture {
                            if let index = choosenDoctors.firstIndex(of: doctor.userId) {
                                choosenDoctors.remove(at: index)
                            } else {
                                choosenDoctors.append(doctor.userId)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct DoctorsList_Previews: PreviewProvider {
    static var previews: some View {
        DoctorsList(choosenDoctors: .constant([]))
            .environmentObject(ProfileViewModel())
    }
}
