//
//  DomainViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class DomainViewCell: UICollectionViewCell {
    @IBOutlet weak var domainImageView: UIImageView!
    @IBOutlet weak var domainTitle: UILabel!

    var onDelete: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        let interaction = UIContextMenuInteraction(delegate: self)
        contentView.addInteraction(interaction)
    }

    func configure(_ model: InterestModel) {
        domainTitle.text = model.title
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        contentView.backgroundColor = .white
        if let iconName = model.icon {
            domainImageView.image = UIImage(systemName: iconName)
            domainImageView.isHidden = false
        } else {
            domainImageView.isHidden = true
        }
    }
}

extension DomainViewCell: UIContextMenuInteractionDelegate {

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
