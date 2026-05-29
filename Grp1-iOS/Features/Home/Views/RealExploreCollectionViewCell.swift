import UIKit

class RealExploreCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var pickLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!

    private var gradientLayer: CAGradientLayer?

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 7
        contentView.layer.masksToBounds = true

        contentView.clipsToBounds = true

        newsImageView.contentMode = .scaleAspectFill
        newsImageView.layer.cornerRadius = 7
        newsImageView.layer.masksToBounds = true
        newsImageView.clipsToBounds = true

        pickLabel.textColor = .systemGray
        headlineLabel.numberOfLines = 2
        headlineLabel.textColor = .black

        timeLabel.textColor = .systemGray

    }

    func configureCell(with article: NewsArticle) {

        newsImageView.setSmartImage(from: article.imageName)

        pickLabel.text = article.source
        headlineLabel.text = article.title
        timeLabel.text = DateUtils.formattedArticleDate(from: article.date)
    }
}
