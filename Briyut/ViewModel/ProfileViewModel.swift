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
    let storageViewModel: StorageViewModel

    let userManager: UserManagerProtocol
    let authenticationManager: AuthenticationManagerProtocol
    
    init(data: InterfaceData, procedureViewModel: ProcedureViewModel, orderViewModel: OrderViewModel, userManager: UserManagerProtocol, authenticationManager: AuthenticationManagerProtocol, storageManager: StorageManagerProtocol) {
        self.data = data
        self.procedureViewModel = procedureViewModel
        self.orderViewModel = orderViewModel
        self.userManager = userManager
        self.authenticationManager = authenticationManager
        self.storageViewModel = StorageViewModel(storageManager: storageManager)
    }
    
    func loadCurrentUser() async throws {
        let authDataResult = try authenticationManager.getAuthenticatedUser()
        data.user = try await getUser(userId: authDataResult.uid)
    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await userManager.getUser(userId: userId)
    }
    
    func getAllUsers() async throws {
        data.users = try await userManager.getAllUsers()
    }
    
    func getProvider() {
        if let providers = try? authenticationManager.getProvider() {
            data.authProviders = providers
        }
    }
            
    func signOut() throws {
        do {
            try authenticationManager.signOut()
        } catch  {
            print("Log out error: \(error)")
        }
    }
        
    func deleteAccount() async throws {
        guard let user = data.user else { throw URLError(.badServerResponse) }
        try await orderViewModel.deleteUnfinishedOrders(idType: .client, id: user.userId)
        try await userManager.deleteUser(userId: user.userId)
        try await storageViewModel.deleteStorageFolderContents(documentId: user.userId, childStorage: "users")
        try await authenticationManager.deleteAccount()
        data.user = nil
    }
    
    func updateBlockStatus(userID: String, isBlocked: Bool) async throws {
        try await userManager.updateBlockStatus(userID: userID, isBlocked: isBlocked)
        if isBlocked {
            try await orderViewModel.deleteUnfinishedOrders(idType: .client, id: userID)
        }
        data.activeLastDocument = nil
        data.activeOrders = []
        try await orderViewModel.getRequiredOrders(dataFetchMode: .user, isDone: false, countLimit: 2)
        try await getAllUsers()
    }
    
    func addDoctor(userID: String) async throws {
        guard try await userManager.checkIfUserExists(userId: userID) else {
            return
        }
        try await userManager.makeDoctor(userID: userID)
        try await getAllDoctors()
    }
    
    func removeDoctor(userID: String) async throws {
        guard userID != data.user?.userId else { return }
        try await userManager.removeDoctor(userID: userID)
        try await orderViewModel.deleteUnfinishedOrders(idType: .doctor, id: userID)
        try await procedureViewModel.updateProceduresForDoctor(userID: userID)
        try await getAllDoctors()
    }
    
    func getAllDoctors() async throws {
        data.doctors = try await userManager.getAllDoctors()
    }
    
    func editProfile(userID: String, name: String?, lastName: String?, phoneNumber: String?, photoURL: String?, customSchedule: Bool?, scheduleTimes: [String: String]?, vacation: Bool?, vacationDates: [Timestamp]?) async throws {
        return try await userManager.editProfile(userID: userID, name: name, lastName: lastName, phoneNumber: phoneNumber, photoURL: photoURL, customSchedule: customSchedule, scheduleTimes: scheduleTimes, vacation: vacation, vacationDates: vacationDates)
    }
    
    func savePhoto(item: PhotosPickerItem, childStorage: String) async throws -> String {
        let contentTypes: [String] = ["image/jpeg", "image/png", "image/heif", "image/heic"]
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw URLError(.badServerResponse)
        }
        guard let user = self.data.user else {
            throw URLError(.badServerResponse)
        }
        return try await storageViewModel.saveImage(data: data, childStorage: childStorage, documentId: user.userId, contentTypes: contentTypes)
    }
    
    func deletePreviousPhoto(url: String) async throws {
        try await storageViewModel.deletePreviousPhoto(url: url)
    }
    
    func getUrlForImage(path: String) async throws -> String {
        return try await storageViewModel.getUrlForImage(path: path)
    }
}

