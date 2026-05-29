import UIKit

// MARK: - Options Menu & Glass

extension news1ViewController {
    func setupOptionsMenu() {
        let recommendAction = UIAction(
            title: "Recommend more",
            image: UIImage(systemName: "hand.thumbsup")
        ) { [weak self] _ in
            guard let self = self, let article = self.article else { return }

            ArticleScorer.shared.updateWeights(for: article.title, body: article.bodyText, signal: .recommendMore)

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            self.animateRecommendationPulse()

            self.showToast(message: "We'll show you more articles like this.")

            print("Recommend more like: \(article.title)")
        }

        let saveAction = UIAction(
            title: "Save article",
            image: UIImage(systemName: "bookmark")
        ) { [weak self] _ in
            guard let self = self, let article = self.article else { return }

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            let sheetVC = SaveArticleSheetViewController(
                folders: Bookmarks.mockBookmarks,
                articleTitle: article.title
            ) { [weak self] folderTitle in
                guard let self = self, let article = self.article else { return }
                SavedArticlesStore.shared.save(article, to: folderTitle)
                self.animateSaveBookmarkIcon()
                self.showToast(message: "Saved to \(folderTitle)")
            }

            sheetVC.modalPresentationStyle = .pageSheet
            if #available(iOS 16.0, *) {
                if let sheet = sheetVC.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                    sheet.prefersGrabberVisible = true
                    sheet.preferredCornerRadius = 24
                }
            }

            self.present(sheetVC, animated: true)
        }

        let shareAction = UIAction(
            title: "Share article",
            image: UIImage(systemName: "square.and.arrow.up")
        ) { [weak self] _ in
            guard let self = self, let article = self.article else { return }

            let customActivity = ShareToFriendsActivity()
            customActivity.article = article

            let activityVC = UIActivityViewController(
                activityItems: [article.title],
                applicationActivities: [customActivity]
            )

            activityVC.popoverPresentationController?.barButtonItem = self.optionsButton

            self.present(activityVC, animated: true)
        }

        let menu = UIMenu(
            title: "",
            children: [recommendAction, saveAction, shareAction]
        )

        optionsButton.menu = menu
    }

    func setupGlassEffect() {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = glassView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        glassView.addSubview(blurView)
        blurView.layer.zPosition = 0

        glassView.layer.cornerRadius = 22
        glassView.layer.masksToBounds = true

        glassView.layer.borderWidth = 1
        glassView.layer.borderColor = UIColor.white.withAlphaComponent(0.95).cgColor

        blurView.backgroundColor = UIColor.white.withAlphaComponent(0.95)

        for subview in glassView.subviews where !(subview is UIVisualEffectView) {
            subview.layer.zPosition = 1
        }
    }
}
