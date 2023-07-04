//
//  ChooseDoctorView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 15.05.2023.
//

import SwiftUI

struct ChooseDoctorView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    var procedure: ProcedureModel
    var cornerRadius = ScreenSize.width / 30
    @Binding var selectedTab: Tab
    
    var body: some View {
        VStack {
            TopBar<BackButton, Text>(
                text: "choose-doctor-string",
                leftButton: BackButton()
            )
            
            ScrollView {
                                
                ForEach(procedure.availableDoctors, id: \.self) { doctorId in
                    
                    if let doctor = vm.doctors.first(where: { $0.userId == doctorId }) {
                        
                        NavigationLink {
                            DateTimeSelectionView(
                                doctor: doctor,
                                procedure: procedure,
                                mainButtonTitle: "add-appointment-string",
                                client: vm.user,
                                selectedTab: $selectedTab
                            )
                        } label: {
                            UserRow(
                                vm: vm,
                                user: doctor,
                                showButtons: false,
                                userStatus: .doctor
                            )
                        }
                    }
                }
            }
            
            Spacer()
        }
        .background(Color.backgroundColor)
        .navigationBarBackButtonHidden(true)
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

struct ChooseDoctorView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ChooseDoctorView(procedure: ProcedureModel(procedureId: "", name: "", duration: 0, cost: 0, parallelQuantity: 1, availableDoctors: []), selectedTab: .constant(.plus))
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal, 20)
        .background(Color.backgroundColor)
    }
}
