//
//  DoneAnimation.swift
//  Briyut
//
//  Created by Egor Bubiryov on 21.05.2023.
//

import SwiftUI
import Lottie

struct DoneAnimation: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        let animation = LottieAnimation.named("Done")
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .playOnce
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

struct DoneAnimation_Previews: PreviewProvider {
    static var previews: some View {
        DoneAnimation()
    }
}
