// MARK: - Animations

import UIKit

extension news1ViewController {
    func animateRecommendationPulse() {
        guard let glassView = self.glassView else { return }

        let pulseView = UIView(frame: glassView.bounds)
        pulseView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.22)
        pulseView.layer.cornerRadius = glassView.layer.cornerRadius
        pulseView.layer.masksToBounds = true
        pulseView.alpha = 0
        pulseView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)

        glassView.addSubview(pulseView)
        glassView.bringSubviewToFront(pulseView)

        UIView.animate(
            withDuration: 0.18,
            animations: {
                pulseView.alpha = 1
                pulseView.transform = .identity
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.25,
                    delay: 0.15,
                    options: .curveEaseOut,
                    animations: {
                        pulseView.alpha = 0
                        pulseView.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
                    },
                    completion: { _ in
                        pulseView.removeFromSuperview()
                    }
                )
            }
        )
    }

    func animateSaveBookmarkIcon() {
        let anchorView: UIView = glassView ?? self.view

        let iconSize: CGFloat = 28
        let bookmark = UIImageView(image: UIImage(systemName: "bookmark.fill"))
        bookmark.tintColor = .systemYellow
        bookmark.alpha = 0
        bookmark.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)

        anchorView.addSubview(bookmark)
        bookmark.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bookmark.topAnchor.constraint(equalTo: anchorView.topAnchor, constant: 16),
            bookmark.trailingAnchor.constraint(equalTo: anchorView.trailingAnchor, constant: -20),
            bookmark.widthAnchor.constraint(equalToConstant: iconSize),
            bookmark.heightAnchor.constraint(equalToConstant: iconSize)
        ])

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.8,
            options: .curveEaseOut,
            animations: {
                bookmark.alpha = 1
                bookmark.transform = .identity
                bookmark.transform = CGAffineTransform(translationX: 0, y: -4)
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.25,
                    delay: 0.7,
                    options: .curveEaseIn,
                    animations: {
                        bookmark.alpha = 0
                        bookmark.transform = CGAffineTransform(translationX: 0, y: -12)
                    },
                    completion: { _ in
                        bookmark.removeFromSuperview()
                    }
                )
            }
        )
    }
}
