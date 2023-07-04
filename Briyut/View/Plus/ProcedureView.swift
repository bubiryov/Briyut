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
    @State private var loading: Bool = false
    @Binding var isEditing: Bool
            
    var body: some View {
        
        VStack {
            TopBar<BackButton, DeleteButton?>(
                text: title,
                leftButton: BackButton(),
                rightButton: procedure != nil ? DeleteButton(showAlert: $showAlert) : nil
            )
            .padding(.bottom)
            
            ScrollView {
                VStack(spacing: ScreenSize.height * 0.02) {
                    
                    AccentInputField(
                        promptText: "massage-string",
                        title: "procedure-name-string",
                        input: $name
                    )
                    
                    AccentInputField(
                        promptText: "30",
                        title: "duration-string",
                        input: $duration
                    )
                    .keyboardType(.numberPad)
                    
                    AccentInputField(
                        promptText: "2",
                        title: "count-of-parallel-string",
                        input: $parallelQuantity
                    )
                    .keyboardType(.numberPad)
                    
                    AccentInputField(
                        promptText: "1000",
                        title: "price-string",
                        input: $cost
                    )
                    .keyboardType(.numberPad)
                }
            }
            .alert(isPresented: $showAlert) {
                deleteProcedureAlert
            }
            
            Spacer()
            
            NavigationLink {
                AvailableDoctorsView(choosenDoctors: $availableDoctors)
            } label: {
                AccentButton(
                    text: "choose-available-specialists-string",
                    isButtonActive: true
                )
            }
            
            Button {
                Haptics.shared.play(.light)
                Task {
                    if procedure == nil {
                        try await addProcedure()
                    } else {
                        try await editProcedure()
                    }
                }
            } label: {
                AccentButton(
                    text: buttonText,
                    isButtonActive: validateFields(),
                    animation: loading
                )
            }
            .disabled(!validateFields() || loading)
        }
        .padding(.bottom, 20)
        .background(Color.backgroundColor)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadDataFromProcedure()
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
        .ignoresSafeArea(.keyboard)
    }
    
//    func validateFields() -> Bool {
//        if name.isEmpty || duration.isEmpty || cost.isEmpty || Int(cost) == nil || availableDoctors.isEmpty || parallelQuantity.isEmpty || Int(parallelQuantity) == nil {
//            return false
//        }
//        if !duration.allSatisfy({ $0.isNumber }) || !cost.allSatisfy({ $0.isNumber }) {
//            return false
//        }
//
//        return true
//    }
//
//    func addProcedure() async throws {
//        let newProcedure = ProcedureModel(procedureId: UUID().uuidString, name: name, duration: Int(duration)!, cost: Int(cost)!, parallelQuantity: Int(parallelQuantity)!, availableDoctors: availableDoctors)
//        do {
//            loading = true
//            try await vm.addNewProcedure(procedure: newProcedure)
//            loading = false
//            presentationMode.wrappedValue.dismiss()
//        } catch {
//            loading = false
//            print("Can't add the procedure")
//        }
//    }
//
//    func editProcedure() async throws {
//        do {
//            loading = true
//            try await vm.editProcedure(procedureId: procedure?.procedureId ?? "", name: name, duration: Int(duration)!, cost: Int(cost)!, parallelQuantity: Int(parallelQuantity)!, availableDoctors: availableDoctors)
//            loading = false
//            presentationMode.wrappedValue.dismiss()
//        } catch {
//            loading = false
//            print("Can't edit the procedure")
//        }
//    }
//
//    func loadDataFromProcedure() {
//        if let procedure = procedure {
//            if name == "" {
//                name = procedure.name
//                duration = String(procedure.duration)
//                cost = String(procedure.cost)
//                availableDoctors = procedure.availableDoctors
//                parallelQuantity = String(procedure.parallelQuantity)
//            }
//        }
//    }

}

struct AddProcedure_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProcedureView(title: "edit-procedure-string", buttonText: "save-changes-string", isEditing: .constant(false))
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal, 20)
        .background(Color.backgroundColor)
    }
}

// MARK: Components

extension ProcedureView {
    
    private var deleteProcedureAlert: Alert {
        Alert(
            title: Text("delete-procedure-alert-title-string"),
            message: Text("delete-procedure-alert-message-string"),
            primaryButton: .destructive(Text("delete-string"), action: {
                Task {
                    do {
                        try await vm.removeProcedure(procedureId: procedure!.procedureId)
                        isEditing = false
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        print("Something went wrong")
                    }
                }
            }),
            secondaryButton: .default(Text("cancel-string"), action: { })
        )
    }

}

// MARK: Functions

extension ProcedureView {
    
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
            loading = true
            try await vm.addNewProcedure(procedure: newProcedure)
            loading = false
            presentationMode.wrappedValue.dismiss()
        } catch {
            loading = false
            print("Can't add the procedure")
        }
    }
    
    func editProcedure() async throws {
        do {
            loading = true
            try await vm.editProcedure(procedureId: procedure?.procedureId ?? "", name: name, duration: Int(duration)!, cost: Int(cost)!, parallelQuantity: Int(parallelQuantity)!, availableDoctors: availableDoctors)
            loading = false
            presentationMode.wrappedValue.dismiss()
        } catch {
            loading = false
            print("Can't edit the procedure")
        }
    }
    
    func loadDataFromProcedure() {
        if let procedure = procedure {
            if name == "" {
                name = procedure.name
                duration = String(procedure.duration)
                cost = String(procedure.cost)
                availableDoctors = procedure.availableDoctors
                parallelQuantity = String(procedure.parallelQuantity)
            }
        }
    }

}
