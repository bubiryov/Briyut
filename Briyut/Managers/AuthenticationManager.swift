//
//  AuthenticationManager.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import Foundation
import FirebaseAuth

final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init() { }
    
    @discardableResult
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func getProvider() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        
        var providers: [AuthProviderOption] = []
        
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        return providers
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { throw URLError(.badServerResponse) }
        do {
            try await user.delete()
            print("Auth user is deleted")
        } catch {
            print("Auth user was not deleted")
        }
    }

}

// MARK: Email functions

extension AuthenticationManager {
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }

    @discardableResult
    func signIn(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }

    func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            print("Sent")
        } catch {
            print("Error")
        }
    }
    
    func changePassword(currentPassword: String, newPassword: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        guard let userEmail = user.email else { throw URLError(.badServerResponse) }

        let credential = EmailAuthProvider.credential(withEmail: userEmail, password: currentPassword)

        do {
            try await user.reauthenticate(with: credential)
            try await user.updatePassword(to: newPassword)
        } catch {
            throw error
        }
    }
}

// MARK: Phone number functions

extension AuthenticationManager {
    func sendCode(_ phoneNumber: String) async throws -> String {
        do {
            let id = try await PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil)
            return id
        } catch {
            print("Error verifying phone number: \(error.localizedDescription)")
            throw error
        }
    }
    
    @discardableResult
    func verifyCode(ID: String, code: String) async throws -> (AuthDataResultModel, String?) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: ID, verificationCode: code)
        let authDataResult = try await Auth.auth().signIn(with: credential)
        let number = Auth.auth().currentUser?.phoneNumber
        return (AuthDataResultModel(user: authDataResult.user), number)
    }
}

// MARK: Google functions

extension AuthenticationManager {
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}

// MARK: Apple functions

extension AuthenticationManager {
    
    @discardableResult
    func signInWithApple(tokens: AppleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(
            withProviderID: AuthProviderOption.apple.rawValue,
            idToken: tokens.token,
            rawNonce: tokens.nonce)
        return try await signIn(credential: credential)
    }
}
