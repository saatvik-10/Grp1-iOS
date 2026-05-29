import UIKit

class GenerativeViewController2: UIViewController {

    // MARK: - Properties
    var classroomParams: ClassroomScenario?
    var currentEnvelopeIndex = 0
    var playerReactions: [String: String] = [:] // Saves their choices

    // UI Elements (Envelopes)
    let envelopeTitleLabel = UILabel()
    let textStackView = UIStackView()
    let reactionsStackView = UIStackView()

    // UI Elements (Final UI)
    let finalContainer = UIView()
    let confidenceSlider = UISlider()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // 1. Load the JSON here
        loadData()

        // 2. Setup the UI layout (not written out to save space, but similar to Screen 1)
        setupUI()
        // 3. Show first envelope
        showEnvelope(at: 0)
    }

        let continueButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Continue", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.layer.cornerRadius = 12
        return btn
    }()

        // MARK: - UI Setup
    private func setupUI() {
        envelopeTitleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        envelopeTitleLabel.textAlignment = .center
        envelopeTitleLabel.numberOfLines = 0
        envelopeTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        textStackView.axis = .vertical
        textStackView.spacing = 16
        textStackView.alignment = .center
        textStackView.translatesAutoresizingMaskIntoConstraints = false

        reactionsStackView.axis = .vertical
        reactionsStackView.spacing = 12
        reactionsStackView.translatesAutoresizingMaskIntoConstraints = false

        finalContainer.translatesAutoresizingMaskIntoConstraints = false
        finalContainer.isHidden = true

        view.addSubview(envelopeTitleLabel)
        view.addSubview(textStackView)
        view.addSubview(reactionsStackView)
        view.addSubview(finalContainer)

        NSLayoutConstraint.activate([
            // Envelope Title at the top
            envelopeTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            envelopeTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            envelopeTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Text stack right below the title
            textStackView.topAnchor.constraint(equalTo: envelopeTitleLabel.bottomAnchor, constant: 40),
            textStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Reaction buttons anchored to the bottom
            reactionsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            reactionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            reactionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Final assessment container in the absolute center
            finalContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            finalContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            finalContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40)
        ])

                // --- Add the Continue Button to the Final Container ---
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)

        finalContainer.addSubview(continueButton)

        NSLayoutConstraint.activate([
            continueButton.topAnchor.constraint(equalTo: finalContainer.topAnchor, constant: 40),
            continueButton.bottomAnchor.constraint(equalTo: finalContainer.bottomAnchor),
            continueButton.leadingAnchor.constraint(equalTo: finalContainer.leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: finalContainer.trailingAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])

    }

    private func loadData() {
        guard let url = Bundle.main.url(forResource: "GenerativeGame2", withExtension: "json") else { return }
        do {
            let data = try Data(contentsOf: url)
            self.classroomParams = try JSONDecoder().decode(ClassroomScenario.self, from: data)
        } catch { print(error) }
    }

    // MARK: - State Machine
    func showEnvelope(at index: Int) {
        guard let scenario = classroomParams else { return }

        if index < scenario.envelopes.count {
            // Display Envelope Data
            let envelope = scenario.envelopes[index]
            envelopeTitleLabel.text = envelope.title

            // Note: Add cool UIView flip/open animation here

            // Populate revealed texts
            textStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                        for text in envelope.revealedTexts {
                let lbl = UILabel()
                lbl.text = text
                lbl.font = .systemFont(ofSize: 18)
                lbl.textAlignment = .center
                lbl.numberOfLines = 0
                textStackView.addArrangedSubview(lbl)
            }

            // Populate reaction buttons
            reactionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                        for reaction in envelope.reactionOptions {
                let btn = UIButton(type: .system)
                btn.setTitle(reaction, for: .normal)
                btn.backgroundColor = .systemGray6
                btn.layer.cornerRadius = 8
                btn.heightAnchor.constraint(equalToConstant: 50).isActive = true

                let action = UIAction { _ in self.handleReactionTap(reaction: reaction, envelopeId: envelope.id) }
                btn.addAction(action, for: .touchUpInside)
                reactionsStackView.addArrangedSubview(btn)
            }

        } else {
            // All envelopes opened -> Show Final Assessment
            showFinalAssessment()
        }
    }

    func handleReactionTap(reaction: String, envelopeId: String) {
        playerReactions[envelopeId] = reaction

        // Animate out current envelope, animate in the next one
        currentEnvelopeIndex += 1
        showEnvelope(at: currentEnvelopeIndex)
    }

    func showFinalAssessment() {
        // Hide Envelope UI, bring in the Slider and the Final Question
        envelopeTitleLabel.isHidden = true
        textStackView.isHidden = true
        reactionsStackView.isHidden = true
        finalContainer.isHidden = false

        let sliderData = classroomParams?.finalAssessment.slider
        // Set slider labels based on sliderData.minLabel and maxLabel...
    }
        @objc func continueTapped() {
        // Collect choices if needed
        print("Moving to Screen 3. Final choices: \(playerReactions)")

        let screen3 = GenerativeViewController3()
        screen3.modalPresentationStyle = .fullScreen

        // Push or Present based on your app structure
        self.present(screen3, animated: true)
    }

}
