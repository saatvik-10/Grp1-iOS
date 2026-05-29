//
//  dailyPuzzle.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 05/02/26.
//

import Foundation

struct DailyPuzzle: Codable {
    let sector: String
    let companies: [Company]
    let visibleIndicators: [IndicatorValue]
    let twistIndicators: [IndicatorValue]
    let results: [Result1]
}

extension DailyPuzzle {

    func bestCompanyId() -> String? {
        // Use results (ground truth) to decide best company
        let best = results.max(by: { $0.returnPercent < $1.returnPercent })
        return best?.companyId
    }
}

// extension DailyPuzzle {
//
//    func calculateScores() -> [CompanyScore] {
//        var result: [CompanyScore] = []
//
//        for company in companies {
//
//            let indicatorsForCompany = (visibleIndicators + twistIndicators)
//                .filter { $0.companyId == company.id }
//
//            var pillarScores: [Pillar: Double] = [:]
//            var total: Double = 0
//
//            for indicator in indicatorsForCompany {
//                let score = scoreForIndicator(indicator)
//                pillarScores[indicator.pillar, default: 0] += score
//                total += score
//            }
//
//            result.append(
//                CompanyScore(
//                    companyId: company.id,
//                    totalScore: total,
//                    breakdown: pillarScores
//                )
//            )
//        }
//
//        return result.sorted { $0.totalScore > $1.totalScore }
//    }
//    
//    func bestCompanyId() -> String? {
//            let scores = calculateScores()
//            return scores.first?.companyId
//        }
//
//    private func scoreForIndicator(_ indicator: IndicatorValue) -> Double {
//
//        let cleaned = indicator.displayValue
//            .replacingOccurrences(of: "%", with: "")
//            .replacingOccurrences(of: "₹", with: "")
//            .trimmingCharacters(in: .whitespaces)
//
//        let numeric = Double(cleaned) ?? 0
//
//        switch indicator.pillar {
//        case .growthConsistency:
//            return numeric * 1.0
//
//        case .financialStrength:
//            return numeric * 0.8
//
//        case .debtLevels:
//            return max(0, 100 - numeric) * 0.6
//
//        case .valuation:
//            return max(0, 100 - numeric) * 0.7
//        }
//    }
// }
