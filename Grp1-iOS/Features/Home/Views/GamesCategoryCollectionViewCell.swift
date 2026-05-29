//
//  GamesCategoryCollectionViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 20/03/26.
//

import UIKit

class GamesCategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!

    var onRecommendTapped: (() -> Void)?
    var onNotRecommendTapped: (() -> Void)?
    private var gradientLayer: CAGradientLayer?
    var onArticleLensTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true

        contentView.clipsToBounds = true

        newsImageView.contentMode = .scaleAspectFill
        newsImageView.clipsToBounds = true

        timeLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        timeLabel.textColor = .systemGray

        headlineLabel.numberOfLines = 2
        headlineLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        headlineLabel.textColor = .black

    }

    private func setupGradientOverlay() {
        // Remove existing gradient if any
        newsImageView.layer.sublayers?.removeAll()

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.black.withAlphaComponent(0).cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor,
            UIColor.black.withAlphaComponent(0.6).cgColor
        ]
        gradient.locations = [0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.frame = newsImageView.bounds

        newsImageView.layer.insertSublayer(gradient, at: 0)
        self.gradientLayer = gradient
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Update gradient frame on layout
        if let gradient = gradientLayer {
            gradient.frame = newsImageView.bounds
        }
    }

    // Configure with GameCategory
    func configure(with gameCategory: GameCategory) {
        headlineLabel.text = gameCategory.title
        timeLabel.text = gameCategory.description

        // Set image from assets (you provide the image name)
        newsImageView.image = UIImage(named: gameCategory.title)

        // Fallback to system image if asset image not found
        if newsImageView.image == nil {
            newsImageView.image = gameCategory.icon
        }
    }

    // Keep the old method for backward compatibility if needed
    func configureCell(with article: NewsArticle) {
        newsImageView.setSmartImage(from: article.imageName)
        headlineLabel.text = article.title
        timeLabel.text = DateUtils.formattedArticleDate(from: article.date)
    }
}
