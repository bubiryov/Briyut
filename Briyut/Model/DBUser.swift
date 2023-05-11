//
//  DBUser.swift
//  Briyut
//
//  Created by Egor Bubiryov on 05.05.2023.
//

import Foundation

struct DBUser: Codable {
    let userId: String
    let name: String?
    let lastName: String?
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
    let isDoctor: Bool
    let phoneNumber: String?

    init(auth: AuthDataResultModel, name: String?, lastName: String?, dateCreated: Date?, isDoctor: Bool, phoneNumber: String?) {
        self.userId = auth.uid
        self.name = name
        self.lastName = lastName
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = dateCreated
        self.isDoctor = isDoctor
        self.phoneNumber = phoneNumber
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name = "name"
        case lastName = "last_name"
        case email = "email"
        case photoUrl = "phoro_url"
        case dateCreated = "date_created"
        case isDoctor = "is_doctor"
        case phoneNumber = "phone_number"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.lastName, forKey: .lastName)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.isDoctor, forKey: .isDoctor)
        try container.encodeIfPresent(self.phoneNumber, forKey: .phoneNumber)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        self.isDoctor = try container.decodeIfPresent(Bool.self, forKey: .isDoctor) ?? false
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
    }
}
