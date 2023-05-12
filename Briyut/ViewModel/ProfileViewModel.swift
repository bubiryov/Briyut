//
//  ProfileViewModel.swift
//  Briyut
//
//  Created by Egor Bubiryov on 08.05.2023.
//

import Foundation
import FirebaseFirestore

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
        self.doctors = try await UserManager.shared.getAllDoctors()
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
//        guard try await !ProcedureManager.shared.checkIfProcedureExists(procedureId: procedure.procedureId) else {
//            throw URLError(.badServerResponse)
//        }
        try await ProcedureManager.shared.createNewProcedure(procedure: procedure)
    }
    
    func getProcedures() async throws {
        let (newProducts, lastDocument) = try await ProcedureManager.shared.getAllProcedures(countLimit: 10, lastDocument: lastDocument)
        self.procedures.append(contentsOf: newProducts)
        if let lastDocument {
            self.lastDocument = lastDocument
        }
        print("Gotten!!!")
    }
    
}
