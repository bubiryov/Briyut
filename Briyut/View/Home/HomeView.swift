//
//  HomeView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Binding var selectedTab: Tab
    @Binding var justOpened: Bool
    @Binding var showSearch: Bool
    @State private var showFullOrder: Bool = false
    @State private var showMap: Bool = false
    
    var body: some View {
        
        NavigationView {
            VStack(alignment: .leading, spacing: 25) {
                BarTitle<MapButton, ProfileButton>(text: "", leftButton: MapButton(image: "pin", showMap: $showMap), rightButton: ProfileButton(selectedTab: $selectedTab, photo: vm.user?.photoUrl ?? ""), action: {})
                
                Text("Find your procedure")
                    .font(Mariupol.bold, 30)
                    .lineLimit(1)
                            
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selectedTab = .plus
                        showSearch = true
                    }
                } label: {
                    HStack {
                        BarButtonView(image: "search", scale: 0.4, textColor: .primary, backgroundColor: .clear)
                        
                        Text("Search")
                            .foregroundColor(.secondary)
                            .font(Mariupol.medium, 17)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: ScreenSize.height * 0.07)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(ScreenSize.width / 30)
                }
                  
                VStack(alignment: .leading) {
                    
                    HStack(alignment: .center) {
                        Text("Appointments")
                            .font(Mariupol.medium, 22)
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedTab = .plus
                            }
                        } label: {
                            Text("See all")
                                .font(Mariupol.medium, 17)
                                .foregroundColor(.secondary.opacity(0.6))
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.primary)
                    }

                    if let nearestOrder = vm.activeOrders.first {
                        ZStack {
                            if vm.activeOrders.count > 1 {
                                RoundedRectangle(cornerRadius: ScreenSize.width / 15)
                                    .frame(height: ScreenSize.height * 0.14)
                                    .offset(y: ScreenSize.height / 35)
                                    .scaleEffect(0.85)
                                    .foregroundColor(.mainColor.opacity(0.7))
                            }
                            OrderRow(
                                vm: vm,
                                order: nearestOrder,
                                withButtons: false,
                                color: .mainColor,
                                fontColor: .white,
                                bigDate: true,
                                userInformation: vm.user?.isDoctor ?? false ? .client : .doctor, photoBackgroundColor: .white
                            )
                        }
                    } else {
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedTab = .calendar
                            }
                        } label: {
                            Text("You don't have any appointments yet")
                                .font(Mariupol.medium, 17)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .frame(height: ScreenSize.height * 0.14)
                                .background(Color.secondaryColor)
                                .cornerRadius(ScreenSize.width / 20)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                
                Spacer()
                
//                if !vm.doctors.isEmpty {
//                    VStack(alignment: .leading) {
//
//                        HStack(alignment: .center) {
//                            Text("Specialists")
//                                .font(Mariupol.medium, 22)
//
//                            Spacer()
//
//                            NavigationLink {
//                                AllDoctorsView()
//                            } label: {
//                                Text("See all")
//                                    .font(Mariupol.medium, 17)
//                                    .foregroundColor(.secondary.opacity(0.6))
//                            }
//                            .buttonStyle(.plain)
//                            .foregroundColor(.primary)
//                        }
//
//                        ScrollView(.horizontal) {
//                            LazyHStack(spacing: 15) {
//                                let doctors = vm.doctors
//                                ForEach(doctors, id: \.userId) { doctor in
//                                    VStack(alignment: .center, spacing: 10) {
//                                        ProfileImage(photoURL: doctor.photoUrl, frame: ScreenSize.height * 0.06, color: .clear)
//                                            .cornerRadius(ScreenSize.width / 30)
//
//                                        VStack(spacing: 2) {
//                                            Text(doctor.lastName ?? "")
//                                                .font(Mariupol.medium, 17)
//                                                .multilineTextAlignment(.center)
//                                                .lineLimit(1)
//
//                                            Text(doctor.name ?? "")
//                                                .font(Mariupol.medium, 17)
//                                                .multilineTextAlignment(.center)
//                                                .lineLimit(1)
//                                        }
//
//                                        Text("Rehabilitator")
//                                            .font(Mariupol.regular, 14)
//                                            .foregroundColor(.secondary)
//                                    }
//                                    .padding()
//                                    .frame(width: ScreenSize.height * 0.15)
////                                    .frame(maxWidth: ScreenSize.height * 0.18)
////                                    .frame(minWidth: ScreenSize.height * 0.15)
//                                    .frame(height: ScreenSize.height * 0.18)
//                                    .background(Color.secondaryColor)
//                                    .cornerRadius(ScreenSize.width / 20)
//                                }
//                            }
//                        }
//                        .scrollIndicators(.hidden)
//                        .frame(height: ScreenSize.height * 0.18)
//                    }
//                }
            }
            .onAppear {
                Task {
                    try await vm.loadCurrentUser()
                    try await vm.getAllDoctors()
                    try await vm.getAllProcedures()
                    if vm.user?.isDoctor ?? false {
                        try await vm.getAllUsers()
                    }
                    if justOpened {
                        try await vm.updateOrdersStatus(isDone: false, isDoctor: vm.user?.isDoctor ?? false)
                        justOpened = false
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showMap) {
            ClinicMapView()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HomeView(selectedTab: .constant(.profile), justOpened: .constant(false), showSearch: .constant(false))
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

struct ProfileButton: View {
    
    @Binding var selectedTab: Tab
    var photo: String
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedTab = .profile
            }
        } label: {
            ProfileImage(photoURL: photo, frame: ScreenSize.height * 0.06, color: Color.secondary.opacity(0.1), padding: 16)
        }
        .buttonStyle(.plain)
        .cornerRadius(ScreenSize.width / 30)
    }
}

struct MapButton: View {

    var image: String
    @Binding var showMap: Bool

    var body: some View {
                
        Button {
            showMap = true
        } label: {
            BarButtonView(image: image)
        }
        .buttonStyle(.plain)
    }
}
