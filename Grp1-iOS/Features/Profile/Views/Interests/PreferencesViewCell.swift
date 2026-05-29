//
//  InterestCollectionViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 12/01/26.
//

import UIKit

class PreferencesViewCell: UICollectionViewCell {

    @IBOutlet weak var interestIconView: UIImageView!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var subtitleInterestLabel: UILabel!

    var onDelete: (() -> Void)?

    let config = UIImage.SymbolConfiguration(weight: .light)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        contentView.layer.cornerRadius = 16
        contentView.backgroundColor = UIColor.white

        let interaction = UIContextMenuInteraction(delegate: self)
        contentView.addInteraction(interaction)
    }

    func configure(_ model: InterestModel) {
        interestLabel.text = model.title
        subtitleInterestLabel.text = model.subtitle

        if let iconName = model.icon {
            interestIconView.image = UIImage(systemName: iconName, withConfiguration: config)
            interestIconView.tintColor = .systemBlue
            interestIconView.isHidden = false
        } else {
            interestIconView.isHidden = true
        }
    }
}

extension PreferencesViewCell: UIContextMenuInteractionDelegate {

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {

        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in

            let delete = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self.onDelete?()
            }

            return UIMenu(title: "", children: [delete])
        }
    }
}
