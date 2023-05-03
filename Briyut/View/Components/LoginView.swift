//
//  LoginView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct LoginView: View {
    
    @Binding var email: String
    @Binding var password: String
    
    var body: some View {
        VStack(spacing: 30) {
            InputField(field: $email, showEye: false, isSecureField: false, title: "briyut@gmail.com", header: "Your email address")
            
            InputField(field: $password, isSecureField: true, title: "min. 6 characters", header: "Choose your password")
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(email: .constant(""), password: .constant(""))
    }
}
