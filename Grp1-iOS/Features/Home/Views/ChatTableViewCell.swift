//
//  ChatTableViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 11/12/25.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var bubbleLeadingConstraint: NSLayoutConstraint!
        @IBOutlet weak var bubbleTrailingConstraint: NSLayoutConstraint!

        override func awakeFromNib() {
            super.awakeFromNib()
            bubbleView.layer.cornerRadius = 16
        }

        func configure(with message: ChatMessage) {

            messageLabel.text = message.text

            if message.isIncoming {
                bubbleView.backgroundColor = UIColor.systemGray5
                bubbleLeadingConstraint.isActive = true
                bubbleTrailingConstraint.isActive = false
            } else {
                bubbleView.backgroundColor = UIColor.systemBlue
                bubbleLeadingConstraint.isActive = false
                bubbleTrailingConstraint.isActive = true
            }
        }

        static func nib() -> UINib {
            return UINib(nibName: "ChatTableViewCell", bundle: nil)
        }

}
