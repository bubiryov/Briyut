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
    var filteredUsers: [DBUser] {
        return vm.users.filter { user in
            searchable.isEmpty ? true : (user.name ?? "").localizedCaseInsensitiveContains(searchable) || (user.lastName ?? "").localizedCaseInsensitiveContains(searchable)
        }
    }
    
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
                    ForEach(filteredUsers, id: \.userId) { user in
                        UserRow(user: user, showCallButton: true)
                    }
                }
                .onAppear {
                    Task {
                        try await vm.getAllUsers()
                    }
            }
            }
            
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
    
    let user: DBUser
    let showCallButton: Bool
    
    var body: some View {
        HStack {
            ProfileImage(photoURL: user.photoUrl, frame: ScreenSize.height * 0.08, color: .lightBlueColor)
                .cornerRadius(ScreenSize.width / 30)
            
            Text("\(user.name ?? user.userId) \(user.lastName ?? "")")
                .foregroundColor(.primary)
                .bold()
                .padding(.leading, 8)
                .lineLimit(1)
            
            Spacer()
            
            if let phoneNumber = user.phoneNumber, showCallButton == true {
                Button {
                    guard let url = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) else {
                        return
                    }
                    UIApplication.shared.open(url)
                } label: {
                    Image("call")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.4)
                        .frame(width: ScreenSize.height * 0.05)
                        .foregroundColor(.white)
                        .background(Color.mainColor)
                        .cornerRadius(ScreenSize.width / 30)
                }
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: ScreenSize.height * 0.1)
        .background(Color.secondaryColor)
        .cornerRadius(ScreenSize.width / 30)
    }
}
