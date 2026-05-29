//
//  NumberAnimation.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 02/02/26.
//

import UIKit

final class BlockTarget {
    let block: (CADisplayLink) -> Void

    init(_ block: @escaping (CADisplayLink) -> Void) {
        self.block = block
    }

    @objc func invoke(_ sender: CADisplayLink) {
        block(sender)
    }
}

extension UILabel {

    func animateNumber(
        from startValue: Int,
        to endValue: Int,
        duration: TimeInterval = 0.8,
        prefix: String = "₹"
    ) {
        let startTime = CACurrentMediaTime()
        let delta = endValue - startValue

        let displayLink = CADisplayLink(target: BlockTarget { [weak self] link in
            let elapsed = CACurrentMediaTime() - startTime
            let progress = min(elapsed / duration, 1)

            let currentValue = startValue + Int(Double(delta) * progress)
            self?.text = "\(prefix)\(currentValue)"

            if progress >= 1 {
                link.invalidate()
                self?.text = "\(prefix)\(endValue)"
            }
        }, selector: #selector(BlockTarget.invoke))

        displayLink.add(to: .main, forMode: .common)
    }
}
