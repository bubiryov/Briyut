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
    let latitude: Double
    let longitude: Double
    let address: String
    
    static func == (lhs: LocationModel, rhs: LocationModel) -> Bool {
        lhs.id == rhs.id
    }
    
    init(id: String, latitude: Double, longitude: Double, address: String) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "location_id"
        case latitude = "latitude"
        case longitude = "longitude"
        case address = "address"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.latitude, forKey: .latitude)
        try container.encode(self.longitude, forKey: .longitude)
        try container.encode(self.address, forKey: .address)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        self.address = try container.decode(String.self, forKey: .address)
    }
}

//extension CLLocationCoordinate2D: Codable {
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.unkeyedContainer()
//        try container.encode(longitude)
//        try container.encode(latitude)
//    }
//     
//    public init(from decoder: Decoder) throws {
//        var container = try decoder.unkeyedContainer()
//        let longitude = try container.decode(CLLocationDegrees.self)
//        let latitude = try container.decode(CLLocationDegrees.self)
//        self.init(latitude: latitude, longitude: longitude)
//    }
//}
