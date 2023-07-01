//
//  DBUser.swift
//  Briyut
//
//  Created by Egor Bubiryov on 05.05.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBUser: Codable, Equatable, Comparable {
    let userId: String
    let name: String?
    let lastName: String?
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
    let isDoctor: Bool
    let phoneNumber: String?
    let isBlocked: Bool?
    let customSchedule: Bool?
    let scheduleTimes: [String: String]?
    let vacation: Bool?
    let vacationDates: [Timestamp]?
    
    static func < (lhs: DBUser, rhs: DBUser) -> Bool {
        if let lhsName = lhs.name, let rhsName = rhs.name {
            return lhsName < rhsName
        }
        return lhs.name != nil
    }
    
    init(auth: AuthDataResultModel, name: String?, lastName: String?, dateCreated: Date?, isDoctor: Bool, phoneNumber: String?, isBlocked: Bool?, customSchedule: Bool?, scheduleTimes: [String: String]?, vacation: Bool?, vacationDates: [Timestamp]?) {
        self.userId = auth.uid
        self.name = name
        self.lastName = lastName
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = dateCreated
        self.isDoctor = isDoctor
        self.phoneNumber = phoneNumber
        self.isBlocked = isBlocked
        self.customSchedule = customSchedule
        self.scheduleTimes = scheduleTimes
        self.vacation = vacation
        self.vacationDates = vacationDates
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name = "name"
        case lastName = "last_name"
        case email = "email"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
        case isDoctor = "is_doctor"
        case phoneNumber = "phone_number"
        case isBlocked = "is_blocked"
        case customSchedule = "custom_schedule"
        case scheduleTimes = "schedule_times"
        case vacation = "vacation"
        case vacationDates = "vacation_dates"
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
        try container.encodeIfPresent(self.isBlocked, forKey: .isBlocked)
        try container.encodeIfPresent(self.customSchedule, forKey: .customSchedule)
        try container.encodeIfPresent(self.scheduleTimes, forKey: .scheduleTimes)
        try container.encodeIfPresent(self.vacation, forKey: .vacation)
        try container.encodeIfPresent(self.vacationDates, forKey: .vacationDates)
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
        self.isBlocked = try container.decodeIfPresent(Bool.self, forKey: .isBlocked) ?? false
        self.customSchedule = try container.decodeIfPresent(Bool.self, forKey: .customSchedule) ?? false
        self.scheduleTimes = try container.decodeIfPresent([String: String].self, forKey: .scheduleTimes)
        self.vacation = try container.decodeIfPresent(Bool.self, forKey: .vacation) ?? false
        self.vacationDates = try container.decodeIfPresent([Timestamp].self, forKey: .vacationDates)
    }
}

extension DBUser: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
        hasher.combine(name)
        hasher.combine(lastName)
        hasher.combine(email)
        hasher.combine(photoUrl)
        hasher.combine(dateCreated)
        hasher.combine(isDoctor)
        hasher.combine(phoneNumber)
        hasher.combine(isBlocked)
        hasher.combine(customSchedule)
        hasher.combine(scheduleTimes)
        hasher.combine(vacation)
        hasher.combine(vacationDates)
    }
    
    static func ==(lhs: DBUser, rhs: DBUser) -> Bool {
        return lhs.userId == rhs.userId &&
            lhs.name == rhs.name &&
            lhs.lastName == rhs.lastName &&
            lhs.email == rhs.email &&
            lhs.photoUrl == rhs.photoUrl &&
            lhs.dateCreated == rhs.dateCreated &&
            lhs.isDoctor == rhs.isDoctor &&
            lhs.phoneNumber == rhs.phoneNumber &&
            lhs.isBlocked == rhs.isBlocked &&
            lhs.customSchedule == rhs.customSchedule &&
            lhs.scheduleTimes == rhs.scheduleTimes &&
            lhs.vacation == rhs.vacation &&
            lhs.vacationDates == rhs.vacationDates
    }
}


//extension DBUser: Hashable {
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(userId)
//        hasher.combine(name)
//        hasher.combine(lastName)
//        hasher.combine(email)
//        hasher.combine(photoUrl)
//        hasher.combine(dateCreated)
//        hasher.combine(isDoctor)
//        hasher.combine(phoneNumber)
//        hasher.combine(isBlocked)
//    }
//
//    static func ==(lhs: DBUser, rhs: DBUser) -> Bool {
//        return lhs.userId == rhs.userId &&
//        lhs.name == rhs.name &&
//        lhs.lastName == rhs.lastName &&
//        lhs.email == rhs.email &&
//        lhs.photoUrl == rhs.photoUrl &&
//        lhs.dateCreated == rhs.dateCreated &&
//        lhs.isDoctor == rhs.isDoctor &&
//        lhs.phoneNumber == rhs.phoneNumber &&
//        lhs.isBlocked == rhs.isBlocked
//    }
//}

