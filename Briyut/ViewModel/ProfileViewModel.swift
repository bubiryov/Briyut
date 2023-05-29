//
//  ProfileViewModel.swift
//  Briyut
//
//  Created by Egor Bubiryov on 08.05.2023.
//

import Foundation
import FirebaseFirestore
import SwiftUI
import PhotosUI

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
    
    func editProfile(userID: String, name: String?, lastName: String?, phoneNumber: String?, photoURL: String?) async throws {
        print("Edit")
        return try await UserManager.shared.editProfile(userID: userID, name: name, lastName: lastName, phoneNumber: phoneNumber, photoURL: photoURL)
    }
    
    func saveProfilePhoto(item: PhotosPickerItem) async throws -> String {
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw URLError(.badServerResponse)
        }
        guard let user = user else {
            throw URLError(.badServerResponse)
        }
        return try await StorageManager.shared.saveImage(data: data, userID: user.userId)
    }
    
    func deletePreviousPhoto(url: String) async throws {
        try await StorageManager.shared.deletePreviousPhoto(url: url)
    }
    
    func getUrlForImage(path: String) async throws -> String {
        return try await StorageManager.shared.getUrlForImage(path: path)
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
        
    func editProcedure(procedureId: String, name: String, duration: Int, cost: Int, parallelQuantity: Int, availableDoctors: [String]) async throws {
        try await ProcedureManager.shared.editProcedure(procedureId: procedureId, name: name, duration: duration, cost: cost, parallelQuantity: parallelQuantity, availableDoctors: availableDoctors)
    }
    
    func removeProcedure(procedureId: String) async throws {
        try await ProcedureManager.shared.removeProcedure(procedureId: procedureId)
    }
}

// MARK: Orders

extension ProfileViewModel {
        
    func getAllClientOrders(isDone: Bool, countLimit: Int) async throws {
        if !isDone {
            let (activeOrders, activeLastDocument) = try await OrderManager.shared.getAllClientOrders(userId: user?.userId ?? "", isDone: false, countLimit: countLimit, lastDocument: activeLastDocument)
            self.activeOrders.append(contentsOf: activeOrders)
            if let activeLastDocument {
                self.activeLastDocument = activeLastDocument
            }
            print("Догрузка активных ордеров")
        } else {
            let (doneOrders, doneLastDocument) = try await OrderManager.shared.getAllClientOrders(userId: user?.userId ?? "", isDone: true, countLimit: countLimit, lastDocument: doneLastDocument)
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
        try await getAllClientOrders(isDone: false, countLimit: 6)
    }
    
    func editOrderTime(orderId: String, date: Timestamp, end: Timestamp) async throws {
        try await OrderManager.shared.editOrderTime(orderId: orderId, date: date, end: end)
        activeLastDocument = nil
        activeOrders = []
        try await getAllClientOrders(isDone: false, countLimit: 6)
    }
    
    func removeOrder(orderId: String) async throws {
        try await OrderManager.shared.removeOrder(orderId: orderId)
        activeLastDocument = nil
        activeOrders = []
        try await getAllClientOrders(isDone: false, countLimit: 6)
    }
        
    func updateOrdersStatus() async throws {
        try await getAllClientOrders(isDone: false, countLimit: 20)
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
        try await getAllClientOrders(isDone: false, countLimit: 6)
        try await getAllClientOrders(isDone: true, countLimit: 6)
        print("Updated")
    }
    
    func getDayOrders(date: Date, doctorId: String?) async throws -> [OrderModel] {
        return try await OrderManager.shared.getDayOrders(date: date, doctorId: doctorId)
    }
    
    func getDayOrderTimes(date: Date, doctorId: String?) async throws -> [(Date, Date)] {
        let orders = try await getDayOrders(date: date, doctorId: doctorId)
        var occupied = [(Date, Date)]()
        for order in orders {
            let start = order.date.dateValue()
            let end = order.end.dateValue()

            let tuple = (start, end)
            occupied.append(tuple)
        }
        return occupied
    }
    
//    func getDayOrderTimes(date: Date, doctorId: String?) async throws -> [Date: Date] {
//        let orders = try await getDayOrders(date: date, doctorId: doctorId)
//        var occupied = [Date: Date]()
//        for order in orders {
//            let start = order.date.dateValue()
//            let end = order.end.dateValue()
//
//            occupied[start] = end
//        }
//        return occupied
//    }

}
