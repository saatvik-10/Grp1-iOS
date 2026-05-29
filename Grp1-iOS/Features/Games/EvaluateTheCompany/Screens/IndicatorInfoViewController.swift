//
//  IndicatorInfoViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 24/03/26.
//

import UIKit

struct IndicatorInfo {
    let icon: String
    let iconBg: UIColor
    let name: String
    let description: String
}

class IndicatorInfoViewController: UIViewController {

    private var indicators: [IndicatorInfo] = []
    private let visibleIndicatorNames: [String]

    init(visibleIndicatorNames: [String]) {
        self.visibleIndicatorNames = visibleIndicatorNames
        super.init(nibName: nil, bundle: nil)

        let allDefs = DailyPuzzle.getAllIndicatorDefinitions()
        for name in visibleIndicatorNames {
            if let def = allDefs[name] {
                indicators.append(IndicatorInfo(icon: def.icon, iconBg: def.iconBg, name: name, description: def.definition))
            } else {
                let fallback = IndicatorInfo(icon: "chart.bar", iconBg: .systemGray5,
                                              name: name, description: "A key financial metric.")
                indicators.append(fallback)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private let handleView: UIView = {
        let handle = UIView()
        handle.backgroundColor    = UIColor(white: 0.85, alpha: 1)
        handle.layer.cornerRadius = 2.5
        handle.translatesAutoresizingMaskIntoConstraints = false
        return handle
    }()

    private let titleLabel: UILabel = {
        let title = UILabel()
        title.text      = "Understanding the indicators"
        title.font      = UIFont.systemFont(ofSize: 20, weight: .semibold)
        title.textColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()

    private let subtitleLabel: UILabel = {
        let subtitle = UILabel()
        subtitle.text      = "4 metrics shown on every company card"
        subtitle.font      = UIFont.systemFont(ofSize: 16, weight: .regular)
        subtitle.textColor = .secondaryLabel
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        return subtitle
    }()

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis      = .vertical
        sv.spacing   = 0
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        buildRows()
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(handleView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            handleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            handleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 36),
            handleView.heightAnchor.constraint(equalToConstant: 5),

            titleLabel.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            stackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func buildRows() {
        for (index, info) in indicators.enumerated() {
            let row = makeRow(info)
            stackView.addArrangedSubview(row)

            if index < indicators.count - 1 {
                let divider = UIView()
                divider.backgroundColor = UIColor(white: 0.0, alpha: 0.06)
                divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                stackView.addArrangedSubview(divider)
            }
        }
    }

    private func makeRow(_ info: IndicatorInfo) -> UIView {
        // Icon
        let iconBg = UIView()
        iconBg.backgroundColor    = info.iconBg
        iconBg.layer.cornerRadius = 10
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconBg.widthAnchor.constraint(equalToConstant: 38),
            iconBg.heightAnchor.constraint(equalToConstant: 38)
        ])

        let iconImage = UIImageView()
        iconImage.image               = UIImage(systemName: info.icon)
        iconImage.tintColor           = .secondaryLabel
        iconImage.contentMode         = .scaleAspectFit
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(iconImage)
        NSLayoutConstraint.activate([
            iconImage.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconImage.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconImage.widthAnchor.constraint(equalToConstant: 18),
            iconImage.heightAnchor.constraint(equalToConstant: 18)
        ])

        // Text
        let nameLabel = UILabel()
        nameLabel.text      = info.name
        nameLabel.font      = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)

        let descLabel = UILabel()
        descLabel.text          = info.description
        descLabel.font          = UIFont.systemFont(ofSize: 14, weight: .regular)
        descLabel.textColor     = .secondaryLabel
        descLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [nameLabel, descLabel])
        textStack.axis    = .vertical
        textStack.spacing = 3

        // Row
        let row = UIStackView(arrangedSubviews: [iconBg, textStack])
        row.axis      = .horizontal
        row.spacing   = 14
        row.alignment = .top

        // Wrap in a container for padding
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        row.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        return container
    }
}
