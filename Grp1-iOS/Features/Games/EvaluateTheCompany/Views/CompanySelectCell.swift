//
//  CompanySelectCell.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 18/02/26.
//

import UIKit

final class CompanySelectCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var tickImageView: UIImageView!

    private let radioButton = UIView()

        override func awakeFromNib() {
            super.awakeFromNib()

            selectionStyle          = .none
            backgroundColor         = .clear
            contentView.backgroundColor = .clear

            // ── Container card ──
            containerView.layer.cornerRadius  = 16
            containerView.layer.cornerCurve   = .continuous
            containerView.backgroundColor     = .systemBackground
            containerView.layer.masksToBounds = false
            containerView.layer.borderWidth   = 0.5
            containerView.layer.borderColor   = UIColor.black.withAlphaComponent(0.06).cgColor
            containerView.layer.shadowColor   = UIColor.black.cgColor
            containerView.layer.shadowOpacity = 0.05
            containerView.layer.shadowRadius  = 8
            containerView.layer.shadowOffset  = CGSize(width: 0, height: 3)

            // ── Labels ──
            nameLabel.font      = UIFont.systemFont(ofSize: 20, weight: .semibold)
            nameLabel.textColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)

            descLabel.font      = UIFont.systemFont(ofSize: 14, weight: .regular)
            descLabel.textColor = .systemGray
            // ── Hide the storyboard tick image — we replace with custom radio ──
            tickImageView.isHidden = true

            // ── Custom radio button (circle) ──
            radioButton.layer.cornerRadius  = 11
            radioButton.layer.borderWidth   = 1.5
            radioButton.layer.borderColor   = UIColor(red: 0.8, green: 0.8, blue: 0.78, alpha: 1).cgColor
            radioButton.backgroundColor     = .clear
            radioButton.translatesAutoresizingMaskIntoConstraints = false
            radioButton.widthAnchor.constraint(equalToConstant: 22).isActive  = true
            radioButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
            containerView.addSubview(radioButton)

            NSLayoutConstraint.activate([
                radioButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                radioButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])
        }

        func configure(company: Company, isSelected: Bool) {
            nameLabel.text = company.name
            descLabel.text = company.description

            let green = UIColor(red: 0.18, green: 0.62, blue: 0.37, alpha: 1)

            if isSelected {
                // Green border on card
                containerView.layer.borderWidth = 1.5
                containerView.layer.borderColor = green.cgColor
                containerView.backgroundColor   = .systemBackground

                // Filled green radio with checkmark
                radioButton.backgroundColor   = green
                radioButton.layer.borderColor = green.cgColor

                // Add checkmark label if not already there
                if radioButton.subviews.isEmpty {
                    let check = UILabel()
                    check.text          = "✓"
                    check.font          = UIFont.systemFont(ofSize: 12, weight: .bold)
                    check.textColor     = .white
                    check.textAlignment = .center
                    check.translatesAutoresizingMaskIntoConstraints = false
                    radioButton.addSubview(check)
                    NSLayoutConstraint.activate([
                        check.centerXAnchor.constraint(equalTo: radioButton.centerXAnchor),
                        check.centerYAnchor.constraint(equalTo: radioButton.centerYAnchor)
                    ])
                }
                radioButton.subviews.forEach { $0.isHidden = false }

            } else {
                // Default state
                containerView.layer.borderWidth = 0.5
                containerView.layer.borderColor = UIColor.black.withAlphaComponent(0.06).cgColor
                containerView.backgroundColor   = .systemBackground

                // Empty circle radio
                radioButton.backgroundColor   = .clear
                radioButton.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.78, alpha: 1).cgColor
                radioButton.subviews.forEach { $0.isHidden = true }
            }
        }
    }
