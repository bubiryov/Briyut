//
//  SplashView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 17.05.2023.
//

import SwiftUI

struct SplashView: View {
            
    var body: some View {
        VStack {
            Text("Briyut")
                .foregroundColor(.white)
                .font(.custom("Alokary", size: 25))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mainColor)
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
