//
//  GoogleAuthenticationManager.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.05.2023.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth

class GoogleAuthenticationManager {
    
    @MainActor
    func signInGoogle() async throws -> AuthDataResultModel {
        let tokens = try await getGoogleToken()
        return try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
    }
    
    @MainActor
    func getGoogleToken() async throws -> GoogleSignInResultModel {
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let accessToken = gidSignInResult.user.accessToken.tokenString
        return GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
    }
}

