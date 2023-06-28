//
//  ArticlesViewModel.swift
//  Briyut
//
//  Created by Egor Bubiryov on 23.06.2023.
//

import Foundation
import FirebaseFirestore
import PhotosUI
import SwiftUI

@MainActor
final class ArticlesViewModel: ObservableObject {
    
    @Published var articles: [ArticleModel] = []
    @Published var lastArticle: DocumentSnapshot? = nil
    
    deinit {
        print("Deinit")
    }
    
    func createNewArticle(article: ArticleModel) async throws {
        try await ArticleManager.shared.createNewArticle(article: article)
        articles = []
        lastArticle = nil
        try await getRequiredArticles(countLimit: 6)
    }
    
    func removeArticle(article_id: String) async throws {
        try await deleteStorageFolderContents(documentId: article_id, childStorage: "articles")
        try await ArticleManager.shared.removeArticle(article_id: article_id)
        articles = []
        lastArticle = nil
        try await getRequiredArticles(countLimit: 6)
    }
    
    func deleteStorageFolderContents(documentId: String, childStorage: String) async throws {
        try await StorageManager.shared.deleteFolderContents(documentId: documentId, childStorage: childStorage)
    }
    
    func getUrlForImage(path: String) async throws -> String {
        return try await StorageManager.shared.getUrlForImage(path: path)
    }
    
    func savePhoto(item: PhotosPickerItem, articleId: String, childStorage: String) async throws -> String {
        let contentTypes: [String] = ["image/jpeg", "image/png", "image/heif", "image/heic"]
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw URLError(.badServerResponse)
        }
        return try await StorageManager.shared.saveImage(data: data, childStorage: childStorage, documentId: articleId, contentTypes: contentTypes)
    }
    
    func getRequiredArticles(countLimit: Int?) async throws {
        let (articles, lastArticle) = try await ArticleManager.shared.getRequiredArticles(countLimit: countLimit, lastDocument: lastArticle)
        self.articles.append(contentsOf: articles)
        if let lastArticle {
            self.lastArticle = lastArticle
        }
    }
}
