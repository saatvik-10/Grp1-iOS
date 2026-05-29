import UIKit

class IntroViewController: UIViewController {

    // MARK: - UI Components

    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        // If you have a background bubbles image, set it here:
        // iv.image = UIImage(named: "bubbles_background")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sunk Cost"
        label.textAlignment = .center
        label.textColor = UIColor(white: 0.2, alpha: 1.0)

        // Try to use Georgia (serif) to match the screenshot, fallback to system bold
        if let serifFont = UIFont(name: "Georgia-Bold", size: 40) {
            label.font = serifFont
        } else {
            label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        }

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Avoid the psychological trap of throwing good money after bad."
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = UIColor(white: 0.35, alpha: 1.0)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let capitalCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24

        // Soft drop shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.shadowRadius = 20
        view.layer.masksToBounds = false

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let capitalLabel: UILabel = {
        let label = UILabel()
        label.text = "₹50,000"
        label.font = UIFont.systemFont(ofSize: 42, weight: .semibold)
        // Deep elegant green
        label.textColor = UIColor(red: 0.18, green: 0.31, blue: 0.24, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let contextLabel: UILabel = {
        let label = UILabel()
        label.text = "You have invested ₹50,000.\nDo you cut losses or invest more?"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(white: 0.35, alpha: 1.0)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let beginnerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Begin Your Journey →", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.setTitleColor(.white, for: .normal)

        // Charcoal grey
        button.backgroundColor = UIColor(white: 0.28, alpha: 1.0)
        button.layer.cornerRadius = 22
        button.clipsToBounds = true

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewHierarchy()
        setupConstraints()
        setupActions()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Very subtle entry animation
        capitalCard.alpha = 0
        capitalCard.transform = CGAffineTransform(translationX: 0, y: 15)

        UIView.animate(withDuration: 0.7, delay: 0.1, options: [.curveEaseOut]) {
            self.capitalCard.alpha = 1
            self.capitalCard.transform = .identity
        }
    }

    // MARK: - Setup UI

    private func setupViewHierarchy() {
        // Light grey fallback background
        view.backgroundColor = UIColor(white: 0.96, alpha: 1.0)

        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        view.addSubview(capitalCard)
        capitalCard.addSubview(capitalLabel)
        capitalCard.addSubview(separatorView)
        capitalCard.addSubview(contextLabel)
        capitalCard.addSubview(beginnerButton)

        // view.addSubview(durationLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background Image
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Capital Card (Now Centered vertically with a small positive offset)
            capitalCard.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),
            capitalCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            capitalCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            // Subtitle Label (Pinned ABOVE Capital Card)
            subtitleLabel.bottomAnchor.constraint(equalTo: capitalCard.topAnchor, constant: -40),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            // Title Label (Pinned ABOVE Subtitle)
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // --- Elements Inside the Card ---

            // Capital Amount Label
            capitalLabel.topAnchor.constraint(equalTo: capitalCard.topAnchor, constant: 30),
            capitalLabel.centerXAnchor.constraint(equalTo: capitalCard.centerXAnchor),

            // Separator Line
            separatorView.topAnchor.constraint(equalTo: capitalLabel.bottomAnchor, constant: 24),
            separatorView.leadingAnchor.constraint(equalTo: capitalCard.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: capitalCard.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            // Context Label
            contextLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 24),
            contextLabel.leadingAnchor.constraint(equalTo: capitalCard.leadingAnchor, constant: 20),
            contextLabel.trailingAnchor.constraint(equalTo: capitalCard.trailingAnchor, constant: -20),

            // Beginner Button
            beginnerButton.topAnchor.constraint(equalTo: contextLabel.bottomAnchor, constant: 24),
            beginnerButton.leadingAnchor.constraint(equalTo: capitalCard.leadingAnchor, constant: 20),
            beginnerButton.trailingAnchor.constraint(equalTo: capitalCard.trailingAnchor, constant: -20),
            beginnerButton.heightAnchor.constraint(equalToConstant: 54),

            // Pin bottom of card to bottom of button with padding
            capitalCard.bottomAnchor.constraint(equalTo: beginnerButton.bottomAnchor, constant: 24)

            // Duration Label (Below Capital Card)
//            durationLabel.topAnchor.constraint(equalTo: capitalCard.bottomAnchor, constant: 20),
//            durationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupActions() {
        // Setup the hold to fill animation we previously created
        beginnerButton.setupHoldToFillAnimation(duration: 1.2)

        // Navigation target if they finish the hold
        beginnerButton.addTarget(self, action: #selector(beginButtonPressed), for: .touchUpInside)
    }

    // MARK: - Handlers

    @objc private func beginButtonPressed() {
        guard let gameVC = storyboard?.instantiateViewController(
            withIdentifier: "GameViewController"
        ) as? GameViewController else { return }

        gameVC.modalPresentationStyle = .fullScreen
        present(gameVC, animated: true)
    }
}

// MARK: - Hold to Fill Animation Extension
extension UIButton {

    func setupHoldToFillAnimation(duration: TimeInterval = 2.0) {
        gestureRecognizers?.forEach { removeGestureRecognizer($0) }

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleHoldGesture(_:)))
        longPress.minimumPressDuration = 0.0
        addGestureRecognizer(longPress)

        layer.setValue(duration, forKey: "fillDuration")
    }

    @objc private func handleHoldGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            animateFillFromLeft(gesture: gesture)
        case .ended, .cancelled, .failed:
            resetFill(completed: false)
        default: break
        }
    }

    private func animateFillFromLeft(gesture: UILongPressGestureRecognizer) {
        layer.sublayers?.first(where: { $0.name == "fillLayer" })?.removeFromSuperlayer()

        let fillLayer = CALayer()
        fillLayer.name = "fillLayer"
        // Lighter gray overlay matching the charcoal button theme
        fillLayer.backgroundColor = UIColor(white: 1.0, alpha: 0.15).cgColor

        fillLayer.frame = CGRect(x: 0, y: 0, width: 0, height: bounds.height)
        fillLayer.cornerRadius = layer.cornerRadius
        fillLayer.borderWidth = 1.5
        fillLayer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor

        fillLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
        fillLayer.position = CGPoint(x: 0, y: bounds.height / 2)

        layer.insertSublayer(fillLayer, at: 0)

        let duration = layer.value(forKey: "fillDuration") as? TimeInterval ?? 2.0

        let animation = CABasicAnimation(keyPath: "bounds.size.width")
        animation.fromValue = 0
        animation.toValue = bounds.width
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false

        fillLayer.add(animation, forKey: "widthAnimation")
        fillLayer.bounds.size.width = bounds.width

        UIView.animate(withDuration: duration) {
            self.alpha = 0.85
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self, weak gesture] in
            guard let self = self, let gesture = gesture else { return }
            if gesture.state == .changed || gesture.state == .began {
                self.onFillComplete()
            }
        }
    }

    private func resetFill(completed: Bool) {
        guard let fillLayer = layer.sublayers?.first(where: { $0.name == "fillLayer" }) else { return }
        fillLayer.removeAllAnimations()

        UIView.animate(withDuration: 0.2) {
            fillLayer.opacity = 0
            self.alpha = 1.0
        } completion: { _ in
            fillLayer.removeFromSuperlayer()
        }
    }

    private func onFillComplete() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        })

        sendActions(for: .touchUpInside)
        resetFill(completed: true)
    }
}
