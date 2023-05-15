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
    var lastDocument: DocumentSnapshot? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
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

extension ProfileViewModel {
    
    func addNewProcedure(procedure: ProcedureModel) async throws {
        try await ProcedureManager.shared.createNewProcedure(procedure: procedure)
        try await getAllProcedures()
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
