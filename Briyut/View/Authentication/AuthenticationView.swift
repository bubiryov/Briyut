//
//  AuthenticationView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct AuthenticationView: View {
    
    @State private var showTipsAlert: Bool = false
    @State private var showResetPasswordView: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Text("Briyut")
                        .font(.custom("Alokary", size: 25))
                        .padding(.top, ScreenSize.height * 0.1)
                    Spacer()
                }
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea(.keyboard)
                
                VStack {
                    
                    LoginView()
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, ScreenSize.height * 0.03)
                .background(Color.white)
                .cornerRadius(30)
                .shadow(radius: 10, y: -10)
                .offset(y: ScreenSize.height / 3.5)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea(.keyboard)
            }
            .background(Color.secondaryColor)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showResetPasswordView = true
                        } label: {
                            Text("Reset password")
                        }
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.secondary)
                            .bold()
                    }
                }
            }
        }
        .sheet(isPresented: $showResetPasswordView) {
            ResetPasswordView(showResetPasswordView: $showResetPasswordView)
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(21)
        }
    }
}
struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AuthenticationViewModel())
    }
}
