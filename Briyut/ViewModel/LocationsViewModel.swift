//
//  LocationsViewModel.swift
//  Briyut
//
//  Created by Egor Bubiryov on 21.06.2023.
//

import Foundation
import SwiftUI
import MapKit

@MainActor
final class LocationsViewModel: ObservableObject {
    
    @Published var locations: [LocationModel] = []
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    @Published var mapLocation: LocationModel? = nil {
        didSet {
            updateMapRegion(location: mapLocation)
        }
    }
    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.02)
    
    init() {
        Task {
            do {
                try await getAllLocations()
                print("Location")
            } catch {
                print("Error")
            }
            if locations.count == 1 {
                mapLocation = locations.first
            }
            self.updateMapRegion(location: !locations.isEmpty ? locations.first! : nil)
        }
    }
    
    private func updateMapRegion(location: LocationModel?) {
        Task {
            withAnimation(.easeInOut) {
                var coordinateRegion: MKCoordinateRegion
                var center: CLLocationCoordinate2D
                var span: MKCoordinateSpan
                
                if !locations.isEmpty {
                    if locations.count > 1 {
                        // Найти минимальную область, охватывающую все локации
                        var minLat = locations[0].latitude
                        var maxLat = locations[0].latitude
                        var minLng = locations[0].longitude
                        var maxLng = locations[0].longitude
                        
                        for location in locations {
                            minLat = min(minLat, location.latitude)
                            maxLat = max(maxLat, location.latitude)
                            minLng = min(minLng, location.longitude)
                            maxLng = max(maxLng, location.longitude)
                        }
                        
                        if let mapLocation {
                            center = CLLocationCoordinate2D(
                                latitude: mapLocation.latitude,
                                longitude: mapLocation.longitude)
                        } else {
                            center = CLLocationCoordinate2D(
                                latitude: (minLat + maxLat) / 2,
                                longitude: (minLng + maxLng) / 2)
                        }
                        
                        if mapLocation != nil {
                            span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        } else {
                            span = MKCoordinateSpan(
                                latitudeDelta: abs(maxLat - minLat) * 1.2,
                                longitudeDelta: abs(maxLng - minLng) * 1.5)
                        }
                        
                        coordinateRegion = MKCoordinateRegion(center: center, span: span)
                    } else {
                        
                        center = CLLocationCoordinate2D(
                            latitude: locations.first!.latitude,
                            longitude: locations.first!.longitude)
                        
                        if mapLocation != nil {
                            span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        } else {
                            span = MKCoordinateSpan(
                                latitudeDelta: 0.055,
                                longitudeDelta: 0.02)
                        }
                        
                        coordinateRegion = MKCoordinateRegion(center: center, span: span)
                        
                    }
                } else {
                    span = MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.02)
                    // Если нет локаций, использовать значения по умолчанию
                    coordinateRegion = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude: 50.005778910087265,
                            longitude: 36.22916888328209),
                        span: span)
                }
                
                mapRegion = coordinateRegion
            }
        }
    }

    func showNextLocation(location: LocationModel) {
        withAnimation(.easeInOut) {
            mapLocation = location
        }
    }
    
    func openMapsAppWithDirections(location: LocationModel) {
        let coordinate = CLLocationCoordinate2D(
            latitude: location.latitude,
            longitude: location.longitude)
        
        let urlString = "http://maps.apple.com/?daddr=\(coordinate.latitude),\(coordinate.longitude)&dirflg=d"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func createNewLocation(location: LocationModel) async throws {
        try await LocationManager.shared.createNewLocation(location: location)
        try await getAllLocations()
    }
    
    func getAllLocations() async throws {
        locations = try await LocationManager.shared.getAllLocations()
    }
    
    func editLocation(locationId: String, latitude: Double, longitude: Double, address: String) async throws {
        try await LocationManager.shared.editLocation(locationId: locationId, latitude: latitude, longitude: longitude, address: address)
        try await getAllLocations()
    }
    
    func removeLocation(locationId: String) async throws {
        try await LocationManager.shared.removeLocation(locationId: locationId)
        try await getAllLocations()
    }
}
