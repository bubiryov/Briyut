//
//  HomeView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @EnvironmentObject var orderViewModel: OrderViewModel
    @EnvironmentObject var procedureViewModel: ProcedureViewModel
    @EnvironmentObject var articlesVM: ArticlesViewModel
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedTab: Tab
    @Binding var justOpened: Bool
    @Binding var showSearch: Bool
    @Binding var splashView: Bool
    @State private var showFullOrder: Bool = false
    @State private var showMap: Bool = false
        
    var body: some View {
        
        NavigationView {
            VStack(alignment: .leading, spacing: 25) {
                            
                TopBar<MapButton, ProfileButton>(
                    text: "",
                    leftButton: MapButton(image: "pin", showMap: $showMap),
                    rightButton: ProfileButton(selectedTab: $selectedTab, photo: profileViewModel.user?.photoUrl ?? ""))
                
                Text("find-your-procedure-string")
                    .font(Mariupol.bold, 30)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                searchButton
                                            
                appointmentsStack
                
                articlesStack
                
                Spacer()
                
            }
            .onAppear {
                loadData()
            }
            .background(Color.backgroundColor)
        }
        .fullScreenCover(isPresented: $showMap) {
            ClinicMapView(profileVM: profileViewModel)
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
            .environmentObject(PropertyViewModel())
            .environmentObject(ArticlesViewModel())
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

// MARK: Components

extension HomeView {
    
    var searchButton: some View {
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
    }
    
    var appointmentsStack: some View {
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
            
            if let nearestOrder = profileViewModel.activeOrders.first {
                ZStack {
                    if orderViewModel.activeOrders.count > 1 {
                        RoundedRectangle(cornerRadius: ScreenSize.width / 15)
                            .frame(height: ScreenSize.height * 0.14)
                            .offset(y: ScreenSize.height / 35)
                            .scaleEffect(0.85)
                            .foregroundColor(.mainColor.opacity(0.7))
                    }
                    OrderRow(
                        vm: profileViewModel,
                        order: nearestOrder,
                        withButtons: false,
                        color: .mainColor,
                        fontColor: .white,
                        bigDate: true,
                        userInformation: profileViewModel.user?.isDoctor ?? false ? .client : .doctor,
                        photoBackgroundColor: colorScheme == .dark ? .white.opacity(0.2) : .white
                    )
                }
                .padding(.bottom, orderViewModel.activeOrders.count > 1 ? 5 : 0)
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
    }
    
    var articlesStack: some View {
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
    }
}

// MARK: Functions

extension HomeView {
    
    private func loadData() {
        Task {
            do {
                try await profileViewModel.loadCurrentUser()
                try await profileViewModel.getAllDoctors()
                try await procedureViewModel.getAllProcedures()
                
                if profileViewModel.user?.isDoctor ?? false {
                    try await profileViewModel.getAllUsers()
                }
                
                if justOpened {
                    try await orderViewModel.updateOrdersStatus(isDone: false, isDoctor: profileViewModel.user?.isDoctor ?? false)
                    try await articlesVM.getRequiredArticles(countLimit: 6)
                    justOpened = false
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
