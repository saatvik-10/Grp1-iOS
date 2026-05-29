import Foundation

class WordHistoryManager {
    static let shared = WordHistoryManager()
    
    private let wordleKey = "wordlePlayedWordsHistory"
    private let crosswordKey = "crosswordPlayedWordsHistory"
    
    private init() {}
    
    // MARK: - Wordle
    
    func hasPlayedWordleWord(_ word: String) -> Bool {
        let played = getWordlePlayedWords()
        return played.contains(word.lowercased())
    }
    
    func markWordleWordPlayed(_ word: String) {
        var played = getWordlePlayedWords()
        played.insert(word.lowercased())
        if let data = try? JSONEncoder().encode(Array(played)) {
            UserDefaults.standard.set(data, forKey: wordleKey)
        }
    }
    
    private func getWordlePlayedWords() -> Set<String> {
        if let data = UserDefaults.standard.data(forKey: wordleKey),
           let array = try? JSONDecoder().decode([String].self, from: data) {
            return Set(array)
        }
        return []
    }
    
    // MARK: - Crossword
    
    func hasPlayedCrosswordWordRecently(_ word: String, withinDays days: Int = 6) -> Bool {
        let history = getCrosswordHistory()
        guard let playedDate = history[word.uppercased()] else { return false }
        
        let diff = Calendar.current.dateComponents([.day], from: playedDate, to: Date()).day ?? 0
        return diff < days
    }
    
    func markCrosswordWordsPlayed(_ words: [String]) {
        var history = getCrosswordHistory()
        let now = Date()
        for word in words {
            history[word.uppercased()] = now
        }
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: crosswordKey)
        }
    }
    
    private func getCrosswordHistory() -> [String: Date] {
        if let data = UserDefaults.standard.data(forKey: crosswordKey),
           let dict = try? JSONDecoder().decode([String: Date].self, from: data) {
            return dict
        }
        return [:]
    }
}
