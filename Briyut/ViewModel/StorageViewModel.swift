//
//  StorageViewModel.swift
//  Briyut
//
//  Created by Egor Bubiryov on 08.07.2023.
//

import Foundation

@MainActor
class StorageViewModel {
    
    let storageManager: StorageManagerProtocol
    
    init(storageManager: StorageManagerProtocol) {
        self.storageManager = storageManager
    }
    
    func deleteStorageFolderContents(documentId: String, childStorage: String) async throws {
        try await storageManager.deleteFolderContents(documentId: documentId, childStorage: childStorage)
    }
    
    func saveImage(data: Data, childStorage: String, documentId: String, contentTypes: [String]) async throws -> String {
        try await storageManager.saveImage(data: data, childStorage: childStorage, documentId: documentId, contentTypes: contentTypes)
    }
    
    func deletePreviousPhoto(url: String) async throws {
        try await storageManager.deletePreviousPhoto(url: url)
    }
    
    func getUrlForImage(path: String) async throws -> String {
        try await storageManager.getUrlForImage(path: path)
    }
}
