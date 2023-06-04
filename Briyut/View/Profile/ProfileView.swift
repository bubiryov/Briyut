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
    
    var body: some View {
        
        NavigationView {
            
            ScrollView {
                VStack(spacing: 20) {
                    VStack {
                        
                        HStack {
                            Spacer()
                            BarButton(notEntered: $notEntered)
                        }
                        
                        Spacer()
                        
                        ProfileImage(photoURL: vm.user?.photoUrl, frame: ScreenSize.height * 0.12, color: Color.secondary.opacity(0.1))
                            .cornerRadius(ScreenSize.width / 20)
                        
                        HStack {
                            Text(vm.user?.name ?? (vm.user?.userId ?? "No"))
                                .font(.title.bold())
                                .lineLimit(1)
                            
                            Text(vm.user?.lastName ?? "name")
                                .font(.title.bold())
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        BarButton(notEntered: $notEntered)
                            .disabled(true)
                            .opacity(0)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, maxHeight: ScreenSize.width * 0.85)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(ScreenSize.width / 15)
                    
    //                if vm.user?.isDoctor == true {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)], spacing: 20) {
                        
                        NavigationLink {
                            //
                        } label: {
                            VStack {
                                Image("users")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: ScreenSize.width * 0.06)
                                Text("Users")
                                    .font(.title3.bold())
                            }
                            .foregroundColor(.mainColor)
                            .frame(maxWidth: ScreenSize.height * 0.3)
                            .frame(height: ScreenSize.height * 0.14)
                            .background(Color.secondaryColor)
                            .cornerRadius(ScreenSize.width / 20)
                        }

                        NavigationLink {
                            AddDoctorView()
                        } label: {
                            VStack {
                                Image("stethoscope")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: ScreenSize.width * 0.06)
                                Text("Doctors")
                                    .font(.title3.bold())
                            }
                            .foregroundColor(.mainColor)
                            .frame(maxWidth: ScreenSize.height * 0.3)
                            .frame(height: ScreenSize.height * 0.14)
                            .background(Color.secondaryColor)
                            .cornerRadius(ScreenSize.width / 20)
                        }

                        NavigationLink {
                            //
                        } label: {
                            VStack {
                                Image("history")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: ScreenSize.width * 0.06)
                                Text("History")
                                    .font(.title3.bold())
                            }
                            .foregroundColor(.mainColor)
                            .frame(maxWidth: ScreenSize.height * 0.3)
                            .frame(height: ScreenSize.height * 0.14)
                            .background(Color.secondaryColor)
                            .cornerRadius(ScreenSize.width / 20)
                        }
                        
                        NavigationLink {
                            //
                        } label: {
                            VStack {
                                Image("stats")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: ScreenSize.width * 0.06)
                                Text("Statistics")
                                    .font(.title3.bold())
                            }
                            .foregroundColor(.mainColor)
                            .frame(maxWidth: ScreenSize.height * 0.3)
                            .frame(height: ScreenSize.height * 0.14)
                            .background(Color.secondaryColor)
                            .cornerRadius(ScreenSize.width / 20)
                        }


                    }
    //                }
                    
                    Spacer()
                    
                }
            }
            .scrollIndicators(.hidden)
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

struct BarButton: View {
    
    @Binding var notEntered: Bool
    
    var body: some View {
        NavigationLink {
            EditProfileView(notEntered: $notEntered)
        } label: {
            BarButtonView(image: "settings", backgroundColor: .white)
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
