import UIKit

// MARK: - Keyboard Setup

extension WordleViewController {

    func setupKeyboard() {
        let rows: [[String]] = [
            ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
            ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
            ["Z", "X", "C", "V", "B", "N", "M", "⌫", "✓"]
        ]

        for row in rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 6
            rowStack.distribution = .fillEqually

            for key in row {
                let button = makeKey(title: key)
                rowStack.addArrangedSubview(button)
            }

            keyboardStack.addArrangedSubview(rowStack)
        }
    }

    private func makeKey(title: String) -> UIButton {
        let button = UIButton(type: .system)

        button.setTitle(title, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)

        button.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor.systemGray4
            : UIColor.white
        }

        button.layer.cornerRadius = 14
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.12
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4

        button.heightAnchor.constraint(equalToConstant: 52).isActive = true

        button.addAction(UIAction { _ in
            UIView.animate(withDuration: 0.08, animations: {
                button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }, completion: { _ in
                UIView.animate(withDuration: 0.08) {
                    button.transform = .identity
                }
            })
        }, for: .touchDown)

        if title == "⌫" {
            button.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        } else if title == "✓" {
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        } else {
            button.addTarget(self, action: #selector(letterTapped(_:)), for: .touchUpInside)
        }

        return button
    }
}

// MARK: - Progress & Popups

extension WordleViewController {

    func showPointsPopupFromBottom(
        text: String,
        color: UIColor,
        completion: @escaping () -> Void
    ) {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = color
        label.backgroundColor = color.withAlphaComponent(0.18)
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true

        let width: CGFloat = 54
        let height: CGFloat = 28

        let startPoint = CGPoint(
            x: view.bounds.midX,
            y: view.bounds.maxY - 150
        )

        label.frame = CGRect(x: 0, y: 0, width: width, height: height)
        label.center = startPoint
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)

        view.addSubview(label)

        let target = profitPoints.convert(
            profitPoints.bounds.center,
            to: view
        )

        UIView.animate(
            withDuration: 0.70,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.2,
            options: [.curveEaseOut],
            animations: {
                label.alpha = 1
                label.transform = .identity
                label.center.y -= 120
            }
        )

        UIView.animate(
            withDuration: 0.6,
            delay: 0.35,
            options: [.curveEaseInOut],
            animations: {
                label.center = CGPoint(
                    x: target.x + 100,
                    y: target.y - 6
                )
                label.alpha = 0
                label.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            },
            completion: { _ in
                label.removeFromSuperview()
                completion()
            }
        )
    }

    func updateProgressWithPopups(from result: GuessResult) {
        let greenCount = result.evaluations.filter { $0.state == .correct }.count
        let yellowCount = result.evaluations.filter { $0.state == .present }.count

        let totalPoints = (greenCount * 10) + (yellowCount * 5)
        guard totalPoints > 0 else { return }

        let progressIncrement =
            (Float(greenCount) * 0.10) +
            (Float(yellowCount) * 0.05)

        let popupColor: UIColor =
            greenCount > yellowCount ? .systemGreen : .systemYellow

        showPointsPopupFromBottom(
            text: "+$\(totalPoints)",
            color: popupColor
        ) {
            self.incrementProgress(by: progressIncrement)
        }
    }

    func incrementProgress(by value: Float) {
        progressScore = min(1.0, progressScore + value)

        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                self.profitPoints.setProgress(self.progressScore, animated: true)
                self.updateProgressColor()
            }
        )
    }

    func updateProgressColor() {
        switch progressScore {
        case 0.7...1.0:
            profitPoints.progressTintColor = .systemGreen
        case 0.4..<0.7:
            profitPoints.progressTintColor = .systemYellow
        default:
            profitPoints.progressTintColor = .systemRed
        }
    }
}

// MARK: - Keyboard Feedback

extension WordleViewController {

    func updateKeyboard(with result: GuessResult) {
        for evaluation in result.evaluations {
            let letter = evaluation.character
            let newState = evaluation.state

            let oldState = keyStates[letter]

            if let old = oldState {
                if old == .correct { continue }
                if old == .present && newState == .absent { continue }
            }

            keyStates[letter] = newState
            updateKeyAppearance(letter: letter, state: newState)
        }
    }

    func updateCurrentGuessFromGrid() {
        let row = engine.attempts
        var guess = ""

        for tile in tileGrid[row] {
            if let text = tile.label.text, !text.isEmpty {
                guess.append(text.lowercased())
            }
        }

        currentGuess = guess
    }

    private func updateKeyAppearance(letter: Character, state: LetterTileView.State) {
        let letterString = String(letter).uppercased()

        for row in keyboardStack.arrangedSubviews {
            guard let rowStack = row as? UIStackView else { continue }

            for view in rowStack.arrangedSubviews {
                guard let button = view as? UIButton else { continue }
                guard button.title(for: .normal) == letterString else { continue }

                UIView.animate(withDuration: 0.25) {
                    switch state {
                    case .correct:
                        button.backgroundColor = .systemGreen
                        button.setTitleColor(.white, for: .normal)
                    case .present:
                        button.backgroundColor = .systemYellow
                        button.setTitleColor(.white, for: .normal)
                    case .absent:
                        button.backgroundColor = .systemGray2
                        button.setTitleColor(.white, for: .normal)
                    case .empty:
                        break
                    }
                }
            }
        }
    }
}

// MARK: - Confetti & Animations

extension WordleViewController {

    func showConfetti() {
        let emitter = CAEmitterLayer()

        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else { return }

        emitter.emitterPosition = CGPoint(
            x: window.bounds.midX,
            y: -10
        )
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(
            width: window.bounds.width,
            height: 1
        )

        emitter.zPosition = CGFloat(Float.greatestFiniteMagnitude)

        let colors: [UIColor] = [
            .systemGreen,
            .systemBlue,
            .systemYellow,
            .systemPink,
            .systemOrange
        ]

        emitter.emitterCells = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 6
            cell.lifetime = 5.0
            cell.velocity = 150
            cell.velocityRange = 60
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.spin = 3
            cell.spinRange = 4
            cell.scale = 0.04
            cell.scaleRange = 0.02
            cell.color = color.cgColor
            cell.contents = UIImage(systemName: "circle.fill")?.cgImage
            return cell
        }

        window.layer.addSublayer(emitter)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            emitter.birthRate = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            emitter.removeFromSuperlayer()
        }
    }

    func slideHintText(_ text: String) {
        if hintLabel.alpha == 0 {
            hintLabel.text = text
            hintLabel.transform = CGAffineTransform(translationX: 0, y: 20)

            UIView.animate(
                withDuration: 0.45,
                delay: 0,
                usingSpringWithDamping: 0.85,
                initialSpringVelocity: 0.4,
                options: [.curveEaseOut],
                animations: {
                    self.hintLabel.alpha = 1
                    self.hintLabel.transform = .identity
                }
            )
            return
        }

        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.hintLabel.alpha = 0
                self.hintLabel.transform = CGAffineTransform(translationX: 0, y: -16)
            },
            completion: { _ in
                self.hintLabel.transform = .identity

                self.hintLabel.text = text

                self.view.layoutIfNeeded()

                self.hintLabel.transform = CGAffineTransform(translationX: 0, y: 20)

                UIView.animate(
                    withDuration: 0.45,
                    delay: 0,
                    usingSpringWithDamping: 0.85,
                    initialSpringVelocity: 0.4,
                    options: [.curveEaseOut],
                    animations: {
                        self.hintLabel.alpha = 1
                        self.hintLabel.transform = .identity
                    },
                    completion: { _ in
                        self.glowHintLabel()
                    }
                )
            }
        )
    }

    private func glowHintLabel() {
        hintLabel.layer.shadowColor = UIColor(
            red: 1.0,
            green: 0.9,
            blue: 0.3,
            alpha: 1.0
        ).cgColor
        hintLabel.layer.shadowRadius = 38
        hintLabel.layer.shadowOpacity = 0.8
        hintLabel.layer.shadowOffset = .zero

        let glowIn = CABasicAnimation(keyPath: "shadowOpacity")
        glowIn.fromValue = 0
        glowIn.toValue = 0.8
        glowIn.duration = 0.35
        glowIn.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let pulse = CABasicAnimation(keyPath: "shadowRadius")
        pulse.fromValue = 12
        pulse.toValue = 22
        pulse.duration = 0.6
        pulse.autoreverses = true
        pulse.repeatCount = 2
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let glowOut = CABasicAnimation(keyPath: "shadowOpacity")
        glowOut.fromValue = 0.8
        glowOut.toValue = 0
        glowOut.beginTime = CACurrentMediaTime() + 1.2
        glowOut.duration = 0.4
        glowOut.fillMode = .forwards
        glowOut.isRemovedOnCompletion = false

        hintLabel.layer.add(glowIn, forKey: "glowIn")
        hintLabel.layer.add(pulse, forKey: "pulse")
        hintLabel.layer.add(glowOut, forKey: "glowOut")
    }
}
