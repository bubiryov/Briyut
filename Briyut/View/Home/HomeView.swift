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
    
    var body: some View {
        
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                BarTitle<MapButton, ProfileButton>(text: "", leftButton: MapButton(image: "pin"), rightButton: ProfileButton(selectedTab: $selectedTab, photo: vm.user?.photoUrl ?? ""), action: {})
                
                Text("Find your procedure")
                    .font(.largeTitle.bold())
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
                            .font(.callout.bold())
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: ScreenSize.height * 0.07)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(ScreenSize.width / 30)
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
                            userInformation: vm.user?.isDoctor ?? false ? .client : .doctor, photoBackgroundColor: .white)
                    }
                } else {
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedTab = .plus
                        }
                    } label: {
                        Text("You don't have any appointments yet. \n Want to add?")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: ScreenSize.height * 0.14)
                            .background(Color.secondaryColor)
                            .cornerRadius(ScreenSize.width / 20)
                            .foregroundColor(.secondary)
                    }
                }

                
                Spacer()
                
                VStack(alignment: .leading) {
                    
                    HStack(alignment: .center) {
                        Text("Specialists")
                            .font(.title2.bold())
                        
                        Spacer()
                        
                        NavigationLink {
                            AllDoctorsView()
//                            if vm.user?.isDoctor ?? false {
//                                AddDoctorView()
//                            } else {
//                                AllDoctorsView()
//                            }
                        } label: {
                            Text("See all")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.primary)
                    }

                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 15) {
                            let doctors = vm.doctors
                                ForEach(doctors, id: \.userId) { doctor in
                                    VStack(alignment: .center, spacing: 7) {
                                        ProfileImage(photoURL: doctor.photoUrl, frame: ScreenSize.height * 0.06, color: .lightBlueColor)
                                            .cornerRadius(ScreenSize.width / 30)

                                        VStack {
                                            Text(doctor.lastName ?? "")
                                                .font(.callout.bold())
                                                .multilineTextAlignment(.center)
                                                .lineLimit(1)
                                            
                                            Text(doctor.name ?? "")
                                                .font(.callout.bold())
                                                .multilineTextAlignment(.center)
                                                .lineLimit(1)
                                        }

                                        Text("Rehabilitator")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .frame(maxWidth: ScreenSize.height * 0.18)
                                    .frame(minWidth: ScreenSize.height * 0.16)
                                    .frame(maxHeight: ScreenSize.height * 0.18)
                                    .background(Color.secondaryColor)
                                    .cornerRadius(ScreenSize.width / 20)
                                }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .frame(maxHeight: ScreenSize.height * 0.18)
                }
            }
            .onAppear {
                Task {
                    try await vm.loadCurrentUser()
                    try await vm.getAllDoctors()
                    if vm.user?.isDoctor ?? false {
                        try await vm.getAllUsers()
                    }
                    if justOpened {
                        vm.addListenerForProcuderes()
                        try await vm.updateOrdersStatus(isDone: false, isDoctor: vm.user?.isDoctor ?? false)
                        justOpened = false
                    } else {
                        try await vm.getRequiredOrders(dataFetchMode: .user, isDone: false, countLimit: 2)
                    }
                }
        }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(selectedTab: .constant(.profile), justOpened: .constant(false), showSearch: .constant(false))
            .environmentObject(ProfileViewModel())
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
            ProfileImage(photoURL: photo, frame: ScreenSize.height * 0.06, color: Color.secondary.opacity(0.1))
        }
        .buttonStyle(.plain)
        .cornerRadius(ScreenSize.width / 30)
    }
}

struct MapButton: View {

    var image: String

    var body: some View {
        Button {
            //
        } label: {
            BarButtonView(image: image)
        }
        .buttonStyle(.plain)

    }
}
