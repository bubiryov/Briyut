//
//  AuthDataResultModel.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let isVerified: Bool?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.isVerified = user.isEmailVerified
    }
}
