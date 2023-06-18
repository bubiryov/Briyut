//
//  StorageManager.swift
//  Briyut
//
//  Created by Egor Bubiryov on 25.05.2023.
//

import Foundation
import FirebaseStorage
import UIKit
import UniformTypeIdentifiers

final class StorageManager {
    static let shared = StorageManager()
    
    private init() {}
    
    private let storage = Storage.storage().reference()
        
    private func userReference(userId: String) -> StorageReference {
        storage.child("users").child(userId)
    }
    
    func saveImage(data: Data, userID: String, contentTypes: [String]) async throws -> String {
        let meta = StorageMetadata()
        meta.contentType = contentTypes.first // Устанавливаем первый тип контента по умолчанию

        let fileExtension: String
        if let firstContentType = contentTypes.first,
           let firstExtension = UTType(filenameExtension: firstContentType)?.preferredFilenameExtension {
            fileExtension = firstExtension
        } else {
            fileExtension = "jpeg" // Если не удалось определить расширение, используем "jpeg" в качестве значения по умолчанию
        }
        
        let path = "\(UUID().uuidString).\(fileExtension)"
        
        let returnedMetaData = try await userReference(userId: userID).child(path).putDataAsync(data, metadata: meta)
        guard let returnedPath = returnedMetaData.path else {
            throw URLError(.badServerResponse)
        }
        
        return returnedPath
    }
    
    func deleteFolderContents(userId: String) async throws {
        let folderRef = userReference(userId: userId)
        
        do {
            try await deleteContentsOfReference(folderRef: folderRef)
            print("Folder contents deleted successfully")
        } catch {
            print("Failed to delete folder contents: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func deleteContentsOfReference(folderRef: StorageReference) async throws {
        let listResult = try await folderRef.listAll()
        
        for item in listResult.items {
            try await item.delete()
        }
        
        for prefix in listResult.prefixes {
            try await deleteContentsOfReference(folderRef: prefix)
        }
    }

    func deletePreviousPhoto(url: String) async throws {
        guard let path = getPathForURL(url: url) else { return }
        try await Storage.storage().reference(withPath: path).delete()
    }
        
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
