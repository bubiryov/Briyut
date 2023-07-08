//
//  AllUsersView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 05.06.2023.
//

import SwiftUI

struct AllUsersView: View {
    
    @EnvironmentObject var interfaceData: InterfaceData
    @EnvironmentObject var mainViewModel: MainViewModel
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showSearch: Bool = false
    @State private var searchable: String = ""
    @FocusState var focus: Bool
    @State private var tupleUsers: [(DBUser, Bool)] = []
    
    var body: some View {
        ZStack {
            
            Color.backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack {
                TopBar<BackButton, SearchButton>(
                    text: "users-string",
                    leftButton: BackButton(),
                    rightButton: SearchButton(showSearch: $showSearch)
                )
                
                if showSearch {
                    AccentInputField(promptText: "Arkadiy Rubin", title: nil, input: $searchable)
                        .focused($focus)
                        .onAppear {
                            focus = true
                        }
                        .onDisappear {
                            showSearch = false
                            searchable = ""
                        }
                        .gesture(
                            DragGesture()
                                .onEnded { gesture in
                                    if gesture.translation.height < 30 {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            showSearch = false
                                            hideKeyboard()
                                        }
                                    }
                                }
                        )
                    
                }
                
                ScrollView {
                    LazyVStack {
                        let filteredUsers = tupleUsers.filter { user in
                            searchable.isEmpty ? true : (user.0.name ?? "").localizedCaseInsensitiveContains(searchable) || (user.0.lastName ?? "").localizedCaseInsensitiveContains(searchable)
                        }
                        
                        ForEach(filteredUsers, id: \.0.userId) { user in
                            UserRow(
                                interfaceData: interfaceData,
                                mainViewModel: mainViewModel,
                                user: user.0,
                                showButtons: user.1,
                                userStatus: .client
                            )
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if let index = tupleUsers.firstIndex(where: { $0.0.userId == user.0.userId }) {
                                        tupleUsers[index].1.toggle()
                                    }
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
            .onChange(of: interfaceData.users, perform: { _ in
                withAnimation(.easeInOut(duration: 0.15)) {
                    tupleUsers = interfaceData.users.map {($0, false)}
                }
            })
            .onAppear {
                Task {
                    try await mainViewModel.profileViewModel.getAllUsers()
                    tupleUsers = interfaceData.users.map {($0, false)}
                }
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
}

struct AllUsersView_Previews: PreviewProvider {
    static var previews: some View {
        
        let interfaceData = InterfaceData()

        VStack {
            AllUsersView()
                .environmentObject(interfaceData)
                .environmentObject(MainViewModel(data: interfaceData))
        }
        .padding(.horizontal, 20)
        .background(Color.backgroundColor)
    }
}
