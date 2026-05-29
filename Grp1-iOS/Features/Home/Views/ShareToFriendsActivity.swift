import UIKit

class ShareToFriendsActivity: UIActivity {

    var article: NewsArticle?

    override var activityTitle: String? {
        return "Share to Friends"
    }

    override var activityImage: UIImage? {
        return UIImage(systemName: "person.3.fill")
    }

    override class var activityCategory: UIActivity.Category {
        return .share
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    override func perform() {
        print("Sharing to friends inside the app")

        guard let root = UIApplication.shared.keyWindowInConnectedScenes?.rootViewController else {
            print("no rootViewController found")
            activityDidFinish(false)
            return
        }

        let topVC = root.topMostViewController()

        let sheetVC = ShareBottomSheetViewController(
            nibName: "ShareBottomSheetViewController",
            bundle: nil
        )
        sheetVC.modalPresentationStyle = .overFullScreen
        sheetVC.modalTransitionStyle = .crossDissolve

        topVC.present(sheetVC, animated: true) { [weak self] in
            self?.activityDidFinish(true)
        }
    }
}
