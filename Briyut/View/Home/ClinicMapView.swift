//
//  MapView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 17.06.2023.
//

import SwiftUI
import MapKit

//struct MapView: UIViewRepresentable {
//    var coordinates: [CoordinateModel]
//    @Binding var selectedPin: CoordinateModel?
//
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.delegate = context.coordinator
//        return mapView
//    }
//
//    func updateUIView(_ mapView: MKMapView, context: Context) {
//        mapView.removeAnnotations(mapView.annotations)
//
//        for coordinate in coordinates {
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
//            mapView.addAnnotation(annotation)
//        }
//
//        if let firstCoordinate = coordinates.first {
//            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: firstCoordinate.latitude, longitude: firstCoordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.02))
//            mapView.setRegion(region, animated: true)
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator()
//    }
//
//    class Coordinator: NSObject, MKMapViewDelegate {
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            let identifier = "LocationPin"
//
//            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//
//            if annotationView == nil {
//                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                annotationView?.canShowCallout = false
//            } else {
//                annotationView?.annotation = annotation
//            }
//
//            return annotationView
//        }
//    }
//}

/*
struct MapView: UIViewRepresentable {
    var coordinates: [CoordinateModel]
    @Binding var selectedPin: CoordinateModel?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeAnnotations(mapView.annotations)
        
        for coordinate in coordinates {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            mapView.addAnnotation(annotation)
        }
        
        if let selectedPin = selectedPin {
            if let annotation = mapView.annotations.first(where: { $0.coordinate.latitude == selectedPin.latitude && $0.coordinate.longitude == selectedPin.longitude }) {
                mapView.selectAnnotation(annotation, animated: true)
            } else if let firstAnnotation = mapView.annotations.first {
                mapView.selectAnnotation(firstAnnotation, animated: true)
            }
        }
        
        // Определение видимой области карты
        if !coordinates.isEmpty {
            let mapRect = mapView.overlappingMapRect(coordinates: coordinates)
            let edgePadding = UIEdgeInsets(top: 300, left: 100, bottom: 300, right: 100) // Увеличенные значения отступа
            
            mapView.setVisibleMapRect(mapRect, edgePadding: edgePadding, animated: true)
        }
    }

    
//    func updateUIView(_ mapView: MKMapView, context: Context) {
//        mapView.removeAnnotations(mapView.annotations)
//
//        for coordinate in coordinates {
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
//            mapView.addAnnotation(annotation)
//        }
//
//        if let selectedPin = selectedPin {
//            if let annotation = mapView.annotations.first(where: { $0.coordinate.latitude == selectedPin.latitude && $0.coordinate.longitude == selectedPin.longitude }) {
//                mapView.selectAnnotation(annotation, animated: true)
//            } else if let firstAnnotation = mapView.annotations.first {
//                mapView.selectAnnotation(firstAnnotation, animated: true)
//            }
//        }
//    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "LocationPin"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
        
        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            let mapView = gestureRecognizer.view as! MKMapView
            let tapPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)

            let tappedAnnotations = mapView.annotations.filter { annotation in
                guard let annotationView = mapView.view(for: annotation) else {
                    return false
                }

                let annotationPoint = annotationView.convert(annotationView.center, to: mapView)
                return annotationView.bounds.contains(tapPoint) && annotationPoint == tapPoint
            }

            if let tappedAnnotation = tappedAnnotations.first {
                parent.selectedPin = CoordinateModel(latitude: tappedAnnotation.coordinate.latitude, longitude: tappedAnnotation.coordinate.longitude)
            } else {
//                parent.selectedPin = nil
            }
        }
    }
}

 */

class LocationsViewModel: ObservableObject {
    
    @Published var locations: [LocationModel] = []
    
    @Published var mapLocation: LocationModel? {
        didSet {
            updateMapRegion(location: mapLocation)
        }
    }
    
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    
    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    
    init() {
        Task {
            do {
                try await getAllLocations()
                print(locations)
            } catch {
                print("Error")
            }
        }
//        let locations: [LocationModel] = [
//            LocationModel(id: "1", coordinates: CLLocationCoordinate2D(latitude: 49.992084, longitude: 36.2307)),
//            LocationModel(id: "2", coordinates: CLLocationCoordinate2D(latitude: 49.998449, longitude: 36.22798))
//        ]
//        self.locations = locations
        self.mapLocation = locations.count == 1 ? locations.first : nil
        self.updateMapRegion(location: !locations.isEmpty ? locations.first! : nil)
    }
    
    private func updateMapRegion(location: LocationModel?) {
        withAnimation(.easeInOut) {
            mapRegion = MKCoordinateRegion(
                center: location?.coordinates ?? CLLocationCoordinate2D(latitude: 49.992084, longitude: 36.2307),
                span: mapSpan)
        }
    }
    
    func showNextLocation(location: LocationModel) {
        withAnimation(.easeInOut) {
            mapLocation = location
        }
    }
    
    func openMapsAppWithDirections(coordinate: CLLocationCoordinate2D) {
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
                            vm.openMapsAppWithDirections(coordinate: location.coordinates)
                        }
                    } label: {
                        AccentButton(text: "Navigate", isButtonActive: vm.mapLocation == nil ? false : true)
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
            MapAnnotation(coordinate: location.coordinates) {
                LocationMapAnnotationView()
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
            Text("B")
                .frame(width: 30, height: 30)
                .font(.custom("Alokary", size: 15))
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
//                .padding(.bottom, 40)
        }
        .shadow(color: .black.opacity(0.3), radius: 2, y: 7)
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
