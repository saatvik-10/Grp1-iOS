//
//  EndingViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 02/02/26.
//

import UIKit

// swiftlint:disable file_length
// MARK: - Main Class
class EndingViewController: UIViewController {

    // swiftlint:disable:next identifier_name
    @IBOutlet weak var ContentView: UIView!
    @IBOutlet weak var biasScoreView: UIView!
    @IBOutlet weak var capitalCardView: UIView!
    @IBOutlet weak var capitalLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var biasCardStackView: UIStackView!
    @IBOutlet weak var biasLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var quoteCardView: UIView!

    var endingType: EndingType!
    var finalCapital: Int = 0
    var biasScore: Int = 0
    var dominantBias: CognitiveBias?
    var biasExposure: [CognitiveBias: Int] = [:]

    private let scrollView  = UIScrollView()
    private let contentView = UIView()

    private enum C {
        static let bg         = UIColor(red: 0.961, green: 0.957, blue: 0.945, alpha: 1)
        static let green      = UIColor(red: 0.18, green: 0.62, blue: 0.37, alpha: 1)
        static let greenLight = UIColor(red: 0.90, green: 0.97, blue: 0.92, alpha: 1)
        static let greenDark  = UIColor(red: 0.05, green: 0.17, blue: 0.10, alpha: 1)
        static let red        = UIColor(red: 0.75, green: 0.18, blue: 0.13, alpha: 1)
        static let redLight   = UIColor(red: 0.98, green: 0.93, blue: 0.92, alpha: 1)
        static let charcoal   = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)
        static let card       = UIColor.systemBackground
        static let text       = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)
        static let subtext    = UIColor(red: 0.50, green: 0.50, blue: 0.50, alpha: 1)
        static let border     = UIColor.black.withAlphaComponent(0.06)
        static let separator  = UIColor.black.withAlphaComponent(0.05)
        static let gold       = UIColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1)
        static let orange     = UIColor(red: 0.97, green: 0.55, blue: 0.12, alpha: 1)
    }

    private var isSuccess: Bool {
        endingType == .success || endingType == .partialFailure
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.subviews.forEach { $0.removeFromSuperview() }
        view.backgroundColor = C.bg
        setupScrollView()
        buildUI()
    }
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
            text: "What investors see is all there is \u{2014} past prices anchor expectations, even when the future has already changed.",
            author: "Daniel Kahneman",
            endingType: .criticalFailure
        )
    ]

    let biasDefinitions: [CognitiveBias: BiasDefine] = [
        .lossAversion: BiasDefine(
            bias: .lossAversion,
            title: "Loss Aversion",
            description: "Holding losing positions felt safer than accepting a loss. "
                + "The emotional pain of losses outweighed rational evaluation of future returns.\n\n"
                + "Lesson: Accept small losses early to avoid larger ones later.",
            iconName: "exclamationmark.triangle"
        ),
        .sunkCost: BiasDefine(
            bias: .sunkCost,
            title: "Sunk Cost Fallacy",
            description: "Past investments influenced future decisions. "
                + "Additional capital was committed to justify earlier losses.\n\n"
                + "Lesson: Markets don\u{2019}t care what you already invested.",
            iconName: "arrow.triangle.2.circlepath"
        ),
        .overconfidence: BiasDefine(
            bias: .overconfidence,
            title: "Overconfidence",
            description: "Strong narratives increased conviction. "
                + "Confidence exceeded the accuracy of available information.\n\n"
                + "Lesson: Confidence should follow evidence \u{2014} not stories.",
            iconName: "brain.head.profile"
        ),
        .statusQuo: BiasDefine(
            bias: .statusQuo,
            title: "Status Quo Bias",
            description: "Inaction felt less risky than change. "
                + "Staying invested delayed necessary decisions.\n\n"
                + "Lesson: Inaction is also a decision.",
            iconName: "pause.circle"
        ),
        .anchoring: BiasDefine(
            bias: .anchoring,
            title: "Anchoring",
            description: "Early price levels anchored expectations. "
                + "New information was underweighted.\n\n"
                + "Lesson: Yesterday\u{2019}s price is irrelevant.",
            iconName: "paperclip"
        )
    ]
}

// MARK: - UI Setup
extension EndingViewController {
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func buildUI() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])

        stack.addArrangedSubview(padded(makeBanner(), horizontal: 16, vertical: 10))
        stack.addArrangedSubview(sectionLabel("Your Performance", icon: "chart.bar.fill"))
        stack.addArrangedSubview(padded(makePerformanceCard(), horizontal: 16, vertical: 0))
        stack.addArrangedSubview(sectionLabel("Detected Biases", icon: "brain.head.profile"))
        stack.addArrangedSubview(padded(makeBiasesStack(), horizontal: 16, vertical: 0))
        stack.addArrangedSubview(sectionLabel("Insights", icon: "quote.opening"))
        stack.addArrangedSubview(padded(makeQuoteCard(), horizontal: 16, vertical: 0))
        stack.addArrangedSubview(padded(makeCTAs(), horizontal: 16, vertical: 20))
    }

    private func sectionLabel(_ text: String, icon: String) -> UIView {
        let wrapper = UIView()

        let img = UIImageView(image: UIImage(systemName: icon))
        img.tintColor = C.subtext
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        img.widthAnchor.constraint(equalToConstant: 13).isActive = true
        img.heightAnchor.constraint(equalToConstant: 13).isActive = true

        let lbl = UILabel()
        lbl.text = text.uppercased()
        lbl.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        lbl.textColor = C.subtext

        let row = UIStackView(arrangedSubviews: [img, lbl])
        row.axis = .horizontal
        row.spacing = 5
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false

        wrapper.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 20),
            row.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 20),
            row.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -8)
        ])
        return wrapper
    }

    private func padded(_ view: UIView, horizontal: CGFloat, vertical: CGFloat) -> UIView {
        let wrapper = UIView()
        wrapper.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: vertical),
            view.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -vertical),
            view.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: horizontal),
            view.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -horizontal)
        ])
        return wrapper
    }
}

// MARK: - Section Builders
extension EndingViewController {
    private func makeBanner() -> UIView {
        let card = UIView()
        card.layer.cornerRadius = 22
        card.layer.cornerCurve = .continuous
        card.clipsToBounds = true

        let theme = bannerTheme()
        card.backgroundColor = theme.bgColor

        let iconBox = makeIconBox(iconName: theme.iconName, iconColor: theme.iconColor)
        let badgeLabel = makeBadgeLabel(iconColor: theme.iconColor)
        let badgeRow = UIStackView(arrangedSubviews: [iconBox, badgeLabel])
        badgeRow.axis = .horizontal
        badgeRow.spacing = 8
        badgeRow.alignment = .center

        let title = UILabel()
        title.text = theme.titleText
        title.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        title.textColor = .white
        title.numberOfLines = 0

        let msg = makeBannerMessage()
        let vstack = UIStackView(arrangedSubviews: [badgeRow, title, msg])
        vstack.axis = .vertical
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

    private struct BannerTheme {
        let bgColor: UIColor
        let iconColor: UIColor
        let iconName: String
        let titleText: String
    }

    private func bannerTheme() -> BannerTheme {
        switch endingType {
        case .success:
            return BannerTheme(bgColor: C.greenDark, iconColor: C.green, iconName: "checkmark", titleText: "Strategic Victory")
        case .partialFailure:
            return BannerTheme(
                bgColor: UIColor(red: 0.25, green: 0.20, blue: 0.1, alpha: 1),
                iconColor: C.gold,
                iconName: "exclamationmark",
                titleText: "Capital Preserved"
            )
        case .failure:
            return BannerTheme(bgColor: C.charcoal, iconColor: C.red, iconName: "xmark", titleText: "Costly Mistakes")
        case .criticalFailure:
            return BannerTheme(
                bgColor: UIColor(red: 0.4, green: 0.08, blue: 0.08, alpha: 1),
                iconColor: UIColor(red: 0.98, green: 0.4, blue: 0.4, alpha: 1),
                iconName: "xmark.octagon.fill",
                titleText: "Systemic Collapse"
            )
        default:
            return BannerTheme(bgColor: C.charcoal, iconColor: C.red, iconName: "xmark", titleText: "Systemic Collapse")
        }
    }

    private func makeIconBox(iconName: String, iconColor: UIColor) -> UIView {
        let iconBox = UIView()
        iconBox.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
        iconBox.layer.cornerRadius = 10
        iconBox.translatesAutoresizingMaskIntoConstraints = false
        iconBox.widthAnchor.constraint(equalToConstant: 36).isActive = true
        iconBox.heightAnchor.constraint(equalToConstant: 36).isActive = true

        let iconImg = UIImageView(image: UIImage(systemName: iconName))
        iconImg.tintColor = iconColor
        iconImg.contentMode = .scaleAspectFit
        iconImg.translatesAutoresizingMaskIntoConstraints = false
        iconBox.addSubview(iconImg)
        NSLayoutConstraint.activate([
            iconImg.centerXAnchor.constraint(equalTo: iconBox.centerXAnchor),
            iconImg.centerYAnchor.constraint(equalTo: iconBox.centerYAnchor),
            iconImg.widthAnchor.constraint(equalToConstant: 16),
            iconImg.heightAnchor.constraint(equalToConstant: 16)
        ])
        return iconBox
    }

    private func makeBadgeLabel(iconColor: UIColor) -> UILabel {
        let badgeLabel = UILabel()
        badgeLabel.text = "RESULT"
        badgeLabel.font = UIFont.systemFont(ofSize: 9, weight: .semibold)
        badgeLabel.textColor = iconColor
        return badgeLabel
    }

    private func makeBannerMessage() -> UILabel {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_IN")
        let formattedCapital = formatter.string(from: NSNumber(value: finalCapital)) ?? "\(finalCapital)"

        let msg = UILabel()
        msg.text = "You finished the scenario with \u{20B9}\(formattedCapital) in capital."
        msg.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        msg.textColor = UIColor.white.withAlphaComponent(0.65)
        msg.numberOfLines = 0
        return msg
    }

    private func makePerformanceCard() -> UIView {
        let card = UIView()
        card.backgroundColor = C.card
        card.layer.cornerRadius = 16
        card.layer.cornerCurve = .continuous
        card.layer.borderWidth = 1.5
        card.layer.borderColor = (isSuccess ? C.green : C.red).withAlphaComponent(0.4).cgColor

        let topRow = makePerformanceTopRow()
        let descLabel = UILabel()
        descLabel.text = "Your overall cognitive bias score. Lower means more rational decisions."
        descLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        descLabel.textColor = C.subtext
        descLabel.numberOfLines = 0

        let divider = UIView()
        divider.backgroundColor = C.separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.widthAnchor.constraint(equalToConstant: 1).isActive = true

        let rightStack = makeScoreStack()
        let leftStack = UIStackView(arrangedSubviews: [topRow, descLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 3

        let hstack = UIStackView(arrangedSubviews: [leftStack, divider, rightStack])
        hstack.axis = .horizontal
        hstack.spacing = 14
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

    private func makePerformanceTopRow() -> UIView {
        let scoreLabel = UILabel()
        scoreLabel.text = "Bias Score"
        scoreLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        scoreLabel.textColor = C.text

        let badgeBg = UIView()
        badgeBg.backgroundColor = isSuccess ? C.greenLight : C.redLight
        badgeBg.layer.cornerRadius = 7

        let badgeLbl = UILabel()
        badgeLbl.text = isSuccess ? "Rational" : "Biased"
        badgeLbl.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        badgeLbl.textColor = isSuccess ? C.green : C.red
        badgeLbl.translatesAutoresizingMaskIntoConstraints = false

        let badgeIcon = UIImageView(image: UIImage(systemName: isSuccess ? "brain" : "exclamationmark.triangle.fill"))
        badgeIcon.tintColor = isSuccess ? C.green : C.red
        badgeIcon.contentMode = .scaleAspectFit
        badgeIcon.translatesAutoresizingMaskIntoConstraints = false
        badgeIcon.widthAnchor.constraint(equalToConstant: 10).isActive = true
        badgeIcon.heightAnchor.constraint(equalToConstant: 10).isActive = true

        let badgeRow = UIStackView(arrangedSubviews: [badgeIcon, badgeLbl])
        badgeRow.axis = .horizontal
        badgeRow.spacing = 4
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
        topRow.axis = .horizontal
        topRow.spacing = 8
        topRow.alignment = .center
        return topRow
    }

    private func makeScoreStack() -> UIView {
        let rankNum = UILabel()
        rankNum.text = "\(biasScore)"
        rankNum.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        rankNum.textColor = isSuccess ? C.green : C.red
        rankNum.textAlignment = .center

        let rankSub = UILabel()
        rankSub.text = "Pts"
        rankSub.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        rankSub.textColor = C.subtext
        rankSub.textAlignment = .center

        let rightStack = UIStackView(arrangedSubviews: [rankNum, rankSub])
        rightStack.axis = .vertical
        rightStack.spacing = 0
        rightStack.alignment = .center
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        rightStack.widthAnchor.constraint(equalToConstant: 64).isActive = true
        return rightStack
    }

    private func makeBiasesStack() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
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
        card.backgroundColor = C.card
        card.layer.cornerRadius = 16
        card.layer.cornerCurve = .continuous
        card.layer.borderWidth = isDominant ? 1.5 : 0.5
        card.layer.borderColor = isDominant ? C.orange.withAlphaComponent(0.6).cgColor : C.border.cgColor

        let iconBox = UIView()
        iconBox.backgroundColor = isDominant
            ? UIColor(red: 0.99, green: 0.95, blue: 0.9, alpha: 1)
            : UIColor(red: 0.96, green: 0.96, blue: 0.95, alpha: 1)
        iconBox.layer.cornerRadius = 10
        iconBox.translatesAutoresizingMaskIntoConstraints = false
        iconBox.widthAnchor.constraint(equalToConstant: 36).isActive = true
        iconBox.heightAnchor.constraint(equalToConstant: 36).isActive = true

        let img = UIImageView(image: UIImage(systemName: define.iconName))
        img.tintColor = isDominant ? C.orange : UIColor(red: 0.40, green: 0.40, blue: 0.42, alpha: 1)
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
        titleLbl.text = define.title
        titleLbl.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLbl.textColor = C.text

        let descLbl = UILabel()
        descLbl.text = define.description
        descLbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        descLbl.textColor = UIColor(red: 0.45, green: 0.45, blue: 0.47, alpha: 1)
        descLbl.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [titleLbl, descLbl])
        textStack.axis = .vertical
        textStack.spacing = 3

        let hstack = UIStackView(arrangedSubviews: [iconBox, textStack])
        hstack.axis = .horizontal
        hstack.spacing = 12
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
            addDominantBadge(to: card)
        }

        return card
    }

    private func addDominantBadge(to card: UIView) {
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

    private func makeQuoteCard() -> UIView {
        let card = UIView()
        card.backgroundColor = C.card
        card.layer.cornerRadius = 16
        card.layer.cornerCurve = .continuous
        card.layer.borderWidth = 0.5
        card.layer.borderColor = C.border.cgColor

        guard let ending = endingType,
              let quote = kahnemanEndingQuotes.first(where: { $0.endingType == ending }) else {
            return card
        }

        let quoteLbl = UILabel()
        quoteLbl.text = "\u{201C}\(quote.text)\u{201D}"
        quoteLbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        quoteLbl.textColor = C.text
        quoteLbl.numberOfLines = 0
        quoteLbl.textAlignment = .center

        let authorLbl = UILabel()
        authorLbl.text = "\u{2014} \(quote.author)"
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
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }

    private func makeButton(title: String, bg: UIColor, fg: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(fg, for: .normal)
        button.backgroundColor = bg
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        button.layer.cornerRadius = 14
        button.layer.cornerCurve = .continuous
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }
}

// MARK: - Actions
extension EndingViewController {
    @IBAction func restartTapped(_ sender: Any) {
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
}
// swiftlint:enable file_length
