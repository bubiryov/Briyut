//
//  DBUser.swift
//  Briyut
//
//  Created by Egor Bubiryov on 05.05.2023.
//

import Foundation

//struct DBUser: Codable {
//    let userId: String
//    let name: String?
//    let email: String?
//    let photoUrl: String?
//    let dateCreated: Date?
//    let isDoctor: Bool?
////     Исправить тип!
//    let procedures: [Any]?
//
//    init(auth: AuthDataResultModel) {
//        self.userId = auth.uid
//        self.email = auth.email
//        self.dateCreated = Date()
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case userId = "user_id"
//        case isAnonymous = "is_anonymous"
//        case email = "email"
//        case photoUrl = "phoro_url"
//        case dateCreated = "date_created"
//        case isPremium = "is_premium"
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encodeIfPresent(self.userId, forKey: .userId)
//        try container.encodeIfPresent(self.isAnonymous, forKey: .isAnonymous)
//        try container.encodeIfPresent(self.email, forKey: .email)
//        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
//        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
//        try container.encodeIfPresent(self.isPremium, forKey: .isPremium)
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.userId = try container.decode(String.self, forKey: .userId)
//        self.isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
//        self.email = try container.decodeIfPresent(String.self, forKey: .email)
//        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
//        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
//        self.isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium)
//    }
//
//}
