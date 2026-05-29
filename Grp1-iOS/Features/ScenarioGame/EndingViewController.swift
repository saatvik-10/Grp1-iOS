//
//  EndingViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 02/02/26.
//

import UIKit

class EndingViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var biasScoreView: UIView!

    @IBOutlet weak var capitalCardView: UIView!
    @IBOutlet weak var capitalLabel: UILabel!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var biasCardStackView: UIStackView!
    @IBOutlet weak var biasLabel: UILabel!

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var quoteCardView: UIView!
    private let scoreValueLabel = UILabel()
    private let scoreTitleLabel = UILabel()
    private var ringLayer: CAShapeLayer?
    private var ringTrackLayer: CAShapeLayer?
    private var accentColor: UIColor = UIColor(red: 0.97, green: 0.55, blue: 0.12, alpha: 1.0)

    var endingType: EndingType!
    var finalCapital: Int = 0
    var biasScore: Int = 0
    var dominantBias: CognitiveBias?
    var biasExposure: [CognitiveBias: Int] = [:]

    let kahnemanEndingQuotes: [KahnemanQuote] = [

        KahnemanQuote(
            text: "The goal of investing is not to avoid risk, but to understand it well enough to take the right one.",
            author: "Daniel Kahneman",
            endingType: .success
        ),

        KahnemanQuote(
            text: "Investors often accept a smaller, certain loss today to avoid the emotional pain of a larger, uncertain one tomorrow.",
            author: "Daniel Kahneman",
            endingType: .partialFailure
        ),

        KahnemanQuote(
            text: "Confidence in financial decisions often reflects a good story, not a good understanding of probabilities.",
            author: "Daniel Kahneman",
            endingType: .failure
        ),

        KahnemanQuote(
            text: "What investors see is all there is — past prices anchor expectations, even when the future has already changed.",
            author: "Daniel Kahneman",
            endingType: .criticalFailure
        )

    ]

    let biasDefinitions: [CognitiveBias: BiasDefine] = [

        .lossAversion: BiasDefine(
            bias: .lossAversion,
            title: "Loss Aversion",
            description: """
            Holding losing positions felt safer than accepting a loss.
            The emotional pain of losses outweighed rational evaluation of future returns.

            Lesson: Accept small losses early to avoid larger ones later.
            """,
            iconName: "exclamationmark.triangle"
        ),

        .sunkCost: BiasDefine(
            bias: .sunkCost,
            title: "Sunk Cost Fallacy",
            description: """
            Past investments influenced future decisions.
            Additional capital was committed to justify earlier losses.

            Lesson: Markets don't care what you already invested.
            """,
            iconName: "arrow.triangle.2.circlepath"
        ),

        .overconfidence: BiasDefine(
            bias: .overconfidence,
            title: "Overconfidence",
            description: """
            Strong narratives increased conviction.
            Confidence exceeded the accuracy of available information.

            Lesson: Confidence should follow evidence — not stories.
            """,
            iconName: "brain.head.profile"
        ),

        .statusQuo: BiasDefine(
            bias: .statusQuo,
            title: "Status Quo Bias",
            description: """
            Inaction felt less risky than change.
            Staying invested delayed necessary decisions.

            Lesson: Inaction is also a decision.
            """,
            iconName: "pause.circle"
        ),

        .anchoring: BiasDefine(
            bias: .anchoring,
            title: "Anchoring",
            description: """
            Early price levels anchored expectations.
            New information was underweighted.

            Lesson: Yesterday's price is irrelevant.
            """,
            iconName: "paperclip"
        )
    ]

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureQuoteCard()
        renderEnding()
        renderQuote()
        contentView.backgroundColor = .clear
        configureTitleLabel()
        configureBiasScoreView()
        populateBiasCards()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        drawBiasScoreRing()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCapitalCard()
        quoteCardView.isUserInteractionEnabled = false
        biasCardStackView.isUserInteractionEnabled = false
    }
}

// MARK: - Rendering
extension EndingViewController {

    func renderQuote() {
        guard let ending = endingType,
              let quote = kahnemanEndingQuotes.first(where: { $0.endingType == ending }) else {
            quoteCardView.isHidden = true
            return
        }

        quoteLabel.text = "\u{201C}\(quote.text)\u{201D}"
        authorLabel.text = "\u{2014} \(quote.author)"
    }

    func renderEnding() {
        guard let endingType = endingType else { return }

        view.backgroundColor = .systemBackground
        titleLabel.textColor = .label

        switch endingType {

        case .success:
            titleLabel.text = "Strategic Victory"
            accentColor = UIColor(red: 0.20, green: 0.68, blue: 0.36, alpha: 1.0)
            view.backgroundColor = UIColor(red: 0.89, green: 0.97, blue: 0.91, alpha: 1.0)

        case .partialFailure:
            titleLabel.text = "Capital Preserved"
            accentColor = UIColor(red: 0.95, green: 0.73, blue: 0.18, alpha: 1.0)
            view.backgroundColor = UIColor(red: 0.99, green: 0.96, blue: 0.86, alpha: 1.0)

        case .failure:
            titleLabel.text = "Costly Mistakes"
            accentColor = UIColor(red: 0.97, green: 0.55, blue: 0.12, alpha: 1.0)
            view.backgroundColor = UIColor(red: 0.98, green: 0.56, blue: 0.16, alpha: 1.0)

        case .criticalFailure:
            titleLabel.text = "Systemic Collapse"
            accentColor = UIColor(red: 0.85, green: 0.15, blue: 0.18, alpha: 1.0)
            view.backgroundColor =  UIColor(red: 0.85, green: 0.15, blue: 0.18, alpha: 1.0)
            titleLabel.textColor = .white
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_IN")
        let formattedCapital = formatter.string(from: NSNumber(value: finalCapital)) ?? "\(finalCapital)"
        capitalLabel.text = "Final Capital: \u{20B9}\(formattedCapital)"
        scoreValueLabel.text = "\(biasScore)"
    }
}

// MARK: - Configuration
extension EndingViewController {

    private func applyCardStyle(_ view: UIView, cornerRadius: CGFloat = 24, backgroundColor: UIColor = .white) {
        view.backgroundColor = backgroundColor
        view.layer.cornerRadius = cornerRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.12
        view.layer.shadowRadius = 16
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.masksToBounds = false
    }

    private func configureCapitalCard() {
        applyCardStyle(capitalCardView)

        capitalCardView.translatesAutoresizingMaskIntoConstraints = false
        capitalLabel.translatesAutoresizingMaskIntoConstraints = false

        capitalLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        capitalLabel.textColor = accentColor
        capitalLabel.textAlignment = .center

        NSLayoutConstraint.activate([
            capitalCardView.heightAnchor.constraint(equalToConstant: 80),
            capitalLabel.centerXAnchor.constraint(equalTo: capitalCardView.centerXAnchor),
            capitalLabel.centerYAnchor.constraint(equalTo: capitalCardView.centerYAnchor)
        ])
    }

    private func configureBiasScoreView() {
        applyCardStyle(biasScoreView)

        biasLabel.isHidden = true

        scoreValueLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        scoreValueLabel.font = UIFont.systemFont(ofSize: 44, weight: .bold)
        scoreValueLabel.textAlignment = .center
        scoreValueLabel.text = "\(biasScore)"

        scoreTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        scoreTitleLabel.textColor = .secondaryLabel
        scoreTitleLabel.textAlignment = .center
        scoreTitleLabel.text = "Final Score"

        capitalLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        capitalLabel.textColor = accentColor
        capitalLabel.textAlignment = .center

        if scoreValueLabel.superview == nil {
            biasScoreView.addSubview(scoreValueLabel)
            biasScoreView.addSubview(scoreTitleLabel)
        }

        NSLayoutConstraint.activate([
            biasScoreView.heightAnchor.constraint(equalToConstant: 240),
            scoreValueLabel.centerXAnchor.constraint(equalTo: biasScoreView.centerXAnchor),
            scoreValueLabel.centerYAnchor.constraint(equalTo: biasScoreView.centerYAnchor, constant: -24),
            scoreTitleLabel.topAnchor.constraint(equalTo: scoreValueLabel.bottomAnchor, constant: 4),
            scoreTitleLabel.centerXAnchor.constraint(equalTo: biasScoreView.centerXAnchor)
        ])
    }

    private func configureTitleLabel() {
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
    }

    private func populateBiasCards() {
        biasCardStackView.axis = .vertical
        biasCardStackView.spacing = 16

        biasCardStackView.arrangedSubviews.forEach {
            biasCardStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let sortedBiases = biasExposure
            .sorted { abs($0.value) > abs($1.value) }
            .prefix(3)
        guard !sortedBiases.isEmpty else { return }

        for (bias, _) in sortedBiases {
            guard let define = biasDefinitions[bias] else { continue }

            let card = makeBiasCard(define: define)

            if bias == dominantBias {
                card.layer.borderWidth = 2
                card.layer.borderColor = accentColor.cgColor
            }

            biasCardStackView.addArrangedSubview(card)
        }
    }

    private func configureQuoteCard() {
        applyCardStyle(
            quoteCardView,
            cornerRadius: 24,
            backgroundColor: UIColor(red: 1.0, green: 0.97, blue: 0.94, alpha: 1.0)
        )

        quoteLabel.numberOfLines = 0
        quoteLabel.font = UIFont.systemFont(ofSize: 16)
        quoteLabel.textColor = UIColor(white: 0.35, alpha: 1.0)

        authorLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        authorLabel.textColor = .label
        authorLabel.textAlignment = .right

        quoteLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false

        let accent = UIView()
        accent.translatesAutoresizingMaskIntoConstraints = false
        accent.backgroundColor = accentColor
        accent.layer.cornerRadius = 2
        quoteLabel.removeFromSuperview()
        authorLabel.removeFromSuperview()

        quoteCardView.addSubview(quoteLabel)
        quoteCardView.addSubview(authorLabel)

        NSLayoutConstraint.activate([
            quoteLabel.topAnchor.constraint(equalTo: quoteCardView.topAnchor, constant: 24),
            quoteLabel.leadingAnchor.constraint(equalTo: quoteCardView.leadingAnchor, constant: 20),
            quoteLabel.trailingAnchor.constraint(equalTo: quoteCardView.trailingAnchor, constant: -24),

            authorLabel.topAnchor.constraint(equalTo: quoteLabel.bottomAnchor, constant: 12),
            authorLabel.leadingAnchor.constraint(equalTo: quoteCardView.leadingAnchor, constant: 20),
            authorLabel.trailingAnchor.constraint(equalTo: quoteCardView.trailingAnchor, constant: -16),

            authorLabel.bottomAnchor.constraint(equalTo: quoteCardView.bottomAnchor, constant: -20)
        ])
    }

    private func makeBiasCard(define: BiasDefine) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        applyCardStyle(card, cornerRadius: 24, backgroundColor: UIColor(red: 1.0, green: 0.97, blue: 0.94, alpha: 1.0))

        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = UIColor(red: 1.0, green: 0.94, blue: 0.86, alpha: 1.0)
        iconContainer.layer.cornerRadius = 16

        let iconView = UIImageView(image: UIImage(systemName: define.iconName))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = accentColor
        iconView.contentMode = .scaleAspectFit

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = define.title
        title.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        title.textColor = .label
        title.numberOfLines = 0

        let body = UILabel()
        body.translatesAutoresizingMaskIntoConstraints = false
        body.text = define.description.replacingOccurrences(of: "\n", with: " ")
        body.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        body.textColor = UIColor(white: 0.35, alpha: 1.0)
        body.numberOfLines = 0

        let accent = UIView()
        accent.translatesAutoresizingMaskIntoConstraints = false
        accent.backgroundColor = accentColor
        accent.layer.cornerRadius = 2

        card.addSubview(iconContainer)
        iconContainer.addSubview(iconView)
        card.addSubview(title)
        card.addSubview(body)
        card.addSubview(accent)

        NSLayoutConstraint.activate([
            iconContainer.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            iconContainer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            iconContainer.widthAnchor.constraint(equalToConstant: 52),
            iconContainer.heightAnchor.constraint(equalToConstant: 52),

            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            title.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            body.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 12),
            body.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            body.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            accent.topAnchor.constraint(equalTo: body.bottomAnchor, constant: 16),
            accent.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            accent.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            accent.heightAnchor.constraint(equalToConstant: 4),
            accent.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])

        return card
    }

    private func drawBiasScoreRing() {
        let ringInset: CGFloat = 22
        let radius = min(biasScoreView.bounds.width, biasScoreView.bounds.height) / 2 - ringInset
        guard radius > 0 else { return }

        ringLayer?.removeFromSuperlayer()
        ringTrackLayer?.removeFromSuperlayer()

        let center = CGPoint(x: biasScoreView.bounds.midX, y: biasScoreView.bounds.midY)
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + CGFloat.pi * 2

        let trackPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        let trackLayer = CAShapeLayer()
        trackLayer.path = trackPath.cgPath
        trackLayer.strokeColor = UIColor(red: 1.0, green: 0.91, blue: 0.78, alpha: 1.0).cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        biasScoreView.layer.addSublayer(trackLayer)
        ringTrackLayer = trackLayer

        let progress = max(0, min(1, CGFloat(biasScore) / 120.0))
        let ringPath = UIBezierPath(
            arcCenter: center, radius: radius,
            startAngle: startAngle,
            endAngle: startAngle + progress * (CGFloat.pi * 2),
            clockwise: true
        )
        let ringLayer = CAShapeLayer()
        ringLayer.path = ringPath.cgPath
        ringLayer.strokeColor = accentColor.cgColor
        ringLayer.lineWidth = 10
        ringLayer.lineCap = .round
        ringLayer.fillColor = UIColor.clear.cgColor
        biasScoreView.layer.addSublayer(ringLayer)
        self.ringLayer = ringLayer
    }
}

// MARK: - Navigation
extension EndingViewController {

    func navigateToHome() {
        let storyboard = UIStoryboard(name: "HomeMain", bundle: nil)
        if let homeVC = storyboard.instantiateInitialViewController() {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else {
                return
            }
            window.rootViewController = homeVC

            UIView.transition(with: window, duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: nil)

            window.makeKeyAndVisible()
        }
    }

    @IBAction func restartTapped(_ sender: UIButton) {
        navigateToHome()
    }
}
