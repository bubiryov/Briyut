//
//  ProfileView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 06.05.2023.
//

import SwiftUI
import CachedAsyncImage

struct ProfileView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Binding var notEntered: Bool
    @State private var logOutAlert: Bool = false
    @State private var copyIdAlert: Bool = false
    
    var body: some View {
        
        NavigationView {
            VStack(spacing: 20) {
                BarTitle<CopyIdButton, LogOutButton>(
                    text: "",
                    leftButton: CopyIdButton(vm: vm, copyIdAlert: $copyIdAlert),
                    rightButton: LogOutButton(logOutAlert: $logOutAlert)
                )
                
                ProfileImage(
                    photoURL: vm.user?.photoUrl,
                    frame: ScreenSize.height * 0.12,
                    color: Color.secondary.opacity(0.1)
                )
                .cornerRadius(ScreenSize.width / 20)
                
                HStack {
                    Text(vm.user?.name ?? (vm.user?.userId ?? "Blocked user"))
                        .font(.title2.bold())
                        .lineLimit(1)
                    
                    Text(vm.user?.lastName ?? "")
                        .font(.title2.bold())
                        .lineLimit(1)
                }
                                
                NavigationLink {
                    EditProfileView(notEntered: $notEntered)
                } label: {
                    Text("Edit profile")
                        .frame(width: ScreenSize.height * 0.2, height: ScreenSize.height * 0.05)
                        .buttonStyle(.plain)
                        .foregroundColor(.white)
                        .bold()
                        .background(Color.mainColor)
                        .cornerRadius(ScreenSize.width / 30)
                }
                                                
                VStack {
                    NavigationRow(destination: AllDoctorsView(), imageName: "stethoscope", title: "Specialists")

                    if vm.user?.isDoctor ?? false {
                        
                        NavigationRow(destination: AllUsersView(), imageName: "users", title: "User managment")
                                                
                        NavigationRow(destination: StatsView(), imageName: "stats", title: "Stats")
                                                
                        NavigationRow(destination: HistoryView(), imageName: "history", title: "History")
                        
                    }
                    
                    if !vm.authProviders.contains(.phone) {
                        NavigationRow(destination: ChangePasswordView(), imageName: "lock", title: "Change password")
                    }
                }
                
                Spacer()
                
            }
            .alert(isPresented: $logOutAlert) {
                Alert(
                    title: Text("Are you sure you want to log out?"),
                    primaryButton: .destructive(Text("Log out"), action: {
                        Task {
                            try vm.signOut()
                            notEntered = true
                        }
                    }),
                    secondaryButton: .default(Text("Cancel"), action: {
                        
                    })
                )
            }
        }
        .alert(isPresented: $copyIdAlert) {
            Alert(
                title: Text("UserID has been copied"),
                dismissButton: .default(Text("Got it!"))
            )
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
    }
}

struct SettingsButton: View {
    
    @Binding var notEntered: Bool
    
    var body: some View {
        NavigationLink {
            EditProfileView(notEntered: $notEntered)
        } label: {
            BarButtonView(image: "settings", backgroundColor: .secondary.opacity(0.1))
        }
        .buttonStyle(.plain)
    }
}

struct ProfileImage: View {
    
    var photoURL: String?
    var frame: CGFloat
    var color: Color
    
    var body: some View {
        VStack {
            CachedAsyncImage(url: URL(string: photoURL ?? ""), urlCache: .imageCache) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: frame, height: frame, alignment: .center)
                    .clipped()
                
            } placeholder: {
                Image(systemName: "person.fill")
                    .resizable()
                    .padding()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: frame, height: frame, alignment: .center)
                    .clipped()
                    .foregroundColor(.secondary)
                    .background(color)
            }
        }
    }
}

struct CopyIdButton: View {
    
    let vm: ProfileViewModel
    @Binding var copyIdAlert: Bool
    
    var body: some View {
        Button {
            UIPasteboard.general.string = vm.user?.userId
            copyIdAlert = true
        } label: {
            BarButtonView(image: "copy")
        }
        .buttonStyle(.plain)
    }
}

struct NavigationRow<Destination: View>: View {
    var destination: Destination
    var imageName: String
    var title: String
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.8)
                    .frame(width: ScreenSize.height * 0.03)
                    .foregroundColor(.mainColor)
                    .cornerRadius(10)
                
                Text(title)
                    .foregroundColor(.primary)
                    .bold()
                    .padding(.leading, 8)
                    .lineLimit(1)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: ScreenSize.height * 0.06)
            .background(Color.secondaryColor)
            .cornerRadius(ScreenSize.width / 30)
        }
    }
}

struct LogOutButton: View {
    
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
