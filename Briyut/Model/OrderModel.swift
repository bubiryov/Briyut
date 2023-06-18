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
    let doctorId: String
    let clientId: String
    let date: Timestamp
    let end: Timestamp
    let isDone: Bool
    let price: Int
    
//    static func <(lhs: OrderModel, rhs: OrderModel) -> Bool {
//        return lhs.date.dateValue() < rhs.date
//    }
    
    init(orderId: String, procedureId: String, doctorId: String, clientId: String, date: Timestamp, end: Timestamp, isDone: Bool, price: Int) {
        self.orderId = orderId
        self.procedureId = procedureId
        self.doctorId = doctorId
        self.clientId = clientId
        self.date = date
        self.end = end
        self.isDone = isDone
        self.price = price
    }
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case procedureId = "procedure_id"
        case doctorId = "doctor_id"
        case clientId = "client_id"
        case date = "date"
        case end = "end"
        case isDone = "is_done"
        case price = "price"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.orderId, forKey: .orderId)
        try container.encode(self.procedureId, forKey: .procedureId)
        try container.encode(self.doctorId, forKey: .doctorId)
        try container.encode(self.clientId, forKey: .clientId)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.end, forKey: .end)
        try container.encode(self.isDone, forKey: .isDone)
        try container.encode(self.price, forKey: .price)
    }
        
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.orderId = try container.decode(String.self, forKey: .orderId)
        self.procedureId = try container.decode(String.self, forKey: .procedureId)
        self.doctorId = try container.decode(String.self, forKey: .doctorId)
        self.clientId = try container.decode(String.self, forKey: .clientId)
        self.date = try container.decode(Timestamp.self, forKey: .date)
        self.end = try container.decode(Timestamp.self, forKey: .end)
        self.isDone = try container.decode(Bool.self, forKey: .isDone)
        self.price = try container.decode(Int.self, forKey: .price)
    }
}
