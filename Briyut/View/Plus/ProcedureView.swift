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
            BarTitle<BackButton, DeleteProcedureButton?>(text: title, leftButton: BackButton(), rightButton: procedure != nil ? DeleteProcedureButton(showAlert: $showAlert) : nil)
                .padding(.bottom)
            
            ScrollView {
                VStack(spacing: ScreenSize.height * 0.02) {
                    
                    AccentInputField(
                        promptText: "Massage",
                        title: "Procedure name",
                        input: $name
                    )
                    
                    AccentInputField(
                        promptText: "30",
                        title: "Duration (minutes)",
                        input: $duration
                    )
                    .keyboardType(.numberPad)
                    
                    AccentInputField(
                        promptText: "2",
                        title: "Count of parallel procedures",
                        input: $parallelQuantity
                    )
                    .keyboardType(.numberPad)
                    
                    AccentInputField(
                        promptText: "1000",
                        title: "Price",
                        input: $cost
                    )
                    .keyboardType(.numberPad)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Are you sure you want to delete the procedure?"),
                    message: Text("This action will not be undone and all scheduled sessions will be canceled"),
                    primaryButton: .destructive(Text("Delete"), action: {
                        Task {
                            try await vm.removeProcedure(procedureId: procedure!.procedureId)
                            isEditing = false
                            presentationMode.wrappedValue.dismiss()
                        }
                    }),
                    secondaryButton: .default(Text("Cancel"), action: { })
                )
            }
            
            Spacer()
            
            NavigationLink {
                AvailableDoctorsView(choosenDoctors: $availableDoctors)
            } label: {
                AccentButton(
                    text: "Choose available doctors",
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
            if let procedure {
                if name == "" {
                    name = procedure.name
                    duration = String(procedure.duration)
                    cost = String(procedure.cost)
                    availableDoctors = procedure.availableDoctors
                    parallelQuantity = String(procedure.parallelQuantity)
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
                .onEnded { gesture in
                    if gesture.translation.height > 100 {
                        hideKeyboard()
                    }
                }
        )
        .ignoresSafeArea(.keyboard)
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
}

struct AddProcedure_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProcedureView(title: "Edit procedure", buttonText: "Save changes", isEditing: .constant(false))
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal, 20)
        .background(Color.backgroundColor)
    }
}

fileprivate struct DeleteProcedureButton: View {
    
    @Binding var showAlert: Bool
    
    var body: some View {
        Button {
            showAlert = true
        } label: {
            BarButtonView(image: "trash", textColor: .white, backgroundColor: Color.destructiveColor)
        }
        .buttonStyle(.plain)
    }
}
