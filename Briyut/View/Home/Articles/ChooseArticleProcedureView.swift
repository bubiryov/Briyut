//
//  ChooseArticleProcedureView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 24.06.2023.
//

import SwiftUI

struct ChooseArticleProcedureView: View {
    
    @Binding var clippedProcedure: ProcedureModel?
    @EnvironmentObject var vm: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            BarTitle<BackButton, Text>(
                text: "Choose procedure",
                leftButton: BackButton()
            )
            
            ScrollView {
                ForEach(vm.procedures, id: \.procedureId) { procedure in
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(procedure.name)
                                .font(Mariupol.medium, 20)
                                .foregroundColor(clippedProcedure?.procedureId ?? "" == procedure.procedureId ? .white : .primary)
                            Text("\(procedure.duration) min")
                                .font(Mariupol.regular, 14)
                                .foregroundColor(clippedProcedure?.procedureId ?? "" == procedure.procedureId ? .white : .primary)
                        }
                        .padding(.vertical, 7)
                        
                        Spacer()
                        
                        VStack {
                            Text("₴ \(procedure.cost)")
                                .font(Mariupol.regular, 22)
                                .foregroundColor(clippedProcedure?.procedureId ?? "" == procedure.procedureId ? .white : .primary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(minHeight: ScreenSize.height * 0.09)
                    .background(clippedProcedure?.procedureId ?? "" == procedure.procedureId ? Color.mainColor : Color.secondaryColor)
                    .cornerRadius(ScreenSize.width / 30)
                    .onTapGesture {
                        if clippedProcedure?.procedureId ?? "" != procedure.procedureId {
                            clippedProcedure = procedure
                        } else {
                            clippedProcedure = nil
                        }
                    }
                }
            }
        }
        .background(Color.backgroundColor)
        .navigationBarBackButtonHidden()
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width > 100 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )

//        .onAppear {
//            Task {
//                try await vm.getAllProcedures()
//            }
//        }
    }
}

struct ChooseArticleProcedureView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ChooseArticleProcedureView(clippedProcedure: .constant(nil))
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal)
    }
}
