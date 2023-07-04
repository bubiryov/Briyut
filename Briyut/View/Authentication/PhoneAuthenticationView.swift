//
//  PhoneAuthenticationView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.05.2023.
//

import SwiftUI
import OtpView_SwiftUI

struct PhoneAuthenticationView: View {
    
    @EnvironmentObject var vm: AuthenticationViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var phoneNumber: String = ""
    @State private var code: String = ""
    @State private var sentSms: Bool = false
    @State private var loading: Bool = false
    @Binding var notEntered: Bool
    private var activeButton: Bool {
        if phoneNumber.count < 10 || phoneNumber.count > 13 {
            return false
        }
        return true
    }
        
    var body: some View {
        VStack {
            
            TopBar<BackButton, Text>(text: "phone-sign-in-string", leftButton: BackButton(presentationMode: _presentationMode))
            
            if sentSms {
                Spacer()
            }
                                    
            if sentSms {
                OtpView_SwiftUI(
                    otpCode: $code,
                    otpCodeLength: 6,
                    textColor: .primary,
                    textSize: CGFloat(25)
                )
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .padding(.horizontal)
                
                Spacer()
                
                Button {
                    verifyCodeAndHandleActions()
                } label: {
                    AccentButton(
                        text: "done-string",
                        isButtonActive: code.count != 6 ? false : true
                    )
                }
                .disabled(loading)
                
            } else {
                
                AuthInputField(field: $phoneNumber, isSecureField: false, title: "+380", header: "your-phone-number-string")
                    .keyboardType(.numberPad)
                    .padding(.top)
                
                Spacer()
                
                Button {
                    sendCodeAndHandleActions()
                } label: {
                    AccentButton(
                        text: "send-sms-string",
                        isButtonActive: activeButton, animation: loading
                    )
                }
                .disabled(loading)
                
            }
        }
        .padding(.top, topPadding())
        .padding(.bottom, 20)
        .padding(.horizontal, 20)
        .background(Color.backgroundColor)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.large)
        .onDisappear {
            vm.errorText = nil
            print("Disappear")
        }
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

struct PhoneAuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PhoneAuthenticationView(notEntered: .constant(true))
                .environmentObject(AuthenticationViewModel())
        }
    }
}

extension PhoneAuthenticationView {
    func verifyCodeAndHandleActions() {
        Task {
            do {
                loading = true
                try await vm.verifyCode(code: code)
                hideKeyboard()
                notEntered = false
                sentSms = false
                loading = false
            } catch {
                loading = false
                print("Verifying code error")
            }
        }
    }
    
    func sendCodeAndHandleActions() {
        Task {
            do {
                loading = true
                try await vm.sendCode(phoneNumber)
                withAnimation(.easeInOut(duration: 0.1)) {
                    sentSms = true
                }
                loading = false
            } catch {
                loading = false
                print("Code was not sent")
            }
        }
    }
}

