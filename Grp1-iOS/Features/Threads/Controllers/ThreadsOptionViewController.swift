import UIKit

final class ThreadsOptionViewController: UIViewController {

    private let containerView = UIView()
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupOptions()

        preferredContentSize = CGSize(width: 260, height: 240)
    }

    private func setupUI() {
        view.backgroundColor = .clear

        // Card
        containerView.backgroundColor = .clear
        containerView.layer.cornerRadius = 18
        containerView.clipsToBounds = true
        view.addSubview(containerView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let blur = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = containerView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(blurView)

        // Stack (content)
        stackView.axis = .vertical
        stackView.spacing = 2
        containerView.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -6),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 6),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -6)
        ])
    }

    private func setupOptions() {
        stackView.addArrangedSubview(option(
            title: "Follow",
            icon: "person.badge.plus"
        ))

        stackView.addArrangedSubview(option(
            title: "Bookmark",
            icon: "bookmark"
        ))

        stackView.addArrangedSubview(option(
            title: "Report this user",
            icon: "flag",
            color: .systemRed
        ))

        stackView.addArrangedSubview(option(
            title: "Block user",
            icon: "hand.raised",
            color: .systemRed
        ))

        stackView.addArrangedSubview(option(
            title: "Not interested in this post",
            icon: "exclamationmark.triangle"
        ))
    }

    private func option(
        title: String,
        icon: String,
        color: UIColor = .label
    ) -> UIButton {

        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()

        config.title = title
        config.image = UIImage(systemName: icon)
        config.imagePlacement = .leading
        config.imagePadding = 12
        config.baseForegroundColor = color

        config.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 14,
            bottom: 10,
            trailing: 14
        )

        button.configuration = config
        button.contentHorizontalAlignment = .leading
        button.layer.cornerRadius = 10

        button.configurationUpdateHandler = { btn in
            btn.backgroundColor = btn.isHighlighted
                ? UIColor.white.withAlphaComponent(0.12)
                : .clear
        }

        button.addAction(UIAction { _ in
            self.dismiss(animated: true)
        }, for: .touchUpInside)

        return button
    }
}
