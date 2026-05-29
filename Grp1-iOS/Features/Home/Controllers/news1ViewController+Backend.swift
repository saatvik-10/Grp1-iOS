import UIKit

// MARK: - Backend & Actions

extension news1ViewController {
    func fetchQuestionsFromBackend() {
        guard let articleID = article?.id else {
            qaHistory = []
            collectionView.reloadSections(IndexSet(integer: 1))
            return
        }

        APIService.shared.fetchArticleChatQuestions { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let questions):
                    self?.qaHistory = questions.map { apiQuestion in
                        ArticleQA(
                            question: apiQuestion.question,
                            answer: apiQuestion.answer,
                            createdAt: apiQuestion.createdAt ?? Date()
                        )
                    }
                    print("Fetched \(self?.qaHistory.count ?? 0) questions from backend")

                case .failure(let error):
                    print("Failed to fetch questions from backend: \(error)")
                    self?.qaHistory = NewsDataStore.shared.getQAHistory(for: articleID)
                }

                self?.collectionView.reloadSections(IndexSet(integer: 1))
            }
        }
    }

    @IBAction func segmentChanged(_ sender: Any) {
        guard let article = article else { return }

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        let newText: NSAttributedString
        let direction: CGFloat

        if (sender as AnyObject).selectedSegmentIndex == 0 {
            newText = bulletPointList(strings: article.overview)
            direction = -1
        } else {
            newText = bulletPointList(strings: article.keyTakeaways)
            direction = 1
        }

        guard let card = overviewView else { return }
        let originalX = card.frame.origin.x
        let width = card.frame.width

        UIView.animate(
            withDuration: 0.25,
            animations: {
                card.frame.origin.x = originalX - direction * width
                card.alpha = 0
            },
            completion: { _ in
                self.overviewTextLabel.attributedText = newText

                card.frame.origin.x = originalX + direction * width

                UIView.animate(
                    withDuration: 0.32,
                    delay: 0,
                    usingSpringWithDamping: 0.82,
                    initialSpringVelocity: 0.6,
                    options: [.curveEaseOut],
                    animations: {
                        card.frame.origin.x = originalX
                        card.alpha = 1
                    },
                    completion: nil
                )
            }
        )
    }
}
