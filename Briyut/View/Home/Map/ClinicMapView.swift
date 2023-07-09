//
//  MapView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 17.06.2023.
//

import SwiftUI
import MapKit

struct ClinicMapView: View {
    
    @StateObject var locationViewModel: LocationsViewModel = LocationsViewModel()
    @Environment(\.colorScheme) var colorScheme
    var interfaceData: InterfaceData
        
    var body: some View {
        
        NavigationStack {
            ZStack {
                mapLayer
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    TopBar<BackButton, EditLocationsButton>(
                        text: "",
                        leftButton: BackButton(backgorundColor: colorScheme == .dark ? Color.secondary.opacity(0.3) : nil),
                        rightButton: interfaceData.user?.isDoctor ?? false ? EditLocationsButton(locationViewModel: locationViewModel) : nil
                    )
                    
                    Spacer()
                    
                    Button {
                        if let location = locationViewModel.mapLocation {
                            locationViewModel.openMapsAppWithDirections(location: location)
                        }
                    } label: {
                        AccentButton(
                            text: locationViewModel.mapLocation == nil ? "navigate-string" : locationViewModel.mapLocation?.address ?? "navigate-string",
                            isButtonActive: locationViewModel.mapLocation == nil ? false : true
                        )
                        .shadow(radius: 10, y: 5)
                    }
                    .disabled(locationViewModel.mapLocation == nil ? true : false)

                }
                .padding(.horizontal, 20)
                .padding(.top, topPadding())
                .padding(.bottom, 30)
            }
        }
    }
    
    private var mapLayer: some View {
        Map(coordinateRegion: $locationViewModel.mapRegion,
            annotationItems: locationViewModel.locations,
            annotationContent: { location in
            MapAnnotation(coordinate: CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude)) {
                    LocationMapAnnotationView()
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 7)
                        .scaleEffect(locationViewModel.mapLocation == location ? 1.5 : 1)
                        .onTapGesture {
                            locationViewModel.showNextLocation(location: location)
                        }
                }
        })
    }

}

struct ClinicMapView_Previews: PreviewProvider {
    static var previews: some View {
        ClinicMapView(interfaceData: InterfaceData())
    }
}

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
        
    @ObservedObject var locationViewModel: LocationsViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationLink {
            LocationsList(locationViewModel: locationViewModel)
        } label: {
            BarButtonView(
                image: "pencil",
                backgroundColor: colorScheme == .dark ? Color.secondary.opacity(0.3) : nil
            )
        }
        .buttonStyle(.plain)
    }
}
