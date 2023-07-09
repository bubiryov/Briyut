//
//  UserRow.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.07.2023.
//

import SwiftUI

struct UserRow: View {
    
    let interfaceData: InterfaceData
    let mainViewModel: MainViewModel
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
                userEditingButtons
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(user.isBlocked ?? false ? Color.secondary.opacity(0.1) : Color.secondaryColor)
        .cornerRadius(ScreenSize.width / 30)
    }
}

//struct UserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        UserRow()
//    }
//}

@MainActor
extension UserRow {
    var userEditingButtons: some View {
        HStack {
            if interfaceData.user?.isDoctor ?? false {
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
                            try await mainViewModel.profileViewModel.removeDoctor(userID: user.userId)
                        } else {
                            try await mainViewModel.profileViewModel.updateBlockStatus(userID: user.userId, isBlocked: user.isBlocked != true ? true : false)
                        }
                    }
                }),
                secondaryButton: .default(Text("cancel-string"), action: { })
            )
        }

    }
}
