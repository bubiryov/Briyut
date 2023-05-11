//
//  AddProcedureView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 08.05.2023.
//

import SwiftUI

struct AllProcedures: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                BarTitle<Text, AddProcedureButton>(text: "Procedures", rightButton: vm.user?.isDoctor == true ? AddProcedureButton() : nil)
                
                if alertContition() {
                    NavigationLink {
                        EditProfileView()
                    } label: {
                        HStack {
                            HStack {
                                Text("To create an appointment, you should provide a name and phone number in your profile settings.")
                                    .font(.subheadline)
                                    .bold()
                                Image(systemName: "exclamationmark.triangle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: ScreenSize.height * 0.03)
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 5)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow.opacity(0.3))
                        .cornerRadius(ScreenSize.width / 30)
                    }
                    .buttonStyle(.plain)
                }
                
                ScrollView {
                    ForEach(vm.procedures, id: \.procedureId) { procedure in
                        
                        ProcedureRow(procedure: procedure)
                        
                        if procedure == vm.procedures.last && vm.procedures.count > 9 {
                            ProgressView()
                                .onAppear {
                                    Task {
                                        try await vm.getProcedures()
                                    }
                                }
                        }
                    }
                }
                .listStyle(.inset)
                .scrollIndicators(.hidden)
                
                Spacer()
            }
        }
    }
    
    private func alertContition() -> Bool {
        guard vm.user?.name == nil || vm.user?.phoneNumber == nil, vm.user?.isDoctor == false else {
            return false
        }
        return true
    }
    
}

struct AddProcedureView_Previews: PreviewProvider {
    static var previews: some View {
        AllProcedures()
            .environmentObject(ProfileViewModel())
    }
}

struct AddProcedureButton: View {
    var body: some View {
        NavigationLink {
            AddProcedureView()
        } label: {
            BarButtonView(image: "plus", scale: 0.35)
        }
        .buttonStyle(.plain)
    }
}

struct ProcedureRow: View {
    
    var procedure: ProcedureModel
    var cornerRadius = ScreenSize.width / 30
    
    var body: some View {
                
        NavigationLink {
            //
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(procedure.name)
                        .font(.title3.bold())
                    Text("\(procedure.duration) min")
                        .font(.subheadline)
                }
                .padding(.vertical, 7)
                
                Spacer()
                
                VStack {
                    Text("₴ \(procedure.cost)")
                        .font(.title2)
                }
            }
            .padding(.horizontal, 20)
            .frame(height: ScreenSize.height * 0.12)
            .background(Color.secondaryColor)
            .cornerRadius(cornerRadius)
        }
        .buttonStyle(.plain)
    }
}
