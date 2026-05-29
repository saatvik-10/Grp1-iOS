//
//  Button.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 09/01/26.
//

import UIKit

class OnboardingButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @objc private func touchDown() {
        UIView.animate(
            withDuration: 0.12,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            }
        )
    }

    @objc private func touchUp() {
        UIView.animate(
            withDuration: 0.18,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                self.transform = .identity
            }
        )
    }
}
