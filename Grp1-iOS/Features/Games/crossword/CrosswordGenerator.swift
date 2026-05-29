import Foundation

public let boardSize = 32

public var board: [[Character?]] = []
public var wordArr: [String] = []
public var wordBank: [WordObj] = []
public var wordsActive: [WordObj] = []

public let bounds = Bounds()

public struct Placement {
    public let column: Int
    public let row: Int
    public let direction: Int

    public init(column: Int, row: Int, direction: Int) {
        self.column = column
        self.row = row
        self.direction = direction
    }
}

public final class Bounds {
    public var top = 999
    public var right = 0
    public var bottom = 0
    public var left = 999

    public func update(column: Int, row: Int) {
        top = min(top, row)
        right = max(right, column)
        bottom = max(bottom, row)
        left = min(left, column)
    }

    public func clean() {
        top = 999
        right = 0
        bottom = 0
        left = 999
    }

    public func center() -> (x: Int, y: Int) {
        ((left + right) / 2, (top + bottom) / 2)
    }

    public func width() -> Int {
        return right - left + 1
    }

    public func height() -> Int {
        return bottom - top + 1
    }
}

public final class WordObj {
    public let string: String
    public let chars: [Character]

    public var totalMatches = 0
    public var effectiveMatches = 0
    public var successfulMatches: [Placement] = []

    public var column = 0
    public var row = 0
    public var direction = 0   // 0 = horizontal, 1 = vertical

    public init(_ value: String) {
        self.string = value
        self.chars = Array(value)
    }
}

@MainActor
func distanceScore(column: Int, row: Int) -> Int {
    let center = bounds.center()
    return abs(column - center.x) + abs(row - center.y)
}

@MainActor
func localDensityScore(column: Int, row: Int, length: Int, direction: Int) -> Int {
    var density = 0
    for offset in -2...(length + 2) {
        let px = direction == 0 ? column + offset : column
        let py = direction == 0 ? row : row + offset
        for dx in -1...1 {
            for dy in -1...1 {
                let nx = px + dx
                let ny = py + dy
                if nx >= 0, ny >= 0, nx < boardSize, ny < boardSize {
                    if board[nx][ny] != nil { density += 1 }
                }
            }
        }
    }
    return density
}

@MainActor
func directionBalanceBonus(direction: Int) -> Int {
    let horizontal = wordsActive.filter { $0.direction == 0 }.count
    let vertical = wordsActive.count - horizontal

    if direction == 0 && horizontal > vertical { return -5 }
    if direction == 1 && vertical > horizontal { return -5 }
    return 5
}

@MainActor
func chooseBestSpreadPlacement(
    _ placements: [Placement],
    wordLength: Int
) -> Placement {

    let scored = placements.map { placement -> (Placement, Int) in

        let dist = distanceScore(column: placement.column, row: placement.row) * 3
        let density = localDensityScore(column: placement.column, row: placement.row,
                                        length: wordLength, direction: placement.direction) * 4
        let dirBonus = directionBalanceBonus(direction: placement.direction)

        return (placement, dist - density + dirBonus)
    }

    guard let bestScore = scored.map({ $0.1 }).max() else { return Placement(column: 12, row: 12, direction: 0) }
    let bestCandidates = scored.filter { $0.1 >= bestScore - 3 }
    return bestCandidates.randomElement()?.0 ?? Placement(column: 12, row: 12, direction: 0)
}

@MainActor
func isCompactCrossword() -> Bool {
    let width = bounds.width()
    let height = bounds.height()

    // Crossword should fit in 9x9 grid
    if width > 9 || height > 9 {
        return false
    }

    let wordCount = wordsActive.count
    if wordCount < 3 {
        return false
    }

    let usedCells = board.flatMap { $0 }.compactMap { $0 }.count
    let gridArea = width * height
    let density = Double(usedCells) / Double(gridArea)

    return density >= 0.20 && density <= 0.90
}

@MainActor public func cleanVars() {
    bounds.clean()
    wordBank.removeAll()
    wordsActive.removeAll()

    board = Array(
        repeating: Array(repeating: nil, count: boardSize),
        count: boardSize
    )
}

@MainActor func prepareBoard() {
    wordBank = wordArr.map { WordObj($0) }

    for index in wordBank.indices {
        let wA = wordBank[index]
        for cA in wA.chars {
            for index2 in wordBank.indices where index != index2 {
                let wB = wordBank[index2]
                for cB in wB.chars where cA == cB {
                    wA.totalMatches += 1
                }
            }
        }
    }
}

@MainActor func populateBoard() -> Bool {
    prepareBoard()
    return wordBank.indices.allSatisfy { _ in addWordToBoard() }
}

@MainActor
func addWordToBoard() -> Bool {

    var curIndex = -1
    var minMatchDiff = Int.max

    if wordsActive.isEmpty {

        curIndex = wordBank.indices.min { wordBank[$0].totalMatches < wordBank[$1].totalMatches } ?? 0
        wordBank[curIndex].successfulMatches = [Placement(column: 12, row: 12, direction: 0)]

    } else {

        for index in wordBank.indices {
            let curWord = wordBank[index]
            curWord.effectiveMatches = 0
            curWord.successfulMatches.removeAll()

            for (charIndex, curChar) in curWord.chars.enumerated() {
                for testWord in wordsActive {
                    for (testCharIndex, testChar) in testWord.chars.enumerated()
                        where curChar == testChar {

                        curWord.effectiveMatches += 1
                        var crossColumn = testWord.column
                        var crossRow = testWord.row
                        let crossDirection = testWord.direction == 0 ? 1 : 0

                        if testWord.direction == 0 {
                            crossColumn += testCharIndex
                            crossRow -= charIndex
                        } else {
                            crossRow += testCharIndex
                            crossColumn -= charIndex
                        }

                        if isValidPlacement(word: curWord, column: crossColumn, row: crossRow, direction: crossDirection) {
                            curWord.successfulMatches.append(Placement(column: crossColumn, row: crossRow, direction: crossDirection))
                        }
                    }
                }
            }

            let diff = curWord.totalMatches - curWord.effectiveMatches
            if diff < minMatchDiff && !curWord.successfulMatches.isEmpty {
                minMatchDiff = diff
                curIndex = index
            }
        }
    }

    if curIndex == -1 { return false }

    let word = wordBank.remove(at: curIndex)
    wordsActive.append(word)

    let match = chooseBestSpreadPlacement(word.successfulMatches, wordLength: word.chars.count)

    word.column = match.column
    word.row = match.row
    word.direction = match.direction

    for charOffset in word.chars.indices {
        let col = word.direction == 0 ? word.column + charOffset : word.column
        let row = word.direction == 0 ? word.row : word.row + charOffset
        board[col][row] = word.chars[charOffset]
        bounds.update(column: col, row: row)
    }

    return true
}

@MainActor
func isValidPlacement(word: WordObj, column: Int, row: Int, direction: Int) -> Bool {
    let length = word.chars.count

    for index in 0..<length {
        let px = direction == 0 ? column + index : column
        let py = direction == 0 ? row : row + index

        if px < 0 || py < 0 || px >= boardSize || py >= boardSize {
            return false
        }

        if let existing = board[px][py], existing != word.chars[index] {
            return false
        }
    }

    return true
}

@MainActor
public func generateCrossword(words: [String]) -> ([[Character?]], [WordObj]) {

    wordArr = words.filter { $0.count >= 4 && $0.count <= 8 }
    wordArr = Array(wordArr.prefix(6))  // Max 6 words

    guard wordArr.count >= 3 else {
        return ([], [])
    }

    var success = false
    var attempts = 0
    let maxAttempts = 30

    while !success && attempts < maxAttempts {
        cleanVars()
        success = populateBoard()

        if success {
            success = isCompactCrossword()
        }

        attempts += 1
    }

    return success ? (board, wordsActive) : ([], [])
}

@MainActor
public func generateUniqueCrosswords(
    from items: [CrosswordData],
    count: Int
) -> [([String], [String: String])] {

    var puzzles: [([String], [String: String])] = []
    var usedCombinations: Set<String> = []

    for _ in 0..<count {
        var attempts = 0
        var foundUnique = false

        while !foundUnique && attempts < 20 {

            let shuffled = items.shuffled()
            let subset = Array(shuffled.prefix(min(6, shuffled.count)))

            let words = subset.map { $0.name }
            let clues = Dictionary(uniqueKeysWithValues: subset.map { ($0.name, $0.clue) })

            let signature = words.sorted().joined()

            if !usedCombinations.contains(signature) {

                let (_, placedWords) = generateCrossword(words: words)

                if !placedWords.isEmpty && placedWords.count >= 3 {
                    puzzles.append((words, clues))
                    usedCombinations.insert(signature)
                    foundUnique = true
                }
            }

            attempts += 1
        }
    }

    return puzzles
}
