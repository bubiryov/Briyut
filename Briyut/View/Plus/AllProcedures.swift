//
//  AddProcedureView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 08.05.2023.
//

import SwiftUI

struct AllProcedures: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Binding var notEntered: Bool
    @State private var isEditing: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                BarTitle<EditButton, AddProcedureButton>(
                    text: "Procedures",
                    leftButton: vm.user?.isDoctor == true ? EditButton(isEditing: $isEditing) : nil,
                    rightButton: vm.user?.isDoctor == true ? AddProcedureButton(isEditing: $isEditing) : nil)
                
                if alertContition() {
                    NavigationLink {
                        EditProfileView(notEntered: $notEntered)
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
                        
                        ProcedureRow(vm: vm, procedure: procedure, isEditing: $isEditing)
                            .offset(x: isEditing ? 2 : 0)
                            .offset(x: isEditing ? -2 : 0)
                            .animation(.easeInOut(duration: randomize(
                                interval: 0.12,
                                withVariance: 0.055
                            )).repeat(while: isEditing), value: isEditing)
                            .padding(.horizontal, isEditing ? 3 : 0)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }
    
    private func alertContition() -> Bool {
        guard vm.user?.name == nil || vm.user?.phoneNumber == nil, vm.user?.isDoctor == false else {
            return false
        }
        return true
    }
    
    private func randomize(interval: TimeInterval, withVariance variance: Double) -> TimeInterval {
        let random = (Double(arc4random_uniform(1000)) - 500.0) / 500.0
        return interval + variance * random
    }
    
}

struct AddProcedureView_Previews: PreviewProvider {
    static var previews: some View {
        AllProcedures(notEntered: .constant(false))
            .environmentObject(ProfileViewModel())
    }
}

struct AddProcedureButton: View {
    @Binding var isEditing : Bool
    var body: some View {
        NavigationLink {
            ProcedureView(title: "New procedure", buttonText: "Add", isEditing: $isEditing)
        } label: {
            BarButtonView(image: "plus", scale: 0.35)
        }
        .buttonStyle(.plain)
    }
}

struct ProcedureRow: View {
    
    var vm: ProfileViewModel
    var procedure: ProcedureModel
    var cornerRadius = ScreenSize.width / 30
    @Binding var isEditing: Bool
    
    var body: some View {
                        
        NavigationLink {
            if isEditing {
                ProcedureView(title: "Editing procedure", buttonText: "Save changes", procedure: procedure, isEditing: $isEditing)
            }
//            if vm.user?.isDoctor == true {
//                AddProcedureView(title: "Editing procedure", buttonText: "Save changes", procedure: procedure)
//            }
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

fileprivate struct EditButton: View {
    
    @Binding var isEditing: Bool
    
    var body: some View {
        Button {
            isEditing.toggle()
        } label: {
            BarButtonView(image: "pencil", textColor: isEditing ? .white : nil, backgroundColor: isEditing ? .mainColor : nil)
        }
        .buttonStyle(.plain)
    }
}