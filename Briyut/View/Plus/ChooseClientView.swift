//
//  ChooseClientView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.06.2023.
//

import SwiftUI

struct ChooseClientView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    var procedure: ProcedureModel
    @State private var showSearch: Bool = false
    @State private var searchText: String = ""
    @Binding var selectedTab: Tab
    @FocusState var focus: Bool
    
    var filteredUsers: [DBUser] {
        return vm.users.filter { user in
            searchText.isEmpty ? true : (user.name ?? "").localizedCaseInsensitiveContains(searchText) || (user.lastName ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack {
            BarTitle<BackButton, SearchButton>(text: "Choose a client", leftButton: BackButton(), rightButton: SearchButton(showSearch: $showSearch, searchText: $searchText))
            
            if showSearch {
                AccentInputField(promptText: "User's name", title: nil, input: $searchText)
                    .focused($focus)
                    .onAppear {
                        focus = true
                    }
                    .onDisappear {
                        focus = false
                        showSearch = false
                        searchText = ""
                    }
            }
            
            ScrollView {
                ForEach(filteredUsers, id: \.userId) { user in
                    NavigationLink {
                        DateTimeSelectionView(doctor: vm.user, procedure: procedure, mainButtonTitle: "Add appoinment", client: user, selectedTab: $selectedTab)
                    } label: {
                        UserRow(user: user, showCallButton: false)
                    }

//                    NavigationLink {
//
//                        DateTimeSelectionView(doctor: vm.user, procedure: procedure, mainButtonTitle: "Add appoinment", client: user, selectedTab: $selectedTab)
//
//                    } label: {
//                        HStack {
//                            ProfileImage(photoURL: user.photoUrl, frame: ScreenSize.height * 0.06, color: .lightBlueColor)
//                                .cornerRadius(ScreenSize.width / 30)
//
//                            Text("\(user.name ?? user.userId) \(user.lastName ?? "")")
//                                .foregroundColor(.primary)
//                                .bold()
//                                .padding(.leading, 8)
//                                .lineLimit(1)
//                        }
//                        .padding(.horizontal)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .frame(height: ScreenSize.height * 0.09)
//                        .background(Color.secondaryColor)
//                        .cornerRadius(ScreenSize.width / 30)
//                    }
                }
            }
            .scrollIndicators(.hidden)
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onEnded { gesture in
                if gesture.translation.width > 100 {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        )
    }
}

struct ChooseClienView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseClientView(procedure: ProcedureModel(procedureId: "", name: "", duration: 0, cost: 0, parallelQuantity: 1, availableDoctors: []), selectedTab: .constant(.home))
            .environmentObject(ProfileViewModel())
    }
}
