//
//  ProcedureModel.swift
//  Briyut
//
//  Created by Egor Bubiryov on 06.05.2023.
//

import Foundation

struct ProcedureModel: Codable {
    let id: String
    let name: String
    let duration: Int
    let cost: Double
    let doctor: String
}
