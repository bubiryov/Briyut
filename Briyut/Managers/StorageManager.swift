//
//  StorageManager.swift
//  Briyut
//
//  Created by Egor Bubiryov on 25.05.2023.
//

import Foundation
import FirebaseStorage
import UIKit

final class StorageManager {
    static let shared = StorageManager()
    
    private init() {}
    
    private let storage = Storage.storage().reference()
        
    private func userReference(userId: String) -> StorageReference {
        storage.child("users").child(userId)
    }
    
    func saveImage(data: Data, userID: String) async throws -> String {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let path = "\(UUID().uuidString).jpeg"
        let returnedMetaData = try await userReference(userId: userID).child(path).putDataAsync(data, metadata: meta)
        guard let returnedPath = returnedMetaData.path else {
            throw URLError(.badServerResponse)
        }
        
        return returnedPath
    }
    
    func deletePreviousPhoto(url: String) async throws {
        guard let path = getPathForURL(url: url) else { return }
        try await Storage.storage().reference(withPath: path).delete()
    }
    
//    func saveImage(image: UIImage, userId: String) async throws -> (path: String, name: String) {
//        guard let data = image.jpegData(compressionQuality: 0.5) else {
//            throw URLError(.backgroundSessionWasDisconnected)
//        }
//        return try await saveImage(data: data, userID: userId)
//    }
    
    func getData(userId: String, path: String) async throws -> Data {
        try await userReference(userId: userId).child(path).data(maxSize: 3 * 1024 * 1024)
    }
    
    func getUrlForImage(path: String) async throws -> String {
        return try await Storage.storage().reference(withPath: path).downloadURL().absoluteString
    }
    
    func getPathForURL(url: String) -> String? {
        let reference = Storage.storage().reference(forURL: url)
        return reference.fullPath
    }

}
