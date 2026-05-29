//
//  Untitled.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 12/02/26.
//

import UIKit

// MARK: - Main View Controller

final class ResultViewController: UIViewController {

    var puzzle: DailyPuzzle!
    var selectedCompanyId: String!

    var data: ResultScreenData!

    private let scrollView  = UIScrollView()
    private let contentView = UIView()

    // ── Palette (matches game theme) ──────────────────────────────────────
    enum C {
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
    }

    // ── Rank circle colors ──
    let rankColors: [UIColor] = [
        UIColor(red: 0.18, green: 0.62, blue: 0.37, alpha: 1),  // 1st — green
        UIColor(red: 0.55, green: 0.55, blue: 0.58, alpha: 1),  // 2nd — silver
        UIColor(red: 0.63, green: 0.47, blue: 0.31, alpha: 1),  // 3rd — bronze
        UIColor(red: 0.78, green: 0.78, blue: 0.76, alpha: 1)  // 4th — grey
    ]

    // ── Top 2 correlations per twist indicator ──
    let correlationMap: [String: [String]] = [
        "5Y Sales CAGR": ["EPS Growth (YoY)", "Net Profit Margin"],
        "5Y Revenue CAGR": ["EPS Growth (YoY)", "Net Profit Margin"],
        "Net Profit Margin": ["EPS Growth (YoY)", "Debt-to-Equity"],
        "EPS Growth (YoY)": ["P/E Ratio", "Net Profit Margin"],
        "P/E Ratio": ["EPS Growth (YoY)", "Debt-to-Equity"],
        "Debt-to-Equity": ["Net Profit Margin", "P/E Ratio"],
        "Return on Equity": ["EPS Growth (YoY)", "Net Profit Margin"]
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = C.bg

        guard let screenData = puzzle.buildResultScreenData(selectedCompanyId: selectedCompanyId) else { return }
        self.data = screenData

        // Mark the daily game completed and clear saved active session state
        DailyGameManager.shared.markGamePlayed(.evaluate)
        EvaluateGameStateManager.shared.clearState()

        setupScrollView()
        buildUI()
        animateEntrance()
    }

    // MARK: - ScrollView

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

    // MARK: - Build UI

    private func buildUI() {
        let stack = UIStackView()
        stack.axis    = .vertical
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
        stack.addArrangedSubview(sectionLabel("Your pick", icon: "person.fill"))
        stack.addArrangedSubview(padded(makePickStrip(), horizontal: 16, vertical: 0))
        stack.addArrangedSubview(sectionLabel("Twist indicator", icon: "bolt.fill"))
        stack.addArrangedSubview(padded(makeTwistCard(), horizontal: 16, vertical: 0))
        stack.addArrangedSubview(sectionLabel("How it affects other indicators", icon: "arrow.triangle.branch"))
        stack.addArrangedSubview(padded(makeCorrelationsStack(), horizontal: 16, vertical: 0))
        stack.addArrangedSubview(sectionLabel("Best company to invest in", icon: "star.fill"))
        stack.addArrangedSubview(padded(makeBestCard(), horizontal: 16, vertical: 0))
        stack.addArrangedSubview(sectionLabel("Final rankings", icon: "list.number"))
        stack.addArrangedSubview(padded(makeRankTable(), horizontal: 16, vertical: 0))
        stack.addArrangedSubview(padded(makeCTAs(), horizontal: 16, vertical: 20))
    }

    // MARK: - Section label

    private func sectionLabel(_ text: String, icon: String) -> UIView {
        let wrapper = UIView()

        let img = UIImageView(image: UIImage(systemName: icon))
        img.tintColor  = C.subtext
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        img.widthAnchor.constraint(equalToConstant: 13).isActive  = true
        img.heightAnchor.constraint(equalToConstant: 13).isActive = true

        let lbl = UILabel()
        lbl.text      = text.uppercased()
        lbl.font      = UIFont.systemFont(ofSize: 10, weight: .semibold)
        lbl.textColor = C.subtext

        let row = UIStackView(arrangedSubviews: [img, lbl])
        row.axis      = .horizontal
        row.spacing   = 5
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

    // MARK: - Entrance animation

    private func animateEntrance() {
        contentView.alpha     = 0
        contentView.transform = CGAffineTransform(translationX: 0, y: 24)
        UIView.animate(withDuration: 0.45, delay: 0.05,
                       usingSpringWithDamping: 0.88, initialSpringVelocity: 0) {
            self.contentView.alpha     = 1
            self.contentView.transform = .identity
        }
    }

    // MARK: - Actions

    @objc func nextRoundTapped() {
        navigationController?.popToRootViewController(animated: true)
    }

    @objc func homeTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - Safe subscript

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
