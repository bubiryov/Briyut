//
//  HomeView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @EnvironmentObject var articlesVM: ArticlesViewModel
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedTab: Tab
    @Binding var justOpened: Bool
    @Binding var showSearch: Bool
    @Binding var splashView: Bool
    @State private var showFullOrder: Bool = false
    @State private var showMap: Bool = false
    
//    additional color (secondary)
    
    var body: some View {
        
        NavigationView {
            VStack(alignment: .leading, spacing: 25) {
                            
                BarTitle<MapButton, ProfileButton>(
                    text: "",
                    leftButton: MapButton(image: "pin", showMap: $showMap),
                    rightButton: ProfileButton(selectedTab: $selectedTab, photo: vm.user?.photoUrl ?? ""))
                
                Text("find-your-procedure-string")
                    .font(Mariupol.bold, 30)
                    .lineLimit(1)
                            
                Button {
                    Haptics.shared.play(.light)
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selectedTab = .plus
                        showSearch = true
                    }
                } label: {
                    HStack {
                        BarButtonView(image: "search", scale: 0.4, textColor: .primary, backgroundColor: .clear)
                        
                        Text("search-string")
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
                        Text("appointments-string")
                            .font(Mariupol.medium, 22)
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedTab = .calendar
                            }
                        } label: {
                            Text("see-all-string")
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
                                userInformation: vm.user?.isDoctor ?? false ? .client : .doctor,
                                photoBackgroundColor: colorScheme == .dark ? .white.opacity(0.2) : .white
                            )
                        }
                        .padding(.bottom, vm.activeOrders.count > 1 ? 5 : 0)
                    } else {
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedTab = .plus
                            }
                        } label: {
                            Text("no-any-appointments-string")
                                .font(Mariupol.medium, 17)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .frame(height: ScreenSize.height * 0.14)
                                .background(Color.secondaryColor)
                                .cornerRadius(ScreenSize.width / 20)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    
                    HStack(alignment: .center) {
                        Text("articles-string")
                            .font(Mariupol.medium, 22)
                        
                        Spacer()
                        
                        NavigationLink {
                            ArticlesList()
                        } label: {
                            Text("see-all-string")
                                .font(Mariupol.medium, 17)
                                .foregroundColor(.secondary.opacity(0.6))
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.primary)
                    }
                                        
                    if let nearestArticle = articlesVM.articles.first {
                        ZStack {
                            if articlesVM.articles.count > 1 {
                                RoundedRectangle(cornerRadius: ScreenSize.width / 15)
                                    .frame(height: ScreenSize.height * 0.14)
                                    .offset(y: ScreenSize.height / 35)
                                    .scaleEffect(0.85)
                                    .foregroundColor(colorScheme == .light ? Color(#colorLiteral(red: 0.8550214171, green: 0.9174225926, blue: 0.9357536435, alpha: 1)) : .secondaryColor.opacity(0.7))
                            }

                            ArticleRow(article: nearestArticle)
                            
                        }
                        .padding(.bottom, articlesVM.articles.count > 1 ? 5 : 0)
                        
                    } else {
                        Text("no-articles-string")
                            .font(Mariupol.medium, 17)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: ScreenSize.height * 0.14)
                            .background(Color.secondaryColor)
                            .cornerRadius(ScreenSize.width / 20)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
                
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
                        try await articlesVM.getRequiredArticles(countLimit: 6)
                        justOpened = false
                    }
                }
            }
            .background(Color.backgroundColor)
        }
        .fullScreenCover(isPresented: $showMap) {
            ClinicMapView(profileVM: vm)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HomeView(
                selectedTab: .constant(.profile),
                justOpened: .constant(false),
                showSearch: .constant(false),
                splashView: .constant(false)
            )
            .environmentObject(ProfileViewModel())
            .environmentObject(ArticlesViewModel())
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

//try await vm.loadCurrentUser()
//try await vm.getAllDoctors()
//try await vm.getAllProcedures()
//if vm.user?.isDoctor ?? false {
//    try await vm.getAllUsers()
//}
//if justOpened {
//    try await vm.updateOrdersStatus(isDone: false, isDoctor: vm.user?.isDoctor ?? false)
//    try await articlesVM.getRequiredArticles(countLimit: 6)
//    let endTime = DispatchTime.now()
//    let difference = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
//    try await Task.sleep(nanoseconds: difference > 6_000_000_000 ? 6_000_000_000 : 3_000_000_000 - difference)
//    splashView = false
//    justOpened = false
//    print("Content end")
//
//}
