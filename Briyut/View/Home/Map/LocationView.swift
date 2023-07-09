//
//  LocationView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 21.06.2023.
//

import SwiftUI

struct LocationView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var locationViewModel: LocationsViewModel
    var location: LocationModel? = nil
    @State private var city: String = ""
    @State private var street: String = ""
    @State private var buildingNumber: String = ""
    @State private var coordinates: String = ""
    @State private var showAlert: Bool = false
    @State private var loading: Bool = false
    
    var body: some View {
        VStack {
            TopBar<BackButton, DeleteButton>(
                text: location != nil ? "edit-address-string" : "new-address-string",
                leftButton: BackButton(),
                rightButton: location != nil ? DeleteButton(showAlert: $showAlert) : nil
            )
            .padding(.bottom)
            
            ScrollView {
                VStack(spacing: ScreenSize.height * 0.02) {
                    
                    AccentInputField(
                        promptText: "Харків",
                        title: "city-string",
                        spaceAllow: false,
                        input: $city
                    )
                    
                    AccentInputField(
                        promptText: "Сумська",
                        title: "street-string",
                        input: $street
                    )
                    
                    AccentInputField(
                        promptText: "17-А",
                        title: "building-string",
                        input: $buildingNumber
                    )
                    
                    AccentInputField(
                        promptText: "49.991236239813, 36.225463473776614",
                        title: "coordinates-string",
                        input: $coordinates
                    )
                }
            }
            .scrollIndicators(.hidden)
            
            Button {
                Task {
                    Haptics.shared.play(.light)
                    if location == nil {
                        do {
                            loading = true
                            try await addNewAddress()
                            loading = false
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print("Can't add new address")
                        }
                    } else {
                        do {
                            loading = true
                            try await editAddress()
                            loading = false
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            loading = false
                            print("Can't edit address")
                        }
                    }
                }
            } label: {
                AccentButton(
                    text: location != nil ? "edit-string" : "add-string",
                    isButtonActive: validateFields(),
                    animation: loading
                )
            }
            .disabled(!validateFields() || loading)
        }
        .padding(.top, topPadding())
        .padding(.bottom, 20)
        .padding(.horizontal, 20)
        .background(Color.backgroundColor)
        .navigationBarBackButtonHidden()
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width > 100 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .onEnded { gesture in
                    if gesture.translation.height > 100 {
                        hideKeyboard()
                    }
                }
        )
        .onAppear {
            if let location {
                city = splitAddress().city
                street = splitAddress().street
                buildingNumber = splitAddress().house
                coordinates = "\(location.latitude), \(location.longitude)"
            }
        }
        .ignoresSafeArea(.keyboard)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("delete-address-alert-title-string"),
                primaryButton: .destructive(Text("delete-string"), action: {
                    Task {
                        try await locationViewModel.removeLocation(locationId: location!.id)
                        presentationMode.wrappedValue.dismiss()
                    }
                }),
                secondaryButton: .default(Text("cancel-string"), action: { })
            )
        }
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView(locationViewModel: LocationsViewModel())
    }
}

extension LocationView {
    func addNewAddress() async throws {
        guard let coordinates = splitCoordinates() else {
            return
        }
        
        let (latitude, longitude) = coordinates
        
        let location = LocationModel(
            id: UUID().uuidString,
            latitude: latitude,
            longitude: longitude,
            address: "\(street), \(buildingNumber), \(city)"
        )
        try await locationViewModel.createNewLocation(location: location)
    }
    
    func editAddress() async throws {
        guard let coordinates = splitCoordinates() else {
            return
        }
        let (latitude, longitude) = coordinates
        
        try await locationViewModel.editLocation(
            locationId: location!.id,
            latitude: latitude,
            longitude: longitude,
            address: "\(street), \(buildingNumber), \(city)")
    }
       
    func validateFields() -> Bool {

        let cityRegex = "^(?!.*[\\s-]{2,})(?!^[-\\s])(?!.*[-\\s]$)[A-ZА-ЯЄЇІ][a-zA-Zа-яА-ЯЄЇІіїє\\s-]*$"
        let cityPredicate = NSPredicate(format: "SELF MATCHES %@", cityRegex)
        let isCityValid = cityPredicate.evaluate(with: city)

        let streetRegex = "^(?!.*[\\s-]{2,})(?!^[-\\s])(?!.*[-\\s]$)(?!.*([\\s-])\\1)[a-zA-Zа-яА-ЯЄЇІіїє]+(\\s+[a-zA-Zа-яА-ЯЄЇІіїє]+)*$"
        let streetPredicate = NSPredicate(format: "SELF MATCHES %@", streetRegex)
        let isStreetValid = streetPredicate.evaluate(with: street) && !street.contains(where: \.isNumber)

        let buildingNumberRegex = "^(?!^[-\\s])(?!.*[-\\s]$)(?!.*([\\s-])\\1)[^\\s]+$"
        let buildingNumberPredicate = NSPredicate(format: "SELF MATCHES %@", buildingNumberRegex)
        let isBuildingNumberValid = buildingNumberPredicate.evaluate(with: buildingNumber) && !buildingNumber.isEmpty

        return isCityValid && isStreetValid && isBuildingNumberValid && validateCoordinates()
    }
    
    private func validateCoordinates() -> Bool {
        let coordinateComponents = coordinates.components(separatedBy: ", ")
        
        guard coordinateComponents.count == 2 else {
            return false
        }
        
        for component in coordinateComponents {
            guard let coordinate = Double(component) else {
                return false
            }
            
            guard !coordinate.isNaN && !coordinate.isInfinite else {
                return false
            }
        }
        
        return true
    }
    
    func splitCoordinates() -> (Double, Double)? {
        let coordinateComponents = coordinates.components(separatedBy: ", ")
        
        guard coordinateComponents.count == 2,
              let latitude = Double(coordinateComponents[0].trimmingCharacters(in: .whitespaces)),
              let longitude = Double(coordinateComponents[1].trimmingCharacters(in: .whitespaces)) else {
            return nil
        }
        
        return (latitude, longitude)
    }
    
    private func splitAddress() -> (city: String, house: String, street: String) {
        
        guard let location = location else {
            return ("", "", "")
        }
        
        let components = location.address.components(separatedBy: ",")
        
        var city = ""
        var house = ""
        var street = ""
        
        if components.count >= 1 {
            city = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if components.count >= 2 {
            house = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if components.count >= 3 {
            street = components[2].trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return (city, house, street)
    }

}
