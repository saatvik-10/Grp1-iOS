//
//  EvaluateGameStateManager.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 29/05/26.
//

import Foundation

struct EvaluateGameState: Codable {
    let date: String             // "yyyy-MM-dd" to ensure state is active only for today!
    let currentStep: String      // "home", "twist", "selection"
    let puzzle: DailyPuzzle
    let flippedCards: [Int]      // Saved card flips
    var selectedCompanyId: String? // Saved company selection from InvestViewController
}

enum EvaluateGameStatus: String {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case pausedOrQuit = "Paused/Quit"
    case completedToday = "Completed Today"
    case availableTomorrow = "Available Tomorrow"
}

class EvaluateGameStateManager {
    static let shared = EvaluateGameStateManager()
    private let stateKey = "evaluateGameState"

    private init() {}

    private func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    func saveState(step: String, puzzle: DailyPuzzle, flippedCards: Set<Int> = [], selectedCompanyId: String? = nil) {
        let state = EvaluateGameState(
            date: todayString(),
            currentStep: step,
            puzzle: puzzle,
            flippedCards: Array(flippedCards),
            selectedCompanyId: selectedCompanyId
        )
        do {
            let data = try JSONEncoder().encode(state)
            UserDefaults.standard.set(data, forKey: stateKey)
            print("💾 Saved Evaluate Game State: step=\(step), date=\(state.date), selectedCompanyId=\(selectedCompanyId ?? "nil")")
        } catch {
            print("❌ Failed to save Evaluate Game State: \(error)")
        }
    }

    func loadState() -> EvaluateGameState? {
        guard let data = UserDefaults.standard.data(forKey: stateKey),
              let state = try? JSONDecoder().decode(EvaluateGameState.self, from: data) else {
            return nil
        }

        // Ensure state is from today
        if state.date == todayString() {
            return state
        } else {
            // State is stale, clear it
            clearState()
            return nil
        }
    }

    func clearState() {
        UserDefaults.standard.removeObject(forKey: stateKey)
        print("🗑️ Cleared Evaluate Game State")
    }

    var hasSavedState: Bool {
        return loadState() != nil
    }

    func getDetailedStatus() -> EvaluateGameStatus {
        if !DailyGameManager.shared.canPlay(.evaluate) {
            return .completedToday
        }
        if hasSavedState {
            return .pausedOrQuit
        }
        return .notStarted
    }
}
