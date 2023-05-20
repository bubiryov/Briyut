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
    
    func getProduct(orderId: String) async throws -> OrderModel {
        try await orderDocument(orderId: orderId).getDocument(as: OrderModel.self)
    }

//    private func getAllOrders() -> Query {
//        orderCollection
//    }
    
    func createNewOrder(order: OrderModel) async throws {
        try orderDocument(orderId: order.orderId)
            .setData(from: order, merge: false)
    }
    
    func removeOrder(orderId: String) async throws {
        try await orderDocument(orderId: orderId).delete()
    }
    
    private func filter(clientId: String, isDone: Bool) -> Query {
        orderCollection
            .whereField(OrderModel.CodingKeys.clientId.rawValue, isEqualTo: clientId)
            .whereField(OrderModel.CodingKeys.isDone.rawValue, isEqualTo: isDone)
            .order(by: OrderModel.CodingKeys.date.rawValue, descending: false)
    }
    
    func getAllOrders(userId: String, isDone: Bool, countLimit: Int, lastDocument: DocumentSnapshot?) async throws -> (products: [OrderModel], lastDocument: DocumentSnapshot?) {
                
        let query = filter(clientId: userId, isDone: isDone)
                
        if let lastDocument {
            return try await query
                .limit(to: countLimit)
                .start(afterDocument: lastDocument)
                .getDocumentsWithSnapshot(as: OrderModel.self)
        } else {
            return try await query
                .limit(to: countLimit)
                .getDocumentsWithSnapshot(as: OrderModel.self)
        }
    }
    
    func updateOrderStatus(orderId: String) async throws {
        let data: [String : Any] = [
            OrderModel.CodingKeys.isDone.rawValue : true
        ]
        try await orderDocument(orderId: orderId).updateData(data)
    }
        
    func getDayOrders(date: Date) async throws -> [OrderModel] {
        let calendar = Calendar.current
        
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        let query = orderCollection
            .whereField(OrderModel.CodingKeys.isDone.rawValue, isEqualTo: false)
            .whereField(OrderModel.CodingKeys.date.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(OrderModel.CodingKeys.date.rawValue, isLessThan: endDate)
            .order(by: OrderModel.CodingKeys.date.rawValue, descending: false)

        return try await query.getDocuments(as: OrderModel.self)
    }

    
}
