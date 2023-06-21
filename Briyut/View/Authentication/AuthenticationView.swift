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
    @Binding var notEntered: Bool
    
    var body: some View {
        GeometryReader { _ in
            NavigationView {
                ZStack {
                    VStack {
                        Text("Rubinko")
                            .foregroundColor(.white)
                            .tracking(2)
                            .font(.custom("Alokary", size: 25))
                            .padding(.top, ScreenSize.height * 0.14)

                        Spacer()
                    }
                    .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        
                        LoginView(notEntered: $notEntered)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, ScreenSize.height * 0.05)
                    .background(Color.white)
                    .cornerRadius(ScreenSize.width / 30)
                    .shadow(radius: 10, y: -10)
                    .offset(y: ScreenSize.height / 3.5)
                    .edgesIgnoringSafeArea(.all)
                }
                .background(Color.mainColor)
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
                    .presentationCornerRadius(20)
            }
        }.ignoresSafeArea(.keyboard)
    }
}
struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView(notEntered: .constant(true))
            .environmentObject(AuthenticationViewModel())
    }
}
