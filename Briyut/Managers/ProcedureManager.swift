//
//  ProcedureManager.swift
//  Briyut
//
//  Created by Egor Bubiryov on 09.05.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class ProcedureManager {
    
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
        try procedureDocument(procedureId: String(procedure.procedureId))
            .setData(from: procedure, merge: false)
    }
    
    private func getAllProcedures() -> Query {
        proceduresCollection
    }

    func getAllProcedures(countLimit: Int, lastDocument: DocumentSnapshot?) async throws -> (procedures: [ProcedureModel], lastDocument: DocumentSnapshot?) {
        
        let query: Query = getAllProcedures()
                
        if let lastDocument {
            return try await query
                .limit(to: countLimit)
                .start(afterDocument: lastDocument)
                .getDocumentsWithSnapshot(as: ProcedureModel.self)
        } else {
            return try await query
                .limit(to: countLimit)
                .getDocumentsWithSnapshot(as: ProcedureModel.self)
        }
    }
    
//    func checkIfProcedureExists(procedureId: Int) async throws -> Bool {
//        let document = procedureDocument(procedureId: String(procedureId))
//        let snapshot = try await document.getDocument()
//        return snapshot.exists
//    }
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

