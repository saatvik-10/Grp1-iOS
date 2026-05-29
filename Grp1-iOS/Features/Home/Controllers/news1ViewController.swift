import UIKit

class news1ViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var floatingButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    private var didSetupJargons = false

    var selectedJargon: String?
    @IBOutlet weak var optionsButton: UIBarButtonItem!
    @IBOutlet weak var glassView: UIView!
    @IBOutlet weak var overviewView: UIView!
    @IBOutlet weak var gradientImageView: UIImageView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var overviewTextLabel: UILabel!

    var passedDominantColor: UIColor = .systemBackground
    let newsStore = NewsDataStore.shared
    var relatedNews: [NewsArticle] = []
    var qaHistory: [ArticleQA] = []

    var article: NewsArticle?

    private var gradientApplied = false
    var extractedDominantColor: UIColor?
    var dominantColor: UIColor?

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        overviewTextLabel.numberOfLines = 0
        if let points = article?.overview {
            overviewTextLabel.attributedText = bulletPointList(strings: points)
        }
        view.backgroundColor = .white
        overviewView.layer.cornerRadius = 25
        overviewView.layer.masksToBounds = true

        if article == nil {
            article = newsStore.getArticle(by: 1)
        }

        setupUI()

        if let currentScore = article?.relevanceScore {
            relatedNews = newsStore.getAllNews()
                .filter { $0.id != article?.id && abs($0.relevanceScore - currentScore) <= 1 }
                .shuffled()
        } else {
            relatedNews = newsStore.getAllNews().shuffled()
        }
        fetchQuestionsFromBackend()

        setupCollectionView()
        setupGlassEffect()
        setupOptionsMenu()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !gradientApplied,
           let img = topImageView.image,
           let color = dominantColor(from: img) {

            extractedDominantColor = color
            let gradientImg = createGradientImage(
                color: color,
                size: gradientImageView.bounds.size
            )
            AppTheme.shared.dominantColor = color
            gradientImageView.image = gradientImg
            gradientApplied = true
            floatingButton.tintColor = color.withAlphaComponent(0.80)
        }

        setupJargons()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChat" {

            if let nav = segue.destination as? UINavigationController {

                if let chatVC = nav.topViewController as? HomeChatDetailViewController {
                    chatVC.articleID = self.article?.id

                }
            }
        }
        if segue.identifier == "showJargonDetail" {
            if let vc = segue.destination as? jargonDefinationViewController {
                vc.jargonWord     = selectedJargon
                vc.articleContext = article?.overview.joined(separator: " ") ?? ""
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchQuestionsFromBackend()
    }
}

// MARK: - Setup Methods

extension news1ViewController {
    func setupUI() {
        guard let article = article else { return }

        headlineLabel.text = article.title
        dateLabel.text = "\(article.source) • \(DateUtils.formattedArticleDate(from: article.date))"

        topImageView.setSmartImage(from: article.imageName)
    }

    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear

        collectionView.register(
            UINib(nibName: "moreLikeThisCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "realexplore_cell"
        )

        collectionView.register(
            UINib(nibName: "askQuestionsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "ask_cell"
        )

        collectionView.register(
            UINib(nibName: "HeaderView", bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "header_cell"
        )

        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
    }

    func generateLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in

            if sectionIndex == 0 {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.5),
                    heightDimension: .fractionalHeight(1.0)
                )

                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 10)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .estimated(280)
                )

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )

                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(40)
                )

                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: "header",
                    alignment: .top
                )

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.boundarySupplementaryItems = [header]

                return section
            }

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.98),
                heightDimension: .fractionalHeight(1.0)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 50, trailing: 2)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.95),
                heightDimension: .absolute(280)
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(40)
            )

            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: "header",
                alignment: .top
            )

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            section.boundarySupplementaryItems = [header]

            return section
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension news1ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return relatedNews.count
        }
        return qaHistory.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "realexplore_cell",
                for: indexPath
            ) as? moreLikeThisCollectionViewCell else {
                return UICollectionViewCell()
            }

            cell.configureCell(with: relatedNews[indexPath.row])
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ask_cell",
            for: indexPath
        ) as? askQuestionsCollectionViewCell else {
            return UICollectionViewCell()
        }

        let qa = qaHistory[indexPath.row]
        cell.configureCell(with: qa)
        return cell
    }

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

        if indexPath.section == 0 {
            headerView.headerLabel.text = "More Like This"
            headerView.arrowImageView.isHidden = true
        } else {
            headerView.headerLabel.text = "Questions Asked"
            headerView.arrowImageView.isHidden = true
        }

        headerView.headerLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        return headerView
    }
}

extension news1ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath.section == 0 {
            let selected = relatedNews[indexPath.row]

            let storyboard = UIStoryboard(name: "HomeMain", bundle: nil)
            if let vc = storyboard.instantiateViewController(
                withIdentifier: "news1ViewController"
            ) as? news1ViewController {

                vc.article = selected

                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
