//
//  OrderManager.swift
//  Briyut
//
//  Created by Egor Bubiryov on 15.05.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class OrderManager {
    
    static let shared = OrderManager()
    private init() { }
    
    private let orderCollection = Firestore.firestore().collection("orders")
    
    private func orderDocument(orderId: String) -> DocumentReference {
        orderCollection.document(orderId)
    }

    private func getAllOrders() -> Query {
        orderCollection
    }
    
    func createNewProcedure(order: OrderModel) async throws {
        try orderDocument(orderId: order.orderId)
            .setData(from: order, merge: false)
    }
    
    func removeOrder(orderId: String) async throws {
        try await orderDocument(orderId: orderId).delete()
    }

    func getAllOrders() async throws -> [OrderModel] {
        
        let query: Query = getAllOrders()
        
        return try await query
            .getDocuments(as: OrderModel.self)
    }
    
    
}
