//
//  ProcedureRow.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.07.2023.
//

import SwiftUI

struct ProcedureRow: View {
    
    var interfaceData: InterfaceData
    var procedure: ProcedureModel
    var cornerRadius = ScreenSize.width / 30
    @Binding var isEditing: Bool
    @Binding var selectedTab: Tab
    
    var body: some View {
        
        NavigationLink {
            if isEditing {
                ProcedureView(
                    title: "editing-procedure-string",
                    buttonText: "save-changes-string",
                    procedure: procedure,
                    isEditing: $isEditing
                )
            } else {
                if interfaceData.user?.isDoctor == true {
                    ChooseClientView(
                        procedure: procedure,
                        selectedTab: $selectedTab
                    )
                } else {
                    ChooseDoctorView(
                        procedure: procedure,
                        selectedTab: $selectedTab
                    )
                }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(procedure.name)
                        .font(Mariupol.medium, 20)
                    Text("\(procedure.duration) \("min-string".localized)")
                        .font(Mariupol.regular, 14)
                }
                .padding(.vertical, 7)
                
                Spacer()
                
                VStack {
                    Text("₴ \(procedure.cost)")
                        .font(Mariupol.regular, 22)
                }
            }
            .padding(.horizontal, 20)
            .frame(minHeight: ScreenSize.height * 0.09)
            .background(Color.secondaryColor)
            .cornerRadius(cornerRadius)
        }
        .buttonStyle(.plain)
    }
}

struct ProcedureRow_Previews: PreviewProvider {
    static var previews: some View {
        ProcedureRow(
            interfaceData: InterfaceData(),
            procedure: ProcedureModel(
                procedureId: "",
                name: "Massage",
                duration: 30,
                cost: 1000,
                parallelQuantity: 0,
                availableDoctors: []),
            isEditing: .constant(false),
            selectedTab: .constant(.plus)
        )
    }
}
