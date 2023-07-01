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
        ZStack {
            
            Color.backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack {
                BarTitle<BackButton, SearchButton>(
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
            .onChange(of: vm.users, perform: { _ in
                withAnimation(.easeInOut(duration: 0.15)) {
                    tupleUsers = vm.users.map {($0, false)}
                }
            })
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
}

struct AllUsersView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AllUsersView()
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal, 20)
        .background(Color.backgroundColor)
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
        "delete-specialist-alert-title-string".localized :
        (user.isBlocked ?? false ? "unblock-user-alert-title-string".localized : "block-user-alert-title-string".localized)
    }
    
    var alertMessage: String {
        userStatus == .doctor ?
        "delete-specialist-alert-message-string".localized :
        (user.isBlocked ?? false ? "unblock-user-alert-message-string".localized : "block-user-alert-message-string".localized)
    }
    var deleteButtonTitle: String {
        userStatus == .doctor ? "delete-string".localized : (user.isBlocked ?? false ? "unblock-string".localized : "block-string".localized)
    }
    
    var body: some View {
        VStack {
            HStack {
                ProfileImage(
                    photoURL: user.photoUrl,
                    frame: ScreenSize.height * 0.06,
                    color: .clear,
                    padding: 10
                )
                .cornerRadius(ScreenSize.width / 30)
                
                Text("\(user.name ?? user.userId) \(user.lastName ?? "")")
                    .font(Mariupol.medium, 17)
                    .foregroundColor(.primary)
                    .padding(.leading, 8)
                    .lineLimit(1)
                
                Spacer()
                
            }
            .frame(height: ScreenSize.height * 0.09)
            
            if showButtons {
                HStack {
                    if vm.user?.isDoctor ?? false {
                        Button {
                            Task {
                                Haptics.shared.notify(.warning)
                                deleteAlert = true
                            }
                        } label: {
                            Text(deleteButtonTitle)
                                .foregroundColor(.black)
                                .font(Mariupol.medium, 17)
                                .frame(height: ScreenSize.height * 0.05)
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
                        Text("call-string")
                            .foregroundColor(.white)
                            .font(Mariupol.medium, 17)
                            .frame(height: ScreenSize.height * 0.05)
                            .frame(maxWidth: .infinity)
                            .background(Color.mainColor)
                            .cornerRadius(ScreenSize.width / 30)
                    }
                    .buttonStyle(.plain)
                    .disabled(user.phoneNumber == nil && user.phoneNumber?.count ?? 0 < 8 ? true : false)
                }
                .offset(y: -10)
                .alert(isPresented: $deleteAlert) {
                    Alert(
                        title: Text(alertTitle),
                        message: Text(alertMessage),
                        primaryButton: .destructive(Text(deleteButtonTitle), action: {
                            Task {
                                if userStatus == .doctor {
                                    try await vm.removeDoctor(userID: user.userId)
                                } else {
                                    try await vm.updateBlockStatus(userID: user.userId, isBlocked: user.isBlocked != true ? true : false)
                                }
                            }
                        }),
                        secondaryButton: .default(Text("cancel-string"), action: { })
                    )
                }
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
//        .frame(minHeight: ScreenSize.height * 0.09, maxHeight: 200)
        .background(user.isBlocked ?? false ? Color.secondary.opacity(0.1) : Color.secondaryColor)
        .cornerRadius(ScreenSize.width / 30)
    }
}
