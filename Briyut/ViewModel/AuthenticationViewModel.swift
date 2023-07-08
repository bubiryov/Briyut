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
    @Published var ID: String? = ""

    let userManager: UserManagerProtocol
    let authenticationManager: AuthenticationManagerProtocol
    
    init() {
        self.userManager = UserManager.shared
        self.authenticationManager = AuthenticationManager.shared
    }
        
    func getAuthUser() {
        self.authUser = try? authenticationManager.getAuthenticatedUser()
    }
}

// MARK: Email functions

extension AuthenticationViewModel {
    
    func validate(email: String, password: String?, repeatPassword: String?) -> Bool {
        return validateEmail(email) && validatePassword(password, repeatPassword: repeatPassword)
    }

    func validateEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        guard
            !email.isEmpty,
            email.lowercased() == email,
            emailPredicate.evaluate(with: email),
            email.filter({ $0 == "." }).count == 1 else {
            return false
        }
        
        return true
    }

    func validatePassword(_ password: String?, repeatPassword: String?) -> Bool {
        if let password = password {
            guard password.count > 5, password.contains(where: { $0.isLetter }), password.contains(where: { $0.isNumber }) else {
                return false
            }
        }
        
        if let repeatPassword = repeatPassword {
            guard repeatPassword == password else {
                return false
            }
        }
        
        return true
    }

    func logInWithEmail() async throws {
        do {
            try await authenticationManager.signIn(email: email, password: password)
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
            let authDataResult = try await authenticationManager.createUser(email: email, password: password)
            let user = DBUser(auth: authDataResult, name: nil, lastName: nil, dateCreated: Date(), isDoctor: false, phoneNumber: nil, isBlocked: false, customSchedule: nil, scheduleTimes: nil, vacation: nil, vacationDates: nil)
            try await userManager.createNewUser(user: user)
            email = ""
            password = ""
        } catch let error {
            print(error.localizedDescription)
            throw error
        }
    }
    
    func resetPassword() async throws {
        try await authenticationManager.resetPassword(email: email)
    }
    
    func changePassword(currentPassword: String, newPassword: String) async throws {
        guard validatePassword(newPassword, repeatPassword: newPassword) else { throw URLError(.badServerResponse) }
        try await authenticationManager.changePassword(currentPassword: currentPassword, newPassword: newPassword)
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
                let id = try await authenticationManager.sendCode(validateNumber)
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
                let (authDataResult, phoneNumber) = try await authenticationManager.verifyCode(ID: ID, code: code)
                do {
                    try await userManager.getUser(userId: authDataResult.uid)
                } catch {
                    let user = DBUser(auth: authDataResult, name: nil, lastName: nil, dateCreated: Date(), isDoctor: false, phoneNumber: phoneNumber, isBlocked: false, customSchedule: nil, scheduleTimes: nil, vacation: nil, vacationDates: nil)
                    try await userManager.createNewUser(user: user)
                    errorText = nil
                }
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
        let authDataResult = try await googleManager.signInGoogle()
        do {
            try await userManager.getUser(userId: authDataResult.uid)
        } catch {
            let user = DBUser(auth: authDataResult, name: nil, lastName: nil, dateCreated: Date(), isDoctor: false, phoneNumber: nil, isBlocked: false, customSchedule: nil, scheduleTimes: nil, vacation: nil, vacationDates: nil)
            try await userManager.createNewUser(user: user)
        }
    }
}

// MARK: Apple functions

extension AuthenticationViewModel {
            
    func singInWithApple() async throws {
        let appleManager = AppleAuthenticationManager()
        let tokens = try await appleManager.startSignInWithAppleFlow()
        let authDataResult = try await authenticationManager.signInWithApple(tokens: tokens)
        let user = DBUser(auth: authDataResult, name: nil, lastName: nil, dateCreated: Date(), isDoctor: false, phoneNumber: nil, isBlocked: false, customSchedule: nil, scheduleTimes: nil, vacation: nil, vacationDates: nil)
        try await userManager.createNewUser(user: user)
    }
}

