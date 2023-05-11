//
//  ProcedureModel.swift
//  Briyut
//
//  Created by Egor Bubiryov on 06.05.2023.
//

import Foundation

struct ProcedureModel: Codable, Equatable {
    let procedureId: String
    let name: String
    let duration: Int
    let cost: Int
    let availableDoctors: [String]
    
    static func == (lhs: ProcedureModel, rhs: ProcedureModel) -> Bool {
        return lhs.procedureId == rhs.procedureId
    }

}
