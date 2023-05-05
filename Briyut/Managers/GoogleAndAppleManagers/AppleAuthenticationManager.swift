//
//  AppleAuthenticationManager.swift
//  Briyut
//
//  Created by Egor Bubiryov on 04.05.2023.
//

import Foundation
import AuthenticationServices
import CryptoKit

@MainActor
class AppleAuthenticationManager: NSObject {
    
    private var currentNonce: String?
    private var completionHandler: ((Result<AppleSignInResultModel, Error>) -> Void)? = nil
    
    func startSignInWithAppleFlow() async throws -> AppleSignInResultModel {
        return try await withCheckedThrowingContinuation { continuation in
            let completion: (Result<AppleSignInResultModel, Error>) -> Void = { result in
                switch result {
                case .success(let model):
                    continuation.resume(returning: model)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            guard let topVC = Utilities.shared.topViewController() else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            let nonce = randomNonceString()
            currentNonce = nonce
            completionHandler = completion
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = topVC
            authorizationController.performRequests()
        }
    }
                        
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

@available(iOS 13.0, *)
extension AppleAuthenticationManager: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let nonce = currentNonce,
            let appleIDToken = appleIDCredential.identityToken,
            let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completionHandler?(.failure(URLError(.badServerResponse)))
            return
        }
        
        let result = AppleSignInResultModel(token: idTokenString, nonce: nonce)
        completionHandler?(.success(result))
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }
}

extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
