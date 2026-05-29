//
//  WordleViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 03/02/26.
//

import UIKit

class WordleViewController: UIViewController {

    @IBOutlet weak var revealButton: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var ProfitPoints: UIProgressView!
    @IBOutlet weak var keyboardStack: UIStackView!
    @IBOutlet weak var gridContainer: UIStackView!
    private var tileGrid: [[LetterTileView]] = []
    private var keyStates: [Character: LetterTileView.State] = [:]
    private var isGameOver = false
    private var hints: [String] = []
    private var revealedPositions: Set<Int> = []
    private var revealedLetters: [Int: Character] = [:]
    private var currentHintIndex = 0
    private var revealUsed = false
    private var progressScore: Float = 0.0
    private var wordLength: Int {
        engine.revealedAnswer.count
    }

        private var currentGuess = ""

        private lazy var currentWordItem: WordleItem = {
            let unplayed = WordleData.items.filter { !WordHistoryManager.shared.hasPlayedWordleWord($0.word) }
            return unplayed.randomElement() ?? WordleData.items.randomElement()!
        }()
        private lazy var engine = WordleEngine(answer: currentWordItem.word.lowercased())

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
        let g = CAGradientLayer()
        g.colors = [
                UIColor.systemBlue.withAlphaComponent(0.2).cgColor,
                UIColor.systemTeal.withAlphaComponent(0.2).cgColor
            ]
        g.frame = view.bounds
        return g
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

        guard let index = (0..<wordLength).first(where: { i in
            let tile = tileGrid[row][i]
            let isEmpty = tile.label.text?.isEmpty ?? true
            let isLocked = revealedPositions.contains(i)
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

        guard let index = (0..<wordLength).reversed().first(where: { i in
            let tile = tileGrid[row][i]
            let isFilled = !(tile.label.text?.isEmpty ?? true)
            let isLocked = revealedPositions.contains(i)
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
    
    private func showPointsPopupFromBottom(
        text: String,
        color: UIColor,
        completion: @escaping () -> Void
    ) {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = color
        label.backgroundColor = color.withAlphaComponent(0.18)
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true

        let width: CGFloat = 54
        let height: CGFloat = 28

        let startPoint = CGPoint(
            x: view.bounds.midX,
            y: view.bounds.maxY - 150
        )

        label.frame = CGRect(x: 0, y: 0, width: width, height: height)
        label.center = startPoint
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)

        view.addSubview(label)

        let target = ProfitPoints.convert(
            ProfitPoints.bounds.center,
            to: view
        )

        UIView.animate(
            withDuration: 0.70,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.2,
            options: [.curveEaseOut],
            animations: {
                label.alpha = 1
                label.transform = .identity
                label.center.y -= 120
            }
        )

        UIView.animate(
            withDuration: 0.6,
            delay: 0.35,
            options: [.curveEaseInOut],
            animations: {
                label.center = CGPoint(
                    x: target.x + 100,
                    y: target.y - 6
                )
                label.alpha = 0
                label.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            },
            completion: { _ in
                label.removeFromSuperview()
                completion()
            }
        )
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
    
    private func updateProgressWithPopups(from result: GuessResult) {

        let greenCount = result.evaluations.filter { $0.state == .correct }.count
        let yellowCount = result.evaluations.filter { $0.state == .present }.count

        let totalPoints = (greenCount * 10) + (yellowCount * 5)
        guard totalPoints > 0 else { return }

        let progressIncrement =
            (Float(greenCount) * 0.10) +
            (Float(yellowCount) * 0.05)

        let popupColor: UIColor =
            greenCount > yellowCount ? .systemGreen : .systemYellow

        showPointsPopupFromBottom(
            text: "+$\(totalPoints)",
            color: popupColor
        ) {
            self.incrementProgress(by: progressIncrement)
        }
    }
    private func incrementProgress(by value: Float) {
        progressScore = min(1.0, progressScore + value)

        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                self.ProfitPoints.setProgress(self.progressScore, animated: true)
                self.updateProgressColor()
            }
        )
    }
    
    private func updateProgressColor() {
        switch progressScore {
        case 0.7...1.0:
            ProfitPoints.progressTintColor = .systemGreen
        case 0.4..<0.7:
            ProfitPoints.progressTintColor = .systemYellow
        default:
            ProfitPoints.progressTintColor = .systemRed
        }
    }
    
    
    private func updateKeyboard(with result: GuessResult) {
        for evaluation in result.evaluations {
            let letter = evaluation.character
            let newState = evaluation.state

            let oldState = keyStates[letter]

            if let old = oldState {
                if old == .correct { continue }
                if old == .present && newState == .absent { continue }
            }

            keyStates[letter] = newState
            updateKeyAppearance(letter: letter, state: newState)
        }
    }
    private func updateCurrentGuessFromGrid() {
        let row = engine.attempts
        var guess = ""

        for tile in tileGrid[row] {
            if let text = tile.label.text, !text.isEmpty {
                guess.append(text.lowercased())
            }
        }

        currentGuess = guess
    }
    
    private func updateKeyAppearance(letter: Character, state: LetterTileView.State) {
        let letterString = String(letter).uppercased()

        for row in keyboardStack.arrangedSubviews {
            guard let rowStack = row as? UIStackView else { continue }

            for view in rowStack.arrangedSubviews {
                guard let button = view as? UIButton else { continue }
                guard button.title(for: .normal) == letterString else { continue }

                UIView.animate(withDuration: 0.25) {
                    switch state {
                    case .correct:
                        button.backgroundColor = .systemGreen
                        button.setTitleColor(.white, for: .normal)

                    case .present:
                        button.backgroundColor = .systemYellow
                        button.setTitleColor(.white, for: .normal)

                    case .absent:
                        button.backgroundColor = .systemGray2
                        button.setTitleColor(.white, for: .normal)

                    case .empty:
                        break
                    }
                }
            }
        }
    }


    private func render(_ result: GuessResult, row: Int) {
            let row = engine.attempts - 1

            for (i, evaluation) in result.evaluations.enumerated() {
                let tile = tileGrid[row][i]

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
        DailyGameManager.shared.markGamePlayed(.Wordle)
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
        currentWordItem = unplayed.randomElement() ?? WordleData.items.randomElement()!
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

    private func showConfetti() {
        let emitter = CAEmitterLayer()

        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else { return }

        emitter.emitterPosition = CGPoint(
            x: window.bounds.midX,
            y: -10
        )
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(
            width: window.bounds.width,
            height: 1
        )

        emitter.zPosition = CGFloat(Float.greatestFiniteMagnitude)

        let colors: [UIColor] = [
            .systemGreen,
            .systemBlue,
            .systemYellow,
            .systemPink,
            .systemOrange
        ]

        emitter.emitterCells = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 6
            cell.lifetime = 5.0
            cell.velocity = 150
            cell.velocityRange = 60
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.spin = 3
            cell.spinRange = 4
            cell.scale = 0.04
            cell.scaleRange = 0.02
            cell.color = color.cgColor
            cell.contents = UIImage(systemName: "circle.fill")?.cgImage
            return cell
        }

        window.layer.addSublayer(emitter)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            emitter.birthRate = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            emitter.removeFromSuperlayer()
        }
    }
    
    private func setupKeyboard() {

        let rows: [[String]] = [
            ["Q","W","E","R","T","Y","U","I","O","P"],
            ["A","S","D","F","G","H","J","K","L"],
            ["Z","X","C","V","B","N","M","⌫","✓"]
        ]

        for row in rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 6
            rowStack.distribution = .fillEqually

            for key in row {
                let button = makeKey(title: key)
                rowStack.addArrangedSubview(button)
            }

            keyboardStack.addArrangedSubview(rowStack)
        }
    }
    private func makeKey(title: String) -> UIButton {
        let button = UIButton(type: .system)

        button.setTitle(title, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)

        button.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor.systemGray4
            : UIColor.white
        }

        button.layer.cornerRadius = 14
        button.layer.masksToBounds = false

        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.12
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4

        button.heightAnchor.constraint(equalToConstant: 52).isActive = true

        button.addAction(UIAction { _ in
            UIView.animate(withDuration: 0.08, animations: {
                button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.08) {
                    button.transform = .identity
                }
            }
        }, for: .touchDown)

        if title == "⌫" {
            button.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        } else if title == "✓" {
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        } else {
            button.addTarget(self, action: #selector(letterTapped(_:)), for: .touchUpInside)
        }

        return button
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
    
    @IBAction func hintTapped(_ sender: UIButton) {
        guard !hints.isEmpty else { return }

            currentHintIndex = (currentHintIndex + 1) % hints.count

            let newHint = hints[currentHintIndex]
            slideHintText(newHint)
    }
    
    private func glowHintLabel() {

        hintLabel.layer.shadowColor = UIColor(
            red: 1.0,
            green: 0.9,
            blue: 0.3,
            alpha: 1.0
        ).cgColor
        hintLabel.layer.shadowRadius = 38
        hintLabel.layer.shadowOpacity = 0.8
        hintLabel.layer.shadowOffset = .zero

        let glowIn = CABasicAnimation(keyPath: "shadowOpacity")
        glowIn.fromValue = 0
        glowIn.toValue = 0.8
        glowIn.duration = 0.35
        glowIn.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let pulse = CABasicAnimation(keyPath: "shadowRadius")
        pulse.fromValue = 12
        pulse.toValue = 22
        pulse.duration = 0.6
        pulse.autoreverses = true
        pulse.repeatCount = 2
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let glowOut = CABasicAnimation(keyPath: "shadowOpacity")
        glowOut.fromValue = 0.8
        glowOut.toValue = 0
        glowOut.beginTime = CACurrentMediaTime() + 1.2
        glowOut.duration = 0.4
        glowOut.fillMode = .forwards
        glowOut.isRemovedOnCompletion = false

        hintLabel.layer.add(glowIn, forKey: "glowIn")
        hintLabel.layer.add(pulse, forKey: "pulse")
        hintLabel.layer.add(glowOut, forKey: "glowOut")
    }
    
    private func slideHintText(_ text: String) {

        if hintLabel.alpha == 0 {
            hintLabel.text = text
            hintLabel.transform = CGAffineTransform(translationX: 0, y: 20)

            UIView.animate(
                withDuration: 0.45,
                delay: 0,
                usingSpringWithDamping: 0.85,
                initialSpringVelocity: 0.4,
                options: [.curveEaseOut],
                animations: {
                    self.hintLabel.alpha = 1
                    self.hintLabel.transform = .identity
                }
            )
            return
        }

        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.hintLabel.alpha = 0
                self.hintLabel.transform = CGAffineTransform(translationX: 0, y: -16)
            },
            completion: { _ in
                self.hintLabel.transform = .identity
                
                self.hintLabel.text = text
                
                self.view.layoutIfNeeded()
                
                self.hintLabel.transform = CGAffineTransform(translationX: 0, y: 20)

                UIView.animate(
                    withDuration: 0.45,
                    delay: 0,
                    usingSpringWithDamping: 0.85,
                    initialSpringVelocity: 0.4,
                    options: [.curveEaseOut],
                    animations: {
                        self.hintLabel.alpha = 1
                        self.hintLabel.transform = .identity
                    },
                    completion: { _ in
                        self.glowHintLabel()
                    }
                )
            }
        )
    }
}


extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}


