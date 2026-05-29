import UIKit

class GenerativeViewController4: UIViewController {

    // MARK: - Properties
    var realityParams: RealityScenario?
    var currentEventIndex = 0
    var capturedState: [String: String] = [:] // Saves all choices map

    // UI Elements
    let containerView = UIView()
    let eventTitleLabel = UILabel()
    let messagesStackView = UIStackView()
    let optionsStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6 // Phone UI vibe

        loadData()
        setupUI()
        showEvent(at: 0)
    }

    private func loadData() {
        guard let url = Bundle.main.url(forResource: "GenerativeGame4", withExtension: "json") else { return }
        do {
            let data = try Data(contentsOf: url)
            self.realityParams = try JSONDecoder().decode(RealityScenario.self, from: data)
        } catch { print(error) }
    }

    // MARK: - UI Setup
    private func setupUI() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 24
        view.addSubview(containerView)

        eventTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        eventTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        eventTitleLabel.textColor = .secondaryLabel
        containerView.addSubview(eventTitleLabel)

        messagesStackView.translatesAutoresizingMaskIntoConstraints = false
        messagesStackView.axis = .vertical
        messagesStackView.spacing = 12
        containerView.addSubview(messagesStackView)

        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        optionsStackView.axis = .vertical
        optionsStackView.spacing = 12
        containerView.addSubview(optionsStackView)

        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: optionsStackView.bottomAnchor, constant: 30),

            eventTitleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            eventTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),

            messagesStackView.topAnchor.constraint(equalTo: eventTitleLabel.bottomAnchor, constant: 20),
            messagesStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            messagesStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            optionsStackView.topAnchor.constraint(equalTo: messagesStackView.bottomAnchor, constant: 40),
            optionsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            optionsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - State Machine
    private func showEvent(at index: Int) {
        guard let scenario = realityParams else { return }

        // Clear previous UI
        messagesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if index < scenario.events.count {
            let event = scenario.events[index]
            eventTitleLabel.text = event.title

            // Build Messages
            for msg in event.messages {
                let lbl = PaddingLabel() // Custom UILabel with padding looking like a chat bubble
                lbl.text = msg
                lbl.backgroundColor = .systemBlue.withAlphaComponent(0.1)
                lbl.layer.cornerRadius = 12
                lbl.clipsToBounds = true
                lbl.numberOfLines = 0
                messagesStackView.addArrangedSubview(lbl)
            }

            // Ask Question
            let qLbl = UILabel()
            qLbl.text = event.question
            qLbl.font = .systemFont(ofSize: 16, weight: .bold)
            qLbl.textAlignment = .center
            optionsStackView.addArrangedSubview(qLbl)

            // Format Options
            for option in event.options {
                let btn = UIButton(type: .system)
                btn.setTitle(option.text, for: .normal)
                btn.backgroundColor = .systemBlue
                btn.setTitleColor(.white, for: .normal)
                btn.layer.cornerRadius = 12
                btn.titleLabel?.numberOfLines = 0
                btn.titleLabel?.textAlignment = .center
                btn.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true

                let action = UIAction { _ in self.handleOptionTap(option: option, stateKey: event.stateKey) }
                btn.addAction(action, for: .touchUpInside)
                optionsStackView.addArrangedSubview(btn)
            }

            // Animate transition
            containerView.alpha = 0
            containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            UIView.animate(withDuration: 0.3) {
                self.containerView.alpha = 1
                self.containerView.transform = .identity
            }

        } else {
            showSummaryScreen()
        }
    }

    private func handleOptionTap(option: EventOption, stateKey: String) {
        capturedState[stateKey] = option.id
        currentEventIndex += 1
        showEvent(at: currentEventIndex)
    }

    // MARK: - Summary Screen
    private func showSummaryScreen() {
        guard let summary = realityParams?.summary else { return }

        eventTitleLabel.text = summary.title
        messagesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Show Stats
        for stat in summary.stats {
            let lbl = UILabel()
            lbl.text = "\(stat.label):\n\(stat.value)"
            lbl.numberOfLines = 2
            lbl.font = .systemFont(ofSize: 16, weight: .medium)
            messagesStackView.addArrangedSubview(lbl)
        }

        // Show Final Question
        let qLbl = UILabel()
        qLbl.text = summary.finalQuestion
        qLbl.font = .systemFont(ofSize: 18, weight: .bold)
        optionsStackView.addArrangedSubview(qLbl)

        for option in summary.finalOptions {
            let btn = UIButton(type: .system)
            btn.setTitle(option.text, for: .normal)
            btn.backgroundColor = .systemRed
            btn.setTitleColor(.white, for: .normal)
            btn.layer.cornerRadius = 12
            btn.titleLabel?.numberOfLines = 0
            btn.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true

            let action = UIAction { _ in
                self.capturedState[summary.stateKey] = option.id
                print("Game Finished! Final State: \(self.capturedState)")
                // Redirect to end screen or home
            }
            btn.addAction(action, for: .touchUpInside)
            optionsStackView.addArrangedSubview(btn)
        }
    }
}

// Simple padding label for chat bubble effect
class PaddingLabel: UILabel {
    var textEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textEdgeInsets))
    }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textEdgeInsets.left + textEdgeInsets.right,
                      height: size.height + textEdgeInsets.top + textEdgeInsets.bottom)
    }
}
