//
//  DailyGameManager.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 25/03/26.
//

import Foundation

// MARK: - Game Types (Safer than strings)
enum GameType: String, CaseIterable {
    case wordle = "Wordle"
    case crossword
    case scenario
    case evaluate = "Evaluate"
}

// MARK: - Data Model
// MARK: - Data Model
struct DailyGameState: Codable {
    var lastPlayedDate: String
    var playedGames: [String]  // Use Array instead of Set for safe Codable
    var streak: Int

    // Convenience
    func hasPlayed(_ game: GameType) -> Bool {
        return playedGames.contains(game.rawValue)
    }

    var hasPlayedAnyGame: Bool {
        return !playedGames.isEmpty
    }
}

// MARK: - Manager
class DailyGameManager {

    static let shared = DailyGameManager()
    private let key = "dailyGameState"

    private init() {}

    // MARK: - Public APIs

    /// Check if a game can be played today
    func canPlay(_ game: GameType) -> Bool {
        let state = loadState()
        return !state.hasPlayed(game)
    }

    func markGamePlayed(_ game: GameType) {
        var state = loadState()

        // Already played this game today — no-op
        guard !state.hasPlayed(game) else { return }

        // First game of the day → increment streak
        if !state.hasPlayedAnyGame {
            state.streak += 1
        }

        state.playedGames.append(game.rawValue)
        state.lastPlayedDate = todayString()

        saveState(state)
    }

    /// Get current streak
    func getStreak() -> Int {
        return loadState().streak
    }

    /// Get all played games today
    func getPlayedGames() -> [String] {
        return loadState().playedGames
    }

    /// Reset manually (optional, for testing)
    func resetAll() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    // MARK: - Core Logic

    private func loadState() -> DailyGameState {
        let today = todayString()

        if let data = UserDefaults.standard.data(forKey: key),
           let state = try? JSONDecoder().decode(DailyGameState.self, from: data) {

            // ✅ Same day → keep everything
            if state.lastPlayedDate == today {
                return state
            }

            // 🔁 New day
            if isYesterday(state.lastPlayedDate) {
                // Continue streak
                return DailyGameState(
                    lastPlayedDate: today,
                    playedGames: [],
                    streak: state.streak
                )
            } else {
                // ❌ Missed a day → reset streak
                return DailyGameState(
                    lastPlayedDate: today,
                    playedGames: [],
                    streak: 0
                )
            }
        }

        // First-time user
        return DailyGameState(
            lastPlayedDate: today,
            playedGames: [],
            streak: 0
        )
    }

    private func saveState(_ state: DailyGameState) {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // MARK: - Date Helpers

    private func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private func isYesterday(_ dateString: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        guard let date = formatter.date(from: dateString),
              let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
            return false
        }

        return Calendar.current.isDate(date, inSameDayAs: yesterday)
    }
}
