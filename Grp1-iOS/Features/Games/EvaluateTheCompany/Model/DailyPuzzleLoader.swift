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
<<<<<<< HEAD
        var puzzle: DailyPuzzle
        
=======

>>>>>>> 21a9307f7428d267491398cd043a445447339b54
        // 1. Try cache
        if let cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let cacheFile = cacheURL.appendingPathComponent("generated_puzzle.json")
            if let data = try? Data(contentsOf: cacheFile),
               let cachedPuzzle = try? JSONDecoder().decode(DailyPuzzle.self, from: data) {
                puzzle = cachedPuzzle
                return DailyPuzzle(
                    sector: puzzle.sector,
                    companies: puzzle.companies.shuffled(),
                    visibleIndicators: puzzle.visibleIndicators,
                    twistIndicators: puzzle.twistIndicators,
                    results: puzzle.results
                )
            }
        }

        // 2. Fallback to bundle
        guard
            let url = Bundle.main.url(forResource: "daily_puzzle", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let bundlePuzzle = try? JSONDecoder().decode(DailyPuzzle.self, from: data)
        else {
            fatalError("❌ Failed to load daily_puzzle.json")
        }

        puzzle = bundlePuzzle
        return DailyPuzzle(
            sector: puzzle.sector,
            companies: puzzle.companies.shuffled(),
            visibleIndicators: puzzle.visibleIndicators,
            twistIndicators: puzzle.twistIndicators,
            results: puzzle.results
        )
    }
}
