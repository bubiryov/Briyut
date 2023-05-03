//
//  PhoneAuthenticationView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.05.2023.
//

import SwiftUI

struct PhoneAuthenticationView: View {
    
    @EnvironmentObject var vm: AuthenticationViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var phoneNumber: String = ""
    @State private var code: String = ""
    @State private var sentSms: Bool = false
    private var activeButton: Bool {
        if phoneNumber.count < 10 || phoneNumber.count > 13 {
            return false
        }
        return true
    }
    
    var body: some View {
        VStack(spacing: ScreenHeight.main * 0.03) {
            if sentSms {
                InputField(field: $code, isSecureField: false, title: "", header: "Code")
                    .keyboardType(.numberPad)
                
                Button {
                    Task {
                        try await vm.verifyCode(code: code)
                    }
                } label: {
                    AccentButton(text: "Done", isButtonActive: code.count != 6 ? false : true)
                }
                
            } else {
                InputField(field: $phoneNumber, isSecureField: false, title: "+380", header: "Your phone number")
                    .keyboardType(.numberPad)
                
                Button {
                    Task {
                        try await vm.sendCode(phoneNumber)
                        sentSms = true
                    }
                } label: {
                    AccentButton(text: "Send SMS", isButtonActive: activeButton)
                }
                
                HStack {
                    if let error = vm.errorText {
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: ScreenHeight.main * 0.02)
            }
            
            Spacer()
        }
        .navigationTitle("Sign in with phone")
        .padding(.top)
        .padding(.horizontal, 30)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton(presentationMode: presentationMode))
        .navigationBarTitleDisplayMode(.large)
        .onDisappear {
            vm.errorText = nil
        }
    }
}

struct PhoneAuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PhoneAuthenticationView()
                .environmentObject(AuthenticationViewModel())
        }
    }
}
