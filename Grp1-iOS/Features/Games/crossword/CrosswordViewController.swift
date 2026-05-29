import UIKit

final class CrosswordViewController: UIViewController,
    UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var gridCollectionView: UICollectionView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var keyboardStack: UIStackView!
    var didSetupRing = false

    var cells: [CrosswordCell] = []
    var didLoadOnce = false
    var words: [CrosswordWord] = []
    var countdownTimer: Timer?
    var remainingSeconds = 120
    let totalSeconds = 120

    let gameState = CrosswordGameState()

    let ringLayer = CAShapeLayer()
    let ringBackgroundLayer = CAShapeLayer()

    let lightHaptic = UIImpactFeedbackGenerator(style: .light)

    let totalCols = 9
    let totalRows = 9

    var minX = 0
    var minY = 0
    var maxX = 0
    var maxY = 0
    var progressScore: Float = 0.0
    var rewardedWords: Set<Int> = []

    var allPuzzles: [([String], [String: String])] = []
    var currentPuzzleIndex = 0

    var isReadOnly = false
    var loadingOverlay: UIView?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupKeyboard()

        gridCollectionView.alpha = 0
        questionLabel.alpha = 0
        keyboardStack.alpha = 0
        progressBar.alpha = 0
        timerLabel.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !didLoadOnce else { return }
        didLoadOnce = true

        showLoadingOverlay()

        Task {
            await generatePuzzles()
            await loadLevel()
            hideLoadingOverlayAndRevealUI()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didSetupRing {
            setupRing()
            didSetupRing = true
        }
        gridCollectionView.collectionViewLayout.invalidateLayout()
    }
}
