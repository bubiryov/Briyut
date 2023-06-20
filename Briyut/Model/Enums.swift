//
//  Enums.swift
//  Briyut
//
//  Created by Egor Bubiryov on 20.06.2023.
//

import Foundation

enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
    case phone = "phone"
}

enum Tab: String, CaseIterable {
    case home = "house"
    case plus = "plus.square"
    case calendar = "calendar"
    case profile = "profile"
}

enum DatePickerMode {
    case days
    case months
}

enum UserStatus {
    case client
    case doctor
}

enum DoctorOption: Hashable {
    case allDoctors
    case user(DBUser)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .allDoctors:
            hasher.combine(0)
        case .user(let user):
            hasher.combine(1)
            hasher.combine(user)
        }
    }
}

enum DateSelectionMode {
    case day
    case month
}

enum DataFetchMode {
    case all
    case user
}

enum ChartCardPurpose: String {
    case earnings = "Earnings"
    case appointments = "Appointments"
}

enum IDType {
    case client
    case doctor
    case procedure
}

enum Mariupol: String {
    case regular = "Mariupol-Regular"
    case medium = "Mariupol-Medium"
    case bold = "Mariupol-Bold"
}

