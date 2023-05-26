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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            BarTitle<MapButton, ProfileButton>(text: "", leftButton: MapButton(image: "pin"), rightButton: ProfileButton(selectedTab: $selectedTab, photo: vm.user?.photoUrl ?? ""))
            
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
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Specialists")
                    .font(.title2.bold())
                
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 15) {
//                        Spacer()
                        if let doctors = vm.doctors {
                            ForEach(doctors, id: \.userId) { doctor in
                                VStack(alignment: .center) {
                                    ProfileImage(photoURL: doctor.photoUrl, frame: ScreenSize.height * 0.1, color: .lightBlueColor)
                                        .cornerRadius(ScreenSize.width / 20)
                                    
                                    Spacer()
                                    
                                    Text("\(doctor.lastName ?? "") \(doctor.name ?? "")")
                                        .font(.callout.bold())
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                    
                                    Spacer()

                                    Text("Rehabilitator")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .frame(width: ScreenSize.height * 0.2, height: ScreenSize.height * 0.2)
                                .background(Color.secondaryColor)
                                .cornerRadius(ScreenSize.width / 20)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .frame(height: ScreenSize.height * 0.2)
            }
            
        }
        .onAppear {
            Task {
                try await vm.loadCurrentUser()
//                try await vm.getAllProcedures()
                try await vm.getAllDoctors()
                if justOpened {
                    vm.addListenerForProcuderes()
                    try await vm.updateOrdersStatus()
                    justOpened = false
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
