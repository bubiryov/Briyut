//
//  AddProcedure.swift
//  Briyut
//
//  Created by Egor Bubiryov on 08.05.2023.
//

import SwiftUI

struct AddProcedureView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var vm: ProfileViewModel
    @State var procedureId: String = ""
    @State var name: String = ""
    @State var duration: String = ""
    @State var cost: String = ""
    @State var availableDoctors: [String] = []
        
    var body: some View {
        VStack {
            BarTitle<BackButton, Text>(text: "New procedure", leftButton: BackButton())
                .padding(.bottom)
            
            ScrollView {
                VStack(spacing: ScreenSize.height * 0.02) {
                                        
//                    InputField(field: $procedureId, isSecureField: false, title: "1", header: "Procedure ID")
//                        .keyboardType(.numberPad)

                    InputField(field: $name, isSecureField: false, title: "Massage", header: "Procedure name")

                    InputField(field: $duration, isSecureField: false, title: "30", header: "Duration (min)")
                        .keyboardType(.numberPad)
                    
                    InputField(field: $cost, isSecureField: false, title: "1000", header: "Price")
                        .keyboardType(.numberPad)
                    
                    NavigationLink {
                        DoctorsList(choosenDoctors: $availableDoctors)
                    } label: {
                        AccentButton(text: "Choose available doctors", isButtonActive: true)
                    }
                    
                    Button {
                        let newProcedure = ProcedureModel(procedureId: UUID().uuidString, name: name, duration: Int(duration)!, cost: Int(cost)!, availableDoctors: availableDoctors)
                        Task {
                            do {
                                try await vm.addNewProcedure(procedure: newProcedure)
                                try await vm.getProcedures()
                                presentationMode.wrappedValue.dismiss()
                            } catch {
                                //
                            }
                        }
                    } label: {
                        AccentButton(text: "Add", isButtonActive: validateFields())
                    }
                }
            }
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func validateFields() -> Bool {
        if name.isEmpty || duration.isEmpty || cost.isEmpty || availableDoctors.isEmpty {
            return false
        }
        if !procedureId.allSatisfy({ $0.isNumber }) || !duration.allSatisfy({ $0.isNumber }) || !cost.allSatisfy({ $0.isNumber }) {
            return false
        }
        return true
    }
}

struct AddProcedure_Previews: PreviewProvider {
    static var previews: some View {
        AddProcedureView()
            .environmentObject(ProfileViewModel())
    }
}

fileprivate struct LocalTextField: View {
    
    @Binding var field: String
    var header: String
    var tittle: String
    var height: Double
    var cornerRadius = ScreenSize.width / 30
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(header)
                .font(.headline)
            
            TextField(tittle, text: $field)
                .padding()
                .frame(height: ScreenSize.height * height)
                .textInputAutocapitalization(.never)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(cornerRadius)
        }
    }
}

