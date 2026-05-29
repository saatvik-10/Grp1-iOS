import UIKit

class WordleViewController: UIViewController {

    @IBOutlet weak var revealButton: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var profitPoints: UIProgressView!
    @IBOutlet weak var keyboardStack: UIStackView!
    @IBOutlet weak var gridContainer: UIStackView!
    var tileGrid: [[LetterTileView]] = []
    var keyStates: [Character: LetterTileView.State] = [:]
    private var isGameOver = false
    private var hints: [String] = [
        "It appears on a company's balance sheet and includes things like cash or investments.",
        "It represents something valuable that can generate future economic benefit."
    ]
    private var revealedPositions: Set<Int> = []
    private var revealedLetters: [Int: Character] = [:]
    private var currentHintIndex = 0
    private var revealUsed = false
    var progressScore: Float = 0.0
    private var wordLength: Int {
        engine.revealedAnswer.count
    }

    var currentGuess = ""

        private lazy var currentWordItem: WordleItem = {
            let unplayed = WordleData.items.filter { !WordHistoryManager.shared.hasPlayedWordleWord($0.word) }
            return unplayed.randomElement() ?? WordleData.items.randomElement() ?? WordleItem(word: "", hints: [], definition: "")
        }()
        lazy var engine = WordleEngine(answer: currentWordItem.word.lowercased())

        override func viewDidLoad() {
            super.viewDidLoad()
            hints = currentWordItem.hints
            hintLabel.text = hints[0]
            hintLabel.alpha = 1
            hintLabel.transform = CGAffineTransform(translationX: 0, y: 20)
            buildGrid()
            setupKeyboard()
//            view.layer.insertSublayer(makeGradient(), at: 0)
        }
    private func makeGradient() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = [
                UIColor.systemBlue.withAlphaComponent(0.2).cgColor,
                UIColor.systemTeal.withAlphaComponent(0.2).cgColor
            ]
        gradient.frame = view.bounds
        return gradient
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    private func buildGrid() {
        gridContainer.axis = .vertical
        gridContainer.spacing = 12
        gridContainer.distribution = .fillEqually

        for _ in 0..<4 {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 8
            row.distribution = .fillEqually

            var tiles: [LetterTileView] = []

            for _ in 0..<wordLength {
                let tile = LetterTileView()
                tile.heightAnchor.constraint(equalToConstant: 30).isActive = true
                row.addArrangedSubview(tile)
                tiles.append(tile)
            }

            gridContainer.addArrangedSubview(row)
            tileGrid.append(tiles)
        }
    }

    func addLetter(_ letter: Character) {
        guard !isGameOver else { return }

        let row = engine.attempts

        guard let index = (0..<wordLength).first(where: { idx in
            let tile = tileGrid[row][idx]
            let isEmpty = tile.label.text?.isEmpty ?? true
            let isLocked = revealedPositions.contains(idx)
            return isEmpty && !isLocked
        }) else {
            return
        }

        tileGrid[row][index].label.text = String(letter).uppercased()
        updateCurrentGuessFromGrid()
    }

    func removeLetter() {
        guard !isGameOver else { return }

        let row = engine.attempts

        guard let index = (0..<wordLength).reversed().first(where: { idx in
            let tile = tileGrid[row][idx]
            let isFilled = !(tile.label.text?.isEmpty ?? true)
            let isLocked = revealedPositions.contains(idx)
            return isFilled && !isLocked
        }) else {
            return
        }

        tileGrid[row][index].label.text = ""
        updateCurrentGuessFromGrid()
    }

    func submitGuess() {
        guard !isGameOver else { return }

        rebuildCurrentGuessFromRow()
        guard currentGuess.count == wordLength else { return }

        let rowIndex = engine.attempts
        let result = engine.evaluate(currentGuess)

        render(result, row: rowIndex)
        updateKeyboard(with: result)
        currentGuess = ""
        updateProgressWithPopups(from: result)

        revealedPositions.removeAll()
        revealedLetters.removeAll()

        if result.isCorrect {
            endGame(won: true)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            showConfetti()
        } else if engine.attempts >= engine.maxAttempts {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            endGame(won: false)
        }
    }

    @IBAction func revealAlphabetTapped(_ sender: UIButton) {
        revealRandomAlphabet()
    }

    func revealRandomAlphabet() {
        guard !isGameOver else { return }
        guard !revealUsed else { return }

        let row = engine.attempts
        let answerChars = Array(engine.revealedAnswer.uppercased())

        let eligibleIndices = (0..<wordLength).filter { index in
            let tile = tileGrid[row][index]

            guard tile.label.text?.isEmpty ?? true else { return false }

            let correctChar = answerChars[index]
            let keyState = keyStates[Character(correctChar.lowercased())]

            if keyState == .correct {
                return false
            }

            if revealedPositions.contains(index) {
                return false
            }

            return true
        }

        guard let index = eligibleIndices.randomElement() else {
            print("No valid letter to reveal")
            return
        }

        revealUsed = true
        revealButton.isEnabled = false

        UIView.animate(withDuration: 0.25) {
            self.revealButton.alpha = 0.5
        }

        let revealedChar = answerChars[index]
        revealedPositions.insert(index)

        let tile = tileGrid[row][index]
        tile.update(letter: revealedChar, state: .correct)

        updateCurrentGuessFromGrid()

        UIView.animate(
            withDuration: 0.25,
            animations: {
                tile.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    tile.transform = .identity
                }
            }
        )
    }

    private func rebuildCurrentGuessFromRow() {
        let row = min(engine.attempts, tileGrid.count - 1)
        var guess = ""

        for tile in tileGrid[row] {
            if let text = tile.label.text, !text.isEmpty {
                guess.append(text.lowercased())
            }
        }

        currentGuess = guess
    }

    private func render(_ result: GuessResult, row: Int) {
        let row = engine.attempts - 1

        for (index, evaluation) in result.evaluations.enumerated() {
            let tile = tileGrid[row][index]

            UIView.transition(
                with: tile,
                duration: 0.3,
                options: .transitionFlipFromTop,
                animations: {
                    tile.update(
                        letter: evaluation.character,
                        state: evaluation.state
                    )
                }
            )
        }
    }

    private func endGame(won: Bool) {
        isGameOver = true

        WordHistoryManager.shared.markWordleWordPlayed(currentWordItem.word)

        self.presentWinSheet()
        DailyGameManager.shared.markGamePlayed(.wordle)
    }

    private func presentWinSheet() {
        let sheet = LearnMoreViewController(
            word: engine.revealedAnswer.uppercased(),
            definition: getDefinitionForWord()
        )

        sheet.modalPresentationStyle = .overFullScreen
        sheet.modalTransitionStyle = .crossDissolve

        present(sheet, animated: true)
    }
}

// MARK: - Utilities
extension WordleViewController {
    private func getDefinitionForWord() -> String {
        return currentWordItem.definition
    }

    private func showEndAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Play Again", style: .default) { _ in
            self.resetGame()
        })

        alert.addAction(UIAlertAction(title: "Close", style: .cancel))

        present(alert, animated: true)
    }

    private func resetGame() {
        isGameOver = false
        currentGuess = ""

        let unplayed = WordleData.items.filter { !WordHistoryManager.shared.hasPlayedWordleWord($0.word) }
        currentWordItem = unplayed.randomElement() ?? WordleData.items.randomElement() ?? WordleItem(word: "", hints: [], definition: "")
        engine = WordleEngine(answer: currentWordItem.word.lowercased())
        hints = currentWordItem.hints
        currentHintIndex = 0
        hintLabel.text = hints[0]
        revealUsed = false
        revealButton.isEnabled = true
        revealButton.alpha = 1.0
        revealedPositions.removeAll()
        revealedLetters.removeAll()

        keyboardStack.isUserInteractionEnabled = true
        keyStates.removeAll()

        gridContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tileGrid.removeAll()
        buildGrid()

        resetKeyboardColors()
    }

    private func resetKeyboardColors() {
        for row in keyboardStack.arrangedSubviews {
            guard let rowStack = row as? UIStackView else { continue }

            for view in rowStack.arrangedSubviews {
                guard let button = view as? UIButton else { continue }

                button.backgroundColor = .systemGray5
                button.setTitleColor(.label, for: .normal)
            }
        }
    }
}

// MARK: - Actions
extension WordleViewController {
    @IBAction func hintTapped(_ sender: UIButton) {
        guard !hints.isEmpty else { return }

        currentHintIndex = (currentHintIndex + 1) % hints.count

        let newHint = hints[currentHintIndex]
        slideHintText(newHint)
    }

    @objc func letterTapped(_ sender: UIButton) {
        guard let letter = sender.titleLabel?.text else { return }
        addLetter(Character(letter.lowercased()))
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    @objc func deleteTapped() {
        removeLetter()
    }

    @objc func submitTapped() {
        submitGuess()
    }
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
