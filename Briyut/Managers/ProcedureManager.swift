//
//  ProcedureManager.swift
//  Briyut
//
//  Created by Egor Bubiryov on 09.05.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

protocol ProcedureManagerProtocol {
    func getProduct(procedureId: String) async throws -> ProcedureModel
    func createNewProcedure(procedure: ProcedureModel) async throws
    func getAllProcedures() async throws -> [ProcedureModel]
    func editProcedure(procedureId: String, name: String, duration: Int, cost: Int, parallelQuantity: Int, availableDoctors: [String]) async throws
    func removeProcedure(procedureId: String) async throws
    func updateProceduresForDoctor(userID: String) async throws
}

final class ProcedureManager: ProcedureManagerProtocol {
    
    static let shared = ProcedureManager()
    private init() { }
    
    private let proceduresCollection = Firestore.firestore().collection("procedures")
    
    private func procedureDocument(procedureId: String) -> DocumentReference {
        proceduresCollection.document(procedureId)
    }
    
    func getProduct(procedureId: String) async throws -> ProcedureModel {
        try await procedureDocument(procedureId: procedureId).getDocument(as: ProcedureModel.self)
    }
        
    func createNewProcedure(procedure: ProcedureModel) async throws {
        try procedureDocument(procedureId: procedure.procedureId)
            .setData(from: procedure, merge: false)
    }
    
    func getAllProcedures() async throws -> [ProcedureModel] {
        let query = proceduresCollection
        return try await query
            .getDocuments(as: ProcedureModel.self)
    }
                
    func editProcedure(procedureId: String, name: String, duration: Int, cost: Int, parallelQuantity: Int, availableDoctors: [String]) async throws {
        let data: [String : Any] = [
            ProcedureModel.CodingKeys.name.rawValue : name,
            ProcedureModel.CodingKeys.duration.rawValue : duration,
            ProcedureModel.CodingKeys.cost.rawValue : cost,
            ProcedureModel.CodingKeys.parallelQuantity.rawValue : parallelQuantity,
            ProcedureModel.CodingKeys.availableDoctors.rawValue : availableDoctors
        ]
        try await procedureDocument(procedureId: procedureId).updateData(data)
    }
    
    func removeProcedure(procedureId: String) async throws {
        try await procedureDocument(procedureId: procedureId).delete()
    }
    
    func updateProceduresForDoctor(userID: String) async throws {
        let proceduresQuery = proceduresCollection.whereField("available_doctors", arrayContains: userID)
        
        let proceduresSnapshot = try await proceduresQuery.getDocuments(as: ProcedureModel.self)
        
        for procedure in proceduresSnapshot {
            let procedureDocument = proceduresCollection.document(procedure.procedureId)
            try await procedureDocument.updateData(["available_doctors": FieldValue.arrayRemove([userID])])
        }
    }
}

extension Query {
    func getDocuments<T: Decodable>(as: T.Type) async throws -> [T] {
        let snapshot = try await self.getDocuments()
        
        return try snapshot.documents.map { document in
            return try document.data(as: T.self)
        }
    }

    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> ([T], DocumentSnapshot?) where T : Decodable {
        let snapshot = try await self.getDocuments()

        let products = try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
        return (products, snapshot.documents.last)
    }
}

