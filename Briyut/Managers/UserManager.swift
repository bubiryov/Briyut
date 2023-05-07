//
//  UserManager.swift
//  Briyut
//
//  Created by Egor Bubiryov on 05.05.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }

    func createNewUser(user: DBUser) async throws {
        do {
            try userDocument(userId: user.userId).setData(from: user, merge: false)
        } catch let error {
            print(error)
            return
        }
    }

    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }

    
}
