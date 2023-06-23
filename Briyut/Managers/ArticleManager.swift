//
//  ArticleManager.swift
//  Briyut
//
//  Created by Egor Bubiryov on 23.06.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class ArticleManager {
    
    static let shared = ArticleManager()
    
    private init() { }
    
    private let locationCollection = Firestore.firestore().collection("articles")
    
    private func locationDocument(locationId: String) -> DocumentReference {
        locationCollection.document(locationId)
    }
    
    func getProduct(locationId: String) async throws -> LocationModel {
        try await locationDocument(locationId: locationId).getDocument(as: LocationModel.self)
    }
    
    func getAllLocations() async throws -> [LocationModel] {
        try await locationCollection.getDocuments(as: LocationModel.self)
    }
    
    func createNewLocation(location: LocationModel) async throws {
        try locationDocument(locationId: location.id)
            .setData(from: location, merge: false)
    }

    func removeLocation(locationId: String) async throws {
        try await locationDocument(locationId: locationId).delete()
    }
    
    func editLocation(locationId: String, latitude: Double, longitude: Double, address: String) async throws {
        let data: [String : Any] = [
            LocationModel.CodingKeys.latitude.rawValue : latitude,
            LocationModel.CodingKeys.longitude.rawValue : longitude,
            LocationModel.CodingKeys.address.rawValue : address
        ]
        try await locationDocument(locationId: locationId).updateData(data)
    }

}
