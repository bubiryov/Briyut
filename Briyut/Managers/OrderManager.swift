//
//  OrderManager.swift
//  Briyut
//
//  Created by Egor Bubiryov on 15.05.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
//import Combine

enum DateSelectionMode {
    case day
    case month
}

enum DataFetchMode {
    case all
    case user
}

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
    
    func createNewOrder(order: OrderModel) async throws {
        try orderDocument(orderId: order.orderId)
            .setData(from: order, merge: false)
    }
    
    func removeOrder(orderId: String) async throws {
        try await orderDocument(orderId: orderId).delete()
    }
    
//    private func filter(dataFetchMode: DataFetchMode, userId: String, isDoctor: Bool, isDone: Bool) -> Query {
//        if dataFetchMode == .all {
//            return orderCollection
//                .order(by: OrderModel.CodingKeys.date.rawValue, descending: true)
//        } else {
//            let query = orderCollection
//                .whereField(OrderModel.CodingKeys.isDone.rawValue, isEqualTo: isDone)
//            if isDoctor {
//                return query
//                    .whereField(OrderModel.CodingKeys.doctorId.rawValue, isEqualTo: userId)
//                    .order(by: OrderModel.CodingKeys.date.rawValue, descending: false)
//            } else {
//                return query
//                    .whereField(OrderModel.CodingKeys.clientId.rawValue, isEqualTo: userId)
//                    .order(by: OrderModel.CodingKeys.date.rawValue, descending: isDone)
//            }
//        }
//    }
    
    private func filter(dataFetchMode: DataFetchMode, userId: String, isDoctor: Bool, isDone: Bool?) -> Query {
        if let isDone {
            let query = orderCollection
                .whereField(OrderModel.CodingKeys.isDone.rawValue, isEqualTo: isDone)

            if dataFetchMode == .all {
                return query
                    .order(by: OrderModel.CodingKeys.date.rawValue, descending: false)
            } else {
                if isDoctor {
                    return query
                        .whereField(OrderModel.CodingKeys.doctorId.rawValue, isEqualTo: userId)
                        .order(by: OrderModel.CodingKeys.date.rawValue, descending: false)
                } else {
                    return query
                        .whereField(OrderModel.CodingKeys.clientId.rawValue, isEqualTo: userId)
                        .order(by: OrderModel.CodingKeys.date.rawValue, descending: isDone)
                }
            }
        } else {
            return orderCollection
                .order(by: OrderModel.CodingKeys.date.rawValue, descending: true)
        }
    }
    
//    private func filter(userId: String, isDoctor: Bool, isDone: Bool?) -> Query {
//        if let isDone {
//            if isDoctor {
//                if userId == "" {
//                    return orderCollection
////                        .whereField(OrderModel.CodingKeys.doctorId.rawValue, isEqualTo: userId)
//                        .whereField(OrderModel.CodingKeys.isDone.rawValue, isEqualTo: isDone)
//                        .order(by: OrderModel.CodingKeys.date.rawValue, descending: false)
//                } else {
//                    return orderCollection
//                        .whereField(OrderModel.CodingKeys.doctorId.rawValue, isEqualTo: userId)
//                        .whereField(OrderModel.CodingKeys.isDone.rawValue, isEqualTo: isDone)
//                        .order(by: OrderModel.CodingKeys.date.rawValue, descending: false)
//                }
//            } else {
//                return orderCollection
//                    .whereField(OrderModel.CodingKeys.clientId.rawValue, isEqualTo: userId)
//                    .whereField(OrderModel.CodingKeys.isDone.rawValue, isEqualTo: isDone)
//                    .order(by: OrderModel.CodingKeys.date.rawValue, descending: isDone ? true : false)
//            }
//        } else {
//            return orderCollection
//                .order(by: OrderModel.CodingKeys.date.rawValue, descending: true)
//        }
//    }
        
    func getRequiredOrders(dataFetchMode: DataFetchMode, userId: String, isDoctor: Bool, isDone: Bool?, countLimit: Int?, lastDocument: DocumentSnapshot?) async throws -> (orders: [OrderModel], lastDocument: DocumentSnapshot?) {

        let query = filter(dataFetchMode: dataFetchMode, userId: userId, isDoctor: isDoctor, isDone: isDone)

        if let countLimit {
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
        } else {
            return try await query
                .getDocumentsWithSnapshot(as: OrderModel.self)
        }
    }

    func updateOrderStatus(orderId: String) async throws {
        let data: [String : Any] = [
            OrderModel.CodingKeys.isDone.rawValue : true
        ]
        try await orderDocument(orderId: orderId).updateData(data)
    }
    
    func getDayMounthOrders(for date: Date, selectionMode: DateSelectionMode, doctorId: String?) async throws -> [OrderModel] {
        let calendar = Calendar.current
        
        var startDate: Date
        var endDate: Date
        
        switch selectionMode {
        case .day:
            startDate = calendar.startOfDay(for: date)
            endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        case .month:
            let components = calendar.dateComponents([.year, .month], from: date)
            startDate = calendar.date(from: components)!
            endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
        }
        
        let query = orderCollection
            .whereField(OrderModel.CodingKeys.date.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(OrderModel.CodingKeys.date.rawValue, isLessThan: endDate)
            .order(by: OrderModel.CodingKeys.date.rawValue, descending: false)
        
        if let doctorId {
            return try await query
                .whereField(OrderModel.CodingKeys.doctorId.rawValue, isEqualTo: doctorId)
                .getDocuments(as: OrderModel.self)
        } else {
            return try await query
                .getDocuments(as: OrderModel.self)
        }
    }

        
//    func getDayOrders(date: Date, doctorId: String?) async throws -> [OrderModel] {
//        let calendar = Calendar.current
//
//        let startDate = calendar.startOfDay(for: date)
//        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
//
//        let query = orderCollection
////            .whereField(OrderModel.CodingKeys.isDone.rawValue, isEqualTo: false)
//            .whereField(OrderModel.CodingKeys.date.rawValue, isGreaterThanOrEqualTo: startDate)
//            .whereField(OrderModel.CodingKeys.date.rawValue, isLessThan: endDate)
//            .order(by: OrderModel.CodingKeys.date.rawValue, descending: false)
//
//        if let doctorId {
//            return try await query
//                .whereField(OrderModel.CodingKeys.doctorId.rawValue, isEqualTo: doctorId)
//                .getDocuments(as: OrderModel.self)
//        } else {
//            return try await query
//                .getDocuments(as: OrderModel.self)
//        }
//    }
    
    func editOrderTime(orderId: String, date: Timestamp, end: Timestamp) async throws {
        let data: [String: Any] = [
            OrderModel.CodingKeys.date.rawValue: date,
            OrderModel.CodingKeys.end.rawValue: end
        ]
        try await orderDocument(orderId: orderId).updateData(data)
    }
    
    func deleteUnfinishedOrders(idType: IdType, id: String) async throws {
        let orderQuery: Query
        
        switch idType {
        case .client:
            orderQuery = orderCollection.whereField("client_id", isEqualTo: id)
        case .doctor:
            orderQuery = orderCollection.whereField("doctor_id", isEqualTo: id)
        case .procedure:
            orderQuery = orderCollection.whereField("procedure_id", isEqualTo: id)
        }
        let ordersSnapshot = try await orderQuery.getDocuments(as: OrderModel.self)
        
        for order in ordersSnapshot {
            let orderDocument = orderCollection.document(order.orderId)
            if !order.isDone {
                try await orderDocument.delete()
            }
        }
    }
}

enum IdType {
    case client
    case doctor
    case procedure
}
