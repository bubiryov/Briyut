//
//  LocationManager.swift
//  Briyut
//
//  Created by Egor Bubiryov on 17.06.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class LocationManager {
    
    static let shared = LocationManager()
    
    private init() { }
    
    private let locationCollection = Firestore.firestore().collection("locations")
    
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
}
