//
//  AllUsersView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 05.06.2023.
//

import SwiftUI

struct AllUsersView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showSearch: Bool = false
    @State private var searchable: String = ""
    @FocusState var focus: Bool
    @State private var tupleUsers: [(DBUser, Bool)] = []
    
    var body: some View {
        VStack {
            BarTitle<BackButton, SearchButton>(text: "Users", leftButton: BackButton(), rightButton: SearchButton(showSearch: $showSearch, searchText: $searchable))
            
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
            }
            
            ScrollView {
                LazyVStack {
                    let filteredUsers = tupleUsers.filter { user in
                        searchable.isEmpty ? true : (user.0.name ?? "").localizedCaseInsensitiveContains(searchable) || (user.0.lastName ?? "").localizedCaseInsensitiveContains(searchable)
                    }
                    
                    ForEach(filteredUsers, id: \.0.userId) { user in
                        UserRow(
                            vm: vm,
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
        .onAppear {
            Task {
                try await vm.getAllUsers()
                tupleUsers = vm.users.map {($0, false)}
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

struct AllUsersView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AllUsersView()
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal, 20)
    }
}

struct UserRow: View {
    
    let vm: ProfileViewModel
    let user: DBUser
    let showButtons: Bool
    let userStatus: UserStatus
    @State private var deleteAlert: Bool = false
    var alertTitle: String {
        userStatus == .doctor ?
        "Are you sure you want to delete the specialist?" :
        "Are you sure you want to block the user?"
    }
    var alertMessage: String {
        userStatus == .doctor ?
        "This action will not be undone. All apppointments will be cancelled." :
        "The user will be blocked and his apppointments will be cancelled."
    }
    var deleteButtonTitle: String {
        userStatus == .doctor ? "Delete" : (user.isBlocked ?? false ? "Unblock" : "Block")
    }
    
    var body: some View {
        VStack {
            HStack {
                ProfileImage(
                    photoURL: user.photoUrl,
                    frame: ScreenSize.height * 0.08,
                    color: .white
                )
                .cornerRadius(ScreenSize.width / 30)
                
                Text("\(user.name ?? user.userId) \(user.lastName ?? "")")
                    .foregroundColor(.primary)
                    .bold()
                    .padding(.leading, 8)
                    .lineLimit(1)
                
                Spacer()
                
            }
            
            if showButtons {
                HStack {
                    if vm.user?.isDoctor ?? false {
                        Button {
                            Task {
                                deleteAlert = true
                            }
                        } label: {
                            Text(deleteButtonTitle)
                                .foregroundColor(.black)
                                .font(.headline.bold())
                                .frame(height: ScreenSize.height * 0.055)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(ScreenSize.width / 30)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    
                    Button {
                        guard let url = URL(string: "tel://\(user.phoneNumber ?? "")"), UIApplication.shared.canOpenURL(url) else {
                            return
                        }
                        UIApplication.shared.open(url)
                        
                    } label: {
                        Text("Call")
                            .foregroundColor(.white)
                            .font(.headline.bold())
                            .frame(height: ScreenSize.height * 0.055)
                            .frame(maxWidth: .infinity)
                            .background(Color.mainColor)
                            .cornerRadius(ScreenSize.width / 30)
                    }
                    .buttonStyle(.plain)
                    .disabled(user.phoneNumber == nil && user.phoneNumber?.count ?? 0 < 8 ? true : false)
                }
                .alert(isPresented: $deleteAlert) {
                    Alert(
                        title: Text(alertTitle),
                        message: Text(alertMessage),
                        primaryButton: .destructive(Text(deleteButtonTitle), action: {
                            Task {
                                if userStatus == .doctor {
                                    try await vm.removeDoctor(userID: user.userId)
// MARK: Возможно вернуть
//                                    vm.doctors = []
//                                    try await vm.getAllDoctors()
                                } else {
                                    try await vm.updateBlockStatus(userID: user.userId, isBlocked: user.isBlocked != true ? true : false)
                                }
                            }
                        }),
                        secondaryButton: .default(Text("Cancel"), action: {
                            
                        })
                    )
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: ScreenSize.height * 0.1, maxHeight: ScreenSize.height * 0.21)
        .background(Color.secondaryColor)
        .cornerRadius(ScreenSize.width / 30)
    }
}
