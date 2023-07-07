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
class ProfileViewModel {
    
    let data: InterfaceData
    let procedureViewModel: ProcedureViewModel
    let orderViewModel: OrderViewModel
    
    init(data: InterfaceData, procedureViewModel: ProcedureViewModel, orderViewModel: OrderViewModel) {
        self.data = data
        self.procedureViewModel = procedureViewModel
        self.orderViewModel = orderViewModel
    }
    
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        data.user = try await getUser(userId: authDataResult.uid)
    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await UserManager.shared.getUser(userId: userId)
    }
    
    func getAllUsers() async throws {
        data.users = try await UserManager.shared.getAllUsers()
    }
    
    func getProvider() {
        if let providers = try? AuthenticationManager.shared.getProvider() {
            data.authProviders = providers
        }
    }
            
    func signOut() throws {
        do {
            try AuthenticationManager.shared.signOut()
        } catch  {
            print("Log out error: \(error)")
        }
    }
    
    func deleteStorageFolderContents(documentId: String, childStorage: String) async throws {
        try await StorageManager.shared.deleteFolderContents(documentId: documentId, childStorage: childStorage)
    }
    
    func deleteAccount() async throws {
        guard let user = data.user else { throw URLError(.badServerResponse) }
        try await orderViewModel.deleteUnfinishedOrders(idType: .client, id: user.userId)
        try await UserManager.shared.deleteUser(userId: user.userId)
        try await deleteStorageFolderContents(documentId: user.userId, childStorage: "users")
        try await AuthenticationManager.shared.deleteAccount()
        data.user = nil
    }
    
    func updateBlockStatus(userID: String, isBlocked: Bool) async throws {
        try await UserManager.shared.updateBlockStatus(userID: userID, isBlocked: isBlocked)
        if isBlocked {
            try await orderViewModel.deleteUnfinishedOrders(idType: .client, id: userID)
        }
        data.activeLastDocument = nil
        data.activeOrders = []
        try await orderViewModel.getRequiredOrders(dataFetchMode: .user, isDone: false, countLimit: 2)
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
        guard userID != data.user?.userId else { return }
        try await UserManager.shared.removeDoctor(userID: userID)
        try await orderViewModel.deleteUnfinishedOrders(idType: .doctor, id: userID)
        try await procedureViewModel.updateProceduresForDoctor(userID: userID)
        try await getAllDoctors()
    }
    
    func getAllDoctors() async throws {
        data.doctors = try await UserManager.shared.getAllDoctors()
    }
    
    func editProfile(userID: String, name: String?, lastName: String?, phoneNumber: String?, photoURL: String?, customSchedule: Bool?, scheduleTimes: [String: String]?, vacation: Bool?, vacationDates: [Timestamp]?) async throws {
        return try await UserManager.shared.editProfile(userID: userID, name: name, lastName: lastName, phoneNumber: phoneNumber, photoURL: photoURL, customSchedule: customSchedule, scheduleTimes: scheduleTimes, vacation: vacation, vacationDates: vacationDates)
    }
    
    func savePhoto(item: PhotosPickerItem, childStorage: String) async throws -> String {
        let contentTypes: [String] = ["image/jpeg", "image/png", "image/heif", "image/heic"]
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw URLError(.badServerResponse)
        }
        guard let user = self.data.user else {
            throw URLError(.badServerResponse)
        }
        return try await StorageManager.shared.saveImage(data: data, childStorage: childStorage, documentId: user.userId, contentTypes: contentTypes)
    }
    
    func deletePreviousPhoto(url: String) async throws {
        try await StorageManager.shared.deletePreviousPhoto(url: url)
    }
    
    func getUrlForImage(path: String) async throws -> String {
        return try await StorageManager.shared.getUrlForImage(path: path)
    }

}

