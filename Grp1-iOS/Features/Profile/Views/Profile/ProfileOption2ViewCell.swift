import UIKit

// MARK: - Protocol (for the Delegate pattern)
protocol ProfileOptionCellDelegate: AnyObject {
    func didTapOption(for cell: ProfileOption2ViewCell)
}

class ProfileOption2ViewCell: UICollectionViewCell {

    weak var delegate: ProfileOptionCellDelegate?

    @IBOutlet weak var textLabel: UILabel!

    @IBOutlet weak var chevronImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
    }

    func configure(title: String, isDestructive: Bool) {
        textLabel.text = title
        textLabel.font = .preferredFont(forTextStyle: .title2)

        if isDestructive {
            textLabel.textColor = .systemRed
            textLabel.textAlignment = .center
            chevronImage.tintColor = .systemRed
//            chevronImage.isHidden = true
        } else {
            textLabel.textColor = .label
//            chevronImage.tintColor = false
        }
    }
}
