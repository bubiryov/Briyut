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
    private let doctorCollection = Firestore.firestore().collection("doctors")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    private func doctorDocument(doctorID: String) -> DocumentReference {
        doctorCollection.document(doctorID)
    }
    
    func createNewUser(user: DBUser) async throws {
        do {
            try userDocument(userId: user.userId).setData(from: user, merge: false)
        } catch let error {
            print(error)
            return
        }
    }
    
    func deleteUser(userId: String) async throws {
        try await userDocument(userId: userId).delete()
    }
    
    func getAllUsers() async throws -> [DBUser] {
        try await userCollection
            .whereField(DBUser.CodingKeys.isDoctor.rawValue, isEqualTo: false)
            .getDocuments(as: DBUser.self)
    }
    
    @discardableResult
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
    func editProfile(userID: String, name: String?, lastName: String?, phoneNumber: String?, photoURL: String?, customSchedule: Bool?, scheduleTimes: [String: String]?, vacation: Bool?, vacationDates: [Timestamp]?) async throws {
        let data: [String : Any] = [
            DBUser.CodingKeys.name.rawValue : name as Any,
            DBUser.CodingKeys.lastName.rawValue : lastName as Any,
            DBUser.CodingKeys.phoneNumber.rawValue : phoneNumber as Any,
            DBUser.CodingKeys.photoUrl.rawValue : photoURL as Any,
            DBUser.CodingKeys.customSchedule.rawValue : customSchedule as Any,
            DBUser.CodingKeys.scheduleTimes.rawValue : scheduleTimes as Any,
            DBUser.CodingKeys.vacation.rawValue : vacation as Any,
            DBUser.CodingKeys.vacationDates.rawValue : vacationDates as Any
        ]
        try await userDocument(userId: userID).updateData(data)
    }
    
    func updateDoctorStatus(userID: String, isDoctor: Bool) async throws {
        var data: [String: Any] = [
            DBUser.CodingKeys.isDoctor.rawValue: isDoctor
        ]
        
        if !isDoctor {
            data[DBUser.CodingKeys.customSchedule.rawValue] = nil
            data[DBUser.CodingKeys.scheduleTimes.rawValue] = nil
            data[DBUser.CodingKeys.vacation.rawValue] = nil
            data[DBUser.CodingKeys.vacationDates.rawValue] = nil
        }
        
        try await userDocument(userId: userID).updateData(data)
    }

    
//    func updateDoctorStatus(userID: String, isDoctor: Bool) async throws {
//        let data: [String : Any] = [
//            DBUser.CodingKeys.isDoctor.rawValue : isDoctor,
//            DBUser.CodingKeys.customSchedule.rawValue : Optional<Any>.none!,
//            DBUser.CodingKeys.scheduleTimes.rawValue : Optional<Any>.none!,
//            DBUser.CodingKeys.vacation.rawValue : Optional<Any>.none!,
//            DBUser.CodingKeys.vacationDates.rawValue : Optional<Any>.none!,
//        ]
//        try await userDocument(userId: userID).updateData(data)
//    }
    
    func updateBlockStatus(userID: String, isBlocked: Bool) async throws {
        let data: [String : Any] = [
            DBUser.CodingKeys.isBlocked.rawValue : isBlocked
        ]
        try await userDocument(userId: userID).updateData(data)
    }
    
    func makeDoctor(userID: String) async throws {
        try await updateDoctorStatus(userID: userID, isDoctor: true)
        try await doctorDocument(doctorID: userID).setData(["id" : userID])
    }
    
    func removeDoctor(userID: String) async throws {
        try await updateDoctorStatus(userID: userID, isDoctor: false)
        try await doctorDocument(doctorID: userID).delete()
    }
    
    func checkIfUserExists(userId: String) async throws -> Bool {
        let document = userDocument(userId: userId)
        let documentSnapshot = try await document.getDocument()
        return documentSnapshot.exists
    }
        
    func getAllDoctors() async throws -> [DBUser] {
        let querySnapshot = try await doctorCollection.getDocuments()
        let doctorIds = querySnapshot.documents.map { $0.documentID }
        var doctors: [DBUser] = []
        for id in doctorIds {
            let doctor = try await getUser(userId: id)
            doctors.append(doctor)
        }
        return doctors
    }
}
