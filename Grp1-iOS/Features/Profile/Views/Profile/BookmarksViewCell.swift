//
//  BookmarksViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 14/01/26.
//

import UIKit

class BookmarksViewCell: UICollectionViewCell {

    @IBOutlet weak var bookmarksDetail: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
    }

    func configure(folders: Int, bookmarks: Int) {
        bookmarksDetail.text = "\(folders) Folders  • \(bookmarks) Bookmarks"
    }
}
