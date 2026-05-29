import UIKit

class GameChoiceButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGameStyle()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGameStyle()
    }

    private func setupGameStyle() {
        // 1. Force Title 3 and center alignment
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
        titleLabel?.textAlignment = .center
        titleLabel?.lineBreakMode = .byClipping // Prevents the "..."

        // 2. Add padding so text doesn't touch edges
        contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)

        // 3. Apply your Glass Effect here so it's permanent
        applyGlass()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Re-enforce font during animations
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
    }
}
