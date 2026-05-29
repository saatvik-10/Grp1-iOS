import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    var autoScrollTimer: Timer?
    var currentIndex = 0
    var rssItem: RSSItem?

    private var refreshTimer: Timer?
    private var lastKnownCount = 0
    private var stableTickCount = 0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        registerCells()
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
        collectionView.dataSource = self
        collectionView.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(articlesDidUpdate),
            name: .articlesUpdated,
            object: nil
        )

        reloadFromStore()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadFromStore()
        startAutoScroll()
        startRefreshPolling()
        NewsDataStore.shared.getAllNews().forEach {
            print("📰 [\(String(format: "%.1f", $0.relevanceScore))] \($0.title)")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoScroll()
        stopRefreshPolling()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Reload

    private func reloadFromStore() {
        let all = newsStore.getAllNews()
        // ✅ Preserve sorted order — NewsDataStore keeps articles sorted by relevanceScore descending
        if !all.isEmpty {
            todaysPick = Array(all.shuffled().prefix(4))
            trendingNews     = all
            marketHighlights = all
        }
        collectionView.reloadData()
    }

    @objc private func articlesDidUpdate() {
        reloadFromStore()
    }

    // MARK: - Polling

    private func startRefreshPolling() {
        stopRefreshPolling()
        lastKnownCount  = newsStore.getAllNews().count
        stableTickCount = 0

        refreshTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let current = self.newsStore.getAllNews().count
            if current != self.lastKnownCount {
                self.lastKnownCount  = current
                self.stableTickCount = 0
                self.reloadFromStore()
            } else {
                self.stableTickCount += 1
                if self.stableTickCount >= 3 {
                    self.stopRefreshPolling()
                }
            }
        }
    }

    private func stopRefreshPolling() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    // MARK: - Properties

    var onArticleLensTapped: (() -> Void)?
    let newsStore = NewsDataStore.shared
    var todaysPick: [NewsArticle] = []
    var trendingNews: [NewsArticle] = []
    var marketHighlights: [NewsArticle] = []
    var article: NewsArticle?

    // MARK: - Auto Scroll

    func startAutoScroll() {
        stopAutoScroll()
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { [weak self] _ in
            self?.scrollTodaysPick()
        }
    }

    func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }

    func scrollTodaysPick() {
        let count = min(todaysPick.count, 4)
        guard count > 1 else { return }
        let lastIndex = count - 1
        currentIndex  = currentIndex < lastIndex ? currentIndex + 1 : 0
        let indexPath = IndexPath(item: currentIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    // MARK: - Navigation

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        var selectedArticle: NewsArticle?

        if indexPath.section == 0 {
            guard indexPath.row < todaysPick.count else { return }
            selectedArticle = todaysPick[indexPath.row]
            performSegue(withIdentifier: "showArticleDetail2", sender: selectedArticle)
            return
        }
        if indexPath.section == 1 {
            guard !trendingNews.isEmpty else { return }
            selectedArticle = trendingNews[0]
        } else if indexPath.section == 2 {
            let items = Array(marketHighlights.filter { $0.relevanceScore >= 2 }.dropFirst(1))
            guard indexPath.row < items.count else { return }
            selectedArticle = items[indexPath.row]
        } else {
            let items = marketHighlights.filter { $0.relevanceScore < 2 }
            guard indexPath.row < items.count else { return }
            selectedArticle = items[indexPath.row]
        }
        if let article = selectedArticle {
            ArticleScorer.shared.updateWeights(for: article.title, body: article.bodyText, signal: .clicked)
        }

        performSegue(withIdentifier: "showArticleDetail", sender: selectedArticle)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showArticleDetail",
           let destinationVC = segue.destination as? news1ViewController,
           let article = sender as? NewsArticle {
            destinationVC.article = article
        }
        if segue.identifier == "showArticleDetail2",
           let destinationVC = segue.destination as? news2ViewController,
           let article = sender as? NewsArticle {
            destinationVC.article = article
        }
    }

    // MARK: - Layout

    func generateLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { section, _ in
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(50)
            )
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: "header",
                alignment: .top
            )
            switch section {
            case 0: return self.section0Layout(headerItem: headerItem)
            case 1: return self.section1Layout(headerItem: headerItem)
            case 3: return self.section3Layout(headerItem: headerItem)
            default: return self.defaultSectionLayout()
            }
        }
    }

    // MARK: - Cell Registration

    func registerCells() {
        collectionView.register(
            UINib(nibName: "TodaysPickCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "today_cell"
        )
        collectionView.register(
            UINib(nibName: "TrendingCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "trending_cell"
        )
        collectionView.register(
            UINib(nibName: "ExploreCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "explore_cell"
        )
        collectionView.register(
            UINib(nibName: "RealExploreCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "realexplore_cell"
        )
        collectionView.register(
            UINib(nibName: "HeaderView", bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "header_cell"
        )
    }
}

// MARK: - Section Layout Helpers

extension HomeViewController {
    private func section0Layout(headerItem: NSCollectionLayoutBoundarySupplementaryItem) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(410)
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = NSDirectionalEdgeInsets(top: -170, leading: 0, bottom: 15, trailing: 0)
        section.boundarySupplementaryItems = [headerItem]
        return section
    }

    private func section1Layout(headerItem: NSCollectionLayoutBoundarySupplementaryItem) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 15, trailing: 10)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(320)
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [headerItem]
        return section
    }

    private func section3Layout(headerItem: NSCollectionLayoutBoundarySupplementaryItem) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.9),
                heightDimension: .estimated(250)
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.boundarySupplementaryItems = [headerItem]
        return section
    }

    private func defaultSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(175)
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0)
        return section
    }
}

// MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { 4 }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return min(todaysPick.count, 4)
        case 1: return min(trendingNews.count, 1)
        case 2: return marketHighlights.filter { $0.relevanceScore >= 2 }.dropFirst(1).count
        case 3: return marketHighlights.filter { $0.relevanceScore < 2 }.count
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0: return cellForTodayPick(collectionView, indexPath: indexPath)
        case 1: return cellForTrending(collectionView, indexPath: indexPath)
        case 2: return cellForExplore(collectionView, indexPath: indexPath)
        default: return cellForRealExplore(collectionView, indexPath: indexPath)
        }
    }
}

// MARK: - Cell Providers

extension HomeViewController {

    private func cellForTodayPick(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row < min(todaysPick.count, 4) else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "today_cell", for: indexPath)
        }
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "today_cell", for: indexPath
        ) as? TodaysPickCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configureCell(with: todaysPick[indexPath.row])
        return cell
    }

    private func cellForTrending(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard !trendingNews.isEmpty else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "trending_cell", for: indexPath)
        }
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "trending_cell", for: indexPath
        ) as? TrendingCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configureCell(with: trendingNews[0])

        cell.onRecommendTapped = { [weak self] in
            guard let self = self else { return }
            let article = self.trendingNews[0]
            ArticleScorer.shared.updateWeights(
                for: article.title, body: article.bodyText, signal: .recommendMore
            )
            self.showToast(message: "Recommendation sent!")
        }
        cell.onNotRecommendTapped = { [weak self] in
            guard let self = self else { return }
            let article = self.trendingNews[0]
            let body = article.overview.joined(separator: " ")
            ArticleScorer.shared.updateWeights(for: article.title, body: body, signal: .recommendLess)
            self.showToast(message: "Got it! We'll show less of this.")
        }
        return cell
    }

    private func cellForExplore(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let items = Array(marketHighlights.filter { $0.relevanceScore >= 2 }.dropFirst(1))
        guard indexPath.row < items.count else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "explore_cell", for: indexPath)
        }
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "explore_cell", for: indexPath
        ) as? ExploreCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configureCell(with: items[indexPath.row])

        cell.onRecommendTapped = { [weak self] in
            guard let self = self else { return }
            let items = Array(self.marketHighlights.filter { $0.relevanceScore >= 2 }.dropFirst(1))
            guard indexPath.row < items.count else { return }
            ArticleScorer.shared.updateWeights(
                for: items[indexPath.row].title,
                body: items[indexPath.row].bodyText,
                signal: .recommendMore
            )
            self.showToast(message: "Recommendation sent!")
        }
        cell.onNotRecommendTapped = { [weak self] in
            guard let self = self else { return }
            let items = Array(self.marketHighlights.filter { $0.relevanceScore >= 2 }.dropFirst(1))
            guard indexPath.row < items.count else { return }
            let article = items[indexPath.row]
            let body = article.overview.joined(separator: " ")
            ArticleScorer.shared.updateWeights(for: article.title, body: body, signal: .recommendLess)
            self.showToast(message: "Got it! We'll show less of this.")
        }
        return cell
    }

    private func cellForRealExplore(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let items = marketHighlights.filter { $0.relevanceScore < 2 }
        guard indexPath.row < items.count else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "realexplore_cell", for: indexPath)
        }
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "realexplore_cell", for: indexPath
        ) as? RealExploreCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configureCell(with: items[indexPath.row])
        return cell
    }
}

// MARK: - Supplementary Views

extension HomeViewController {

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: "header",
            withReuseIdentifier: "header_cell",
            for: indexPath
        ) as? HeaderView else {
            return UICollectionReusableView()
        }

        switch indexPath.section {
        case 0:
            headerView.headerLabel.text        = " "
            headerView.arrowImageView.isHidden = true
            headerView.headerLabel.font        = UIFont.systemFont(ofSize: 34, weight: .bold)
            headerView.headerLabel.textColor   = .black
        case 1:
            headerView.headerLabel.text        = "Your News Feed"
            headerView.arrowImageView.isHidden = true
            headerView.headerLabel.font        = UIFont.systemFont(ofSize: 22, weight: .semibold)
            headerView.headerLabel.textColor   = .black
        case 2:
            headerView.headerLabel.text        = "Explore More"
            headerView.arrowImageView.isHidden = true
            headerView.headerLabel.font        = UIFont.systemFont(ofSize: 22, weight: .semibold)
        default:
            headerView.headerLabel.text        = "Explore More"
            headerView.arrowImageView.isHidden = false
            headerView.headerLabel.font        = UIFont.systemFont(ofSize: 22, weight: .semibold)
        }

        headerView.onTap = { [weak self] in
            guard let self = self else { return }
            if indexPath.section == 2 || indexPath.section == 3 {
                self.openExploreMore()
            }
        }

        return headerView
    }

    func openExploreMore() {
        performSegue(withIdentifier: "toExploreMore", sender: nil)
    }
}
