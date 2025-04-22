//
//  RatingView.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 10/04/25.
//

import UIKit
import Lottie

class RatingView: UIView {

    var starViews: [LottieAnimationView] = []
    var selectedIndex: Int = -1
    var onRatingSelected: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStars()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStars()
    }

    private func setupStars() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .leading
        stack.distribution = .fillEqually
        stack.spacing = 10
        
        for index in 0..<5 {
            let star = LottieAnimationView(name: "star_anim")
            star.contentMode = .scaleAspectFit
            star.loopMode = .playOnce
            star.isUserInteractionEnabled = true
            star.tag = index
            let yellow = ColorManager.primaryColor.lottieColorValue
            let colorProvider = ColorValueProvider(yellow)
            star.setValueProvider(colorProvider, keypath: AnimationKeypath(keypath: "**.Fill 1.Color"))
            star.setValueProvider(colorProvider, keypath: AnimationKeypath(keypath: "**.Stroke 1.Color"))
            

            let tap = UITapGestureRecognizer(target: self, action: #selector(starTapped(_:)))
            star.addGestureRecognizer(tap)

            starViews.append(star)
            stack.addArrangedSubview(star)
        }

        self.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    @objc private func starTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        selectedIndex = index

        for i in 0..<starViews.count {
            let star = starViews[i]
            if i <= index {
                star.play(fromProgress: 0, toProgress: 1, loopMode: .playOnce)
            } else {
                star.stop()
                star.currentProgress = 0
            }
        }
        onRatingSelected?(index + 1)
    }
}
