//
//  CommentTableViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 11/02/26.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var commentLabel: UILabel!

    @IBOutlet weak var likeButton: UIButton!

    var onLikeTapped: (() -> Void)?
        var onReplyTapped: (() -> Void)?

        override func awakeFromNib() {
            super.awakeFromNib()
            selectionStyle = .none

            profileImageView.layer.cornerRadius = 20
            profileImageView.clipsToBounds = true
            commentLabel.numberOfLines = 0
            nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            commentLabel.font = .systemFont(ofSize: 16)

            preservesSuperviewLayoutMargins = false
            contentView.preservesSuperviewLayoutMargins = false
            separatorInset = .zero
            layoutMargins = .zero
        }

    @IBAction func didTapLike(_ sender: UIButton) {
        onLikeTapped?()
    }

        func configure(with comment: APIThreadComment) {
            nameLabel.text = comment.user?.name ?? comment.user?.username ?? "Unknown"
            commentLabel.text = comment.description

            if let imageUrl = comment.user?.profileImageUrl, let url = URL(string: imageUrl) {
                // Async load image
                URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.profileImageView.image = image
                        }
                    }
                }.resume()
            } else {
                profileImageView.image = UIImage(systemName: "person.circle.fill")
            }

            likeButton.isHidden = true
        }
    }
