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
    @State var ordersTime = [Date: Date]()
    @Binding var selectedTab: Tab
    
    var body: some View {
        VStack {
            BarTitle<BackButton, Text>(text: "Choose a doctor", leftButton: BackButton())
            
            ScrollView {
                if let doctors = vm.doctors {
                    ForEach(doctors, id: \.userId) { doctor in
                        NavigationLink {
                            
                            DateTimeSelectionView(doctor: doctor, procedure: procedure, selectedTab: $selectedTab)
//                            AddOrderView(doctor: doctor, procedure: procedure, selectedTab: $selectedTab)
                            
                        } label: {
                            
                            HStack {
                                ProfileImage(photoURL: doctor.photoUrl, frame: ScreenSize.height * 0.06, color: .lightBlueColor)
                                    .cornerRadius(cornerRadius)
                                
                                Text("\(doctor.name ?? doctor.userId) \(doctor.lastName ?? "")")
                                    .foregroundColor(.primary)
                                    .bold()
                                    .padding(.leading, 8)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: ScreenSize.height * 0.09)
                            .background(Color.secondaryColor)
                            .cornerRadius(cornerRadius)
                        }
                    }
                    .listRowSeparator(.hidden)
                }
            }
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ChooseDoctorView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseDoctorView(procedure: ProcedureModel(procedureId: "", name: "", duration: 0, cost: 0, availableDoctors: []), selectedTab: .constant(.plus))
            .environmentObject(ProfileViewModel())
    }
}
