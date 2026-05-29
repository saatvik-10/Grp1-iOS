import UIKit

final class CrosswordViewController: UIViewController,
    UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var gridCollectionView: UICollectionView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var keyboardStack: UIStackView!
    private var didSetupRing = false

    private var cells: [CrosswordCell] = []
    private var didLoadOnce = false
    private var words: [CrosswordWord] = []
    private var countdownTimer: Timer?
    private var remainingSeconds = 120
    private let totalSeconds = 120

    private let gameState = CrosswordGameState()

    private let ringLayer = CAShapeLayer()
    private let ringBackgroundLayer = CAShapeLayer()

    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)

    private let totalCols = 9
    private let totalRows = 9

    private var minX = 0
    private var minY = 0
    private var maxX = 0
    private var maxY = 0
    private var progressScore: Float = 0.0
    private var rewardedWords: Set<Int> = []

    private var allPuzzles: [([String], [String: String])] = []
    private var currentPuzzleIndex = 0

    private var isReadOnly = false
    private var loadingOverlay: UIView?

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
