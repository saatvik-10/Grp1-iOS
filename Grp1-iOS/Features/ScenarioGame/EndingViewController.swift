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
            bgColor = UIColor(red: 0.4, green: 0.08, blue: 0.08, alpha: 1)
            iconColor = UIColor(red: 0.98, green: 0.4, blue: 0.4, alpha: 1)
            iconName = "xmark.octagon.fill"
            titleText = "Systemic Collapse"
        case .none:
            break
        }
        card.backgroundColor = bgColor
        
        let iconBox = UIView()
        iconBox.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
        iconBox.layer.cornerRadius = 10
        iconBox.translatesAutoresizingMaskIntoConstraints = false
        iconBox.widthAnchor.constraint(equalToConstant: 36).isActive  = true
        iconBox.heightAnchor.constraint(equalToConstant: 36).isActive = true
 
        let iconImg = UIImageView(image: UIImage(systemName: iconName))
        iconImg.tintColor    = iconColor
        iconImg.contentMode  = .scaleAspectFit
        iconImg.translatesAutoresizingMaskIntoConstraints = false
        iconBox.addSubview(iconImg)
        NSLayoutConstraint.activate([
            iconImg.centerXAnchor.constraint(equalTo: iconBox.centerXAnchor),
            iconImg.centerYAnchor.constraint(equalTo: iconBox.centerYAnchor),
            iconImg.widthAnchor.constraint(equalToConstant: 16),
            iconImg.heightAnchor.constraint(equalToConstant: 16)
        ])
 
        let badgeLabel = UILabel()
        badgeLabel.text      = "RESULT"
        badgeLabel.font      = UIFont.systemFont(ofSize: 9, weight: .semibold)
        badgeLabel.textColor = iconColor
 
        let badgeRow = UIStackView(arrangedSubviews: [iconBox, badgeLabel])
        badgeRow.axis      = .horizontal
        badgeRow.spacing   = 8
        badgeRow.alignment = .center
 
        let title = UILabel()
        title.text          = titleText
        title.font          = UIFont.systemFont(ofSize: 22, weight: .bold)
        title.textColor     = .white
        title.numberOfLines = 0
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_IN")
        let formattedCapital = formatter.string(from: NSNumber(value: finalCapital)) ?? "\(finalCapital)"
<<<<<<< HEAD
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
=======
 
        let msg = UILabel()
        msg.text = "You finished the scenario with ₹\(formattedCapital) in capital."
        msg.font          = UIFont.systemFont(ofSize: 13, weight: .regular)
        msg.textColor     = UIColor.white.withAlphaComponent(0.65)
        msg.numberOfLines = 0
 
        let vstack = UIStackView(arrangedSubviews: [badgeRow, title, msg])
        vstack.axis    = .vertical
        vstack.spacing = 8
        vstack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(vstack)
 
        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            vstack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            vstack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            vstack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        return card
    }
    
    private func makePerformanceCard() -> UIView {
>>>>>>> 661247719a1460aa7bc648ef07b30326d4379025
        let card = UIView()
        card.backgroundColor    = C.card
        card.layer.cornerRadius = 16
        card.layer.cornerCurve  = .continuous
        card.layer.borderWidth  = 1.5
        card.layer.borderColor  = (isSuccess ? C.green : C.red).withAlphaComponent(0.4).cgColor
 
        // Bias Score
        let scoreLabel = UILabel()
        scoreLabel.text      = "Bias Score"
        scoreLabel.font      = UIFont.systemFont(ofSize: 16, weight: .semibold)
        scoreLabel.textColor = C.text
 
        let badgeBg  = UIView()
        badgeBg.backgroundColor    = isSuccess ? C.greenLight : C.redLight
        badgeBg.layer.cornerRadius = 7
 
        let badgeLbl = UILabel()
        badgeLbl.text      = isSuccess ? "Rational" : "Biased"
        badgeLbl.font      = UIFont.systemFont(ofSize: 10, weight: .semibold)
        badgeLbl.textColor = isSuccess ? C.green : C.red
        badgeLbl.translatesAutoresizingMaskIntoConstraints = false
 
        let badgeIcon = UIImageView(image: UIImage(systemName: isSuccess ? "brain" : "exclamationmark.triangle.fill"))
        badgeIcon.tintColor    = isSuccess ? C.green : C.red
        badgeIcon.contentMode  = .scaleAspectFit
        badgeIcon.translatesAutoresizingMaskIntoConstraints = false
        badgeIcon.widthAnchor.constraint(equalToConstant: 10).isActive  = true
        badgeIcon.heightAnchor.constraint(equalToConstant: 10).isActive = true
 
        let badgeRow = UIStackView(arrangedSubviews: [badgeIcon, badgeLbl])
        badgeRow.axis      = .horizontal
        badgeRow.spacing   = 4
        badgeRow.alignment = .center
        badgeRow.translatesAutoresizingMaskIntoConstraints = false
        badgeBg.addSubview(badgeRow)
        NSLayoutConstraint.activate([
            badgeRow.topAnchor.constraint(equalTo: badgeBg.topAnchor, constant: 4),
            badgeRow.bottomAnchor.constraint(equalTo: badgeBg.bottomAnchor, constant: -4),
            badgeRow.leadingAnchor.constraint(equalTo: badgeBg.leadingAnchor, constant: 8),
            badgeRow.trailingAnchor.constraint(equalTo: badgeBg.trailingAnchor, constant: -8)
        ])
 
        let topRow = UIStackView(arrangedSubviews: [scoreLabel, badgeBg])
        topRow.axis      = .horizontal
        topRow.spacing   = 8
        topRow.alignment = .center
 
        let descLabel = UILabel()
        descLabel.text      = "Your overall cognitive bias score. Lower means more rational decisions."
        descLabel.font      = UIFont.systemFont(ofSize: 12, weight: .regular)
        descLabel.textColor = C.subtext
        descLabel.numberOfLines = 0
 
        let divider = UIView()
        divider.backgroundColor = C.separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.widthAnchor.constraint(equalToConstant: 1).isActive = true
 
        // Score number
        let rankNum = UILabel()
        rankNum.text          = "\(biasScore)"
        rankNum.font          = UIFont.systemFont(ofSize: 28, weight: .bold)
        rankNum.textColor     = isSuccess ? C.green : C.red
        rankNum.textAlignment = .center
 
        let rankSub = UILabel()
        rankSub.text          = "Pts"
        rankSub.font          = UIFont.systemFont(ofSize: 11, weight: .regular)
        rankSub.textColor     = C.subtext
        rankSub.textAlignment = .center
 
        let rightStack = UIStackView(arrangedSubviews: [rankNum, rankSub])
        rightStack.axis      = .vertical
        rightStack.spacing   = 0
        rightStack.alignment = .center
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        rightStack.widthAnchor.constraint(equalToConstant: 64).isActive = true
 
        let leftStack = UIStackView(arrangedSubviews: [topRow, descLabel])
        leftStack.axis    = .vertical
        leftStack.spacing = 3
 
        let hstack = UIStackView(arrangedSubviews: [leftStack, divider, rightStack])
        hstack.axis      = .horizontal
        hstack.spacing   = 14
        hstack.alignment = .center
        hstack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(hstack)
 
        NSLayoutConstraint.activate([
            hstack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            hstack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            hstack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            hstack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }

<<<<<<< HEAD
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
=======
    private func makeBiasesStack() -> UIView {
        let container = UIStackView()
        container.axis    = .vertical
        container.spacing = 10
 
        let sortedBiases = biasExposure
            .sorted { abs($0.value) > abs($1.value) }
            .prefix(3)
        
        guard !sortedBiases.isEmpty else {
            let empty = UILabel()
            empty.text = "No major biases detected."
            empty.font = UIFont.systemFont(ofSize: 13)
            empty.textColor = C.subtext
            container.addArrangedSubview(empty)
            return container
        }
 
        for (bias, _) in sortedBiases {
            guard let define = biasDefinitions[bias] else { continue }
            let isDominant = (bias == dominantBias)
            container.addArrangedSubview(makeBiasRow(define: define, isDominant: isDominant))
        }
 
        return container
    }
    
    private func makeBiasRow(define: BiasDefine, isDominant: Bool) -> UIView {
        let card = UIView()
        card.backgroundColor    = C.card
        card.layer.cornerRadius = 16
        card.layer.cornerCurve  = .continuous
        card.layer.borderWidth  = isDominant ? 1.5 : 0.5
        card.layer.borderColor  = isDominant ? C.orange.withAlphaComponent(0.6).cgColor : C.border.cgColor
 
        let iconBox = UIView()
        iconBox.backgroundColor    = isDominant ? UIColor(red: 0.99, green: 0.95, blue: 0.9, alpha: 1) : UIColor(red: 0.96, green: 0.96, blue: 0.95, alpha: 1)
        iconBox.layer.cornerRadius = 10
        iconBox.translatesAutoresizingMaskIntoConstraints = false
        iconBox.widthAnchor.constraint(equalToConstant: 36).isActive  = true
        iconBox.heightAnchor.constraint(equalToConstant: 36).isActive = true
 
        let img = UIImageView(image: UIImage(systemName: define.iconName))
        img.tintColor   = isDominant ? C.orange : UIColor(red: 0.40, green: 0.40, blue: 0.42, alpha: 1)
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        iconBox.addSubview(img)
        NSLayoutConstraint.activate([
            img.centerXAnchor.constraint(equalTo: iconBox.centerXAnchor),
            img.centerYAnchor.constraint(equalTo: iconBox.centerYAnchor),
            img.widthAnchor.constraint(equalToConstant: 16),
            img.heightAnchor.constraint(equalToConstant: 16)
        ])
 
        let titleLbl = UILabel()
        titleLbl.text      = define.title
        titleLbl.font      = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLbl.textColor = C.text
 
        let descLbl = UILabel()
        descLbl.text          = define.description
        descLbl.font          = UIFont.systemFont(ofSize: 12, weight: .regular)
        descLbl.textColor     = UIColor(red: 0.45, green: 0.45, blue: 0.47, alpha: 1)
        descLbl.numberOfLines = 0
 
        let textStack = UIStackView(arrangedSubviews: [titleLbl, descLbl])
        textStack.axis    = .vertical
        textStack.spacing = 3
 
        let hstack = UIStackView(arrangedSubviews: [iconBox, textStack])
        hstack.axis      = .horizontal
        hstack.spacing   = 12
        hstack.alignment = .top
        hstack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(hstack)
 
        NSLayoutConstraint.activate([
            hstack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            hstack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            hstack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            hstack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
        
        if isDominant {
            let badge = UIView()
            badge.backgroundColor = C.orange
            badge.layer.cornerRadius = 6
            badge.translatesAutoresizingMaskIntoConstraints = false
            let lbl = UILabel()
            lbl.text = "DOMINANT"
            lbl.font = UIFont.systemFont(ofSize: 8, weight: .bold)
            lbl.textColor = .white
            lbl.translatesAutoresizingMaskIntoConstraints = false
            badge.addSubview(lbl)
            NSLayoutConstraint.activate([
                lbl.topAnchor.constraint(equalTo: badge.topAnchor, constant: 3),
                lbl.bottomAnchor.constraint(equalTo: badge.bottomAnchor, constant: -3),
                lbl.leadingAnchor.constraint(equalTo: badge.leadingAnchor, constant: 6),
                lbl.trailingAnchor.constraint(equalTo: badge.trailingAnchor, constant: -6)
            ])
            
            card.addSubview(badge)
            NSLayoutConstraint.activate([
                badge.topAnchor.constraint(equalTo: card.topAnchor, constant: -6),
                badge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12)
            ])
        }
        
        return card
    }
    
    private func makeQuoteCard() -> UIView {
        let card = UIView()
        card.backgroundColor    = C.card
        card.layer.cornerRadius = 16
        card.layer.cornerCurve  = .continuous
        card.layer.borderWidth  = 0.5
        card.layer.borderColor  = C.border.cgColor
        
        guard let ending = endingType,
              let quote = kahnemanEndingQuotes.first(where: { $0.endingType == ending }) else {
            return card
        }
        
        let quoteLbl = UILabel()
        quoteLbl.text = "“\(quote.text)”"
        quoteLbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        quoteLbl.textColor = C.text
        quoteLbl.numberOfLines = 0
        quoteLbl.textAlignment = .center
        
        let authorLbl = UILabel()
        authorLbl.text = "— \(quote.author)"
        authorLbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        authorLbl.textColor = C.subtext
        authorLbl.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [quoteLbl, authorLbl])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        return card
    }

    private func makeCTAs() -> UIView {
        let homeBtn = makeButton(title: "Return to Home", bg: C.charcoal, fg: .white)
        homeBtn.addTarget(self, action: #selector(restartTapped(_:)), for: .touchUpInside)
 
        let stack = UIStackView(arrangedSubviews: [homeBtn])
        stack.axis    = .vertical
        stack.spacing = 10
        return stack
    }
    
    private func makeButton(title: String, bg: UIColor, fg: UIColor) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.setTitleColor(fg, for: .normal)
        b.backgroundColor = bg
        b.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        b.layer.cornerRadius = 14
        b.layer.cornerCurve  = .continuous
        b.translatesAutoresizingMaskIntoConstraints = false
        b.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return b
    }
    
    // MARK: - Actions
    @objc @IBAction func restartTapped(_ sender: Any) {
>>>>>>> 661247719a1460aa7bc648ef07b30326d4379025
        let storyboard = UIStoryboard(name: "HomeMain", bundle: nil)
        if let homeVC = storyboard.instantiateInitialViewController() {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else {
                return
            }
            window.rootViewController = homeVC
<<<<<<< HEAD

=======
            
>>>>>>> 661247719a1460aa7bc648ef07b30326d4379025
            UIView.transition(with: window, duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: nil)

            window.makeKeyAndVisible()
        }
    }
<<<<<<< HEAD

    @IBAction func restartTapped(_ sender: UIButton) {
        navigateToHome()
    }
=======
>>>>>>> 661247719a1460aa7bc648ef07b30326d4379025
}
