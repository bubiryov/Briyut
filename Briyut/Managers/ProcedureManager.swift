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
        try procedureDocument(procedureId: procedure.procedureId)
            .setData(from: procedure, merge: false)
    }
    
//    func getAllProcedures() async throws -> [ProcedureModel] {
//
//        let query = proceduresCollection
//
//        return try await query
//            .getDocuments(as: ProcedureModel.self)
//    }
        
    func addListenerForProcedures(completion: @escaping (_ products: [ProcedureModel]) -> Void) {
        proceduresCollection.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                return
            }
            
            let procedures: [ProcedureModel] = documents.compactMap({ try? $0.data(as: ProcedureModel.self) })
            completion(procedures)
        }
    }
    
//    func addListenerForProcedures() -> AnyPublisher<[ProcedureModel], Error> {
//        return proceduresCollection
//            .addSnapshotListener(as: ProcedureModel.self)
//    }
    
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
        let orderQuery = Firestore.firestore().collection("orders").whereField("procedure_id", isEqualTo: procedureId)
        let ordersSnapshot = try await orderQuery.getDocuments(as: OrderModel.self)
        
        for order in ordersSnapshot {
            let orderDocument = Firestore.firestore().collection("orders").document(order.orderId)
            if !order.isDone {
                try await orderDocument.delete()
            }
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
    
//    func addSnapshotListener<T>(as type: T.Type) -> (AnyPublisher<[T], Error>) where T: Decodable {
//        let publisher = PassthroughSubject<[T], Error> ()
//        let listener = self.addSnapshotListener { querySnapshot, error in
//            guard let documents = querySnapshot?.documents else {
//                print("No documents")
//                return
//            }
//            let products: [T] = documents.compactMap({ try? $0.data(as: T.self) })
//            publisher.send(products)
//        }
//        return publisher.eraseToAnyPublisher()
//    }
}

