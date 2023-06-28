//
//  SplashView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 17.05.2023.
//

import SwiftUI

//struct SplashView: View {
//
//    var body: some View {
//        VStack {
//            Text("Rubinko")
//                .foregroundColor(.mainColor)
//                .font(.custom("Alokary", size: 25))
//                .tracking(2)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.white)
//    }
//}

//struct SplashView: View {
//    @State private var shouldAnimate = false
//    let word = "Rubinko"
//
//    var body: some View {
//        HStack(spacing: 1) {
//            ForEach(Array(word.enumerated()), id: \.offset) { index, char in
//                Text(String(char))
//                    .foregroundColor(.mainColor)
//                    .font(.custom("Alokary", size: 25))
//                    .tracking(2)
//                    .offset(y: shouldAnimate ? 0 : -500)
//                    .animation(.interpolatingSpring(mass: 1, stiffness: 100, damping: 15, initialVelocity: 0).delay(0.2 * Double(index)))
//            }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.white)
//        .onAppear {
//            withAnimation {
//                shouldAnimate = true
//            }
//        }
//    }
//}

struct SplashView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 1) {
            ForEach(Array("Rubinko").indices, id: \.self) { index in
                Text(String(Array("Rubinko")[index]))
                    .foregroundColor(.staticMainColor)
                    .font(.custom("Alokary", size: 25))
                    .tracking(2)
                    .offset(y: isAnimating ? 0 : -ScreenSize.height)
                    .animation(.interpolatingSpring(mass: 1, stiffness: 100, damping: 15, initialVelocity: 0).delay(Double(index) * 0.2), value: isAnimating)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundColor)
        .onAppear {
            Task {
                try await Task.sleep(nanoseconds: 300_000_000)
                isAnimating = true
            }
        }
    }
}



struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}


