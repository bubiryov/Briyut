//
//  SignInEmailView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct AuthenticationView: View {
    
    @StateObject var vm = AuthenticationViewModel()
    
    var body: some View {
        VStack(spacing: 30) {
            
            LoginView(email: $vm.email, password: $vm.password)
            
            AccentButton(email: $vm.email, password: $vm.password)
            
        }
        .padding(.horizontal)
    }
}

struct SignInEmailView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}
