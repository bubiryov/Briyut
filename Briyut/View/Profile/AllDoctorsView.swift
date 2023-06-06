//
//  AllDoctorsView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 06.06.2023.
//

import SwiftUI

struct AllDoctorsView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            BarTitle<BackButton, Text>(text: "Doctors", leftButton: BackButton())
            
            ForEach(vm.doctors, id: \.userId) { doctor in
                UserRow(user: doctor)
            }
            
            Spacer()
        }
        .navigationBarBackButtonHidden()
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

struct AllDoctorsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AllDoctorsView()
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal, 20)
    }
}
