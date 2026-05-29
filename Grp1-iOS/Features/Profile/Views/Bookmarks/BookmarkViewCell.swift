//
//  BookmarkViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 11/12/25.
//

import UIKit

protocol BookmarkCellDelegate: AnyObject {
    func didTapBookmark(in cell: BookmarkViewCell)
}

class BookmarkViewCell: UICollectionViewCell {

    @IBOutlet weak var bookmarkIcon: UIImageView!
    @IBOutlet weak var bookmarkButton: UIButton!
    weak var delegate: BookmarkCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        bookmarkButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    @objc private func handleTap() {
        delegate?.didTapBookmark(in: self)
    }

    func configure(_ item: BookmarkItem) {
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 16

        bookmarkIcon.image = item.icon
        bookmarkIcon.tintColor = .black

        bookmarkButton.setTitle(item.title, for: .normal)
    }
}
