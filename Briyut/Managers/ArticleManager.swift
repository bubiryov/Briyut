//
//  ArticleManager.swift
//  Briyut
//
//  Created by Egor Bubiryov on 23.06.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol ArticleManagerProtocol {
    func createNewArticle(article: ArticleModel) async throws
    func removeArticle(article_id: String) async throws
    func getRequiredArticles(countLimit: Int?, lastDocument: DocumentSnapshot?) async throws -> (orders: [ArticleModel], lastDocument: DocumentSnapshot?)
}

final class ArticleManager: ArticleManagerProtocol {
    
    static let shared = ArticleManager()
    
    private init() { }
    
    private let articleCollection = Firestore.firestore().collection("articles")
    
    private func articleDocument(article_id: String) -> DocumentReference {
        articleCollection.document(article_id)
    }
    
    func createNewArticle(article: ArticleModel) async throws {
        try articleDocument(article_id: article.id)
            .setData(from: article, merge: false)
    }

    func removeArticle(article_id: String) async throws {
        try await articleDocument(article_id: article_id).delete()
    }
    
    func getRequiredArticles(countLimit: Int?, lastDocument: DocumentSnapshot?) async throws -> (orders: [ArticleModel], lastDocument: DocumentSnapshot?) {

        let query = articleCollection.order(by: ArticleModel.CodingKeys.dateCreated.rawValue, descending: true)

        if let countLimit {
            if let lastDocument {
                return try await query
                    .limit(to: countLimit)
                    .start(afterDocument: lastDocument)
                    .getDocumentsWithSnapshot(as: ArticleModel.self)
            } else {
                return try await query
                    .limit(to: countLimit)
                    .getDocumentsWithSnapshot(as: ArticleModel.self)
            }
        } else {
            return try await query
                .getDocumentsWithSnapshot(as: ArticleModel.self)
        }
    }

    
//    func editArticle(article_id: String, tittle: String, body: String, pictureUrl: String?, photoUrl: String?) async throws {
//        let data: [String : Any] = [
//            ArticleModel.CodingKeys.tittle.rawValue : tittle,
//            ArticleModel.CodingKeys.body.rawValue : body,
//            ArticleModel.CodingKeys.pictureUrl.rawValue : pictureUrl as Any,
//            ArticleModel.CodingKeys.pictureUrl.rawValue : pictureUrl as Any
//        ]
//        try await articleDocument(article_id: article_id).updateData(data)
//    }

}
