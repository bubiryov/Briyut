//
//  MapView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 17.06.2023.
//

import SwiftUI
import MapKit

@MainActor
class LocationsViewModel: ObservableObject {
    
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
//        let locationss = [
//        LocationModel(id: "1", latitude: 50.01748624470646, longitude: 36.22833256527455, address: "Hello")
//        ]
//        self.locations = locationss
//            self.mapLocation = locations.count == 1 ? locations.first : nil
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

    
//    private func updateMapRegion(location: LocationModel?) {
//        Task {
//            withAnimation(.easeInOut) {
//                mapRegion = MKCoordinateRegion(
//                    center: CLLocationCoordinate2D(
//                        latitude: location?.latitude ?? 49.992084,
//                        longitude: location?.longitude ?? 36.2307),
//                    span: mapSpan)
//            }
//        }
//    }
    
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
    }
    
    func getAllLocations() async throws {
        locations = try await LocationManager.shared.getAllLocations()
    }
}


struct ClinicMapView: View {
    
    @StateObject var vm: LocationsViewModel = LocationsViewModel()
    @EnvironmentObject var profileVM: ProfileViewModel
        
    var body: some View {
        
        NavigationStack {
            ZStack {
                mapLayer
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    BarTitle<BackButton, EditLocationsButton>(
                        text: "",
                        leftButton: BackButton(),
                        rightButton: profileVM.user?.isDoctor ?? false ? EditLocationsButton() : nil
                    )
                    
                    Spacer()
                    
                    Button {
                        if let location = vm.mapLocation {
                            vm.openMapsAppWithDirections(location: location)
                        }
                    } label: {
                        AccentButton(
                            text: vm.mapLocation == nil ? "Navigate" : vm.mapLocation?.address ?? "Navigate",
                            isButtonActive: vm.mapLocation == nil ? false : true
                        )
                        .shadow(radius: 10, y: 5)
                    }
                    .disabled(vm.mapLocation == nil ? true : false)

                }
                .padding(.horizontal, 20)
                .padding(.top, topPadding())
                .padding(.bottom, 40)
            }
        }
    }
    
    private var mapLayer: some View {
        Map(coordinateRegion: $vm.mapRegion,
            annotationItems: vm.locations,
            annotationContent: { location in
            MapAnnotation(coordinate: CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude)) {
                    LocationMapAnnotationView()
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 7)
                        .scaleEffect(vm.mapLocation == location ? 1.5 : 1)
                        .onTapGesture {
                            vm.showNextLocation(location: location)
                        }
                }
        })
    }

}

struct ClinicMapView_Previews: PreviewProvider {
    static var previews: some View {
        ClinicMapView()
            .environmentObject(LocationsViewModel())
            .environmentObject(ProfileViewModel())
    }
}

//extension MKMapView {
//    func overlappingMapRect(coordinates: [CoordinateModel]) -> MKMapRect {
//        var mapRect = MKMapRect.null
//
//        for coordinate in coordinates {
//            let point = MKMapPoint(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
//            let pointRect = MKMapRect(origin: point, size: MKMapSize(width: 0, height: 0))
//            mapRect = mapRect.union(pointRect)
//        }
//
//        let edgePadding = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
//        let paddedRect = self.mapRectThatFits(mapRect, edgePadding: edgePadding)
//
//        return paddedRect
//    }
//}

struct LocationMapAnnotationView: View {
    
    let accentColor = Color.mainColor
    
    var body: some View {
        VStack(spacing: 0) {
            Text("R")
                .frame(width: 30, height: 30)
                .font(.custom("Alokary", size: 12))
                .foregroundColor(.mainColor)
                .padding(6)
                .background(.white)
                .overlay {
                    Circle()
                        .strokeBorder(Color.mainColor, lineWidth: 5)
                }
                .clipShape(Circle())
            
            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(accentColor)
                .frame(width: 15, height: 10)
                .rotationEffect(Angle(degrees: 180))
                .offset(y: -3)
        }
//        .shadow(color: .black.opacity(0.3), radius: 2, y: 7)
    }
}

struct EditLocationsButton: View {
        
    var body: some View {
        NavigationLink {

        } label: {
            BarButtonView(image: "pencil")
        }
        .buttonStyle(.plain)
    }
}
