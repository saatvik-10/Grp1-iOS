import UIKit

// swiftlint:disable file_length

// MARK: - Card Builders

extension ResultViewController {

    // MARK: - 1. Hero Banner

    func makeBanner() -> UIView {
        let card = UIView()
        card.backgroundColor    = data.isCorrect ? C.greenDark : C.charcoal
        card.layer.cornerRadius = 22
        card.layer.cornerCurve  = .continuous
        card.clipsToBounds      = true

        let iconBox = UIView()
        iconBox.backgroundColor    = data.isCorrect
            ? UIColor(red: 0.12, green: 0.30, blue: 0.18, alpha: 1)
            : UIColor(red: 0.20, green: 0.20, blue: 0.22, alpha: 1)
        iconBox.layer.cornerRadius = 10
        iconBox.translatesAutoresizingMaskIntoConstraints = false
        iconBox.widthAnchor.constraint(equalToConstant: 36).isActive  = true
        iconBox.heightAnchor.constraint(equalToConstant: 36).isActive = true

        let iconImg = UIImageView(image: UIImage(systemName: data.isCorrect ? "checkmark" : "xmark"))
        iconImg.tintColor    = data.isCorrect ? C.green : UIColor(red: 0.85, green: 0.35, blue: 0.30, alpha: 1)
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
        badgeLabel.textColor = data.isCorrect ? C.green : UIColor(red: 0.55, green: 0.55, blue: 0.58, alpha: 1)

        let badgeRow = UIStackView(arrangedSubviews: [iconBox, badgeLabel])
        badgeRow.axis      = .horizontal
        badgeRow.spacing   = 8
        badgeRow.alignment = .center

        let title = UILabel()
        title.text          = data.isCorrect ? "Nailed It, Analyst!" : "Close, But Not Quite!"
        title.font          = UIFont.systemFont(ofSize: 22, weight: .bold)
        title.textColor     = .white
        title.numberOfLines = 0

        let msg = UILabel()
        msg.text = data.isCorrect
            ? "You read the indicators like a pro. \(data.bestCompany.name) was the clear winner — and you saw it."
            : "The twist indicator was the key signal. A low \(data.twistIndicatorName) told the whole story. Every miss is a lesson."
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

    // MARK: - 2. Your Pick

    func makePickStrip() -> UIView {
        let card = UIView()
        card.backgroundColor    = C.card
        card.layer.cornerRadius = 16
        card.layer.cornerCurve  = .continuous
        card.layer.borderWidth  = 1.5
        card.layer.borderColor  = (data.isCorrect ? C.green : C.red).withAlphaComponent(0.4).cgColor

        let nameLabel = UILabel()
        nameLabel.text      = data.selectedCompany.name
        nameLabel.font      = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = C.text

        let badgeBg = makePickBadge()

        let topRow = UIStackView(arrangedSubviews: [nameLabel, badgeBg])
        topRow.axis      = .horizontal
        topRow.spacing   = 8
        topRow.alignment = .center

        let descLabel = UILabel()
        descLabel.text      = data.selectedCompany.description
        descLabel.font      = UIFont.systemFont(ofSize: 12, weight: .regular)
        descLabel.textColor = C.subtext

        let divider = UIView()
        divider.backgroundColor = C.separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.widthAnchor.constraint(equalToConstant: 1).isActive = true

        let rightStack = makeRankSection()

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

    func makePickBadge() -> UIView {
        let badgeBg  = UIView()
        badgeBg.backgroundColor    = data.isCorrect ? C.greenLight : C.redLight
        badgeBg.layer.cornerRadius = 7

        let badgeLbl = UILabel()
        badgeLbl.text      = data.isCorrect ? "Correct" : "Wrong"
        badgeLbl.font      = UIFont.systemFont(ofSize: 10, weight: .semibold)
        badgeLbl.textColor = data.isCorrect ? C.green : C.red
        badgeLbl.translatesAutoresizingMaskIntoConstraints = false

        let badgeIcon = UIImageView(image: UIImage(systemName: data.isCorrect ? "checkmark" : "xmark"))
        badgeIcon.tintColor    = data.isCorrect ? C.green : C.red
        badgeIcon.contentMode  = .scaleAspectFit
        badgeIcon.translatesAutoresizingMaskIntoConstraints = false
        badgeIcon.widthAnchor.constraint(equalToConstant: 9).isActive  = true
        badgeIcon.heightAnchor.constraint(equalToConstant: 9).isActive = true

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
        return badgeBg
    }

    func makeRankSection() -> UIView {
        let rankNum = UILabel()
        let suffix  = ordinalSuffix(data.selectedRank)
        rankNum.text          = "\(data.selectedRank)\(suffix)"
        rankNum.font          = UIFont.systemFont(ofSize: 28, weight: .bold)
        rankNum.textColor     = data.isCorrect ? C.green : C.red
        rankNum.textAlignment = .center

        let rankSub = UILabel()
        rankSub.text          = "of \(data.rankedResults.count)"
        rankSub.font          = UIFont.systemFont(ofSize: 11, weight: .regular)
        rankSub.textColor     = C.subtext
        rankSub.textAlignment = .center

        let rightStack = UIStackView(arrangedSubviews: [rankNum, rankSub])
        rightStack.axis      = .vertical
        rightStack.spacing   = 0
        rightStack.alignment = .center
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        rightStack.widthAnchor.constraint(equalToConstant: 64).isActive = true
        return rightStack
    }

    // MARK: - 3. Twist Indicator Card

    func makeTwistCard() -> UIView {
        let card = UIView()
        card.backgroundColor    = C.card
        card.layer.cornerRadius = 16
        card.layer.cornerCurve  = .continuous
        card.layer.borderWidth  = 0.5
        card.layer.borderColor  = C.border.cgColor

        let headerRow = makeTwistHeader()

        let divider = UIView()
        divider.backgroundColor = C.separator
        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true

        let defLabel = UILabel()
        defLabel.text          = data.twistDefinition
        defLabel.font          = UIFont.systemFont(ofSize: 13, weight: .regular)
        defLabel.textColor     = UIColor(red: 0.30, green: 0.30, blue: 0.30, alpha: 1)
        defLabel.numberOfLines = 0

        let formulaBox = makeTwistFormula()

        let vstack = UIStackView(arrangedSubviews: [headerRow, divider, defLabel, formulaBox])
        vstack.axis    = .vertical
        vstack.spacing = 12
        vstack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(vstack)

        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            vstack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            vstack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            vstack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }

    func makeTwistHeader() -> UIView {
        let iconBox = UIView()
        iconBox.backgroundColor    = UIColor(red: 0.90, green: 0.97, blue: 0.92, alpha: 1)
        iconBox.layer.cornerRadius = 10
        iconBox.translatesAutoresizingMaskIntoConstraints = false
        iconBox.widthAnchor.constraint(equalToConstant: 36).isActive  = true
        iconBox.heightAnchor.constraint(equalToConstant: 36).isActive = true

        let iconImg = UIImageView(image: UIImage(systemName: "waveform.path.ecg"))
        iconImg.tintColor   = C.green
        iconImg.contentMode = .scaleAspectFit
        iconImg.translatesAutoresizingMaskIntoConstraints = false
        iconBox.addSubview(iconImg)
        NSLayoutConstraint.activate([
            iconImg.centerXAnchor.constraint(equalTo: iconBox.centerXAnchor),
            iconImg.centerYAnchor.constraint(equalTo: iconBox.centerYAnchor),
            iconImg.widthAnchor.constraint(equalToConstant: 18),
            iconImg.heightAnchor.constraint(equalToConstant: 18)
        ])

        let nameLabel = UILabel()
        nameLabel.text      = data.twistIndicatorName
        nameLabel.font      = UIFont.systemFont(ofSize: 15, weight: .semibold)
        nameLabel.textColor = C.text

        let subLabel = UILabel()
        subLabel.text      = "Twist indicator"
        subLabel.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        subLabel.textColor = C.subtext

        let nameStack = UIStackView(arrangedSubviews: [nameLabel, subLabel])
        nameStack.axis    = .vertical
        nameStack.spacing = 1

        let keyBadge = UIView()
        keyBadge.backgroundColor    = UIColor(red: 0.90, green: 0.97, blue: 0.92, alpha: 1)
        keyBadge.layer.cornerRadius = 6

        let keyLbl = UILabel()
        keyLbl.text      = "KEY SIGNAL"
        keyLbl.font      = UIFont.systemFont(ofSize: 8.5, weight: .bold)
        keyLbl.textColor = C.green
        keyLbl.translatesAutoresizingMaskIntoConstraints = false
        keyBadge.addSubview(keyLbl)
        NSLayoutConstraint.activate([
            keyLbl.topAnchor.constraint(equalTo: keyBadge.topAnchor, constant: 3),
            keyLbl.bottomAnchor.constraint(equalTo: keyBadge.bottomAnchor, constant: -3),
            keyLbl.leadingAnchor.constraint(equalTo: keyBadge.leadingAnchor, constant: 6),
            keyLbl.trailingAnchor.constraint(equalTo: keyBadge.trailingAnchor, constant: -6)
        ])

        let headerRow = UIStackView(arrangedSubviews: [iconBox, nameStack, keyBadge])
        headerRow.axis      = .horizontal
        headerRow.spacing   = 10
        headerRow.alignment = .center
        return headerRow
    }

    func makeTwistFormula() -> UIView {
        let formulaBox = UIView()
        formulaBox.backgroundColor    = UIColor(red: 0.94, green: 0.98, blue: 0.95, alpha: 1)
        formulaBox.layer.cornerRadius = 10

        let leftBar = UIView()
        leftBar.backgroundColor    = C.green
        leftBar.layer.cornerRadius = 1.5
        leftBar.translatesAutoresizingMaskIntoConstraints = false
        leftBar.widthAnchor.constraint(equalToConstant: 3).isActive = true

        let formulaLbl = UILabel()
        formulaLbl.text          = data.twistFormula
        formulaLbl.font          = UIFont.monospacedSystemFont(ofSize: 12, weight: .medium)
        formulaLbl.textColor     = UIColor(red: 0.10, green: 0.40, blue: 0.22, alpha: 1)
        formulaLbl.numberOfLines = 0

        let formulaInner = UIStackView(arrangedSubviews: [leftBar, formulaLbl])
        formulaInner.axis      = .horizontal
        formulaInner.spacing   = 10
        formulaInner.alignment = .center
        formulaInner.translatesAutoresizingMaskIntoConstraints = false
        formulaBox.addSubview(formulaInner)
        NSLayoutConstraint.activate([
            formulaInner.topAnchor.constraint(equalTo: formulaBox.topAnchor, constant: 10),
            formulaInner.leadingAnchor.constraint(equalTo: formulaBox.leadingAnchor, constant: 12),
            formulaInner.trailingAnchor.constraint(equalTo: formulaBox.trailingAnchor, constant: -12),
            formulaInner.bottomAnchor.constraint(equalTo: formulaBox.bottomAnchor, constant: -10)
        ])
        return formulaBox
    }

    // MARK: - 4. Correlations

    func makeCorrelationsStack() -> UIView {
        let container = UIStackView()
        container.axis    = .vertical
        container.spacing = 10

        let topTwo = correlationMap[data.twistIndicatorName]
            ?? Array(data.correlatedIndicators.prefix(2))

        let visible = puzzle.visibleIndicators.map { $0.indicatorName }
        let toShow  = topTwo.filter { visible.contains($0) }.prefix(2)

        let finalList = toShow.isEmpty
            ? Array(data.correlatedIndicators.prefix(2))
            : Array(toShow)

        let sfIcons = ["chart.line.uptrend.xyaxis", "dollarsign.circle", "clock.arrow.2.circlepath", "building.columns"]

        for (index, name) in finalList.enumerated() {
            let desc = correlationDescription(for: name)
            let icon = sfIcons[safe: index] ?? "chart.bar"
            container.addArrangedSubview(makeCorrelationRow(sfIcon: icon, title: name, desc: desc))
        }

        return container
    }

    func makeCorrelationRow(sfIcon: String, title: String, desc: String) -> UIView {
        let card = UIView()
        card.backgroundColor    = C.card
        card.layer.cornerRadius = 16
        card.layer.cornerCurve  = .continuous
        card.layer.borderWidth  = 0.5
        card.layer.borderColor  = C.border.cgColor

        let iconBox = UIView()
        iconBox.backgroundColor    = UIColor(red: 0.96, green: 0.96, blue: 0.95, alpha: 1)
        iconBox.layer.cornerRadius = 10
        iconBox.translatesAutoresizingMaskIntoConstraints = false
        iconBox.widthAnchor.constraint(equalToConstant: 36).isActive  = true
        iconBox.heightAnchor.constraint(equalToConstant: 36).isActive = true

        let img = UIImageView(image: UIImage(systemName: sfIcon))
        img.tintColor   = UIColor(red: 0.40, green: 0.40, blue: 0.42, alpha: 1)
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
        titleLbl.text      = title
        titleLbl.font      = UIFont.systemFont(ofSize: 13, weight: .semibold)
        titleLbl.textColor = C.text

        let descLbl = UILabel()
        descLbl.text          = desc
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
        return card
    }

    // MARK: - 5. Best Company Card

    func makeBestCard() -> UIView {
        let card = UIView()
        card.backgroundColor    = C.card
        card.layer.cornerRadius = 18
        card.layer.cornerCurve  = .continuous
        card.layer.borderWidth  = 1.5
        card.layer.borderColor  = C.green.cgColor

        let rankCircle = makeRankCircle(rank: 1, size: 28)

        let nameLabel = UILabel()
        nameLabel.text      = data.bestCompany.name
        nameLabel.font      = UIFont.systemFont(ofSize: 17, weight: .bold)
        nameLabel.textColor = C.text

        let descLabel = UILabel()
        descLabel.text      = data.bestCompany.description
        descLabel.font      = UIFont.systemFont(ofSize: 12, weight: .regular)
        descLabel.textColor = C.subtext

        let nameStack = UIStackView(arrangedSubviews: [nameLabel, descLabel])
        nameStack.axis    = .vertical
        nameStack.spacing = 2

        let winnerBadge = makeSmallBadge(text: "Winner", color: C.green)

        let topRow = UIStackView(arrangedSubviews: [rankCircle, nameStack, winnerBadge])
        topRow.axis      = .horizontal
        topRow.spacing   = 10
        topRow.alignment = .center

        let twistVal  = puzzle.twistIndicators.first(where: { $0.companyId == data.bestCompany.id })?.displayValue ?? ""
        let pillStack = UIStackView(arrangedSubviews: [
            makeStatPill(label: data.twistIndicatorName, value: twistVal),
            makeStatPill(label: "Return", value: "\(data.bestResult.returnPercent)%")
        ])
        pillStack.axis    = .horizontal
        pillStack.spacing = 8

        let div = UIView()
        div.backgroundColor = C.separator
        div.heightAnchor.constraint(equalToConstant: 0.5).isActive = true

        let reasonsStack = UIStackView()
        reasonsStack.axis    = .vertical
        reasonsStack.spacing = 10

        for (index, reason) in data.bestReasons.enumerated() {
            reasonsStack.addArrangedSubview(makeReasonRow(num: index + 1, text: reason))
        }

        let vstack = UIStackView(arrangedSubviews: [topRow, pillStack, div, reasonsStack])
        vstack.axis    = .vertical
        vstack.spacing = 12
        vstack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(vstack)

        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            vstack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            vstack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            vstack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }

    func makeReasonRow(num: Int, text: String) -> UIView {
        let circle = makeRankCircle(rank: num, size: 20)

        let lbl = UILabel()
        lbl.text          = text
        lbl.font          = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl.textColor     = UIColor(red: 0.30, green: 0.30, blue: 0.32, alpha: 1)
        lbl.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [circle, lbl])
        row.axis      = .horizontal
        row.spacing   = 10
        row.alignment = .top
        return row
    }

    // MARK: - 6. Rankings Table

    func makeRankTable() -> UIView {
        let card = UIView()
        card.backgroundColor    = C.card
        card.layer.cornerRadius = 16
        card.layer.cornerCurve  = .continuous
        card.clipsToBounds      = true
        card.layer.borderWidth  = 0.5
        card.layer.borderColor  = C.border.cgColor

        let vstack = UIStackView()
        vstack.axis = .vertical
        vstack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(vstack)
        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: card.topAnchor),
            vstack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            vstack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            vstack.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])

        for (index, entry) in data.rankedResults.enumerated() {
            vstack.addArrangedSubview(makeRankRow(entry: entry))
            if index < data.rankedResults.count - 1 {
                let sep = UIView()
                sep.backgroundColor = C.separator
                sep.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                vstack.addArrangedSubview(sep)
            }
        }
        return card
    }

    func makeRankRow(entry: RankedEntry) -> UIView {
        let row = UIView()

        if entry.isUserPick {
            row.backgroundColor = data.isCorrect
                ? UIColor(red: 0.92, green: 0.98, blue: 0.94, alpha: 1)
                : UIColor(red: 0.99, green: 0.94, blue: 0.93, alpha: 1)
        } else {
            row.backgroundColor = .clear
        }

        let circle = makeRankCircle(rank: entry.rank, size: 22)

        let nameLbl = UILabel()
        if entry.isUserPick {
            let base = NSMutableAttributedString(
                string: entry.company.name + "  ",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
                    .foregroundColor: C.text
                ]
            )
            let youBg  = data.isCorrect ? C.green : C.red
            let youTag = NSAttributedString(string: " YOU ", attributes: [
                .font: UIFont.systemFont(ofSize: 8, weight: .bold),
                .foregroundColor: UIColor.white,
                .backgroundColor: youBg
            ])
            base.append(youTag)
            nameLbl.attributedText = base
        } else {
            nameLbl.text      = entry.company.name
            nameLbl.font      = UIFont.systemFont(ofSize: 13, weight: .semibold)
            nameLbl.textColor = C.text
        }

        let descLbl = UILabel()
        descLbl.text      = entry.company.description
        descLbl.font      = UIFont.systemFont(ofSize: 11, weight: .regular)
        descLbl.textColor = C.subtext

        let leftStack = UIStackView(arrangedSubviews: [nameLbl, descLbl])
        leftStack.axis    = .vertical
        leftStack.spacing = 2

        let valColor: UIColor
        switch entry.rank {
        case 1:    valColor = C.green
        case 2, 3: valColor = UIColor(red: 0.63, green: 0.47, blue: 0.31, alpha: 1)
        default:   valColor = entry.isUserPick && !data.isCorrect ? C.red : C.subtext
        }

        let valLbl = UILabel()
        valLbl.text          = entry.twistValue
        valLbl.font          = UIFont.systemFont(ofSize: 14, weight: .bold)
        valLbl.textColor     = valColor
        valLbl.textAlignment = .right

        let subLbl = UILabel()
        subLbl.text          = data.twistIndicatorName
        subLbl.font          = UIFont.systemFont(ofSize: 9, weight: .regular)
        subLbl.textColor     = C.subtext
        subLbl.textAlignment = .right
        subLbl.numberOfLines = 2

        let rightStack = UIStackView(arrangedSubviews: [valLbl, subLbl])
        rightStack.axis      = .vertical
        rightStack.spacing   = 1
        rightStack.alignment = .trailing
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        rightStack.widthAnchor.constraint(equalToConstant: 56).isActive = true

        let hstack = UIStackView(arrangedSubviews: [circle, leftStack, rightStack])
        hstack.axis      = .horizontal
        hstack.spacing   = 12
        hstack.alignment = .center
        hstack.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(hstack)

        NSLayoutConstraint.activate([
            hstack.topAnchor.constraint(equalTo: row.topAnchor, constant: 13),
            hstack.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            hstack.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            hstack.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -13)
        ])
        return row
    }

    // MARK: - 7. CTAs

    func makeCTAs() -> UIView {
        let nextBtn = makeButton(title: "Try Next Round  →", bg: C.charcoal, fg: .white)
        nextBtn.addTarget(self, action: #selector(nextRoundTapped), for: .touchUpInside)

        let homeBtn = makeButton(title: "Return to Home", bg: UIColor(red: 0.88, green: 0.87, blue: 0.85, alpha: 1), fg: C.subtext)
        homeBtn.addTarget(self, action: #selector(homeTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [nextBtn, homeBtn])
        stack.axis    = .vertical
        stack.spacing = 10
        return stack
    }
}

// MARK: - Reusable Helpers

extension ResultViewController {

    func makeRankCircle(rank: Int, size: CGFloat) -> UIView {
        let circle = UIView()
        circle.backgroundColor    = rankColors[safe: rank - 1] ?? C.subtext
        circle.layer.cornerRadius = size / 2
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.widthAnchor.constraint(equalToConstant: size).isActive  = true
        circle.heightAnchor.constraint(equalToConstant: size).isActive = true

        let lbl = UILabel()
        lbl.text          = "\(rank)"
        lbl.font          = UIFont.systemFont(ofSize: size * 0.45, weight: .bold)
        lbl.textColor     = rank <= 3 ? .white : UIColor(red: 0.40, green: 0.40, blue: 0.40, alpha: 1)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(lbl)
        NSLayoutConstraint.activate([
            lbl.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            lbl.centerYAnchor.constraint(equalTo: circle.centerYAnchor)
        ])
        return circle
    }

    func makeSmallBadge(text: String, color: UIColor) -> UIView {
        let bg = UIView()
        bg.backgroundColor    = color.withAlphaComponent(0.12)
        bg.layer.cornerRadius = 6

        let lbl = UILabel()
        lbl.text      = text
        lbl.font      = UIFont.systemFont(ofSize: 9.5, weight: .semibold)
        lbl.textColor = color
        lbl.translatesAutoresizingMaskIntoConstraints = false
        bg.addSubview(lbl)
        NSLayoutConstraint.activate([
            lbl.topAnchor.constraint(equalTo: bg.topAnchor, constant: 3),
            lbl.bottomAnchor.constraint(equalTo: bg.bottomAnchor, constant: -3),
            lbl.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 7),
            lbl.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -7)
        ])
        return bg
    }

    func makeStatPill(label: String, value: String) -> UIView {
        let bg = UIView()
        bg.backgroundColor    = UIColor(red: 0.94, green: 0.94, blue: 0.92, alpha: 1)
        bg.layer.cornerRadius = 8

        let lbl = UILabel()
        lbl.text      = "\(label): \(value)"
        lbl.font      = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl.textColor = UIColor(red: 0.35, green: 0.35, blue: 0.35, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        bg.addSubview(lbl)
        NSLayoutConstraint.activate([
            lbl.topAnchor.constraint(equalTo: bg.topAnchor, constant: 5),
            lbl.bottomAnchor.constraint(equalTo: bg.bottomAnchor, constant: -5),
            lbl.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 10),
            lbl.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -10)
        ])
        return bg
    }

    func makeButton(title: String, bg: UIColor, fg: UIColor) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(fg, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        btn.backgroundColor  = bg
        btn.layer.cornerRadius = 16
        btn.heightAnchor.constraint(equalToConstant: 54).isActive = true
        return btn
    }

    func padded(_ view: UIView, horizontal: CGFloat, vertical vPad: CGFloat) -> UIView {
        let wrapper = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: vPad),
            view.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: horizontal),
            view.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -horizontal),
            view.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -vPad)
        ])
        return wrapper
    }

    // MARK: - Correlation descriptions

    func correlationDescription(for indicatorName: String) -> String {
        let twist = data.twistIndicatorName
        switch indicatorName {
        case "EPS Growth (YoY)":
            return "\(twist) compounds EPS growth over time. A high value validates consistent earnings — not a single lucky quarter."
        case "Net Profit Margin":
            return "Sustained \(twist) forces operational efficiency. Fast growth without margin expansion eventually hits a wall."
        case "P/E Ratio":
            return "Higher \(twist) justifies a premium P/E — investors pay more for proven compounders."
        case "Debt-to-Equity":
            return "High-\(twist) companies fund growth internally, reducing debt reliance. Low CAGR with rising D/E is a red flag."
        default:
            return "\(twist) is directly correlated with \(indicatorName) — both move together as fundamental quality improves."
        }
    }

    // MARK: - Ordinal suffix

    func ordinalSuffix(_ number: Int) -> String {
        switch number {
        case 1: return "st"
        case 2: return "nd"
        case 3: return "rd"
        default: return "th"
        }
    }
}
