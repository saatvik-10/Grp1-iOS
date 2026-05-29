//
//  TwistViewController.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 09/02/26.
//

import UIKit

final class TwistViewController: UIViewController {

    var puzzle: DailyPuzzle!

    private let mainStack     = UIStackView()
    private let cagrContainer = UIView()
    private let valuesStack   = UIStackView()

    // ── Connect this in Storyboard ──
    @IBOutlet weak var proceedButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.961, green: 0.957, blue: 0.945, alpha: 1)
        // Shadow must stay in code (Storyboard can't do shadows)
        proceedButton.layer.shadowColor   = UIColor.black.cgColor
        proceedButton.layer.shadowOpacity = 0.15
        proceedButton.layer.shadowOffset  = CGSize(width: 0, height: 4)
        proceedButton.layer.shadowRadius  = 10
        setupUI()
    }

    // MARK: - Navigation

    @IBAction func proceedTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showInvest", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showInvest",
           let vc = segue.destination as? InvestViewController {
            vc.puzzle = puzzle
        }
    }

    // MARK: - UI

    private func setupUI() {
        mainStack.axis      = .vertical
        mainStack.spacing   = 6
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])

        // ── "TWIST" small caps label ──
        let twistBadge = UILabel()
        twistBadge.text          = "TWIST"
        twistBadge.font          = UIFont.systemFont(ofSize: 40, weight: .bold)
        twistBadge.textColor     = UIColor(red: 0.18, green: 0.62, blue: 0.37, alpha: 1)
        twistBadge.textAlignment = .center
        twistBadge.letterSpacing(2)
        mainStack.addArrangedSubview(twistBadge)
        mainStack.setCustomSpacing(12, after: twistBadge)

        // ── "Wait!" — Georgia serif, matches screen 1 title ──
        let waitLabel = UILabel()
        waitLabel.text          = "Wait!"
        waitLabel.font          = UIFont.systemFont(ofSize: 28, weight: .bold)
        waitLabel.textColor     = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)
        waitLabel.textAlignment = .center
        mainStack.addArrangedSubview(waitLabel)
        mainStack.setCustomSpacing(6, after: waitLabel)

        // ── Subtitle ──
        let subtitle = UILabel()
        subtitle.text          = "This might help your decision"
        subtitle.font          = UIFont.systemFont(ofSize: 20, weight: .regular)
        subtitle.textColor     = .secondaryLabel
        subtitle.numberOfLines = 0
        subtitle.textAlignment = .center
        mainStack.addArrangedSubview(subtitle)
        mainStack.setCustomSpacing(4, after: subtitle)

        // ── Sector ──
        let sector = UILabel()
        sector.text          = "Sector — \(puzzle.sector)"
        sector.font          = UIFont.systemFont(ofSize: 18, weight: .regular)
        sector.textColor     = .systemGray
        sector.textAlignment = .center
        mainStack.addArrangedSubview(sector)

        setupCAGRSection()
    }

    private func setupCAGRSection() {
        cagrContainer.translatesAutoresizingMaskIntoConstraints = false
        cagrContainer.backgroundColor     = .systemBackground
        cagrContainer.layer.cornerRadius  = 20
        cagrContainer.layer.cornerCurve   = .continuous
        cagrContainer.clipsToBounds       = false
        cagrContainer.layer.shadowColor   = UIColor.black.cgColor
        cagrContainer.layer.shadowOpacity = 0.07
        cagrContainer.layer.shadowRadius  = 12
        cagrContainer.layer.shadowOffset  = CGSize(width: 0, height: 4)

        view.addSubview(cagrContainer)

        NSLayoutConstraint.activate([
            cagrContainer.topAnchor.constraint(equalTo: mainStack.bottomAnchor, constant: 20),
            cagrContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cagrContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        // ── Indicator name pill ──
        let pillBg = UIView()
        pillBg.backgroundColor    = UIColor(red: 0.94, green: 0.94, blue: 0.92, alpha: 1)
        pillBg.layer.cornerRadius = 12
        pillBg.translatesAutoresizingMaskIntoConstraints = false

        let indicatorName = puzzle.twistIndicators.first?.indicatorName ?? "Twist Indicator"
        let pillLabel = UILabel()
        pillLabel.text      = indicatorName
        pillLabel.font      = UIFont.systemFont(ofSize: 20, weight: .medium)
        pillLabel.textColor = UIColor(red: 0.30, green: 0.35, blue: 0.30, alpha: 1)
        pillLabel.translatesAutoresizingMaskIntoConstraints = false

        pillBg.addSubview(pillLabel)
        NSLayoutConstraint.activate([
            pillLabel.topAnchor.constraint(equalTo: pillBg.topAnchor, constant: 5),
            pillLabel.bottomAnchor.constraint(equalTo: pillBg.bottomAnchor, constant: -5),
            pillLabel.leadingAnchor.constraint(equalTo: pillBg.leadingAnchor, constant: 12),
            pillLabel.trailingAnchor.constraint(equalTo: pillBg.trailingAnchor, constant: -12)
        ])

        cagrContainer.addSubview(pillBg)
        NSLayoutConstraint.activate([
            pillBg.topAnchor.constraint(equalTo: cagrContainer.topAnchor, constant: 16),
            pillBg.centerXAnchor.constraint(equalTo: cagrContainer.centerXAnchor)
        ])

        // ── Values stack ──
        valuesStack.axis         = .vertical
        valuesStack.spacing      = 10
        valuesStack.translatesAutoresizingMaskIntoConstraints = false
        cagrContainer.addSubview(valuesStack)

        NSLayoutConstraint.activate([
            valuesStack.topAnchor.constraint(equalTo: pillBg.bottomAnchor, constant: 14),
            valuesStack.leadingAnchor.constraint(equalTo: cagrContainer.leadingAnchor, constant: 14),
            valuesStack.trailingAnchor.constraint(equalTo: cagrContainer.trailingAnchor, constant: -14),
            valuesStack.bottomAnchor.constraint(equalTo: cagrContainer.bottomAnchor, constant: -14)
        ])

        addIndicatorRows()
    }

    private func addIndicatorRows() {
        let grouped = Dictionary(grouping: puzzle.twistIndicators, by: \.companyId)

        let numericValues: [(String, Double)] = puzzle.companies.compactMap { company in
            guard let raw = grouped[company.id]?.first?.displayValue else { return nil }
            let cleaned = raw.replacingOccurrences(of: "%", with: "")
                             .replacingOccurrences(of: "₹", with: "")
                             .trimmingCharacters(in: .whitespaces)
            let num = Double(cleaned) ?? 0
            return (company.id, num)
        }
        let maxValue = numericValues.map { $0.1 }.max() ?? 0

        let green = UIColor(red: 0.18, green: 0.62, blue: 0.37, alpha: 1)

        for company in puzzle.companies {
            let card = makeIndicatorCard(for: company, grouped: grouped, maxValue: maxValue, green: green)
            valuesStack.addArrangedSubview(card)
        }
    }

    private func makeIndicatorCard(for company: Company, grouped: [String: [TwistIndicator]], maxValue: Double, green: UIColor) -> UIView {
        let raw = grouped[company.id]?.first?.displayValue ?? "—"
        let cleaned = raw
            .replacingOccurrences(of: "%", with: "")
            .replacingOccurrences(of: "₹", with: "")
            .trimmingCharacters(in: .whitespaces)
        let numVal = Double(cleaned) ?? 0
        let isBest = numVal == maxValue && maxValue > 0

        let card = UIView()
        card.backgroundColor    = UIColor(red: 0.961, green: 0.957, blue: 0.945, alpha: 1)
        card.layer.cornerRadius = 14
        card.layer.cornerCurve  = .continuous
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 72).isActive = true

        if isBest {
            card.backgroundColor   = .systemBackground
            card.layer.borderWidth = 1.5
            card.layer.borderColor = green.cgColor
        }

        let nameLabel = UILabel()
        nameLabel.text      = company.name
        nameLabel.font      = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        let descLabel = UILabel()
        descLabel.text      = company.description
        descLabel.font      = UIFont.systemFont(ofSize: 13, weight: .regular)
        descLabel.textColor = .systemGray
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.text          = raw
        valueLabel.font          = UIFont.systemFont(ofSize: 17, weight: .semibold)
        valueLabel.textColor     = isBest ? green : UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        let barBg = UIView()
        barBg.backgroundColor    = UIColor(red: 0.88, green: 0.87, blue: 0.85, alpha: 1)
        barBg.layer.cornerRadius = 1.5
        barBg.translatesAutoresizingMaskIntoConstraints = false
        barBg.heightAnchor.constraint(equalToConstant: 5).isActive  = true
        barBg.widthAnchor.constraint(equalToConstant: 52).isActive  = true

        let barFill = UIView()
        barFill.backgroundColor   = green
        barFill.layer.cornerRadius = 1.5
        barFill.translatesAutoresizingMaskIntoConstraints = false
        barBg.addSubview(barFill)

        let ratio = maxValue > 0 ? CGFloat(numVal / maxValue) : 0.05
        NSLayoutConstraint.activate([
            barFill.leadingAnchor.constraint(equalTo: barBg.leadingAnchor),
            barFill.topAnchor.constraint(equalTo: barBg.topAnchor),
            barFill.bottomAnchor.constraint(equalTo: barBg.bottomAnchor),
            barFill.widthAnchor.constraint(equalTo: barBg.widthAnchor, multiplier: max(ratio, 0.04))
        ])

        let rightStack = UIStackView(arrangedSubviews: [valueLabel, barBg])
        rightStack.axis      = .vertical
        rightStack.spacing   = 4
        rightStack.alignment = .trailing
        rightStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(nameLabel)
        card.addSubview(descLabel)
        card.addSubview(rightStack)

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),

            descLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            descLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),

            rightStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            rightStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            rightStack.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: 8)
        ])

        return card
    }
}

// MARK: - UILabel helper

private extension UILabel {
    func letterSpacing(_ spacing: CGFloat) {
        guard let text else { return }
        attributedText = NSAttributedString(string: text, attributes: [.kern: spacing])
    }
}
