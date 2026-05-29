import UIKit

class news2ViewController: UIViewController {

    @IBOutlet weak var quizButton: UIButton!
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

    let newsStore = NewsDataStore.shared
    var relatedNews: [NewsArticle] = []
    var qaHistory: [ArticleQA] = []

    var article: NewsArticle?

    private var gradientApplied = false

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
        relatedNews = newsStore.getAllNews().shuffled()

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

            let gradientImg = createGradientImage(color: color, size: gradientImageView.bounds.size)
            AppTheme.shared.dominantColor = color
            gradientImageView.image = gradientImg
            gradientApplied = true
            floatingButton.tintColor = color.withAlphaComponent(0.80)
            quizButton.tintColor = color.withAlphaComponent(0.80)
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
            if let vc = segue.destination as? JargonDetailViewController {
                vc.jargonWord = selectedJargon
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchQuestionsFromBackend()
    }
}
