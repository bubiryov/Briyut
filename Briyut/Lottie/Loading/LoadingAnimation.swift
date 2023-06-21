//
//  LoadingAnimation.swift
//  Briyut
//
//  Created by Egor Bubiryov on 21.06.2023.
//

import SwiftUI
import Lottie

struct LoadingAnimation: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        let animation = LottieAnimation.named("loading")
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        view.addSubview(animationView)
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),
            animationView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor),
            animationView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])

        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        //
    }
}

struct LoadingAnimation_Previews: PreviewProvider {
    static var previews: some View {
        LoadingAnimation()
            .background(Color.mainColor)
    }
}
