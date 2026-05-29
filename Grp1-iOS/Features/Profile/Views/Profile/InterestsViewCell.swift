//
//  InterestsViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 14/01/26.
//

import UIKit

class InterestsViewCell: UICollectionViewCell {

    @IBOutlet weak var interestsLabel: UILabel!

    @IBOutlet weak var badgeStackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
    }

    func configure(interests: [String]) {
        badgeStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let itemsToShow = interests.suffix(4)

        for title in itemsToShow {
            let badge = UILabel()

            badge.text = "\(title)"
            badge.font = .systemFont(ofSize: 12, weight: .medium)
            badge.textColor = .systemBlue
            badge.textAlignment = .center
            badge.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.05)
            badge.layer.cornerRadius = 6
            badge.layer.borderWidth = 1
            badge.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.2).cgColor
            badge.layer.masksToBounds = true
            badge.translatesAutoresizingMaskIntoConstraints = false
            badge.heightAnchor.constraint(equalToConstant: 30).isActive = true

            badgeStackView.addArrangedSubview(badge)
        }
    }
}
