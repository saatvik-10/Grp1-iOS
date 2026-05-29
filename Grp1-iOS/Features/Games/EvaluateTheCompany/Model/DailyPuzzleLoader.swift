//
//  DailyPuzzleLoader.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 05/02/26.
//

import Foundation

final class DailyPuzzleLoader {

    static func loadDailyPuzzle() -> DailyPuzzle {
        let fileManager = FileManager.default

        // 1. Try cache
        if let cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let cacheFile = cacheURL.appendingPathComponent("generated_puzzle.json")
            if let data = try? Data(contentsOf: cacheFile),
               let puzzle = try? JSONDecoder().decode(DailyPuzzle.self, from: data) {
                return puzzle
            }
        }

        // 2. Fallback to bundle
        guard
            let url = Bundle.main.url(forResource: "daily_puzzle", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let puzzle = try? JSONDecoder().decode(DailyPuzzle.self, from: data)
        else {
            fatalError("❌ Failed to load daily_puzzle.json")
        }

        return puzzle
    }
}
