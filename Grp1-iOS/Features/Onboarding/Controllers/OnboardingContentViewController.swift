import UIKit

final class ExperienceOptionButton: UIButton {
    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    private let titleTextLabel = UILabel()
    private let subtitleTextLabel = UILabel()
    private let radioOuterView = UIView()
    private let radioInnerView = UIView()

    private let selectedBlue = UIColor.systemBlue
    private let inactiveBorder = UIColor(red: 0.89, green: 0.91, blue: 0.95, alpha: 1.0)
    private let bodyText = UIColor(red: 0.34, green: 0.40, blue: 0.51, alpha: 1.0)

    var optionTitle: String = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = inactiveBorder.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.03
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 10
        clipsToBounds = false

        titleLabel?.isHidden = true
        contentHorizontalAlignment = .fill

        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.layer.cornerRadius = 18
        iconContainer.backgroundColor = UIColor(red: 0.90, green: 0.91, blue: 0.93, alpha: 1.0)
        iconContainer.isUserInteractionEnabled = false

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = UIColor(red: 0.29, green: 0.32, blue: 0.39, alpha: 1.0)
        iconImageView.isUserInteractionEnabled = false

        titleTextLabel.translatesAutoresizingMaskIntoConstraints = false
        titleTextLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleTextLabel.textColor = .label
        titleTextLabel.adjustsFontForContentSizeCategory = true
        titleTextLabel.isUserInteractionEnabled = false

        subtitleTextLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleTextLabel.font = .systemFont(ofSize: 17, weight: .regular)
        subtitleTextLabel.textColor = bodyText
        subtitleTextLabel.numberOfLines = 3
        subtitleTextLabel.adjustsFontForContentSizeCategory = true
        subtitleTextLabel.isUserInteractionEnabled = false

        radioOuterView.translatesAutoresizingMaskIntoConstraints = false
        radioOuterView.layer.cornerRadius = 13
        radioOuterView.layer.borderWidth = 2
        radioOuterView.layer.borderColor = UIColor(red: 0.78, green: 0.79, blue: 0.87, alpha: 1.0).cgColor
        radioOuterView.isUserInteractionEnabled = false

        radioInnerView.translatesAutoresizingMaskIntoConstraints = false
        radioInnerView.layer.cornerRadius = 7
        radioInnerView.backgroundColor = selectedBlue
        radioInnerView.isHidden = true
        radioInnerView.isUserInteractionEnabled = false

        iconContainer.addSubview(iconImageView)
        radioOuterView.addSubview(radioInnerView)
        addSubview(iconContainer)
        addSubview(titleTextLabel)
        addSubview(subtitleTextLabel)
        addSubview(radioOuterView)

        NSLayoutConstraint.activate([
            iconContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22),
            iconContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 58),
            iconContainer.heightAnchor.constraint(equalToConstant: 58),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),

            radioOuterView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -22),
            radioOuterView.centerYAnchor.constraint(equalTo: centerYAnchor),
            radioOuterView.widthAnchor.constraint(equalToConstant: 26),
            radioOuterView.heightAnchor.constraint(equalToConstant: 26),

            radioInnerView.centerXAnchor.constraint(equalTo: radioOuterView.centerXAnchor),
            radioInnerView.centerYAnchor.constraint(equalTo: radioOuterView.centerYAnchor),
            radioInnerView.widthAnchor.constraint(equalToConstant: 14),
            radioInnerView.heightAnchor.constraint(equalToConstant: 14),

            titleTextLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 18),
            titleTextLabel.trailingAnchor.constraint(equalTo: radioOuterView.leadingAnchor, constant: -16),
            titleTextLabel.topAnchor.constraint(equalTo: topAnchor, constant: 26),

            subtitleTextLabel.leadingAnchor.constraint(equalTo: titleTextLabel.leadingAnchor),
            subtitleTextLabel.trailingAnchor.constraint(equalTo: titleTextLabel.trailingAnchor),
            subtitleTextLabel.topAnchor.constraint(equalTo: titleTextLabel.bottomAnchor, constant: 8),
            subtitleTextLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -18)
        ])
    }

    func configure(title: String, subtitle: String, symbolName: String) {
        optionTitle = title
        titleTextLabel.text = title
        subtitleTextLabel.text = subtitle
        iconImageView.image = UIImage(systemName: symbolName)
        accessibilityLabel = "\(title). \(subtitle)"
    }

    func setSelectedAppearance(_ selected: Bool) {
        layer.borderWidth = selected ? 2 : 1
        layer.borderColor = selected ? selectedBlue.cgColor : inactiveBorder.cgColor
        backgroundColor = .white
        iconContainer.backgroundColor = selected ? selectedBlue : UIColor(red: 0.90, green: 0.91, blue: 0.93, alpha: 1.0)
        iconImageView.tintColor = selected ? .white : UIColor(red: 0.29, green: 0.32, blue: 0.39, alpha: 1.0)
        radioOuterView.layer.borderColor = selected ? selectedBlue.cgColor : UIColor(red: 0.78, green: 0.79, blue: 0.87, alpha: 1.0).cgColor
        radioInnerView.isHidden = !selected
        isSelected = selected
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            }
        }
    }
}

class OnboardingContentViewController: UIViewController {

    @IBOutlet weak var beginnerButton: UIButton!
    @IBOutlet weak var intermediateButton: UIButton!
    @IBOutlet weak var advancedButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    var onOptionSelected: ((String) -> Void)?
    var onNextTapped: (() -> Void)?
    var onSkipTapped: (() -> Void)?

    var selectedButton: UIButton?

    private let selectedBlue = UIColor.systemBlue
    private let screenBackground = UIColor(red: 0.96, green: 0.98, blue: 1.0, alpha: 1.0)
    private var optionButtons: [ExperienceOptionButton] {
        [beginnerButton, intermediateButton, advancedButton].compactMap { $0 as? ExperienceOptionButton }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        disableNextButton()
    }

    func setupUI() {
        view.subviews.forEach { $0.removeFromSuperview() }
        view.backgroundColor = screenBackground

        let skipButton = makeSkipButton()
        let contentContainer = makeContentContainer()
        let titleLabel = makeTitleLabel()
        let subtitleLabel = makeSubtitleLabel()
        let stackView = makeOptionStackView()
        let footerView = makeFooterView()
        let (bottomBackButton, continueButton) = makeFooterButtons()

        view.addSubview(skipButton)
        view.addSubview(contentContainer)
        view.addSubview(footerView)
        contentContainer.addSubview(titleLabel)
        contentContainer.addSubview(subtitleLabel)
        contentContainer.addSubview(stackView)
        footerView.addSubview(bottomBackButton)
        footerView.addSubview(continueButton)

        NSLayoutConstraint.activate([
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            skipButton.widthAnchor.constraint(equalToConstant: 70),
            skipButton.heightAnchor.constraint(equalToConstant: 30),

            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 120),

            contentContainer.topAnchor.constraint(equalTo: view.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: footerView.topAnchor),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 92),
            titleLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -30),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 28),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 42),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -42),

            stackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 58),
            stackView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 38),
            stackView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -38),

            bottomBackButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 38),
            bottomBackButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 20),
            bottomBackButton.widthAnchor.constraint(equalToConstant: 110),
            bottomBackButton.heightAnchor.constraint(equalToConstant: 56),

            continueButton.leadingAnchor.constraint(equalTo: bottomBackButton.trailingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -38),
            continueButton.topAnchor.constraint(equalTo: bottomBackButton.topAnchor),
            continueButton.heightAnchor.constraint(equalTo: bottomBackButton.heightAnchor)
        ])
    }

    private func makeSkipButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Skip", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.tintColor = .white
        button.backgroundColor = selectedBlue
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(skipButtonTapped(_:)), for: .touchUpInside)
        return button
    }

    private func makeContentContainer() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = screenBackground
        return container
    }

    private func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Experience Level"
        label.font = .systemFont(ofSize: 29, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }

    private func makeSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tailor your portfolio by choosing your\nbackground in financial markets."
        label.font = .systemFont(ofSize: 21, weight: .regular)
        label.textColor = UIColor(red: 0.34, green: 0.40, blue: 0.51, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }

    private func makeOptionStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually

        let beginner = ExperienceOptionButton(type: .custom)
        let intermediate = ExperienceOptionButton(type: .custom)
        let advanced = ExperienceOptionButton(type: .custom)

        [beginner, intermediate, advanced].enumerated().forEach { index, button in
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = index
            button.heightAnchor.constraint(equalToConstant: 124).isActive = true
            button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }

        beginnerButton = beginner
        intermediateButton = intermediate
        advancedButton = advanced

        return stackView
    }

    private func makeFooterView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = screenBackground
        return view
    }

    private func makeFooterButtons() -> (UIButton, UIButton) {
        let backButton = UIButton(type: .system)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("  Back", for: .normal)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor(red: 0.12, green: 0.15, blue: 0.19, alpha: 1.0)
        backButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        backButton.backgroundColor = UIColor(red: 0.90, green: 0.91, blue: 0.93, alpha: 1.0)
        backButton.layer.cornerRadius = 22
        backButton.isEnabled = false

        let continueButton = UIButton(type: .system)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setTitle("Continue  ", for: .normal)
        continueButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        continueButton.semanticContentAttribute = .forceRightToLeft
        continueButton.tintColor = .white
        continueButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        continueButton.backgroundColor = selectedBlue
        continueButton.layer.cornerRadius = 22
        continueButton.layer.shadowColor = selectedBlue.cgColor
        continueButton.layer.shadowOpacity = 0.24
        continueButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        continueButton.layer.shadowRadius = 16
        continueButton.addTarget(self, action: #selector(nextTapped(_:)), for: .touchUpInside)

        nextButton = continueButton
        return (backButton, continueButton)
    }

    func setButtonText(button: UIButton, title: String, subtitle: String) {
        guard let button = button as? ExperienceOptionButton else { return }

        let symbolName: String
        switch title {
        case "Beginner":
            symbolName = "graduationcap"
        case "Intermediate":
            symbolName = "chart.line.uptrend.xyaxis"
        default:
            symbolName = "arrow.up.right"
        }

        button.configure(title: title, subtitle: subtitle, symbolName: symbolName)
    }

    func configure(with page: OnboardingPage) {
        guard page.options.count >= 3 else { return }

        setButtonText(button: beginnerButton, title: page.options[0].title, subtitle: page.options[0].subtitle)
        setButtonText(button: intermediateButton, title: page.options[1].title, subtitle: page.options[1].subtitle)
        setButtonText(button: advancedButton, title: page.options[2].title, subtitle: page.options[2].subtitle)

        resetAllOptionButtons()
        applySelectedStyle(to: intermediateButton)
        selectedButton = intermediateButton
        enableNextButton()
    }

    @IBAction func optionTapped(_ sender: UIButton) {
        resetAllOptionButtons()
        applySelectedStyle(to: sender)
        selectedButton = sender
        enableNextButton()

        if let optionButton = sender as? ExperienceOptionButton {
            onOptionSelected?(optionButton.optionTitle)
        }
    }

    func updateNextButtonState() {
        let isSelected = selectedButton != nil
        nextButton.isEnabled = isSelected
        nextButton.alpha = isSelected ? 1.0 : 0.5
    }

    func enableNextButton() {
        nextButton.isEnabled = true
        nextButton.alpha = 1.0
    }

    func disableNextButton() {
        nextButton.isEnabled = false
        nextButton.alpha = 0.5
    }

    func resetAllOptionButtons() {
        optionButtons.forEach { $0.setSelectedAppearance(false) }
    }

    func applySelectedStyle(to button: UIButton) {
        (button as? ExperienceOptionButton)?.setSelectedAppearance(true)
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        onNextTapped?()
    }

    @IBAction func skipButtonTapped(_ sender: UIButton) {
        onSkipTapped?()
    }
}
