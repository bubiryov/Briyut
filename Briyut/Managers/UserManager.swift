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
    
    @discardableResult
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
    func editProfile(userID: String, name: String?, lastName: String?, phoneNumber: String?) async throws {
        let data: [String : Any] = [
            DBUser.CodingKeys.name.rawValue : name as Any,
            DBUser.CodingKeys.lastName.rawValue : lastName as Any,
            DBUser.CodingKeys.phoneNumber.rawValue : phoneNumber as Any
        ]
        try await userDocument(userId: userID).updateData(data)
    }
    
    func updateDoctorStatus(userID: String, isDoctor: Bool) async throws {
        let data: [String : Any] = [
            DBUser.CodingKeys.isDoctor.rawValue : isDoctor
        ]
        try await userDocument(userId: userID).updateData(data)
    }

    func makeDoctor(userID: String) async throws {
        try await updateDoctorStatus(userID: userID, isDoctor: true)
        try await doctorDocument(doctorID: userID).setData(["id" : userID])
//        try await Firestore.firestore().collection("doctors").document(userID).setData(["id" : userID])
    }
    
    func removeDoctor(userID: String) async throws {
        try await updateDoctorStatus(userID: userID, isDoctor: false)
        try await doctorDocument(doctorID: userID).delete()
        let query = Firestore.firestore().collection("procedures").whereField("available_doctors", arrayContains: userID)
        
        let snapshot = try await query.getDocuments(as: ProcedureModel.self)
        for procedure in snapshot {
            let procedureDocument = Firestore.firestore().collection("procedures").document(procedure.procedureId)
            try await procedureDocument.updateData(["available_doctors": FieldValue.arrayRemove([userID])])
        }
//        query.getDocuments { (snapshot, error) in
//            if let error {
//                print("Error getting documents: \(error)")
//            } else {
//                for document in snapshot!.documents {
//                    let docRef = Firestore.firestore().collection("procedures").document(document.documentID)
//                    docRef.updateData(["available_doctors": FieldValue.arrayRemove([userID])])
//                }
//            }
//        }
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
