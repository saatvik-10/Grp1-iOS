import UIKit

// MARK: - Jargons

extension news1ViewController {
    func setupJargons() {
        guard !didSetupJargons else { return }
        didSetupJargons = true

        guard let jargons = article?.jargons else { return }

        glassView.layoutIfNeeded()

        glassView.isUserInteractionEnabled = true
        glassView.subviews
            .filter { $0 is UIButton }
            .forEach { $0.removeFromSuperview() }

        let buttonSize: CGFloat = 90
        let padding: CGFloat = 20
        let maxAttempts = 50

        let maxX = glassView.bounds.width - buttonSize - padding
        let maxY = glassView.bounds.height - buttonSize - padding

        guard maxX > padding, maxY > padding else { return }

        var placedFrames: [CGRect] = []

        for word in jargons {
            let button = UIButton(type: .system)
            button.setTitle(word, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = AppTheme.shared.dominantColor
            button.layer.cornerRadius = buttonSize / 2
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .center

            button.accessibilityIdentifier = word
            button.addTarget(self, action: #selector(jargonTapped(_:)), for: .touchUpInside)

            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.25
            button.layer.shadowRadius = 6
            button.layer.shadowOffset = CGSize(width: 0, height: 4)

            var placed = false

            for _ in 0..<maxAttempts {
                let randomX = CGFloat.random(in: padding...maxX)
                let randomY = CGFloat.random(in: padding...maxY)

                let frame = CGRect(
                    x: randomX,
                    y: randomY,
                    width: buttonSize,
                    height: buttonSize
                )

                let overlaps = placedFrames.contains {
                    $0.insetBy(dx: -10, dy: -10).intersects(frame)
                }

                if !overlaps {
                    button.frame = frame
                    placedFrames.append(frame)
                    placed = true
                    break
                }
            }

            if !placed { continue }

            glassView.addSubview(button)
            glassView.bringSubviewToFront(button)
            addFloatingMotion(to: button, in: glassView)
            addTwinkleEffect(to: button)
        }
    }

    @objc func jargonTapped(_ sender: UIButton) {
        if let article = article {
            _ = article.overview.joined(separator: " ")
            ArticleScorer.shared.updateWeights(for: article.title, body: article.bodyText, signal: .readFull)
        }

        guard let word = sender.accessibilityIdentifier else { return }

        print("Jargon tapped:", word)

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        selectedJargon = word
        selectedWord.word = word
        performSegue(withIdentifier: "showJargonDetail", sender: self)
    }

    private func addTwinkleEffect(to view: UIView) {
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 1.0
        scale.toValue = 1.05
        scale.duration = 1.3
        scale.autoreverses = true
        scale.repeatCount = .infinity
        scale.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        view.layer.add(scale, forKey: "twinkle")
    }

    private func addFloatingMotion(to button: UIButton, in container: UIView) {

        let maxOffset: CGFloat = 15

        func animate() {
            let dx = CGFloat.random(in: -maxOffset...maxOffset)
            let dy = CGFloat.random(in: -maxOffset...maxOffset)

            var newCenter = CGPoint(
                x: button.center.x + dx,
                y: button.center.y + dy
            )

            let halfSize = button.bounds.width / 2
            let minX = halfSize
            let maxX = container.bounds.width - halfSize
            let minY = halfSize
            let maxY = container.bounds.height - halfSize

            newCenter.x = min(max(newCenter.x, minX), maxX)
            newCenter.y = min(max(newCenter.y, minY), maxY)

            UIView.animate(
                withDuration: Double.random(in: 2.8...4.2),
                delay: 0,
                options: [.curveEaseInOut, .allowUserInteraction],
                animations: { button.center = newCenter },
                completion: { _ in animate() }
            )
        }

        animate()
    }
}
