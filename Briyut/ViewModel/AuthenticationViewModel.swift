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
    @Published var ID: String? = ""
    
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
    
    func validate(email: String, password: String?, repeatPassword: String?) -> Bool {
        
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
        guard
            !email.isEmpty,
            email.lowercased() == email,
            emailPredicate.evaluate(with: email),
            email.filter({$0 == "."}).count == 1 else {
            return false
        }

        if let password {
            guard password.count > 5, password.contains(where: { $0.isLetter }), password.contains(where: { $0.isNumber }) else {
                return false
            }
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
    
    func resetPassword() async throws {
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
}

// MARK: Phone number functions

extension AuthenticationViewModel {
    
    func validatePhoneNumber(_ phoneNumber: String) -> String? {
        
        let digitsOnly = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        var formattedPhone = digitsOnly
        if !formattedPhone.hasPrefix("38") {
            formattedPhone = "38" + formattedPhone
        }
        
        if !formattedPhone.hasPrefix("+") {
            formattedPhone = "+" + formattedPhone
        }
        
        if formattedPhone.count < 13 {
            return nil
        }
        
        return formattedPhone
    }

    
    func sendCode(_ phoneNumber: String) async throws {
        
        if let validateNumber = validatePhoneNumber(phoneNumber) {
            do {
                let id = try await AuthenticationManager.shared.sendCode(validateNumber)
                self.ID = id
                print("SMS sent")
            } catch let error {
                errorText = "Something went wrong. \n Try later."
                print("ID has not been gotten: \(error)")
                throw URLError(.badServerResponse)
            }
        } else {
            errorText = "Something went wrong. \n Try later."
            print("Validate number is nil")
            return
        }
    }
    
    func verifyCode(code: String) async throws {
        if let ID {
            do {
                try await AuthenticationManager.shared.verifyCode(ID: ID, code: code)
                notEntered = false
                errorText = nil
            } catch {
                errorText = "Something went wrong"
                Task {
                    try await Task.sleep(nanoseconds: 3_000_000_000)
                    errorText = nil
                }
                print("Error in do catch block verifyCode viewModel")
                throw URLError(.badServerResponse)
            }
        } else {
            print("ID is nil")
            return
        }
    }

}

// MARK: Google functions

extension AuthenticationViewModel {
    func singInWithGoogle() async throws {
        let googleManager = GoogleAuthenticationManager()
        do {
            let authDataResult = try await googleManager.signInGoogle()
//            let user = DBUser(auth: authDataResult)
//            try await UserManager.shared.createNewUser(user: user)
            notEntered = false
        } catch {
            print("Error: \(error)")
            return
        }
    }
}
