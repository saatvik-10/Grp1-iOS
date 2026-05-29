import UIKit

class GenerativeViewController3: UIViewController {

    // MARK: - Properties
    var calculatorParams: CalculatorScenario?

    let scrollView = UIScrollView()
    let mainStackView = UIStackView() // Holds Part 1, Part 2, Part 3 vertically

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        loadData()
        setupUI()
        populateData()
    }

    private func loadData() {
        guard let url = Bundle.main.url(forResource: "GenerativeGame3", withExtension: "json") else { return }
        do {
            let data = try Data(contentsOf: url)
            self.calculatorParams = try JSONDecoder().decode(CalculatorScenario.self, from: data)
        } catch { print(error) }
    }

    // MARK: - UI Setup
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 50
        mainStackView.alignment = .fill

        view.addSubview(scrollView)
        scrollView.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            mainStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -40),
            mainStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
    }

    private func populateData() {
        guard let scenario = calculatorParams else { return }

        // --- Header ---
        let titleLabel = UILabel()
        titleLabel.text = scenario.meta.title
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        mainStackView.addArrangedSubview(titleLabel)

        // --- Part 1: Allocation ---
        let part1Label = UILabel()
        part1Label.text = scenario.part1.title
        part1Label.font = .systemFont(ofSize: 22, weight: .semibold)
        mainStackView.addArrangedSubview(part1Label)

        for fact in scenario.part1.facts {
            let factLbl = UILabel()
            factLbl.text = "• " + fact
            factLbl.textColor = .systemRed
            factLbl.font = .systemFont(ofSize: 18, weight: .medium)
            mainStackView.addArrangedSubview(factLbl)
        }

        // --- Part 2: Upside Scenarios ---
        let part2Label = UILabel()
        part2Label.text = scenario.part2.title
        part2Label.font = .systemFont(ofSize: 22, weight: .semibold)
        mainStackView.addArrangedSubview(part2Label)

        let scenariosStack = UIStackView()
        scenariosStack.axis = .vertical
        scenariosStack.spacing = 16

        for startup in scenario.part2.scenarios {
            let cardBtn = UIButton(type: .system)
            cardBtn.setTitle("\(startup.emoji) \(startup.name)", for: .normal)
            cardBtn.backgroundColor = .systemGray6
            cardBtn.layer.cornerRadius = 12
            cardBtn.heightAnchor.constraint(equalToConstant: 60).isActive = true

            let action = UIAction { _ in self.handleScenarioTap(startup) }
            cardBtn.addAction(action, for: .touchUpInside)
            scenariosStack.addArrangedSubview(cardBtn)
        }
        mainStackView.addArrangedSubview(scenariosStack)

        // --- Part 3: Negotiation ---
        let part3Label = UILabel()
        part3Label.text = scenario.part3.title
        part3Label.font = .systemFont(ofSize: 22, weight: .semibold)
        mainStackView.addArrangedSubview(part3Label)

        let negStack = UIStackView()
        negStack.axis = .vertical
        negStack.spacing = 12

        for option in scenario.part3.options {
            let btn = UIButton(type: .system)
            btn.setTitle(option.text, for: .normal)
            btn.backgroundColor = .systemBlue
            btn.setTitleColor(.white, for: .normal)
            btn.layer.cornerRadius = 8
            btn.titleLabel?.numberOfLines = 0
            btn.titleLabel?.textAlignment = .center
            btn.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true

            let action = UIAction { _ in self.handleNegotiationTap(option) }
            btn.addAction(action, for: .touchUpInside)
            negStack.addArrangedSubview(btn)
        }
        mainStackView.addArrangedSubview(negStack)

        let continueBtn = UIButton(type: .system)
    continueBtn.setTitle("Proceed to Month 3", for: .normal)
    continueBtn.backgroundColor = .black
    continueBtn.setTitleColor(.white, for: .normal)
    continueBtn.layer.cornerRadius = 12
    continueBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true

    let action = UIAction { _ in
        let screen4 = GenerativeViewController4()
        screen4.modalPresentationStyle = .fullScreen
        self.present(screen4, animated: true)
    }
    continueBtn.addAction(action, for: .touchUpInside)
    mainStackView.addArrangedSubview(continueBtn)
    }

    // MARK: - Handlers
    func handleScenarioTap(_ scenario: StartupScenario) {
        let text = scenario.details.joined(separator: "\n")
        let alert = UIAlertController(title: scenario.name, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func handleNegotiationTap(_ option: NegotiationOption) {
        let alert = UIAlertController(title: "Outcome", message: option.response, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Understood", style: .default))
        present(alert, animated: true)
    }
}
