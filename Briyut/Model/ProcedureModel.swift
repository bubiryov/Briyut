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
    
//    init(procedureId: String, name: String, duration: Int, cost: Int, availableDoctors: [String]) {
//        self.procedureId = procedureId
//        self.name = name
//        self.duration = duration
//        self.cost = cost
//        self.availableDoctors = availableDoctors
//    }
    
    enum CodingKeys: String, CodingKey {
        case procedureId = "procedure_id"
        case name = "name"
        case duration = "duration"
        case cost = "cost"
        case availableDoctors = "available_doctors"
    }
        
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.procedureId, forKey: .procedureId)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.duration, forKey: .duration)
        try container.encode(self.cost, forKey: .cost)
        try container.encode(self.availableDoctors, forKey: .availableDoctors)
    }
        
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.procedureId = try container.decode(String.self, forKey: .procedureId)
        self.name = try container.decode(String.self, forKey: .name)
        self.duration = try container.decode(Int.self, forKey: .duration)
        self.cost = try container.decode(Int.self, forKey: .cost)
        self.availableDoctors = try container.decode([String].self, forKey: .availableDoctors)
    }
    
    static func == (lhs: ProcedureModel, rhs: ProcedureModel) -> Bool {
        return lhs.procedureId == rhs.procedureId
    }
}
