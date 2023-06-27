//
//  LocationsList.swift
//  Briyut
//
//  Created by Egor Bubiryov on 21.06.2023.
//

import SwiftUI

struct LocationsList: View {
    
    @ObservedObject var vm: LocationsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        VStack {
            BarTitle<BackButton, AddLocationButton>(
                text: "Addresses",
                leftButton: BackButton(),
                rightButton: AddLocationButton(vm: vm)
            )
            
            ScrollView {
                ForEach(vm.locations, id: \.id) { location in
                    NavigationLink {
                        LocationView(vm: vm, location: location)
//                            .environmentObject(vm)
                    } label: {
                        HStack {
                            LocationMapAnnotationView()
                                .scaleEffect(0.8)
                            
                            Text(location.address)
                                .font(Mariupol.medium, 17)
                                .lineLimit(1)
                                .padding(.leading, 5)
                            
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: ScreenSize.height * 0.09)
                        .background(Color.secondaryColor)
                        .cornerRadius(ScreenSize.width / 30)
                    }
                    .buttonStyle(.plain)
                    
                }
            }
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width > 100 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )
        .navigationBarBackButtonHidden()
        .padding(.top, topPadding())
        .padding(.bottom, 20)
        .padding(.horizontal, 20)
        .background(Color.backgroundColor)
    }
}

struct LocationsList_Previews: PreviewProvider {
    static var previews: some View {
        LocationsList(vm: LocationsViewModel())
//            .environmentObject(LocationsViewModel())
    }
}

struct AddLocationButton: View {
    
    @ObservedObject var vm: LocationsViewModel
        
    var body: some View {
        NavigationLink {
            LocationView(vm: vm)
        } label: {
            BarButtonView(image: "plus", scale: 0.35)
        }
        .buttonStyle(.plain)
    }
}
