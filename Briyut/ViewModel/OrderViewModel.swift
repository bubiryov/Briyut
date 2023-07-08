//
//  OrderViewModel.swift
//  Briyut
//
//  Created by Egor Bubiryov on 07.07.2023.
//

import Foundation
import FirebaseFirestore

@MainActor
class OrderViewModel {
    
    let data: InterfaceData
    let orderManager: OrderManagerProtocol
    let procedureManager: ProcedureManagerProtocol
    
    init(data: InterfaceData, orderManager: OrderManagerProtocol, procedureManager: ProcedureManagerProtocol) {
        self.data = data
        self.orderManager = orderManager
        self.procedureManager = procedureManager
    }
    
    func getRequiredOrders(dataFetchMode: DataFetchMode, isDone: Bool, countLimit: Int) async throws {
        if !isDone {
            let (activeOrders, activeLastDocument) = try await orderManager.getRequiredOrders(dataFetchMode: dataFetchMode, userId: data.user?.userId ?? "", isDoctor: data.user?.isDoctor ?? false, isDone: false, countLimit: countLimit, lastDocument: data.activeLastDocument)
            data.activeOrders.append(contentsOf: activeOrders)
            if let activeLastDocument {
                data.activeLastDocument = activeLastDocument
            }
        } else {
            let (doneOrders, doneLastDocument) = try await orderManager.getRequiredOrders(dataFetchMode: dataFetchMode, userId: data.user?.userId ?? "", isDoctor: data.user?.isDoctor ?? false, isDone: true, countLimit: countLimit, lastDocument: data.doneLastDocument)
            data.doneOrders.append(contentsOf: doneOrders)
            if let doneLastDocument {
                data.doneLastDocument = doneLastDocument
            }
        }
    }
    
    func getAllOrders(dataFetchMode: DataFetchMode, count: Int?, isDone: Bool?) async throws {
        let (orders, lastDocument) = try await orderManager.getRequiredOrders(dataFetchMode: dataFetchMode, userId: "", isDoctor: false, isDone: isDone, countLimit: count, lastDocument: data.allLastDocument)
        data.allOrders.append(contentsOf: orders)
        if let lastDocument {
            data.allLastDocument = lastDocument
        }
        print("Downloaded orders")
    }

    func addNewOrder(order: OrderModel) async throws {
        try await orderManager.createNewOrder(order: order)
        data.activeLastDocument = nil
        data.activeOrders = []
        try await getRequiredOrders(dataFetchMode: .user, isDone: false, countLimit: 6)
    }
    
    func editOrderTime(orderId: String, date: Timestamp, end: Timestamp) async throws {
        try await orderManager.editOrderTime(orderId: orderId, date: date, end: end)
    }
    
    func removeOrder(orderId: String) async throws {
        try await orderManager.removeOrder(orderId: orderId)
    }
        
    func updateOrdersStatus(isDone: Bool, isDoctor: Bool) async throws {
        try await getAllOrders(dataFetchMode: .all, count: nil, isDone: isDone)
        for order in data.allOrders {
            let calendar = Calendar.current
            let procedureDuration = try await procedureManager.getProduct(procedureId: order.procedureId).duration
            if calendar.date(byAdding: .minute, value: procedureDuration, to: order.date.dateValue())! <= Date() {
                try await orderManager.updateOrderStatus(orderId: order.orderId)
            }
        }
        data.allLastDocument = nil
        data.allOrders = []
        try await getRequiredOrders(dataFetchMode: .user, isDone: false, countLimit: 6)
        try await getRequiredOrders(dataFetchMode: .user, isDone: true, countLimit: 6)
    }
    
    func getDayMonthOrders(date: Date, selectionMode: DateSelectionMode, doctorId: String?, firstDate: Date?, secondDate: Date?) async throws -> [OrderModel] {
        return try await orderManager.getDayMounthOrders(for: date, selectionMode: selectionMode, doctorId: doctorId, firstDate: firstDate, secondDate: secondDate)
    }
    
    func deleteUnfinishedOrders(idType: IDType, id: String) async throws {
        do {
            try await orderManager.deleteUnfinishedOrders(idType: idType, id: id)
            print("Active orders deleted")
        } catch {
            print("Error with deleting active orders")
            throw URLError(.badURL)
        }
    }
        
    func getDayOrderTimes(date: Date, selectionMode: DateSelectionMode, doctorId: String?) async throws -> [(Date, Date)] {
        let orders = try await getDayMonthOrders(date: date, selectionMode: selectionMode, doctorId: doctorId, firstDate: nil, secondDate: nil)
        var occupied = [(Date, Date)]()
        for order in orders {
            let start = order.date.dateValue()
            let end = order.end.dateValue()

            let tuple = (start, end)
            occupied.append(tuple)
        }
        return occupied
    }

}
