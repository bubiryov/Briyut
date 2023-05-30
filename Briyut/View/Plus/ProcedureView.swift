//
//  ProcedureView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 08.05.2023.
//

import SwiftUI

struct ProcedureView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var vm: ProfileViewModel
    
    var title: String
    var buttonText: String
    var procedure: ProcedureModel? = nil
    @State var name: String = ""
    @State var duration: String = ""
    @State var parallelQuantity: String = ""
    @State var cost: String = ""
    @State var availableDoctors: [String] = []
    @State private var showAlert = false
    @Binding var isEditing: Bool
    
    @State var test: Int = 0
        
    var body: some View {
        VStack {
            BarTitle<BackButton, DeleteButton?>(text: title, leftButton: BackButton(), rightButton: procedure != nil ? DeleteButton(showAlert: $showAlert) : nil)
                .padding(.bottom)
            
            ScrollView {
                VStack(spacing: ScreenSize.height * 0.02) {
                    
                    AccentInputField(promptText: "Procedure name", input: $name)
                    
                    AccentInputField(promptText: "Duration (minutes)", input: $duration)
                        .keyboardType(.numberPad)
                    
                    AccentInputField(promptText: "Count of parallel procedures", input: $parallelQuantity)
                        .keyboardType(.numberPad)
                    
                    AccentInputField(promptText: "Price", input: $cost)
                        .keyboardType(.numberPad)
                }
            }
            .scrollDisabled(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Are you sure you want to delete the procedure?"),
                    message: Text("This action will not be undone and all scheduled sessions will be canceled"),
                    primaryButton: .destructive(Text("Delete"), action: {
                        Task {
                            try await vm.removeProcedure(procedureId: procedure!.procedureId)
                            isEditing = false
                        }
                    }),
                    secondaryButton: .default(Text("Cancel"), action: {
                        
                    })
                )
            }
            
            Spacer()
            
            NavigationLink {
                AvailableDoctorsView(choosenDoctors: $availableDoctors)
            } label: {
                AccentButton(text: "Choose available doctors", isButtonActive: true)
            }

            Button {
                Task {
                    if procedure == nil {
                        try await addProcedure()
                    } else {
                        try await editProcedure()
                        isEditing = false
                    }
                }
            } label: {
                AccentButton(text: buttonText, isButtonActive: validateFields())
            }
            .disabled(!validateFields())
        }
        .ignoresSafeArea(.keyboard)
        .onTapGesture {
            hideKeyboard()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let procedure {
                if name == "" {
                    name = procedure.name
                    duration = String(procedure.duration)
                    cost = String(procedure.cost)
                    availableDoctors = procedure.availableDoctors
                }
            }
        }
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
    
    func validateFields() -> Bool {
        if name.isEmpty || duration.isEmpty || cost.isEmpty || Int(cost) == nil || availableDoctors.isEmpty || parallelQuantity.isEmpty || Int(parallelQuantity) == nil {
            return false
        }
        if !duration.allSatisfy({ $0.isNumber }) || !cost.allSatisfy({ $0.isNumber }) {
            return false
        }
        
        return true
    }
    
    func addProcedure() async throws {
        let newProcedure = ProcedureModel(procedureId: UUID().uuidString, name: name, duration: Int(duration)!, cost: Int(cost)!, parallelQuantity: Int(parallelQuantity)!, availableDoctors: availableDoctors)
        do {
            try await vm.addNewProcedure(procedure: newProcedure)
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Can't add the procedure")
        }
    }
    
    func editProcedure() async throws {
        do {
            try await vm.editProcedure(procedureId: procedure?.procedureId ?? "", name: name, duration: Int(duration)!, cost: Int(cost)!, parallelQuantity: Int(parallelQuantity)!, availableDoctors: availableDoctors)
            presentationMode.wrappedValue.dismiss()
        } catch  {
            print("Can't edit the procedure")
        }
    }
}

struct AddProcedure_Previews: PreviewProvider {
    static var previews: some View {
        ProcedureView(title: "Edit procedure", buttonText: "Save changes", isEditing: .constant(false))
            .environmentObject(ProfileViewModel())
    }
}

fileprivate struct DeleteButton: View {
    
    @Binding var showAlert: Bool
    
    var body: some View {
        Button {
            showAlert = true
        } label: {
            BarButtonView(image: "trash", textColor: .red)
        }
        .buttonStyle(.plain)
    }
}

struct AccentInputField: View {
    
    var promptText: String
    @Binding var input: String
    
    var body: some View {
        TextField("", text: $input, prompt: Text(promptText))
            .bold()
            .padding(.leading)
            .frame(maxWidth: .infinity)
            .frame(height: ScreenSize.height * 0.06)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(ScreenSize.width / 30)
    }
}
