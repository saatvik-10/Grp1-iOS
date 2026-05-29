//
//  GameViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

// swiftlint:disable file_length

class GameViewController: UIViewController {

    @IBOutlet weak var portfolioCard: UIView!
    @IBOutlet weak var scenarioCard: UIView!
    @IBOutlet weak var biasCard: UIView!

    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var biasLabel: UILabel!
    @IBOutlet weak var capitalLabel: UILabel!
    @IBOutlet weak var scenarioTitleLabel: UILabel!
    @IBOutlet weak var scenatioDescriptionLabel: UILabel!

    @IBOutlet weak var chooseAnOptionLabel: UILabel!
    @IBOutlet weak var choiceButton3: GameChoiceButton!
    @IBOutlet weak var choiceButton2: GameChoiceButton!
    @IBOutlet weak var choiceButton1: GameChoiceButton!

    private var lastRenderedNode: DecisionNode?
    private var frozenFinalCapital: Int?
    private var gameEnded = false
    private var latestBias: CognitiveBias?

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
                + "Lesson: Markets don't care what you already invested.",
            iconName: "arrow.triangle.2.circlepath"
        ),
        .overconfidence: BiasDefine(
            bias: .overconfidence,
            title: "Overconfidence",
            description: "Strong narratives increased conviction. "
                + "Confidence exceeded the accuracy of available information.\n\n"
                + "Lesson: Confidence should follow evidence — not stories.",
            iconName: "brain.head.profile"
        ),
        .statusQuo: BiasDefine(
            bias: .statusQuo,
            title: "Status Quo Bias",
            description: "Inaction felt less risky than change. Staying invested delayed necessary decisions."
                + "\n\nLesson: Inaction is also a decision.",
            iconName: "pause.circle"
        ),
        .anchoring: BiasDefine(
            bias: .anchoring,
            title: "Anchoring",
            description: "Early price levels anchored expectations. New information was underweighted."
                + "\n\nLesson: Yesterday's price is irrelevant.",
            iconName: "paperclip"
        ),
        .adaptability: BiasDefine(
            bias: .adaptability,
            title: "Adaptability",
            description: "Willingness to change strategy when facts change. Avoiding attachment to previous positions."
                + "\n\nLesson: Keep an open mind and pivot when required.",
            iconName: "arrow.triangle.swap"
        )
    ]

    private var state = GameState(
        capital: 50_000,
        node: .act1,
        biasScore: 50
    )
    private var lastCapital = 50_000
    private var initialCapital = 50_000

    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        setupUI()
        biasCard.backgroundColor = .clear
        portfolioCard.backgroundColor = .clear
    }

    func finishGame() {
        guard !gameEnded else { return }
        gameEnded = true
        let ending = evaluateEnding()
        let bias = dominantBias()
        if frozenFinalCapital == nil {
            frozenFinalCapital = state.capital
        }
        showEndingScreen(
            ending: ending,
            capital: frozenFinalCapital ?? state.capital,
            biasScore: state.biasScore,
            dominantBias: bias,
            biasExposure: state.biasExposure
        )
    }
}

// MARK: - UI Setup
extension GameViewController {

    func setupUI() {
        styleCards()
        styleLables()
        setupBiasPopup()
    }

    func setupBiasPopup() {
        biasCard.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(showBiasExplanation))
        biasCard.addGestureRecognizer(tap)
    }

    @objc func showBiasExplanation() {
        guard let bias = latestBias, let definition = biasDefinitions[bias] else { return }
        let alert = UIAlertController(title: definition.title, message: definition.description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .default))
        present(alert, animated: true)
    }

    func styleCards() {
        [portfolioCard, scenarioCard, biasCard].forEach { card in
            guard let card else { return }
            card.layer.cornerRadius = 24
            card.backgroundColor = .white
            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOpacity = 0.08
            card.layer.shadowOffset = CGSize(width: 0, height: 8)
            card.layer.shadowRadius = 20
            card.layer.masksToBounds = false
            card.layer.shouldRasterize = true
            card.layer.rasterizationScale = UIScreen.main.scale
        }
    }

    func styleLables() {
        scenarioTitleLabel.textColor = UIColor(white: 0.2, alpha: 1.0)
        if let serifFont = UIFont(name: "Georgia-Bold", size: 32) {
            scenarioTitleLabel.font = serifFont
        } else {
            scenarioTitleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        }

        scenatioDescriptionLabel.textColor = UIColor(white: 0.35, alpha: 1.0)
        scenatioDescriptionLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)

        timerLabel.textColor = UIColor(white: 0.4, alpha: 1.0)
        timerLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)

        chooseAnOptionLabel.textColor = UIColor(white: 0.4, alpha: 1.0)
        chooseAnOptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }

    func hideAllButtons() {
        [choiceButton1, choiceButton2, choiceButton3].forEach {
            $0?.alpha = 0
            $0?.transform = CGAffineTransform(translationX: 0, y: 12)
            $0?.isHidden = false
        }
    }

    func revealButtonsSequentially(_ buttons: [(UIButton, String)]) {
        for (index, pair) in buttons.enumerated() {
            let button = pair.0
            let title = pair.1
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.35) {
                UIView.animate(
                    withDuration: 1.5,
                    delay: 0.5,
                    usingSpringWithDamping: 1.2,
                    initialSpringVelocity: 1.4,
                    options: .curveEaseOut
                ) {
                    button.alpha = 1
                    button.transform = .identity
                }
                button.typeTitle(title)
            }
        }
    }

    func resetChoices() {
        [choiceButton1, choiceButton2, choiceButton3].forEach {
            $0?.isHidden = false
            $0?.isEnabled = true
            $0?.alpha = 1.0
            $0?.setTitle("", for: .normal)
        }
    }
}

// MARK: - Stats & Bias
extension GameViewController {

    func updatePercentageChange() {
        let change = state.capital - initialCapital
        let percentage = Double(change) / Double(initialCapital) * 100
        let formatted = String(format: "%.1f%%", percentage)
        percentageLabel.text = percentage >= 0 ? "+\(formatted)" : formatted
        let positive = percentage >= 0

        styleStatLabel(
            percentageLabel,
            textColor: positive ? .systemGreen : .systemRed,
            bgColor: (positive ? UIColor.systemGreen : UIColor.systemRed).withAlphaComponent(0.15),
            icon: positive ? "arrow.up.right" : "arrow.down.right"
        )
    }

    func applyBias(_ bias: CognitiveBias, weight: Int) {
        state.biasExposure[bias, default: 0] += weight
        state.biasScore += weight
        latestBias = bias
        updateBiasLabel()
    }

    func updateBiasLabel() {
        biasLabel.numberOfLines = 1
        biasLabel.sizeToFit()
        biasLabel.layoutIfNeeded()

        if let bias = latestBias, let definition = biasDefinitions[bias] {
            biasLabel.text = bias.rawValue.uppercased()

            styleStatLabel(
                biasLabel,
                textColor: .systemIndigo,
                bgColor: UIColor.systemIndigo.withAlphaComponent(0.15),
                icon: definition.iconName
            )
        } else {
            biasLabel.text = "NEUTRAL"

            styleStatLabel(
                biasLabel,
                textColor: .systemGray,
                bgColor: UIColor.systemGray.withAlphaComponent(0.15),
                icon: "minus.circle"
            )
        }
    }

    func dominantBias() -> CognitiveBias? {
        state.biasExposure.max(by: { $0.value < $1.value })?.key
    }

    func evaluateEnding() -> EndingType {
        let capital = frozenFinalCapital ?? state.capital

        if capital >= 80000 { return .success }
        if capital >= 40000 { return .partialFailure }
        if capital <= 40000 && capital >= 20000 { return .failure }
        return .criticalFailure
    }

}

// MARK: - Render
extension GameViewController {

    private var nodeRenderers: [DecisionNode: () -> Void] {
        [
            .act1: renderAct1,
            .loyalistFollowup: renderLoyalistFollowup,
            .loyalistDoubleDown: renderLoyalistDoubleDown,
            .loyalistTimeWillTell: renderLoyalistTimeWillTell,
            .loyalistDoubleDownLoss: renderLoyalistDoubleDownLoss,
            .loyalistExit: renderLoyalistExit,
            .pragmatistFollowup: renderPragmatistFollowup,
            .pragmatistStay: renderPragmatistStay,
            .pragmatistExit: renderPragmatistExit,
            .pragmaticLoss: renderPragmaticLoss,
            .evPivot: renderEVPivot,
            .evPivotLoss: renderEVPivotLoss,
            .evPivotProfit: renderEVPivotProfit,
            .evProfitBook: renderEVProfitBook
        ]
    }

    private func render() {
        if gameEnded { return }

        if lastCapital != state.capital {
            capitalLabel.animateNumber(
                from: lastCapital,
                to: state.capital,
                duration: abs(lastCapital - state.capital) > 20_000 ? 1.0 : 0.6
            )
            lastCapital = state.capital
        } else {
            capitalLabel.text = "₹\(state.capital)"
        }

        timerLabel.text = "0.0 yrs"
        resetChoices()
        updateBiasLabel()
        updatePercentageChange()

        nodeRenderers[state.node]?()

        lastRenderedNode = state.node
    }

    private func renderAct1() {
        scenarioTitleLabel.text = "The Disruptive Spark"
        scenatioDescriptionLabel.typeThenReveal(
            """
            • A leaked National Green Mobility Policy sends shockwaves through the market.
            • By 2030, 40% of all new vehicle sales must be electric.
            • Bharat Motors opens 12% lower.
            • Nothing has changed inside the company — but everything has changed around it.
            """
        )
        hideAllButtons()
        revealButtonsSequentially([
            (choiceButton1, "Hold & Hope"),
            (choiceButton2, "Sell 50 % "),
            (choiceButton3, "Pivot")
        ])
        applyBias(.anchoring, weight: 5)
    }

    private func renderLoyalistFollowup() {
        let nodeChanged = lastRenderedNode != state.node
        scenarioTitleLabel.text = "Comfort in Familiarity"
        if nodeChanged {
            scenatioDescriptionLabel.typeThenReveal(
                """
                • Quarterly results beat expectations, but guidance remains cautious.
                • EPS surprises on the upside.
                • Supply chain risks persist.
                • Analyst opinions are divided.
                """
            )
        }
        hideAllButtons()
        revealButtonsSequentially([
            (choiceButton1, "Hold & Hope"),
            (choiceButton2, "Double Down"),
            (choiceButton3, "Pivot")
        ])
        applyBias(.lossAversion, weight: 15)
        applyBias(.statusQuo, weight: 10)
        timerLabel.text = "0.5yr"
    }

    private func renderLoyalistDoubleDown() {
        let nodeChanged = lastRenderedNode != state.node
        scenarioTitleLabel.text = "The Earnings Surprise"
        if nodeChanged {
            scenatioDescriptionLabel.typeThenReveal(
                """
                • Revenue beats estimates. EBITDA margins expand.
                • Guidance is raised.
                • You double down on your position.
                • The stock responds positively, but sector uncertainty remains.
                """
            )
        }
        hideAllButtons()
        choiceButton2.isEnabled = false
        choiceButton2.alpha = 0
        choiceButton3.isEnabled = false
        choiceButton3.alpha = 0
        revealButtonsSequentially([
            (choiceButton1, "Time Will Tell")
        ])
        applyBias(.sunkCost, weight: 20)
        applyBias(.overconfidence, weight: 15)
        timerLabel.text = "1.0 yr"
    }

    private func renderLoyalistTimeWillTell() {
        let nodeChanged = lastRenderedNode != state.node
        scenarioTitleLabel.text = "Time Will Tell"
        if nodeChanged {
            scenatioDescriptionLabel.typeThenReveal(
                """
                • You decide to wait it out.
                • Years pass. Capital remains stuck.
                • Inflation and opportunity cost compound.
                • The company survives — but your money doesn't grow.
                """
            )
        }
        hideAllButtons()
        revealButtonsSequentially([
            (choiceButton1, "Stay the course")
        ])
        choiceButton2.isEnabled = false
        choiceButton2.alpha = 0
        choiceButton3.isEnabled = false
        choiceButton3.alpha = 0
        chooseAnOptionLabel.isHidden = true
        timerLabel.text = "2.0 yrs"
    }

    private func renderLoyalistDoubleDownLoss() {
        scenarioTitleLabel.text = "You Doubled Down"
        scenatioDescriptionLabel.text = """
        • You added more capital to a losing position.
        • Now liquidity has dried up.
        • Buyers have vanished. Your funds are locked in.
        • You're no longer choosing — the market is choosing for you.
        """
        capitalLabel.text = "₹25000"
        choiceButton1.isHidden = true
        choiceButton2.isHidden = true
        choiceButton3.isHidden = true
        timerLabel.text = "2.0 yrs"
    }

    private func renderLoyalistExit() {
        scenarioTitleLabel.text = "You exit at loss"

        hideAllButtons()
        revealButtonsSequentially([
            (choiceButton1, "Go all in EV")
        ])

        choiceButton2.isEnabled = false
        choiceButton2.alpha = 0
        choiceButton3.isEnabled = false
        choiceButton3.alpha = 0
    }

    private func renderPragmatistFollowup() {
        let nodeChanged = lastRenderedNode != state.node
        scenarioTitleLabel.text = "Partial Exit"
        if nodeChanged {
            scenatioDescriptionLabel.typeThenReveal(
                """
                • You sell half your position.
                • Risk is reduced, but uncertainty still lingers.
                • Some capital is safe — the rest is still exposed.
                • This is a turning point. What do you do next?
                """
            )
        }
        hideAllButtons()
        revealButtonsSequentially([
            (choiceButton1, "Hold Remainder"),
            (choiceButton2, "Complete Exit")
        ])
        choiceButton3.isEnabled = false
        choiceButton3.alpha = 0
    }

    private func renderPragmatistStay() {
        let nodeChanged = lastRenderedNode != state.node
        scenarioTitleLabel.text = "Risk Contained"
        if nodeChanged {
            scenatioDescriptionLabel.typeThenReveal(
                """
                • You reduced exposure early.
                • Losses continue, but on a smaller base.
                • Your capital is bruised — not broken.
                """
            )
        }
        hideAllButtons()
        revealButtonsSequentially([
            (choiceButton1, "Accept Outcome ")
        ])

        choiceButton2.isEnabled = false
        choiceButton2.alpha = 0
        choiceButton3.isEnabled = false
        choiceButton3.alpha = 0
        chooseAnOptionLabel.isHidden = true
        timerLabel.text = "1.0 yr"
    }

    private func renderPragmatistExit() {
        scenarioTitleLabel.text = "Capital in Hand"
        scenatioDescriptionLabel.typeThenReveal(
            """
            • You've exited Legacy Motors completely.
            • Selling 50% earlier softened the blow. Now your remaining capital is free.
            • The optimal strategy is to reinvest into a faster-growing sector.
            • In this market, disruption creates opportunity, and timing defines returns.
            """
        )
        hideAllButtons()
        revealButtonsSequentially([
            (choiceButton1, "Go all in EV with increased capital")
        ])
        choiceButton2.isEnabled = false
        choiceButton2.alpha = 0
        choiceButton3.isEnabled = false
        choiceButton3.alpha = 0
    }

    private func renderPragmaticLoss() {
        scenarioTitleLabel.text = ""
        choiceButton1.setTitle("", for: .normal)
    }

    private func renderEVPivot() {
        let nodeChanged = lastRenderedNode != state.node
        scenarioTitleLabel.text = "The Pivot"
        if nodeChanged {
            scenatioDescriptionLabel.typeThenReveal(
                """
                • You exit the legacy auto position, locking in a realized loss.
                • Capital is freed, improving liquidity and optionality.
                • Emotional bias is reduced, but uncertainty increases.
                • Early entry could yield outsized returns — or sharp drawdowns.
                • You are effectively rotating from stability to speculation.
                """
            )
        }
        hideAllButtons()
        revealButtonsSequentially([
            (choiceButton1, "Go all in EV")
        ])

        choiceButton2.isEnabled = false
        choiceButton2.alpha = 0
        choiceButton3.isEnabled = false
        choiceButton3.alpha = 0
        applyBias(.adaptability, weight: 30)
        applyBias(.lossAversion, weight: -10)
        timerLabel.text = "1.0 yr"
    }

    private func renderEVPivotLoss() {
        scenarioTitleLabel.text = "Lithium Sector goes down"
        scenatioDescriptionLabel.typeThenReveal(
            """
            • Geopolitical tensions erupt across key lithium-producing regions.
            • Export routes are disrupted. Battery manufacturers scramble for inventory.
            • EV production slows overnight.
            • Investor confidence collapses. High-growth EV stocks plunge.
            """
        )
        hideAllButtons()
        revealButtonsSequentially([
            (choiceButton1, "Accept Outcome")
        ])
        choiceButton2.isEnabled = true
        choiceButton2.alpha = 0
        choiceButton3.isEnabled = false
        choiceButton3.alpha = 0
        timerLabel.text = "2.0 yrs"
    }

    private func renderEVPivotProfit() {
        scenarioTitleLabel.typeThenReveal("You have stayed on EV")
        scenatioDescriptionLabel.typeThenReveal(
            """
            • The gamble was worth it, as the EV sector skyrockets and demand outpaces supply.
            • While competitors scramble to retrofit old factories, you are already operational.
            • Now you must defend your territory against new tech giants entering the fray.
            • By staying the course, you've secured a dominant foothold in a fast-growing industry.
            """
        )
        hideAllButtons()
        revealButtonsSequentially([
            (choiceButton1, "Stay the course"),
            (choiceButton2, "Book the profits and exit")
        ])

        choiceButton3.isEnabled = false
        choiceButton3.alpha = 0
        timerLabel.text = "2.0 yrs"
    }

    private func renderEVProfitBook() {
        scenarioTitleLabel.text = "You booked the profit timely"
        scenatioDescriptionLabel.typeThenReveal(
            """
            • Timings matter in the market.
            """
        )
        choiceButton1.isHidden = true
        choiceButton2.isHidden = true
        choiceButton3.isHidden = true
        chooseAnOptionLabel.isHidden = true
        timerLabel.text = "2.0 yrs"
    }
}

// MARK: - Actions & Navigation
extension GameViewController {

    private func applyChoice1EarlyExit() -> Bool {
        switch state.node {
        case .loyalistTimeWillTell:
            state.capital -= 15000; state.biasScore -= 25
            state.node = .loyalistDoubleDownLoss; finishGame(); return true
        case .pragmatistStay:
            state.biasScore -= 10; finishGame(); return true
        case .evPivotLoss:
            finishGame(); return true
        default:
            return false
        }
    }

    @IBAction func choiceButton1(_ sender: UIButton) {
        if applyChoice1EarlyExit() { return }

        switch state.node {
        case .act1:
            state.capital -= 8000; state.biasScore -= 10
            state.node = .loyalistFollowup
        case .loyalistFollowup:
            state.capital -= 15000; state.biasScore -= 20
            state.node = .loyalistTimeWillTell
        case .loyalistDoubleDown:
            state.capital -= 10000; state.biasScore -= 15
            state.node = .loyalistTimeWillTell
        case .pragmatistFollowup:
            state.capital -= 5000; state.biasScore -= 10
            state.node = .pragmatistStay
        case .pragmatistExit:
            state.capital += 10000; state.node = .evPivot
        case .evPivot:
            state.capital += 40000; state.biasScore += 15
            state.node = .evPivotProfit
        case .evPivotProfit:
            state.capital -= 20000; state.biasScore -= 25
            state.node = .evPivotLoss
        default:
            break
        }

        render()
    }

    @IBAction func choiceButton2(_ sender: UIButton) {
        switch state.node {
        case .act1:
            state.capital -= 25000
            applyBias(.adaptability, weight: 15)
            state.biasScore -= 15
            state.node = .pragmatistFollowup

        case .loyalistDoubleDown:
            state.capital -= 10000
            state.node = .loyalistTimeWillTell
        case .loyalistFollowup:
            state.capital += 25000
            state.biasScore -= 20
            state.node = .loyalistDoubleDown

        case .pragmatistFollowup:
            state.biasScore -= 10
            state.node = .pragmatistExit
        case .evPivotLoss:
            state.capital -= 20000
            state.biasScore -= 30
            state.node = .evProfitBook
        case .evPivotProfit:
            finishGame()
            return

        case .pragmatistExit:
            state.node = .evPivot

        default:
            break
        }
        render()
    }

    @IBAction func choiceButton3(_ sender: UIButton) {
        switch state.node {

        case .act1:
            state.capital -= 8000
            state.biasScore += 30
            state.node = .evPivot

        case .loyalistFollowup:
            state.capital -= 4000
            state.biasScore -= 30
            state.node = .evPivot

        case .evPivot:
            state.capital -= 10000
            state.node = .evPivotLoss

        default:
            break
        }
        render()
    }

    func showEndingScreen(
        ending: EndingType,
        capital: Int,
        biasScore: Int,
        dominantBias: CognitiveBias?,
        biasExposure: [CognitiveBias: Int]
    ) {
        let storyboard = UIStoryboard(name: "Scenario", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "EndingViewController"
        ) as? EndingViewController else { return }

        vc.endingType = ending
        vc.finalCapital = capital
        vc.biasScore = biasScore
        vc.dominantBias = dominantBias
        vc.biasExposure = biasExposure
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

// MARK: - UIButton Extensions
extension UIButton {
    func typeTitle(_ text: String, interval: TimeInterval = 0.035) {
        setTitle("", for: .normal)
        let font = UIFont.preferredFont(forTextStyle: .title3)

        var index = 0
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if index < text.count {
                let idx = text.index(text.startIndex, offsetBy: index + 1)
                let currentText = String(text[..<idx])

                let attributedTitle = NSAttributedString(string: currentText, attributes: [
                    .font: font,
                    .foregroundColor: UIColor.black
                ])

                self.setAttributedTitle(attributedTitle, for: .normal)
                index += 1
            } else {
                timer.invalidate()
            }
        }
    }
}

extension UIButton {

    func applyGlass() {
        subviews
            .filter { $0 is UIVisualEffectView }
            .forEach { $0.removeFromSuperview() }

        let blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let blurView = UIVisualEffectView(effect: blur)

        self.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
        self.titleLabel?.adjustsFontForContentSizeCategory = true
        setTitleColor(.black, for: .normal)

        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.isUserInteractionEnabled = false
        blurView.layer.cornerRadius = 18
        blurView.clipsToBounds = true

        insertSubview(blurView, at: 0)

        layer.cornerRadius = 18
        layer.masksToBounds = false

        layer.borderWidth = 1.2
        layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        setTitleColor(.black, for: .normal)

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 5)
    }
}
