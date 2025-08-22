//
//  SwipeToStopDelegate.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 31/07/25.
//


import UIKit

protocol SwipeToStopDelegate: AnyObject {
    func didSwipeToStop()
}

class SwipeToStopButtonView: UIView {

    weak var delegate: SwipeToStopDelegate?

    private let progressView = UIView()
    private let thumbView = UIView()
    private let label = UILabel()
    private var initialCenterX: CGFloat = 0
    private var panGesture: UIPanGestureRecognizer!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        self.backgroundColor = ColorManager.thirdBackgroundColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true

        // Add progress view (red fill as thumb moves)
        progressView.backgroundColor = ColorManager.redColor
        progressView.frame = CGRect(x: 0, y: 0, width: thumbView.frame.width, height: self.frame.height)
        progressView.layer.cornerRadius = self.layer.cornerRadius
        progressView.clipsToBounds = true
        self.addSubview(progressView)

        // Add label on top
        label.text = "Swipe to Stop Charging"
        label.textColor = .darkGray
        label.textAlignment = .center
        label.font = FontManager.regular()
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        // Add thumb view
        let thumbSize = self.frame.height
        thumbView.frame = CGRect(x: 0, y: 0, width: thumbSize, height: thumbSize)
        thumbView.backgroundColor = ColorManager.backgroundColor
        thumbView.layer.cornerRadius = thumbSize / 2
        thumbView.layer.shadowColor = UIColor.black.cgColor
        thumbView.layer.shadowOpacity = 0.2
        thumbView.layer.shadowOffset = CGSize(width: 0, height: 2)
        thumbView.layer.shadowRadius = 4
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        imageView.image = UIImage(systemName: "chevron.right.2", withConfiguration: config)
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        imageView.tintColor = ColorManager.redColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        thumbView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: thumbView.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: thumbView.centerXAnchor)
        ])
        
        self.addSubview(thumbView)

        // Add pan gesture
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        thumbView.addGestureRecognizer(panGesture)
        thumbView.isUserInteractionEnabled = true
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)

        switch gesture.state {
        case .began:
            label.textColor = .clear
            initialCenterX = thumbView.center.x
        case .changed:
            let newCenterX = min(max(initialCenterX + translation.x,
                                     thumbView.frame.width / 2 + 5),
                                 self.bounds.width - thumbView.frame.width / 2 - 5)
            thumbView.center.x = newCenterX

            // Update progress view to match thumb
            let progressWidth = thumbView.frame.maxX
            progressView.frame = CGRect(x: 0, y: 0, width: progressWidth, height: self.frame.height)
            label.textColor = .white
            label.text = "Stop Charging"
        case .ended, .cancelled:
            if thumbView.frame.maxX >= self.bounds.width - 10 {
                // Swipe completed
                delegate?.didSwipeToStop()
                label.textColor = .white
                thumbView.isUserInteractionEnabled = false
                label.text = "stopping..."
            } else {
                // Swipe cancelled - reset
                resetThumb(animated: true)
            }
        default:
            break
        }
    }

     func resetThumb(animated: Bool) {
        let targetX = thumbView.frame.width / 2
        label.textColor = .darkGray
        thumbView.isUserInteractionEnabled = true
        label.text = "Swipe to Stop Charging"
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.thumbView.center.x = targetX
                self.progressView.frame = CGRect(x: 0, y: 0, width: self.thumbView.frame.maxX, height: self.frame.height)
            }
        } else {
            thumbView.center.x = targetX
            progressView.frame = CGRect(x: 0, y: 0, width: thumbView.frame.maxX, height: self.frame.height)
        }
    }
}
