//
//  ArticleModel.swift
//  Briyut
//
//  Created by Egor Bubiryov on 23.06.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ArticleModel: Codable, Equatable {
    let id: String
    let title: String
    let body: String
    let dateCreated: Timestamp
    let pictureUrl: String?
//    let procedureId: String?
    
    init(id: String, title: String, body: String, dateCreated: Timestamp, pictureUrl: String?) {
        self.id = id
        self.title = title
        self.body = body
        self.dateCreated = dateCreated
        self.pictureUrl = pictureUrl
//        self.procedureId = procedureId
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "article_id"
        case title = "title"
        case body = "body"
        case dateCreated = "date_created"
        case pictureUrl = "picture_url"
//        case procedureId = "procedure_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.body, forKey: .body)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.pictureUrl, forKey: .pictureUrl)
//        try container.encodeIfPresent(self.procedureId, forKey: .procedureId)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.body = try container.decode(String.self, forKey: .body)
        self.dateCreated = try container.decode(Timestamp.self, forKey: .dateCreated)
        self.pictureUrl = try container.decodeIfPresent(String.self, forKey: .pictureUrl)
//        self.procedureId = try container.decodeIfPresent(String.self, forKey: .procedureId)
    }
}
