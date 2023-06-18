//
//  CoordinateModel.swift
//  Briyut
//
//  Created by Egor Bubiryov on 17.06.2023.
//

import Foundation
import MapKit


struct LocationModel: Identifiable, Equatable, Codable {
    let id: String
    let coordinates: CLLocationCoordinate2D
    
    static func == (lhs: LocationModel, rhs: LocationModel) -> Bool {
        lhs.id == rhs.id
    }
    
    init(id: String, coordinates: CLLocationCoordinate2D) {
        self.id = id
        self.coordinates = coordinates
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "location_id"
        case coordinates = "coordinates"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.coordinates, forKey: .coordinates)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.coordinates = try container.decode(CLLocationCoordinate2D.self, forKey: .coordinates)
    }
}

extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(longitude)
        try container.encode(latitude)
    }
     
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let longitude = try container.decode(CLLocationDegrees.self)
        let latitude = try container.decode(CLLocationDegrees.self)
        self.init(latitude: latitude, longitude: longitude)
    }
}
