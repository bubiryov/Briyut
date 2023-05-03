//
//  ErrorsEnum.swift
//  Briyut
//
//  Created by Egor Bubiryov on 02.05.2023.
//

import Foundation

enum ErrorsEnum: String, Error {
    case invalidEmail = "There is no user record corresponding to this identifier. The user may have been deleted."
    case invalidPassword = "The password is invalid or the user does not have a password."
    case passwordsDoNotMatch = "Passwords do not match."
}
