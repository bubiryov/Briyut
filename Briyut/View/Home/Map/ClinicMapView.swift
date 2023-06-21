//
//  MapView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 17.06.2023.
//

import SwiftUI
import MapKit

struct ClinicMapView: View {
    
    @ObservedObject var vm: LocationsViewModel = LocationsViewModel()
    var profileVM: ProfileViewModel
        
    var body: some View {
        
        NavigationStack {
            ZStack {
                mapLayer
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    BarTitle<BackButton, EditLocationsButton>(
                        text: "",
                        leftButton: BackButton(),
                        rightButton: profileVM.user?.isDoctor ?? false ? EditLocationsButton(vm: vm) : nil
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
        ClinicMapView(profileVM: ProfileViewModel())
//            .environmentObject(LocationsViewModel())
//            .environmentObject(ProfileViewModel())
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
        
    @ObservedObject var vm: LocationsViewModel
    
    var body: some View {
        NavigationLink {
            LocationsList(vm: vm)
//                .environmentObject(vm)
        } label: {
            BarButtonView(image: "pencil")
        }
        .buttonStyle(.plain)
    }
}
