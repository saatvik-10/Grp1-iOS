import UIKit

class DomainCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var domainIconView: UIImageView!
    @IBOutlet weak var domainName: UILabel!

    @IBOutlet weak var checkMarkView: UIImageView!
    let selectedBorderWidth: CGFloat = 2
    let unselectedBorderWidth: CGFloat = 1

    let config = UIImage.SymbolConfiguration(weight: .light)

    override var isSelected: Bool {
        didSet {
            updateSelectionUI()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            isHighlighted ? touchDown() : touchUp()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        domainName.isUserInteractionEnabled = false
        domainIconView.isUserInteractionEnabled = false

        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
        checkMarkView.alpha = 0
        contentView.transform = .identity
    }

    // MARK: - Press animations (EXACT MATCH)

     func touchDown() {
        UIView.animate(
            withDuration: 0.12,
            delay: 0,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                self.contentView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            }
        )
    }

     func touchUp() {
        UIView.animate(
            withDuration: 0.18,
            delay: 0,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                self.contentView.transform = self.isSelected
                    ? CGAffineTransform(scaleX: 0.97, y: 0.97)
                    : .identity
            }
        )
    }

    // MARK: - Selection UI (NO BOUNCE)

     func updateSelectionUI() {
        UIView.animate(
            withDuration: 0.18,
            delay: 0,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                self.contentView.backgroundColor = self.isSelected
                    ? UIColor.systemBlue.withAlphaComponent(0.08)
                : UIColor.white

                self.contentView.layer.borderColor = self.isSelected
                    ? UIColor.systemBlue.cgColor
                    : UIColor.clear.cgColor

                self.contentView.layer.borderWidth = self.isSelected ? self.selectedBorderWidth : self.unselectedBorderWidth

                self.contentView.layer.borderColor = self.isSelected ?
                UIColor.systemBlue.cgColor : UIColor.systemGray4.cgColor

                self.checkMarkView.alpha = self.isSelected ? 1 : 0
                self.checkMarkView.transform = self.isSelected
                               ? .identity
                               : CGAffineTransform(scaleX: 0.6, y: 0.6)
            }
        )
    }

    // MARK: - Setup

     func setupUI() {
        contentView.layer.cornerRadius = 16
         contentView.layer.borderWidth = 1.75
         contentView.layer.borderColor = UIColor.systemGray4.cgColor
         contentView.backgroundColor = UIColor.white

         checkMarkView.tintColor = .systemBlue
         checkMarkView.alpha = 0
         checkMarkView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    }

    // MARK: - Configure

    func configure(_ model: DomainModel) {
        domainName.text = model.title

        if let iconName = model.icon {
            domainIconView.image = UIImage(systemName: iconName, withConfiguration: config)
            domainIconView.tintColor = .label
            domainIconView.isHidden = false
        } else {
            domainIconView.isHidden = true
        }
    }

    // MARK: - Colors

}
