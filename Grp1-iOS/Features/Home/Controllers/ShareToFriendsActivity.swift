import UIKit

class ShareToFriendsActivity: UIActivity {

    var article: NewsArticle?

    override var activityTitle: String? { "Share to Friends" }
    override var activityImage: UIImage? { UIImage(systemName: "person.2.fill") }

    override class var activityCategory: UIActivity.Category {
        return .action
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    override func perform() {
        print("Sharing to friends inside the app")
        activityDidFinish(true)
    }
}
