//
//  ProfileViewModel.swift
//  Briyut
//
//  Created by Egor Bubiryov on 08.05.2023.
//

import Foundation
import FirebaseFirestore
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published var user: DBUser? = nil
    @Published var doctors: [DBUser]? = nil
    @Published var procedures: [ProcedureModel] = []
    @Published var authProviders: [AuthProviderOption] = []
    @Published var activeOrders: [OrderModel] = []
    @Published var doneOrders: [OrderModel] = []

    var activeLastDocument: DocumentSnapshot? = nil
    var doneLastDocument: DocumentSnapshot? = nil
//    let procedureVM = ProcedureViewModel()
    
    init() {
        print("INIT ProfileViewModel")
    }
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await getUser(userId: authDataResult.uid)
//        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
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
//        self.doctors = try await UserManager.shared.getAllDoctors()
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
        try await getAllProcedures()
    }
    
//    func add2(procedure: ProcedureModel) async throws {
//        self.procedures = try await procedureVM.addNewProcedure(procedure: procedure)
//    }
    
    func getProcedure(procedureId: String) async throws -> ProcedureModel {
        try await ProcedureManager.shared.getProduct(procedureId: procedureId)
    }
    
    func getAllProcedures() async throws {
        let procedures = try await ProcedureManager.shared.getAllProcedures()
        self.procedures = procedures
    }
    
    func editProcedure(procedureId: String, name: String, duration: Int, cost: Int, availableDoctors: [String]) async throws {
        try await ProcedureManager.shared.editProcedure(procedureId: procedureId, name: name, duration: duration, cost: cost, availableDoctors: availableDoctors)
        self.procedures = []
        try await getAllProcedures()
    }
    
    func removeProcedure(procedureId: String) async throws {
        try await ProcedureManager.shared.removeProcedure(procedureId: procedureId)
        try await getAllProcedures()
    }
}

//class ProcedureViewModel {
//    func addNewProcedure(procedure: ProcedureModel) async throws -> [ProcedureModel] {
//        try await ProcedureManager.shared.createNewProcedure(procedure: procedure)
//        return try await getAllProcedures()
//    }
//
//    func getAllProcedures() async throws -> [ProcedureModel] {
//        return try await ProcedureManager.shared.getAllProcedures()
//    }
//
//}

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
    
//    func updateOrdersStatus() async throws {
//        try await getAllOrders(isDone: false, countLimit: 20)
//        for order in activeOrders {
//            if order.date.dateValue() <= Date() {
//                try await OrderManager.shared.updateOrderStatus(orderId: order.orderId)
//            }
//        }
//        activeLastDocument = nil
//        doneLastDocument = nil
//        activeOrders = []
//        doneOrders = []
//        try await getAllOrders(isDone: false, countLimit: 6)
//        try await getAllOrders(isDone: true, countLimit: 6)
//        print("Updated")
//    }
    
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

    
    /*
    func getDayOrders(date: Timestamp) async throws -> [Date: Date] {
        let orders = try await OrderManager.shared.getDayOrders(date: date)
        var occupied = [Date: Date]()
        for order in orders {
            let date = order.date.dateValue()
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.hour, .minute], from: date)
            let hour = dateComponents.hour ?? 0
            let minute = dateComponents.minute ?? 0
            let start = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!

//            let hour = calendar.component(.hour, from: date)
//            let minute = calendar.component(.minute, from: date)
//            let start = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
            
            let procedureDuration = try await ProcedureManager.shared.getProduct(procedureId: order.procedureId).duration
            let end = calendar.date(byAdding: .minute, value: procedureDuration, to: start)!

            
//            let pocedureDuration = try await ProcedureManager.shared.getProduct(procedureId: order.procedureId).duration
//            let end = calendar.date(byAdding: .minute, to: start)!
            return occupied[start: end]

        }
    }
     */
    
//    func getDayOrders(date: Timestamp) async throws -> [Date: Date] {
//        let orders = try await OrderManager.shared.getDayOrders(date: date)
//        var occupied = [Date: Date]()
//        for order in orders {
//            let date = order.date.dateValue()
//            let calendar = Calendar.current
//            let dateComponents = calendar.dateComponents([.hour, .minute], from: date)
//            let hour = dateComponents.hour ?? 0
//            let minute = dateComponents.minute ?? 0
//            let start = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
//
//            let procedureDuration = try await ProcedureManager.shared.getProduct(procedureId: order.procedureId).duration
//            let end = calendar.date(byAdding: .minute, value: procedureDuration, to: start)!
//
//            occupied[start] = end
//        }
//        return occupied
//    }
    
//    func getDayOrders(date: Date) async throws -> [Date: Date] {
//        let orders = try await OrderManager.shared.getDayOrders(date: date)
//        var occupied = [Date: Date]()
//        for order in orders {
//            let orderDate = order.date.dateValue()
//            let calendar = Calendar.current
//            let dateComponents = calendar.dateComponents([.hour, .minute], from: orderDate)
//            let hour = dateComponents.hour ?? 0
//            let minute = dateComponents.minute ?? 0
//            let start = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
//
//            let procedureDuration = try await ProcedureManager.shared.getProduct(procedureId: order.procedureId).duration
//            let end = calendar.date(byAdding: .minute, value: procedureDuration, to: start)!
//
//            occupied[start] = end
//        }
//        print(occupied)
//        return occupied
//    }
    
    func getDayOrders(date: Date) async throws -> [Date: Date] {
        let orders = try await OrderManager.shared.getDayOrders(date: date)
        var occupied = [Date: Date]()
        for order in orders {
            let orderDate = order.date.dateValue()
            let calendar = Calendar.current
//            let dateComponents = calendar.dateComponents([.hour, .minute], from: orderDate)
//            let hour = dateComponents.hour ?? 0
//            let minute = dateComponents.minute ?? 0
//            let start = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
            
            let procedureDuration = try await ProcedureManager.shared.getProduct(procedureId: order.procedureId).duration
            let end = calendar.date(byAdding: .minute, value: procedureDuration, to: orderDate)!
            
            occupied[orderDate] = end
        }
        print(occupied)
        return occupied
    }



    
}
