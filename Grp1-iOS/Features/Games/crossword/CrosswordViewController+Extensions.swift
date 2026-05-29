import UIKit

// swiftlint:disable file_length

// MARK: - Setup & Loading

extension CrosswordViewController {

    func setupCollectionView() {
        gridCollectionView.dataSource = self
        gridCollectionView.delegate = self

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        gridCollectionView.collectionViewLayout = layout
    }

    func showLoadingOverlay() {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.systemBackground
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .systemPurple
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "Generating Puzzle..."
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false

        overlay.addSubview(spinner)
        overlay.addSubview(label)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: overlay.centerYAnchor, constant: -20),
            label.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 16)
        ])

        view.addSubview(overlay)
        loadingOverlay = overlay
    }

    func hideLoadingOverlayAndRevealUI() {
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingOverlay?.alpha = 0
            self.gridCollectionView.alpha = 1
            self.questionLabel.alpha = 1
            self.keyboardStack.alpha = 1
            self.progressBar.alpha = 1
            self.timerLabel.alpha = 1
        }, completion: { _ in
            self.loadingOverlay?.removeFromSuperview()
            self.loadingOverlay = nil
        })
    }

    @MainActor
    func generatePuzzles() async {
        allPuzzles = generateUniqueCrosswords(from: financeData, count: 10)

        print("Generated \(allPuzzles.count) unique puzzles")

        if allPuzzles.isEmpty {
            print("Using fallback puzzles")
        }
        allPuzzles.shuffle()
    }

    @MainActor
    func loadLevel() async {
        guard !allPuzzles.isEmpty else {
            print("No puzzles available")
            return
        }

        isReadOnly = false

        let (inputWords, clues) = allPuzzles[currentPuzzleIndex]

        print("Loading puzzle \(currentPuzzleIndex + 1)/\(allPuzzles.count)")
        print("   Words: \(inputWords.joined(separator: ", "))")

        let (board, placedWords) = generateCrossword(words: inputWords)
        guard !placedWords.isEmpty else {
            print("Failed to generate crossword, trying next puzzle...")
            await loadNextPuzzle()
            return
        }

        let occupied = board.enumerated().flatMap { colIndex, col in
            col.enumerated().compactMap { rowIndex, char in char != nil ? (colIndex, rowIndex) : nil }
        }

        minX = occupied.map { $0.0 }.min() ?? 0
        maxX = occupied.map { $0.0 }.max() ?? 0
        minY = occupied.map { $0.1 }.min() ?? 0
        maxY = occupied.map { $0.1 }.max() ?? 0

        let crosswordCols = maxX - minX + 1
        let crosswordRows = maxY - minY + 1

        let offsetX = (9 - crosswordCols) / 2
        let offsetY = (9 - crosswordRows) / 2

        cells = (0..<81).map { index in
            CrosswordCell(
                index: index,
                row: index / 9,
                col: index % 9,
                numbers: [],
                letter: nil,
                correctLetter: nil,
                isBlocked: true,
                isHighlighted: false,
                isCorrectLetter: false,
                isCorrectWord: false,
                isWrongLetter: false,
                isSelected: false
            )
        }

        for word in placedWords {
            for letterIndex in 0..<word.string.count {
                let letter = word.string[word.string.index(word.string.startIndex, offsetBy: letterIndex)]
                let gx = (word.dir == 0 ? word.x + letterIndex : word.x)
                let gy = (word.dir == 0 ? word.y : word.y + letterIndex)
                let cx = (gx - minX) + offsetX
                let cy = (gy - minY) + offsetY
                let idx = indexForCell(col: cx, row: cy)
                cells[idx].isBlocked = false
                cells[idx].correctLetter = letter
            }
        }

        words = placedWords.enumerated().map { (wordIndex, word) in
            let sx = (word.x - minX) + offsetX
            let sy = (word.y - minY) + offsetY
            let idx = indexForCell(col: sx, row: sy)

            return CrosswordWord(
                number: wordIndex + 1,
                answer: word.string,
                clue: clues[word.string] ?? "No clue",
                startIndex: idx,
                direction: word.dir == 0 ? .across : .down
            )
        }

        for word in words {
            cells[word.startIndex].numbers.append(word.number)
        }

        gridCollectionView.reloadData()

        if let first = words.first {
            gameState.selectedWord = first
            gameState.selectedCellIndex = first.startIndex
            gameState.selectedDirection = first.globalDirection
            updateClueLabel()
            highlightSelectedWord()
        }
        startCountdownTimer()
    }

    @MainActor
    func loadNextPuzzle() async {
        currentPuzzleIndex = (currentPuzzleIndex + 1) % allPuzzles.count
        await loadLevel()
    }
}

// MARK: - Game Logic

extension CrosswordViewController {

    func isPuzzleComplete() -> Bool {
        for cell in cells where !cell.isBlocked {
            if !isCellCorrect(cell.index) { return false }
        }
        return true
    }

    func indexForCell(col: Int, row: Int) -> Int {
        return row * totalCols + col
    }

    func updateClueLabel() {
        guard let word = gameState.selectedWord else { return }
        questionLabel.text = "\(word.number). \(word.clue)"
    }

    func findAllWordsForCell(_ cell: CrosswordCell) -> [CrosswordWord] {
        var matchingWords: [CrosswordWord] = []

        for word in words {
            var row = cells[word.startIndex].row
            var col = cells[word.startIndex].col

            for _ in 0..<word.answer.count {
                if row == cell.row && col == cell.col {
                    matchingWords.append(word)
                    break
                }
                if word.direction == .across { col += 1 } else { row += 1 }
            }
        }
        return matchingWords
    }

    func handleGridTap(_ cell: CrosswordCell) {
        guard !isReadOnly else { return }

        let wordsContainingCell = findAllWordsForCell(cell)
        guard !wordsContainingCell.isEmpty else { return }

        for index in cells.indices { cells[index].isSelected = false }

        cells[cell.index].isSelected = true
        gameState.selectedCellIndex = cell.index

        if wordsContainingCell.count > 1 {
            let hasAcross = wordsContainingCell.contains { $0.direction == .across }
            let hasDown = wordsContainingCell.contains { $0.direction == .down }

            if hasAcross && hasDown {
                gameState.selectedDirection =
                    (gameState.selectedDirection == .across ? .down : .across)
            }
        }

        let preferredWord: CrosswordWord?
        if gameState.selectedDirection == .across {
            preferredWord = wordsContainingCell.first { $0.direction == .across }
                ?? wordsContainingCell.first
        } else {
            preferredWord = wordsContainingCell.first { $0.direction == .down }
                ?? wordsContainingCell.first
        }

        if let word = preferredWord {
            gameState.selectedWord = word
            gameState.selectedDirection = word.globalDirection
            updateClueLabel()
            highlightSelectedWord()
        }

        gridCollectionView.reloadData()
    }

    func moveSelectionForward(from index: Int) {
        guard let word = gameState.selectedWord else { return }

        let current = cells[index]
        var row = current.row
        var col = current.col

        if word.direction == .across { col += 1 } else { row += 1 }

        while row < totalRows && col < totalCols {
            let nextIndex = indexForCell(col: col, row: row)

            if !cells[nextIndex].isBlocked {
                for index in cells.indices { cells[index].isSelected = false }
                cells[nextIndex].isSelected = true
                gameState.selectedCellIndex = nextIndex
                return
            }

            if word.direction == .across { col += 1 } else { row += 1 }
        }
    }

    func highlightSelectedWord() {
        for index in cells.indices { cells[index].isHighlighted = false }

        guard let word = gameState.selectedWord else { return }

        var row = cells[word.startIndex].row
        var col = cells[word.startIndex].col

        for _ in 0..<word.answer.count {
            let idx = indexForCell(col: col, row: row)
            cells[idx].isHighlighted = true
            if word.direction == .across { col += 1 } else { row += 1 }
        }
    }

    func playLightHaptic() {
        lightHaptic.prepare()
        lightHaptic.impactOccurred()
    }

    func insertLetter(_ char: Character) {
        guard !isReadOnly else { return }

        let idx = gameState.selectedCellIndex

        cells[idx].letter = char
        cells[idx].isWrongLetter = false

        if let correct = cells[idx].correctLetter {
            cells[idx].isCorrectLetter = char.uppercased() == correct.uppercased()
        }

        revalidateWords(at: idx)

        if gameState.selectedWord != nil {
            if isSelectedWordComplete() {
                clearSelection()
                highlightSelectedWord()
                gridCollectionView.reloadData()

                if isPuzzleComplete() {
                    showPuzzleCompleteAlert()
                }
                return
            }
        }

        moveSelectionForward(from: idx)
        highlightSelectedWord()
        gridCollectionView.reloadData()
    }

    func isSelectedWordComplete() -> Bool {
        guard let word = gameState.selectedWord else { return false }

        var row = cells[word.startIndex].row
        var col = cells[word.startIndex].col

        for _ in 0..<word.answer.count {
            let idx = indexForCell(col: col, row: row)
            if cells[idx].letter == nil { return false }
            if word.direction == .across { col += 1 } else { row += 1 }
        }
        return true
    }

    func isCellCorrect(_ idx: Int) -> Bool {
        guard let letter = cells[idx].letter,
              let correct = cells[idx].correctLetter else { return false }
        return letter.uppercased() == correct.uppercased()
    }

    func deleteLetter() {
        guard !isReadOnly else { return }
        guard let word = gameState.selectedWord else { return }

        let idx = gameState.selectedCellIndex

        if cells[idx].letter != nil {
            cells[idx].letter = nil
            cells[idx].isWrongLetter = false
            cells[idx].isCorrectWord = false

            revalidateWords(at: idx)
            highlightSelectedWord()
            gridCollectionView.reloadData()
            return
        }

        var row = cells[word.startIndex].row
        var col = cells[word.startIndex].col
        var previousIndex: Int?

        for _ in 0..<word.answer.count {
            let currentIndex = indexForCell(col: col, row: row)
            if currentIndex == idx { break }
            previousIndex = currentIndex
            if word.direction == .across { col += 1 } else { row += 1 }
        }

        guard let prev = previousIndex else { return }

        for index in cells.indices { cells[index].isSelected = false }

        cells[prev].isSelected = true
        gameState.selectedCellIndex = prev

        cells[prev].letter = nil
        cells[prev].isWrongLetter = false
        cells[prev].isCorrectWord = false

        revalidateWords(at: prev)
        highlightSelectedWord()
        gridCollectionView.reloadData()
    }

    func clearSelection() {
        for index in cells.indices { cells[index].isSelected = false }
    }

    func checkWordCompletion(_ word: CrosswordWord) {
        var row = cells[word.startIndex].row
        var col = cells[word.startIndex].col

        var indices: [Int] = []
        var allFilled = true
        var allCorrect = true

        for _ in 0..<word.answer.count {
            let idx = indexForCell(col: col, row: row)
            indices.append(idx)

            if let letter = cells[idx].letter {
                if letter.uppercased() != cells[idx].correctLetter?.uppercased() {
                    allCorrect = false
                }
            } else {
                allFilled = false
            }

            if word.direction == .across { col += 1 } else { row += 1 }
        }

        guard allFilled else {
            for idx in indices { cells[idx].isWrongLetter = false }
            return
        }

        if allCorrect {
            for idx in indices {
                cells[idx].isCorrectWord = true
                cells[idx].isWrongLetter = false
            }
            rewardCorrectWord(word)
        } else {
            for idx in indices { cells[idx].isWrongLetter = true }
        }
    }

    func revalidateWords(at cellIndex: Int) {
        let cell = cells[cellIndex]
        let affectedWords = findAllWordsForCell(cell)
        for word in affectedWords { checkWordCompletion(word) }
    }

    func showPuzzleCompleteAlert() {
        let alert = UIAlertController(
            title: "Puzzle Complete!",
            message: "Congratulations! Would you like to play another puzzle?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Next Puzzle", style: .default) { [weak self] _ in
            Task { await self?.loadNextPuzzle() }
        })

        alert.addAction(UIAlertAction(title: "Done", style: .cancel) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })

        present(alert, animated: true)
        DailyGameManager.shared.markGamePlayed(.crossword)
        stopTimer()
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as? GridCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: cells[indexPath.item])
        return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = cells[indexPath.item]
        if model.isBlocked { return }
        playLightHaptic()
        handleGridTap(model)
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 2
        let totalSpacing = CGFloat(totalCols - 1) * spacing
        let usableWidth = gridCollectionView.bounds.width - totalSpacing
        let cellSide = floor(usableWidth / CGFloat(totalCols))
        return CGSize(width: cellSide, height: cellSide)
    }

    // MARK: - Time Up

    func onTimeUp() {
        timerLabel.text = "00:00"
        timerLabel.textColor = .systemRed
        isReadOnly = true

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        let backButton = UIBarButtonItem(
            title: "Go Back",
            style: .plain,
            target: self,
            action: #selector(goBackTapped)
        )
        backButton.tintColor = .systemRed
        navigationItem.leftBarButtonItem = backButton

        for index in cells.indices {
            cells[index].isSelected = false
            cells[index].isHighlighted = false
        }

        for index in cells.indices where !cells[index].isBlocked {
            if let correct = cells[index].correctLetter {
                cells[index].letter = correct
                cells[index].isCorrectLetter = true
                cells[index].isWrongLetter = false
                cells[index].isCorrectWord = false
            }
        }

        let alert = UIAlertController(
            title: "Time's Up!",
            message: "Would you like to see the answers or go back?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Go Back", style: .cancel) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })

        alert.addAction(UIAlertAction(title: "See Answers", style: .default) { [weak self] _ in
            self?.gridCollectionView.reloadData()
        })

        present(alert, animated: true)
    }

    // MARK: - Keyboard

    func setupKeyboard() {
        let rows: [[String]] = [
            ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
            ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
            ["⌫", "Z", "X", "C", "V", "B", "N", "M", "✓"]
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
            }, completion: { _ in
                UIView.animate(withDuration: 0.08) {
                    button.transform = .identity
                }
            })
        }, for: .touchDown)

        if title == "⌫" {
            button.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        } else if title == "✓" {
            button.backgroundColor = .systemPurple
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        } else {
            button.addTarget(self, action: #selector(letterTapped(_:)), for: .touchUpInside)
        }

        return button
    }

    @objc func letterTapped(_ sender: UIButton) {
        guard let letter = sender.titleLabel?.text?.first else { return }
        insertLetter(letter)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    @objc func submitTapped() {
    }

    @objc func deleteTapped() {
        deleteLetter()
    }

    @objc func goBackTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Timer & Ring

    func startCountdownTimer() {
        countdownTimer?.invalidate()

        remainingSeconds = totalSeconds
        timerLabel.textColor = .label
        updateTimerLabel()
        updateRingProgress(animated: false)

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.remainingSeconds -= 1

            if self.remainingSeconds <= 0 {
                self.stopTimer()
                self.onTimeUp()
                return
            }

            self.updateTimerLabel()
            self.updateRingProgress(animated: true)

            if self.remainingSeconds <= 10 {
                self.timerLabel.textColor = .systemRed
                self.ringLayer.strokeColor = UIColor.systemRed.cgColor

                UIView.animate(withDuration: 0.15, animations: {
                    self.timerLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }, completion: { _ in
                    self.timerLabel.transform = .identity
                })
            }
        }
    }

    func updateRingProgress(animated: Bool) {
        let progress = CGFloat(remainingSeconds) / CGFloat(totalSeconds)

        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = ringLayer.strokeEnd
            animation.toValue = progress
            animation.duration = 1
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            ringLayer.strokeEnd = progress
            ringLayer.add(animation, forKey: "ring")
        } else {
            ringLayer.strokeEnd = progress
        }
    }

    func updateTimerLabel() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }

    func stopTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }

    func setupRing() {
        ringLayer.removeFromSuperlayer()
        ringBackgroundLayer.removeFromSuperlayer()

        let radius: CGFloat = 50
        let center = CGPoint(x: timerLabel.bounds.midX, y: timerLabel.bounds.midY)

        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 1.5 * .pi,
            clockwise: true
        )

        ringBackgroundLayer.path = path.cgPath
        ringBackgroundLayer.strokeColor = UIColor.systemGray4.cgColor
        ringBackgroundLayer.fillColor = UIColor.clear.cgColor
        ringBackgroundLayer.lineWidth = 8

        ringLayer.path = path.cgPath
        ringLayer.strokeColor = UIColor.systemGreen.cgColor
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.lineWidth = 8
        ringLayer.lineCap = .round
        ringLayer.strokeEnd = 1.0

        timerLabel.layer.addSublayer(ringBackgroundLayer)
        timerLabel.layer.addSublayer(ringLayer)
    }

    // MARK: - Progress & Popups

    func showPointsPopupFromBottom(text: String, color: UIColor, completion: @escaping () -> Void) {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = color
        label.backgroundColor = color.withAlphaComponent(0.18)
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true

        label.frame = CGRect(x: 0, y: 0, width: 54, height: 28)
        label.center = CGPoint(x: view.bounds.midX, y: view.bounds.maxY - 140)
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)

        view.addSubview(label)

        let target = progressBar.convert(
            CGPoint(x: progressBar.bounds.midX, y: progressBar.bounds.midY),
            to: view
        )

        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.3, animations: {
            label.alpha = 1
            label.transform = .identity
            label.center.y -= 120
        })

        UIView.animate(withDuration: 0.55, delay: 0.3, options: [.curveEaseInOut], animations: {
            label.center = CGPoint(x: target.x, y: target.y - 6)
            label.alpha = 0
            label.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        }, completion: { _ in
            label.removeFromSuperview()
            completion()
        })
    }

    func incrementProgress(by value: Float) {
        progressScore = min(1.0, progressScore + value)
        UIView.animate(withDuration: 0.35) {
            self.progressBar.setProgress(self.progressScore, animated: true)
            self.updateProgressColor()
        }
    }

    func updateProgressColor() {
        switch progressScore {
        case 0.7...1.0: progressBar.progressTintColor = .systemGreen
        case 0.4..<0.7: progressBar.progressTintColor = .systemYellow
        default:        progressBar.progressTintColor = .systemRed
        }
    }

    func rewardCorrectWord(_ word: CrosswordWord) {
        guard !rewardedWords.contains(word.number) else { return }
        rewardedWords.insert(word.number)

        showPointsPopupFromBottom(text: "+$10", color: .systemGreen) {
            self.incrementProgress(by: 0.10)
        }
    }
}
