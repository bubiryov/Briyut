//
//  OrderModel.swift
//  Briyut
//
//  Created by Egor Bubiryov on 15.05.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct OrderModel: Codable, Equatable {
    let orderId: String
    let procedureId: String
    let procedureName: String
    let doctorId: String
    let doctorName: String
    let clientId: String
    let date: Timestamp
    let isDone: Bool
    let price: Int
    
    init(orderId: String, procedureId: String, procedureName: String, doctorId: String, doctorName: String, clientId: String, date: Timestamp, isDone: Bool, price: Int) {
        self.orderId = orderId
        self.procedureId = procedureId
        self.procedureName = procedureName
        self.doctorId = doctorId
        self.doctorName = doctorName
        self.clientId = clientId
        self.date = date
        self.isDone = isDone
        self.price = price
    }
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case procedureId = "procedure_id"
        case procedureName = "procedure_name"
        case doctorId = "doctor_id"
        case doctorName = "doctor_name"
        case clientId = "client_id"
        case date = "date"
        case isDone = "is_done"
        case price = "price"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.orderId, forKey: .orderId)
        try container.encode(self.procedureId, forKey: .procedureId)
        try container.encode(self.procedureName, forKey: .procedureName)
        try container.encode(self.doctorId, forKey: .doctorId)
        try container.encode(self.doctorName, forKey: .doctorName)
        try container.encode(self.clientId, forKey: .clientId)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.isDone, forKey: .isDone)
        try container.encode(self.price, forKey: .price)
    }
        
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.orderId = try container.decode(String.self, forKey: .orderId)
        self.procedureId = try container.decode(String.self, forKey: .procedureId)
        self.procedureName = try container.decode(String.self, forKey: .procedureName)
        self.doctorId = try container.decode(String.self, forKey: .doctorId)
        self.doctorName = try container.decode(String.self, forKey: .doctorName)
        self.clientId = try container.decode(String.self, forKey: .clientId)
        self.date = try container.decode(Timestamp.self, forKey: .date)
        self.isDone = try container.decode(Bool.self, forKey: .isDone)
        self.price = try container.decode(Int.self, forKey: .price)
    }
}
