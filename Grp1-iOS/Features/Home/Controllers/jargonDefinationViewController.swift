//
//  jargonDefinationViewController.swift
//  Grp1-iOS
//

import UIKit

class jargonDefinationViewController: UIViewController {

    var jargonWord: String!
    var selectedJargon: String?
    var articleContext: String = ""   // ✅ pass from news1/news2ViewController

    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var pageNumberLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var glassView: UIView!
    @IBOutlet weak var jargonDefination: UILabel!

    private var currentIndex = 0
    private var pages: [JargonPage] = []

    // ✅ AI generator
    private let generator = JargonContentGenerator()

    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        view.backgroundColor = AppTheme.shared.dominantColor.withAlphaComponent(0.1)

        jargonWord = selectedWord.word
        title = selectedWord.word

        setupGlassEffect()
        showLoadingState()

        // ✅ Generate content using FoundationModels
        Task { await generateAndDisplay() }
    }

    // MARK: - AI Generation

    private func generateAndDisplay() async {
        await generator.generate(for: jargonWord, articleContext: articleContext)

        pages = generator.toJargonPages(for: jargonWord)

        guard !pages.isEmpty else {
            jargonDefination.text = "Could not generate content for \(jargonWord ?? "this term")."
            headingLabel.text = "Error"
            pageNumberLabel.text = "–"
            actionButton.isHidden = true
            return
        }

        currentIndex = 0
        applyPage(index: currentIndex)
    }

    // MARK: - Loading State

    private func showLoadingState() {
        headingLabel.text = ""
        jargonDefination.text = ""
        pageNumberLabel.text = ""
        actionButton.isHidden = true

        let spinner = UIActivityIndicatorView(style: .large)
        spinner.tag = 99
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        glassView.addSubview(spinner)

        let label = UILabel()
        label.tag = 98
        label.text = "Generating definition..."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        glassView.addSubview(label)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: glassView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: glassView.centerYAnchor),

            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: glassView.centerXAnchor)
        ])
    }

    // MARK: - Page Display

    private func applyPage(index: Int) {
        glassView.viewWithTag(99)?.removeFromSuperview()
            glassView.viewWithTag(98)?.removeFromSuperview()
        guard index >= 0 && index < pages.count else {
            print("Index out of range:", index)
            return

        }

        headingLabel.text = pages[index].title
        pageNumberLabel.text = "\(currentIndex + 1)/\(pages.count)"
        actionButton.isHidden = index != pages.count - 1

        // ✅ Render with paragraph spacing so \n\n shows as a visible gap
        let content = pages[index].content
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = -30        // gap between paragraphs
        paragraphStyle.lineSpacing = 3              // slight line breathing room

        let attributes: [NSAttributedString.Key: Any] = [
            .font: jargonDefination.font ?? UIFont.systemFont(ofSize: 16),
            .foregroundColor: jargonDefination.textColor ?? UIColor.label,
            .paragraphStyle: paragraphStyle
        ]

        jargonDefination.attributedText = NSAttributedString(
            string: content,
            attributes: attributes
        )
        headingLabel.text = pages[index].title
        pageNumberLabel.text = "\(currentIndex + 1)/\(pages.count)"
        actionButton.isHidden = true   // hidden until animation finishes

        animateWordByWord(text: pages[index].content, isLastPage: index == pages.count - 1)
    }

    private var typewriterTimer: Timer?

    private func animateWordByWord(text: String, isLastPage: Bool) {
        typewriterTimer?.invalidate()
        jargonDefination.text = ""

        let words = text.components(separatedBy: " ")
        var currentWordIndex = 0
        var displayedText = ""

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 4
        paragraphStyle.lineSpacing = 3

        let attributes: [NSAttributedString.Key: Any] = [
            .font: jargonDefination.font ?? UIFont.systemFont(ofSize: 16),
            .foregroundColor: jargonDefination.textColor ?? UIColor.label,
            .paragraphStyle: paragraphStyle
        ]

        typewriterTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }

            guard currentWordIndex < words.count else {
                timer.invalidate()
                if isLastPage {
                    UIView.animate(withDuration: 0.3) {
                        self.actionButton.isHidden = false
                    }
                }
                return
            }

            displayedText += (currentWordIndex == 0 ? "" : " ") + words[currentWordIndex]
            self.jargonDefination.attributedText = NSAttributedString(
                string: displayedText,
                attributes: attributes
            )
            currentWordIndex += 1
        }
    }

    // MARK: - Navigation

    @IBAction func forwardTapped(_ sender: UIButton) {
        guard currentIndex < pages.count - 1 else { return }
        animateChange(direction: 1)
    }

    @IBAction func backTapped(_ sender: UIButton) {
        guard currentIndex > 0 else { return }
        animateChange(direction: -1)
    }

    @IBAction func quitTapped(_ sender: Any) {
        let alert = UIAlertController(
            title: "Quit Lesson",
            message: "Do you really want to Quit Lesson?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }

    // MARK: - Animation

    private func animateChange(direction: CGFloat) {
        guard let card = glassView else { return }
        let width = card.frame.width

        UIView.animate(withDuration: 0.25, animations: {
            card.transform = CGAffineTransform(translationX: -direction * width, y: 0)
            card.alpha = 0
        }, completion: { _ in
            self.currentIndex += Int(direction)
            self.applyPage(index: self.currentIndex)

            card.transform = CGAffineTransform(translationX: direction * width, y: 0)

            UIView.animate(
                withDuration: 0.32,
                delay: 0,
                usingSpringWithDamping: 0.85,
                initialSpringVelocity: 0.6,
                options: [.curveEaseOut],
                animations: {
                    card.transform = .identity
                    card.alpha = 1
                }
            )
        })
    }

    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showQuiz",
           let vc = segue.destination as? jargonQuizViewController {
            vc.jargonWord    = jargonWord
            vc.generatedQuiz = generator.toJargonQuiz(for: jargonWord)  // ✅ pass AI quiz
        }
    }

    // MARK: - Glass Effect

    private func setupGlassEffect() {
        glassView.subviews
            .filter { $0 is UIVisualEffectView }
            .forEach { $0.removeFromSuperview() }

        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = glassView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.isUserInteractionEnabled = false

        glassView.insertSubview(blurView, at: 0)
        glassView.layer.cornerRadius = 22
        glassView.layer.masksToBounds = true
        glassView.layer.borderWidth = 1
        glassView.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
    }
}
