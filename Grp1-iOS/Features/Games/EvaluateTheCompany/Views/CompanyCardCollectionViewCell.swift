//
//  CompanyCardCellCollectionViewCell.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 17/02/26.
//

//
//  CompanyCardCollectionViewCell.swift
//  evaluateTheCompany
//

import UIKit

class CompanyCardCollectionViewCell: UICollectionViewCell {

    // ── XIB outlets (all connected in CompanyCardCollectionViewCell.xib) ──
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var indicatorStackView: UIStackView!
    @IBOutlet weak var indicator1Label: UILabel!
    @IBOutlet weak var indicator2Label: UILabel!
    @IBOutlet weak var indicator3Label: UILabel!
    @IBOutlet weak var indicator4Label: UILabel!

    @IBOutlet weak var companyNameBack: UILabel!

    @IBOutlet weak var dividerViewBack: UIView!
    private var isFlipped = false

    override func awakeFromNib() {
        super.awakeFromNib()
        styleCard()
        styleFront()
        styleBack()
        injectPill()

        frontView.isHidden = false
        backView.isHidden  = true
        isFlipped          = false
    }

    // MARK: - Card shell

    private func styleCard() {
        layer.cornerRadius   = 20
        layer.cornerCurve    = .continuous
        layer.masksToBounds  = false
        layer.shadowColor    = UIColor.black.cgColor
        layer.shadowOpacity  = 0.08
        layer.shadowRadius   = 12
        layer.shadowOffset   = CGSize(width: 0, height: 5)

        cardContainerView.layer.cornerRadius  = 20
        cardContainerView.layer.cornerCurve   = .continuous
        cardContainerView.layer.masksToBounds = true
        cardContainerView.layer.borderWidth   = 1
        cardContainerView.layer.borderColor   = UIColor.black.withAlphaComponent(0.06).cgColor
    }

    // MARK: - Front

    private func styleFront() {
        frontView.backgroundColor  = .systemBackground
        companyNameLabel.font      = UIFont.systemFont(ofSize: 20, weight: .semibold)
        companyNameLabel.textColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)
        companyNameLabel.numberOfLines = 2
        descLabel.font             = UIFont.systemFont(ofSize: 15, weight: .regular)
        descLabel.textColor        = .secondaryLabel
        descLabel.numberOfLines    = 4
    }

    private func injectPill() {
        guard let plainLabel = frontView.allSubviews
            .compactMap({ $0 as? UILabel })
            .first(where: { $0.text == "Tap to reveal" || $0.text == "Tap to see indicators" })
        else { return }

        plainLabel.isHidden = true
        let green = UIColor(red: 0.18, green: 0.62, blue: 0.37, alpha: 1)

        let dot = UIView()
        dot.backgroundColor    = green
        dot.layer.cornerRadius = 3.5
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.widthAnchor.constraint(equalToConstant: 7).isActive  = true
        dot.heightAnchor.constraint(equalToConstant: 7).isActive = true

        let lbl = UILabel()
        lbl.text      = "Tap to reveal"
        lbl.font      = UIFont.systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = green

        let row = UIStackView(arrangedSubviews: [dot, lbl])
        row.axis = .horizontal; row.spacing = 5; row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false

        let pill = UIView()
        pill.backgroundColor    = green.withAlphaComponent(0.1)
        pill.layer.cornerRadius = 12
        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: pill.topAnchor, constant: 7),
            row.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -7),
            row.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 11),
            row.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -11)
        ])
        frontView.addSubview(pill)
        NSLayoutConstraint.activate([
            pill.centerXAnchor.constraint(equalTo: plainLabel.centerXAnchor),
            pill.centerYAnchor.constraint(equalTo: plainLabel.centerYAnchor)
        ])
    }

    // MARK: - Back base styling

    private func styleBack() {
        backView.backgroundColor     = UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1)
        dividerViewBack?.backgroundColor = UIColor(white: 0.22, alpha: 1)
      //  indicatorStackView?.spacing      = 8
       // indicatorStackView?.distribution = .fillProportionally
    }

    // MARK: - Configure

    func configureFront(company: Company) {
        companyNameLabel.text = company.name
        descLabel.text        = company.description

        let attrs: [NSAttributedString.Key: Any] = [
            .kern: CGFloat(1.2),
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: UIColor(white: 0.4, alpha: 1)
        ]
        companyNameBack?.attributedText = NSAttributedString(
            string: company.name.uppercased(), attributes: attrs)
    }

    func configureBack(indicators: [IndicatorValue]) {
        let green = UIColor(red: 0.18, green: 0.62, blue: 0.37, alpha: 1)
        let mint  = UIColor(red: 0.75, green: 0.95, blue: 0.82, alpha: 1)

        let labels = [indicator1Label, indicator2Label, indicator3Label, indicator4Label]

        // Remove old bars
        indicatorStackView?.subviews
            .filter { $0.tag == 8888 }
            .forEach { $0.removeFromSuperview() }

        for (labelIdx, label) in labels.enumerated() {
            guard let label = label else { continue }

            if indicators.indices.contains(labelIdx) {
                let ind     = indicators[labelIdx]
                let name    = ind.indicatorName
                let value   = ind.displayValue
                label.isHidden = false

                // Attributed: grey name + bold mint value
                let attributed = NSMutableAttributedString(
                    string: name + "   ",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                        .foregroundColor: UIColor(white: 0.6, alpha: 1)
                    ]
                )
                attributed.append(NSAttributedString(
                    string: value,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
                        .foregroundColor: mint
                    ]
                ))
                label.attributedText = attributed
                label.numberOfLines  = 1

                // Add progress bar as a sibling inside the stack
                let raw     = value
                    .replacingOccurrences(of: "%", with: "")
                    .replacingOccurrences(of: "₹", with: "")
                    .replacingOccurrences(of: "x", with: "")
                    .trimmingCharacters(in: .whitespaces)
                let num   = Double(raw) ?? 0
                let ratio = CGFloat(min(max(num / 50.0, 0.05), 1.0))

                let barContainer = UIView()
                barContainer.tag = 8888
                barContainer.heightAnchor.constraint(equalToConstant: 3).isActive = true

                let barBg = UIView()
                barBg.backgroundColor    = UIColor(white: 0.2, alpha: 1)
                barBg.layer.cornerRadius = 1.5
                barBg.translatesAutoresizingMaskIntoConstraints = false
                barContainer.addSubview(barBg)

                let barFill = UIView()
                barFill.backgroundColor   = green
                barFill.layer.cornerRadius = 1.5
                barFill.translatesAutoresizingMaskIntoConstraints = false
                barBg.addSubview(barFill)

                NSLayoutConstraint.activate([
                    barBg.topAnchor.constraint(equalTo: barContainer.topAnchor),
                    barBg.bottomAnchor.constraint(equalTo: barContainer.bottomAnchor),
                    barBg.leadingAnchor.constraint(equalTo: barContainer.leadingAnchor),
                    barBg.trailingAnchor.constraint(equalTo: barContainer.trailingAnchor),

                    barFill.topAnchor.constraint(equalTo: barBg.topAnchor),
                    barFill.bottomAnchor.constraint(equalTo: barBg.bottomAnchor),
                    barFill.leadingAnchor.constraint(equalTo: barBg.leadingAnchor),
                    barFill.widthAnchor.constraint(equalTo: barBg.widthAnchor, multiplier: ratio)
                ])

                // Insert bar right after this label in the stack
                if let barIndex = indicatorStackView?.arrangedSubviews.firstIndex(of: label) {
                    indicatorStackView?.insertArrangedSubview(barContainer, at: barIndex + 1)
                }
            } else {
                label.text     = ""
                label.isHidden = true
            }
        }
    }

    func configureBackCompanyName(_ name: String) {
        let attrs: [NSAttributedString.Key: Any] = [
            .kern: CGFloat(1.2),
            .font: UIFont.systemFont(ofSize: 9.5, weight: .semibold),
            .foregroundColor: UIColor(white: 0.4, alpha: 1)
        ]
        companyNameBack?.attributedText = NSAttributedString(
            string: name.uppercased(), attributes: attrs)
    }

    // MARK: - Flip

    func flip() {
        guard let fromView = isFlipped ? backView : frontView,
              let toView   = isFlipped ? frontView : backView else { return }
        let flipAngle    = isFlipped ? CGFloat.pi : -CGFloat.pi

        var perspectiveTransform = CATransform3DIdentity
        perspectiveTransform.m34 = -1.0 / 700

        UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseIn) {
            fromView.layer.transform = CATransform3DRotate(perspectiveTransform, flipAngle / 2, 0, 1, 0)
        } completion: { _ in
            fromView.isHidden      = true
            toView.layer.transform = CATransform3DRotate(perspectiveTransform, -flipAngle / 2, 0, 1, 0)
            toView.isHidden        = false
            UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseOut) {
                toView.layer.transform = CATransform3DIdentity
            }
        }

        isFlipped.toggle()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

private extension UIView {
    var allSubviews: [UIView] {
        subviews + subviews.flatMap { $0.allSubviews }
    }
}
