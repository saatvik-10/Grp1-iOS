import UIKit

class ExploreCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var pickLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!

    private var gradientLayer: CAGradientLayer?
    var onRecommendTapped: (() -> Void)?
    var onNotRecommendTapped: (() -> Void)?

    var onArticleLensTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        headlineLabel.numberOfLines = 0
        headlineLabel.lineBreakMode = .byWordWrapping
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 7
        contentView.layer.masksToBounds = true

        contentView.clipsToBounds = true

        newsImageView.contentMode = .scaleAspectFill
        newsImageView.layer.cornerRadius = 7
        newsImageView.layer.masksToBounds = true
        newsImageView.clipsToBounds = true

        headlineLabel.numberOfLines = 2
        headlineLabel.textColor = .black

//        headlineLabel.layer.shadowColor = UIColor.black.cgColor
//        headlineLabel.layer.shadowOpacity = 0.6
//        headlineLabel.layer.shadowRadius = 4
//        headlineLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
    }

    func configureCell(with article: NewsArticle) {

        newsImageView.setSmartImage(from: article.imageName)

        pickLabel.text = article.source
        headlineLabel.text = article.title
        timeLabel.text = DateUtils.formattedArticleDate(from: article.date)
    }
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        let recommendAction = UIAction(
            title: "Recommend this more",
            image: UIImage(systemName: "hand.thumbsup"),
            handler: { [weak self] _ in
                self?.handleRecommend(sender: sender)
            }
        )

        let noRecommendAction = UIAction(
            title: "Do not Recommend",
            image: UIImage(systemName: "hand.thumbsdown"),
            handler: { [weak self] _ in
                self?.handleNotRecommend(sender: sender)
            }
        )

        let menu = UIMenu(
            title: "",
            options: .displayInline,
            children: [recommendAction, noRecommendAction]
        )
            sender.menu = menu
            sender.showsMenuAsPrimaryAction = true

    }

    private func handleRecommend(sender: UIButton) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        onRecommendTapped?()

        guard let cell = sender.superview?.superview as? UICollectionViewCell else { return }

        let bgCircle = UIView()
        bgCircle.backgroundColor = UIColor.systemGreen
        bgCircle.layer.cornerRadius = 35
        bgCircle.alpha = 0
        bgCircle.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        cell.superview?.insertSubview(bgCircle, belowSubview: cell)
        bgCircle.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bgCircle.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            bgCircle.centerXAnchor.constraint(equalTo: cell.centerXAnchor, constant: -80),
            bgCircle.widthAnchor.constraint(equalToConstant: 70),
            bgCircle.heightAnchor.constraint(equalToConstant: 70)
        ])

        let plusIcon = UIImageView(image: UIImage(systemName: "plus"))
        plusIcon.tintColor = .white
        plusIcon.alpha = 0
        plusIcon.contentMode = .scaleAspectFit
        plusIcon.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        bgCircle.addSubview(plusIcon)
        plusIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            plusIcon.centerXAnchor.constraint(equalTo: bgCircle.centerXAnchor),
            plusIcon.centerYAnchor.constraint(equalTo: bgCircle.centerYAnchor),
            plusIcon.widthAnchor.constraint(equalToConstant: 40),
            plusIcon.heightAnchor.constraint(equalToConstant: 40)
        ])

        UIView.animate(withDuration: 0.25, animations: {
            cell.transform = CGAffineTransform(translationX: 190, y: 0)
            bgCircle.alpha = 1
            plusIcon.alpha = 1
            bgCircle.transform = .identity
            plusIcon.transform = .identity
        }, completion: { _ in
            UIView.animate(withDuration: 0.25, delay: 0.5, animations: {
                cell.transform = .identity
                bgCircle.alpha = 0
                plusIcon.alpha = 0
            }, completion: { _ in
                bgCircle.removeFromSuperview()
            })
        })
    }

    private func handleNotRecommend(sender: UIButton) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        onNotRecommendTapped?()

        guard let cell = sender.superview?.superview as? UICollectionViewCell else { return }

        let cross = UIImageView(image: UIImage(systemName: "xmark.circle.fill"))
        cross.tintColor = .systemRed
        cross.alpha = 0
        cross.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)

        cell.contentView.addSubview(cross)
        cross.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cross.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            cross.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 8),
            cross.widthAnchor.constraint(equalToConstant: 28),
            cross.heightAnchor.constraint(equalToConstant: 28)
        ])

        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shake.values = [-8, 8, -6, 6, -4, 4, 0]
        shake.duration = 0.45
        cell.layer.add(shake, forKey: "shake")

        UIView.animate(withDuration: 0.3, animations: {
            cross.alpha = 1
            cross.transform = .identity
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0.6, animations: {
                cross.alpha = 0
            }, completion: { _ in
                cross.removeFromSuperview()
            })
        })
    }
}
extension UIView {
    func parentCell<T: UICollectionViewCell>() -> T? {
        var view = self.superview
        while view != nil {
            if let cell = view as? T { return cell }
            view = view?.superview
        }
        return nil
    }
}
