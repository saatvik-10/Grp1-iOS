//
//  JargonDetailViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 15/12/25.
//

import UIKit

class JargonDetailViewController: UIViewController {
    @IBOutlet weak var questionMark: UIImageView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    var jargonWord: String?

    private var symbolsAdded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.shared.dominantColor.withAlphaComponent(0.1)

        titleLabel.text = selectedWord.word
        questionMark.tintColor = AppTheme.shared.dominantColor

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !symbolsAdded && questionMark.bounds.width > 0 {
            addFloatingSymbols()
            symbolsAdded = true
        }
    }

    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    private func addFloatingSymbols() {
        struct SymbolConfig {
            let name: String
            let angle: CGFloat
            let radius: CGFloat
            let size: CGFloat
            let color: UIColor
            let rotation: CGFloat
        }

        let configurations: [SymbolConfig] = [
            SymbolConfig(name: "dollarsign.circle.fill", angle: 0, radius: 110, size: 35, color: .systemGreen, rotation: 0.1),
            SymbolConfig(name: "chart.pie.fill", angle: .pi / 6, radius: 150, size: 30, color: .systemYellow, rotation: -0.2),
            SymbolConfig(name: "bitcoinsign.circle.fill", angle: 2 * .pi / 6, radius: 110, size: 40, color: .systemRed, rotation: 0.15),
            SymbolConfig(name: "creditcard.fill", angle: 3 * .pi / 6, radius: 150, size: 35, color: .systemGreen, rotation: -0.1),
            SymbolConfig(name: "yensign.circle.fill", angle: 4 * .pi / 6, radius: 110, size: 30, color: .systemYellow, rotation: 0.2),
            SymbolConfig(name: "chart.line.uptrend.xyaxis.circle.fill", angle: 5 * .pi / 6,
                         radius: 150, size: 35, color: .systemRed, rotation: -0.15),
            SymbolConfig(name: "indianrupeesign.circle.fill", angle: 6 * .pi / 6,
                         radius: 110, size: 40, color: .systemGreen, rotation: 0.1),
            SymbolConfig(name: "percent", angle: 7 * .pi / 6, radius: 150, size: 30, color: .systemYellow, rotation: -0.2),
            SymbolConfig(name: "dollarsign.circle.fill", angle: 8 * .pi / 6, radius: 110, size: 35, color: .systemRed, rotation: 0.1),
            SymbolConfig(name: "banknote.fill", angle: 9 * .pi / 6, radius: 150, size: 35, color: .systemGreen, rotation: -0.15),
            SymbolConfig(name: "sterlingsign.circle.fill", angle: 10 * .pi / 6, radius: 110, size: 30, color: .systemYellow, rotation: 0.2),
            SymbolConfig(name: "chart.pie.fill", angle: 11 * .pi / 6, radius: 150, size: 30, color: .systemRed, rotation: -0.2)
        ]

        let centerPoint = questionMark.center

        for config in configurations {
            let image = UIImage(systemName: config.name)?.withConfiguration(UIImage.SymbolConfiguration(weight: .medium))
            let imageView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))

            imageView.tintColor = config.color
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: 0, y: 0, width: config.size, height: config.size)

            // Start behind the question mark, scaled down, and hidden
            imageView.center = centerPoint
            imageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            imageView.alpha = 0

            view.insertSubview(imageView, belowSubview: questionMark)

            // Calculate final position
            let xOffset = cos(config.angle) * config.radius
            let yOffset = sin(config.angle) * config.radius
            let finalCenter = CGPoint(x: centerPoint.x + xOffset, y: centerPoint.y + yOffset)

            // Simultaneous emergence animation (slower)
            UIView.animate(withDuration: 1.5, delay: 0,
                           usingSpringWithDamping: 0.7, initialSpringVelocity: 0.2,
                           options: .curveEaseOut, animations: {
                imageView.center = finalCenter
                imageView.transform = CGAffineTransform(rotationAngle: config.rotation)
                imageView.alpha = 1
            }, completion: nil)
        }
    }
}
