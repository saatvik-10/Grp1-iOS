import UIKit

extension TwistViewController {

    func setupCAGRSection() {
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
            cagrContainer.topAnchor.constraint(equalTo: mainStack.bottomAnchor, constant: 16),
            cagrContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cagrContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        // ── Integrated Insight Metric Badge (Enlarged) ──
        let greenColor = UIColor(red: 0.18, green: 0.62, blue: 0.37, alpha: 1)

        let dot = UIView()
        dot.backgroundColor    = greenColor
        dot.layer.cornerRadius = 3.5
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.widthAnchor.constraint(equalToConstant: 7).isActive  = true
        dot.heightAnchor.constraint(equalToConstant: 7).isActive = true

        let lbl = UILabel()
        lbl.text      = puzzle.twistIndicators.first?.indicatorName ?? "Twist Indicator"
        lbl.font      = UIFont.systemFont(ofSize: 15, weight: .semibold)
        lbl.textColor = greenColor

        let row = UIStackView(arrangedSubviews: [dot, lbl])
        row.axis                 = .horizontal
        row.spacing              = 6
        row.alignment            = .center
        row.isUserInteractionEnabled = false
        row.translatesAutoresizingMaskIntoConstraints = false

        let pillBg = UIView()
        pillBg.backgroundColor    = greenColor.withAlphaComponent(0.10)
        pillBg.layer.cornerRadius = 16
        pillBg.layer.borderWidth  = 1
        pillBg.layer.borderColor  = greenColor.withAlphaComponent(0.25).cgColor
        pillBg.translatesAutoresizingMaskIntoConstraints = false

        pillBg.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: pillBg.topAnchor, constant: 8),
            row.bottomAnchor.constraint(equalTo: pillBg.bottomAnchor, constant: -8),
            row.leadingAnchor.constraint(equalTo: pillBg.leadingAnchor, constant: 14),
            row.trailingAnchor.constraint(equalTo: pillBg.trailingAnchor, constant: -14)
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
            valuesStack.topAnchor.constraint(equalTo: pillBg.bottomAnchor, constant: 16),
            valuesStack.leadingAnchor.constraint(equalTo: cagrContainer.leadingAnchor, constant: 16),
            valuesStack.trailingAnchor.constraint(equalTo: cagrContainer.trailingAnchor, constant: -16),
            valuesStack.bottomAnchor.constraint(equalTo: cagrContainer.bottomAnchor, constant: -16)
        ])

        addIndicatorRows()
    }

    private func addIndicatorRows() {
        let grouped = Dictionary(grouping: puzzle.twistIndicators, by: \.companyId)

        let numericValues: [(String, Double)] = puzzle.companies.compactMap { company in
            guard let raw = grouped[company.id]?.first?.displayValue else { return nil }
            let cleaned = raw.replacingOccurrences(of: "%", with: "")
                             .replacingOccurrences(of: "₹", with: "")
                             .trimmingCharacters(in: CharacterSet.whitespaces)
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

    private func makeIndicatorCard(for company: Company, grouped: [String: [IndicatorValue]], maxValue: Double, green: UIColor) -> UIView {
        let raw = grouped[company.id]?.first?.displayValue ?? "—"
        let cleaned = raw
            .replacingOccurrences(of: "%", with: "")
            .replacingOccurrences(of: "₹", with: "")
            .trimmingCharacters(in: CharacterSet.whitespaces)
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
