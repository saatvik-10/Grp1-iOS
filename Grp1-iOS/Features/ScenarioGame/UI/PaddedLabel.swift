//
//  PaddedLabel.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 05/02/26.
//
import UIKit

class PaddedLabel: UILabel {

    var topInset: CGFloat = 6
    var bottomInset: CGFloat = 6
    var leftInset: CGFloat = 12
    var rightInset: CGFloat = 12

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(
            top: topInset,
            left: leftInset,
            bottom: bottomInset,
            right: rightInset
        )
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + leftInset + rightInset,
            height: size.height + topInset + bottomInset
        )
    }
}
