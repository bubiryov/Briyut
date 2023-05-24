//
//  ProfileViewModel.swift
//  Briyut
//
//  Created by Egor Bubiryov on 08.05.2023.
//

import Foundation
import FirebaseFirestore
import SwiftUI
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published var user: DBUser? = nil
    @Published var doctors: [DBUser]? = nil
    @Published var procedures: [ProcedureModel] = []
    @Published var authProviders: [AuthProviderOption] = []
    @Published var activeOrders: [OrderModel] = []
    @Published var doneOrders: [OrderModel] = []
    @Published var dayOrders: [OrderModel] = []

    var activeLastDocument: DocumentSnapshot? = nil
    var doneLastDocument: DocumentSnapshot? = nil
        
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await getUser(userId: authDataResult.uid)
    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await UserManager.shared.getUser(userId: userId)
    }
    
    func getProvider() {
        if let providers = try? AuthenticationManager.shared.getProvider() {
            authProviders = providers
        }
    }
        
    func signOut() throws {
        do {
            try AuthenticationManager.shared.signOut()
        } catch  {
            print("Log out error: \(error)")
        }
    }
    
    func addDoctor(userID: String) async throws {
        guard try await UserManager.shared.checkIfUserExists(userId: userID) else {
            return
        }
        try await UserManager.shared.makeDoctor(userID: userID)
        self.doctors = try await UserManager.shared.getAllDoctors()
    }
    
    func removeDoctor(userID: String) async throws {
        guard userID != user?.userId else { return }
        try await UserManager.shared.removeDoctor(userID: userID)
        try await getAllDoctors()
    }
    
    func getAllDoctors() async throws {
        self.doctors = try await UserManager.shared.getAllDoctors()
    }
    
    func editProfile(userID: String, name: String?, lastName: String?, phoneNumber: String?) async throws {
        try await UserManager.shared.editProfile(userID: userID, name: name, lastName: lastName, phoneNumber: phoneNumber)
    }
    
}

// MARK: Procedures

extension ProfileViewModel {
    
    func addNewProcedure(procedure: ProcedureModel) async throws {
        try await ProcedureManager.shared.createNewProcedure(procedure: procedure)
    }
        
    func getProcedure(procedureId: String) async throws -> ProcedureModel {
        try await ProcedureManager.shared.getProduct(procedureId: procedureId)
    }
        
    func addListenerForProcuderes() {
        ProcedureManager.shared.addListenerForProcedures { [weak self] products in
            self?.procedures = products
        }
    }
        
    func editProcedure(procedureId: String, name: String, duration: Int, cost: Int, availableDoctors: [String]) async throws {
        try await ProcedureManager.shared.editProcedure(procedureId: procedureId, name: name, duration: duration, cost: cost, availableDoctors: availableDoctors)
    }
    
    func removeProcedure(procedureId: String) async throws {
        try await ProcedureManager.shared.removeProcedure(procedureId: procedureId)
    }
}

// MARK: Orders

extension ProfileViewModel {
        
    func getAllOrders(isDone: Bool, countLimit: Int) async throws {
        if !isDone {
            let (activeOrders, activeLastDocument) = try await OrderManager.shared.getAllOrders(userId: user?.userId ?? "", isDone: false, countLimit: countLimit, lastDocument: activeLastDocument)
            self.activeOrders.append(contentsOf: activeOrders)
            if let activeLastDocument {
                self.activeLastDocument = activeLastDocument
            }
            print("Догрузка активных ордеров")
        } else {
            let (doneOrders, doneLastDocument) = try await OrderManager.shared.getAllOrders(userId: user?.userId ?? "", isDone: true, countLimit: countLimit, lastDocument: doneLastDocument)
            self.doneOrders.append(contentsOf: doneOrders)
            if let doneLastDocument {
                self.doneLastDocument = doneLastDocument
            }
            print("Догрузка выполненных ордеров")
        }
    }

    func addNewOrder(order: OrderModel) async throws {
        try await OrderManager.shared.createNewOrder(order: order)
        activeLastDocument = nil
        activeOrders = []
        try await getAllOrders(isDone: false, countLimit: 6)
    }
    
    func removeOrder(orderId: String) async throws {
        try await OrderManager.shared.removeOrder(orderId: orderId)
    }
        
    func updateOrdersStatus() async throws {
        try await getAllOrders(isDone: false, countLimit: 20)
        for order in activeOrders {
            let calendar = Calendar.current
            let procedureDuration = try await ProcedureManager.shared.getProduct(procedureId: order.procedureId).duration
            if calendar.date(byAdding: .minute, value: procedureDuration, to: order.date.dateValue())! <= Date() {
                try await OrderManager.shared.updateOrderStatus(orderId: order.orderId)
            }
        }
        activeLastDocument = nil
        doneLastDocument = nil
        activeOrders = []
        doneOrders = []
        try await getAllOrders(isDone: false, countLimit: 6)
        try await getAllOrders(isDone: true, countLimit: 6)
        print("Updated")
    }
    
    func getDayOrders(date: Date) async throws -> [OrderModel] {
        return try await OrderManager.shared.getDayOrders(date: date)
    }

    func getDayOrderTimes(date: Date) async throws -> [Date: Date] {
        let orders = try await getDayOrders(date: date)
        var occupied = [Date: Date]()
        for order in orders {
            let orderDate = order.date.dateValue()
            let calendar = Calendar.current
            let procedureDuration = try await ProcedureManager.shared.getProduct(procedureId: order.procedureId).duration
            let end = calendar.date(byAdding: .minute, value: procedureDuration, to: orderDate)!

            occupied[orderDate] = end
        }
        print(occupied)
        return occupied
    }
}
