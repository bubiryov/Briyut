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
    @Published var doctors: [DBUser] = []
    @Published var users: [DBUser] = []
    @Published var procedures: [ProcedureModel] = []
    @Published var authProviders: [AuthProviderOption] = []
    @Published var activeOrders: [OrderModel] = []
    @Published var doneOrders: [OrderModel] = []
    @Published var allOrders: [OrderModel] = []

    var activeLastDocument: DocumentSnapshot? = nil
    var doneLastDocument: DocumentSnapshot? = nil
    var allLastDocument: DocumentSnapshot? = nil
    
//    init() {
//        for familyName in UIFont.familyNames {
//            print(familyName)
//            for fontName in UIFont.fontNames(forFamilyName: familyName) {
//                print("--- \(fontName)")
//            }
//        }
//    }
        
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        user = try await getUser(userId: authDataResult.uid)
    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await UserManager.shared.getUser(userId: userId)
    }
    
    func getAllUsers() async throws {
        users = try await UserManager.shared.getAllUsers()
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
    
    func deleteStorageFolderContents(userId: String) async throws {
        try await StorageManager.shared.deleteFolderContents(userId: userId)
    }
    
    func deleteAccount() async throws {
        guard let user = user else { throw URLError(.badServerResponse) }
        try await deleteUnfinishedOrders(idType: .client, id: user.userId)
        try await UserManager.shared.deleteUser(userId: user.userId)
        try await deleteStorageFolderContents(userId: user.userId)
        try await AuthenticationManager.shared.deleteAccount()
        self.user = nil
    }
    
    func updateBlockStatus(userID: String, isBlocked: Bool) async throws {
        try await UserManager.shared.updateBlockStatus(userID: userID, isBlocked: isBlocked)
//        users = []
        if isBlocked {
            try await deleteUnfinishedOrders(idType: .client, id: userID)
        }
        activeLastDocument = nil
        activeOrders = []
        try await getRequiredOrders(dataFetchMode: .user, isDone: false, countLimit: 2)
        try await getAllUsers()
    }
    
    func addDoctor(userID: String) async throws {
        guard try await UserManager.shared.checkIfUserExists(userId: userID) else {
            return
        }
        try await UserManager.shared.makeDoctor(userID: userID)
        try await getAllDoctors()
    }
    
    func removeDoctor(userID: String) async throws {
        guard userID != user?.userId else { return }
        try await UserManager.shared.removeDoctor(userID: userID)
        try await deleteUnfinishedOrders(idType: .doctor, id: userID)
        try await updateProceduresForDoctor(userID: userID)
        try await getAllDoctors()
    }
    
    func getAllDoctors() async throws {
        self.doctors = try await UserManager.shared.getAllDoctors()
    }
    
    func editProfile(userID: String, name: String?, lastName: String?, phoneNumber: String?, photoURL: String?) async throws {
        return try await UserManager.shared.editProfile(userID: userID, name: name, lastName: lastName, phoneNumber: phoneNumber, photoURL: photoURL)
    }
    
    func saveProfilePhoto(item: PhotosPickerItem) async throws -> String {
        let contentTypes: [String] = ["image/jpeg", "image/png", "image/heif", "image/heic"]
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw URLError(.badServerResponse)
        }
        guard let user = user else {
            throw URLError(.badServerResponse)
        }
        return try await StorageManager.shared.saveImage(data: data, userID: user.userId, contentTypes: contentTypes)
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
        try await getAllProcedures()
    }
        
    func getProcedure(procedureId: String) async throws -> ProcedureModel {
        try await ProcedureManager.shared.getProduct(procedureId: procedureId)
    }
    
    func getAllProcedures() async throws {
        procedures = try await ProcedureManager.shared.getAllProcedures()
    }
    
//    func addListenerForProcuderes() {
//        ProcedureManager.shared.addListenerForProcedures { [weak self] products in
//            self?.procedures = products
//        }
//    }
        
    func editProcedure(procedureId: String, name: String, duration: Int, cost: Int, parallelQuantity: Int, availableDoctors: [String]) async throws {
        try await ProcedureManager.shared.editProcedure(procedureId: procedureId, name: name, duration: duration, cost: cost, parallelQuantity: parallelQuantity, availableDoctors: availableDoctors)
        try await getAllProcedures()
    }
    
    func removeProcedure(procedureId: String) async throws {
        try await ProcedureManager.shared.removeProcedure(procedureId: procedureId)
        try await deleteUnfinishedOrders(idType: .procedure, id: procedureId)
        try await getAllProcedures()
        activeLastDocument = nil
        activeOrders = []
        try await getRequiredOrders(dataFetchMode: .user, isDone: false, countLimit: 2)
    }
    
    func updateProceduresForDoctor(userID: String) async throws {
        try await ProcedureManager.shared.updateProceduresForDoctor(userID: userID)
    }
}

// MARK: Orders

extension ProfileViewModel {
        
    func getRequiredOrders(dataFetchMode: DataFetchMode, isDone: Bool, countLimit: Int) async throws {
        if !isDone {
            let (activeOrders, activeLastDocument) = try await OrderManager.shared.getRequiredOrders(dataFetchMode: dataFetchMode, userId: user?.userId ?? "", isDoctor: user?.isDoctor ?? false, isDone: false, countLimit: countLimit, lastDocument: activeLastDocument)
            self.activeOrders.append(contentsOf: activeOrders)
            if let activeLastDocument {
                self.activeLastDocument = activeLastDocument
            }
        } else {
            let (doneOrders, doneLastDocument) = try await OrderManager.shared.getRequiredOrders(dataFetchMode: dataFetchMode, userId: user?.userId ?? "", isDoctor: user?.isDoctor ?? false, isDone: true, countLimit: countLimit, lastDocument: doneLastDocument)
            self.doneOrders.append(contentsOf: doneOrders)
            if let doneLastDocument {
                self.doneLastDocument = doneLastDocument
            }
        }
    }
    
    func getAllOrders(dataFetchMode: DataFetchMode, count: Int?, isDone: Bool?) async throws {
        let (orders, lastDocument) = try await OrderManager.shared.getRequiredOrders(dataFetchMode: dataFetchMode, userId: "", isDoctor: false, isDone: isDone, countLimit: count, lastDocument: allLastDocument)
        self.allOrders.append(contentsOf: orders)
        if let lastDocument {
            self.allLastDocument = lastDocument
        }
    }

    func addNewOrder(order: OrderModel) async throws {
        try await OrderManager.shared.createNewOrder(order: order)
        activeLastDocument = nil
        activeOrders = []
        try await getRequiredOrders(dataFetchMode: .user, isDone: false, countLimit: 6)
    }
    
    func editOrderTime(orderId: String, date: Timestamp, end: Timestamp) async throws {
        try await OrderManager.shared.editOrderTime(orderId: orderId, date: date, end: end)
//        activeLastDocument = nil
//        activeOrders = []
//        try await getAllOrders(isDone: false, countLimit: 6)
    }
    
    func removeOrder(orderId: String) async throws {
        try await OrderManager.shared.removeOrder(orderId: orderId)
        activeLastDocument = nil
        activeOrders = []
        try await getRequiredOrders(dataFetchMode: .user, isDone: false, countLimit: 6)
    }
        
    func updateOrdersStatus(isDone: Bool, isDoctor: Bool) async throws {
        try await getAllOrders(dataFetchMode: .all, count: nil, isDone: isDone)
        for order in allOrders {
            let calendar = Calendar.current
            let procedureDuration = try await ProcedureManager.shared.getProduct(procedureId: order.procedureId).duration
            if calendar.date(byAdding: .minute, value: procedureDuration, to: order.date.dateValue())! <= Date() {
                try await OrderManager.shared.updateOrderStatus(orderId: order.orderId)
            }
        }
        allLastDocument = nil
        allOrders = []
        try await getRequiredOrders(dataFetchMode: .user, isDone: false, countLimit: 6)
        try await getRequiredOrders(dataFetchMode: .user, isDone: true, countLimit: 6)
    }
    
    func getDayMonthOrders(date: Date, selectionMode: DateSelectionMode, doctorId: String?) async throws -> [OrderModel] {
        return try await OrderManager.shared.getDayMounthOrders(for: date, selectionMode: selectionMode, doctorId: doctorId)
    }
    
    func deleteUnfinishedOrders(idType: IDType, id: String) async throws {
        do {
            try await OrderManager.shared.deleteUnfinishedOrders(idType: idType, id: id)
            print("Active orders deleted")
        } catch {
            print("Error with deleting active orders")
            throw URLError(.badURL)
        }
    }
    
//    func getDayOrders(date: Date, doctorId: String?) async throws -> [OrderModel] {
//        let dayOrders = try await OrderManager.shared.getDayOrders(date: date, doctorId: doctorId)
//        return dayOrders
//    }
    
    func getDayOrderTimes(date: Date, selectionMode: DateSelectionMode, doctorId: String?) async throws -> [(Date, Date)] {
        let orders = try await getDayMonthOrders(date: date, selectionMode: selectionMode, doctorId: doctorId)
        var occupied = [(Date, Date)]()
        for order in orders {
            let start = order.date.dateValue()
            let end = order.end.dateValue()

            let tuple = (start, end)
            occupied.append(tuple)
        }
        return occupied
    }

    
//    func getDayOrderTimes(date: Date, doctorId: String?) async throws -> [(Date, Date)] {
//        let orders = try await getDayOrders(date: date, doctorId: doctorId)
//        var occupied = [(Date, Date)]()
//        for order in orders {
//            let start = order.date.dateValue()
//            let end = order.end.dateValue()
//
//            let tuple = (start, end)
//            occupied.append(tuple)
//        }
//        return occupied
//    }
}
