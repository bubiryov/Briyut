//
//  AuthenticationViewModel.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import Foundation
import SwiftUI

@MainActor
final class AuthenticationViewModel: ObservableObject {
        
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var authUser: AuthDataResultModel? = nil
    @Published var errorText: String? = nil
    @Published var notEntered = true
    
    func loadAuthUser() {
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
    }
    
    func signOut() throws {
        do {
            try AuthenticationManager.shared.signOut()
            withAnimation {
                notEntered = true
            }
        } catch  {
            print("Log out error: \(error)")
        }
    }
}

// MARK: Email functions

extension AuthenticationViewModel {
    
    func validate(email: String, password: String, repeatPassword: String?) -> Bool {
        guard email.lowercased() == email, email.contains("@"), email.contains(".") else {
            return false
        }
        guard password.count > 5, password.contains(where: { $0.isLetter }), password.contains(where: { $0.isNumber }) else {
            return false
        }
        if let repeatPassword {
            guard repeatPassword == password else {
                return false
            }
        }
        return true
    }

    func logInWithEmail() async throws {
        do {
            try await AuthenticationManager.shared.signIn(email: email, password: password)
            notEntered = false
            email = ""
            password = ""
            errorText = nil
        } catch let error {
            errorText = "Check the entered data"
            print(error.localizedDescription)
            password = ""
            Task {
                try await Task.sleep(nanoseconds: 3_000_000_000)
                errorText = nil
            }
            throw error
        }
    }
    
    func createUserWithEmail() async throws {
        do {
            let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
            notEntered = false
            email = ""
            password = ""
        } catch let error {
            print(error.localizedDescription)
            throw error
        }
    }

}
