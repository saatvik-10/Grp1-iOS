import UIKit

class ArticleLensPopupViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var messageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black.withAlphaComponent(0.0)

        containerView.layer.cornerRadius = 20

        containerView.layer.masksToBounds = true

        containerView.transform = CGAffineTransform(translationX: 0, y: 600)

        messageLabel.text = "Your FD returns remain stable. Current 7.2% rate is competitive. "
            + "Consider ladder strategy for better liquidity while maintaining returns."
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        animateIn()
    }

    private func animateIn() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.7,
            options: .curveEaseOut,
            animations: {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
                self.containerView.transform = .identity
            },
            completion: nil
        )
    }

    private func animateOut(completion: (() -> Void)? = nil) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                self.containerView.transform = CGAffineTransform(translationX: 0, y: 600)
            },
            completion: { _ in completion?() }
        )
    }

    @IBAction func dismissPopup(_ sender: Any) {
        animateOut { self.dismiss(animated: false) }
    }
}
