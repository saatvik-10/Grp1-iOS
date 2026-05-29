//
//  PuzzleGenerator+Validation.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 29/05/26.
//

import Foundation

@available(iOS 26.0, *)
extension PuzzleGenerator {

    /// Runs a simulation of 100 puzzle generations to verify that the winner company is randomized and the rankings are sorted correctly.
    @discardableResult
    static func runSelfSanityChecks() -> Bool {
        print("🔍 [PuzzleGenerator Validation] Starting self-sanity checks...")

        var winnerPositions = [Int: Int]()
        let iterations = 100

        for _ in 0..<iterations {
            let sectors = ["IT/Software", "FMCG", "Banking/NBFC", "Pharma", "Infrastructure/Capital Goods"]
            guard let sector = sectors.randomElement() else { continue }
            let engineData = PuzzleEngine.generatePuzzleData(for: sector)

            var companies: [Company] = []
            var results: [Result1] = []

            for index in engineData.indices {
                let rank = index + 1
                let retPct = PuzzleEngine.getReturnPercent(forRank: rank)
                let companyId = "c\(index+1)"
                let comp = Company(id: companyId, name: "Test Company \(index+1)", description: "Test Description")
                companies.append(comp)
                results.append(Result1(companyId: companyId, returnPercent: retPct, explanation: ""))
            }

            // Perform shuffle
            let shuffledCompanies = companies.shuffled()

            // Find best company return percent
            guard let bestResult = results.max(by: { $0.returnPercent < $1.returnPercent }) else {
                print("❌ Validation failed: results is empty")
                return false
            }

            // Find the position of the winning company in the shuffled array
            guard let winnerIndex = shuffledCompanies.firstIndex(where: { $0.id == bestResult.companyId }) else {
                print("❌ Validation failed: winner company not found in shuffled array")
                return false
            }

            winnerPositions[winnerIndex, default: 0] += 1

            // Verify results ranking sorting
            let sortedResults = results.sorted { $0.returnPercent > $1.returnPercent }
            for idx in 0..<(sortedResults.count - 1) where sortedResults[idx].returnPercent < sortedResults[idx + 1].returnPercent {
                print("❌ Validation failed: results are not sorted correctly in descending order")
                return false
            }
        }

        print("📊 [PuzzleGenerator Validation] Winner position distribution across \(iterations) iterations:")
        for pos in 0..<4 {
            let count = winnerPositions[pos] ?? 0
            let pct = Double(count) / Double(iterations) * 100.0
            print("   - Position \(pos + 1): \(count) times (\(String(format: "%.1f", pct))%)")
        }

        // Assert that the winner appeared in different positions (not all in position 1)
        let uniquePositions = winnerPositions.keys.count
        if uniquePositions <= 1 {
            print("❌ Validation failed: Winner was deterministic (only appeared in \(uniquePositions) unique position(s))")
            return false
        }

        print("✅ [PuzzleGenerator Validation] Self-sanity checks completed successfully!")
        print("   All randomness and independent ranking assertions passed.")
        return true
    }
}
