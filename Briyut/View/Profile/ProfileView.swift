//
//  ProfileView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 06.05.2023.
//

import SwiftUI
import CachedAsyncImage
import AlertToast

struct ProfileView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Binding var notEntered: Bool
    @State private var logOutAlert: Bool = false
    @State private var copyIdAlert: Bool = false
        
    var body: some View {
        
        NavigationView {
            VStack(spacing: 25) {
                TopBar<EditProfileButton, LogOutButton>(
                    text: "",
                    leftButton: EditProfileButton(notEntered: $notEntered),
                    rightButton: LogOutButton(logOutAlert: $logOutAlert)
                )
                
                ProfileImage(
                    photoURL: vm.user?.photoUrl,
                    frame: ScreenSize.height * 0.12,
                    color: Color.secondary.opacity(0.1),
                    padding: 16
                )
                .cornerRadius(ScreenSize.width / 20)
                
                HStack {
                    Text(vm.user?.name ?? (vm.user?.userId ?? "blocked-user-string".localized))
                        .font(Mariupol.bold, 22)
                        .lineLimit(1)
                    
                    Text(vm.user?.lastName ?? "")
                        .font(Mariupol.bold, 22)
                        .lineLimit(1)
                }
                                                
                VStack {
                    NavigationRow(destination: AllDoctorsView(), imageName: "stethoscope", title: "specialists-string")

                    if vm.user?.isDoctor ?? false {
                        
                        NavigationRow(destination: AllUsersView(), imageName: "users", title: "user-managment-string")
                                                
                        NavigationRow(destination: StatsView(), imageName: "stats", title: "stats-string")
                                                
                        NavigationRow(destination: HistoryView(), imageName: "history", title: "history-string")
                        
                    }
                    
                    if vm.authProviders.contains(.email) {
                        NavigationRow(destination: ChangePasswordView(), imageName: "lock", title: "change-password-string")
                    }
                    
                    Button {
                        UIPasteboard.general.string = vm.user?.userId
                        Haptics.shared.notify(.success)
                        copyIdAlert = true
                    } label: {
                        SettingsButtonView(imageName: "copy", title: "copy-id-string".localized)
                    }

                }
                
                Spacer()
                
            }
            .background(Color.backgroundColor)
            .alert(isPresented: $logOutAlert) {
                Alert(
                    title: Text("log-out-alert-string"),
                    primaryButton: .destructive(Text("log-out-string"), action: {
                        Task {
                            try vm.signOut()
                            notEntered = true
                        }
                    }),
                    secondaryButton: .default(Text("cancel-string"), action: {
                        
                    })
                )
            }
        }
        .toast(isPresenting: $copyIdAlert, duration: 1) {
            AlertToast(displayMode: .hud, type: .regular, title: "id-is-copied-string")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProfileView(notEntered: .constant(false))
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal, 20)
        .background(Color.backgroundColor)
    }
}

fileprivate struct EditProfileButton: View {
    
    @Binding var notEntered: Bool
        
    var body: some View {
        NavigationLink {
            EditProfileView(notEntered: $notEntered)
        } label: {
            BarButtonView(image: "gear")
        }
        .buttonStyle(.plain)
    }
}

fileprivate struct NavigationRow<Destination: View>: View {
    var destination: Destination
    var imageName: String
    var title: String
    
    var body: some View {
        NavigationLink(destination: destination) {
            SettingsButtonView(
                imageName: imageName,
                title: title.localized
            )
        }
    }
}

fileprivate struct LogOutButton: View {
    
    @Binding var logOutAlert: Bool
    
    var body: some View {
        Button {
            logOutAlert = true
        } label: {
            BarButtonView(image: "exit")
        }
        .buttonStyle(.plain)
    }
}

fileprivate struct SettingsButtonView: View {
    
    var imageName: String
    var title: String
    
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .scaleEffect(0.8)
                .frame(width: ScreenSize.height * 0.03)
                .foregroundColor(.staticMainColor)
                .cornerRadius(10)
            
            Text(title)
                .font(Mariupol.medium, 17)
                .foregroundColor(.primary)
                .padding(.leading, 8)
                .lineLimit(1)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: ScreenSize.height * 0.07)
        .background(Color.secondaryColor)
        .cornerRadius(ScreenSize.width / 30)
    }
}
