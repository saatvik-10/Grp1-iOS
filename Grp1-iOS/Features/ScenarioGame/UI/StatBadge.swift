//
//  StatBadgeHelper.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 04/02/26.
//

import UIKit
func styleStatLabel(_ label: UILabel,
                    textColor: UIColor,
                    bgColor: UIColor,
                    icon: String? = nil) {

    label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    label.textColor = textColor
    label.textAlignment = .center
    label.backgroundColor = bgColor
    label.layer.cornerRadius = 14
    label.layer.masksToBounds = true

    // Padding (UILabel doesn’t support padding by default)
    label.layer.sublayers?.removeAll()

    if let icon {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: icon)?.withTintColor(textColor)
        attachment.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)

        let attr = NSMutableAttributedString(attachment: attachment)
        attr.append(NSAttributedString(string: " \(label.text ?? "")"))
        label.attributedText = attr
    }

    // Soft shadow
    label.layer.shadowColor = UIColor.black.cgColor
    label.layer.shadowOpacity = 0.06
    label.layer.shadowRadius = 6
    label.layer.shadowOffset = CGSize(width: 0, height: 2)
}
