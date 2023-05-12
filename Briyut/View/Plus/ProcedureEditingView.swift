//
//  ProcedureEditingView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 12.05.2023.
//

import SwiftUI

struct ProcedureEditingView: View {
    
    var procedure: ProcedureModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ProcedureEditingView_Previews: PreviewProvider {
    static var previews: some View {
        ProcedureEditingView(procedure: ProcedureModel(procedureId: "aaa", name: "Massage", duration: 30, cost: 850, availableDoctors: ["12345"]))
    }
}
