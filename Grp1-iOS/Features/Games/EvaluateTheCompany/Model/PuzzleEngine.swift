//
//  PuzzleEngine.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 13/05/26.
//

import Foundation

struct SectorWeights {
    let growth: Double
    let financial: Double
    let debt: Double
    let valuation: Double
}

struct IndicatorSets {
    let growth: Set<String>
    let financial: Set<String>
    let debt: Set<String>
    let valuation: Set<String>
}

struct PuzzleEngine {

    struct BaseVariables {
        var revenueGrowth: Double
        var opMargin: Double
        var debtToEquity: Double
        var assetTurnover: Double
        var capexIntensity: Double
        var peMultiple: Double
    }

    struct GeneratedCompanyData {
        let base: BaseVariables
        let indicators: [String: Double]
        var score: Double = 0.0
    }

    static func generatePuzzleData(for sector: String) -> [GeneratedCompanyData] {
        var attempts = 0
        while attempts < 3 {
            let companies = (0..<4).map { _ in generateBaseVariables(for: sector) }
            var dataList = companies.map {
                GeneratedCompanyData(base: $0, indicators: deriveIndicators(from: $0))
            }

            // Score them
            dataList = scoreCompanies(dataList, in: sector)

            let sorted = dataList.sorted { $0.score > $1.score }
            if let first = sorted.first, let last = sorted.last {
                if first.score - last.score >= 0.20 {
                    return sorted
                }
            }
            attempts += 1
        }

        // Return whatever we have if we fail 3 times
        var fallback = (0..<4).map { _ in generateBaseVariables(for: sector) }
        var dataList = fallback.map {
            GeneratedCompanyData(base: $0, indicators: deriveIndicators(from: $0))
        }
        dataList = scoreCompanies(dataList, in: sector)
        return dataList.sorted { $0.score > $1.score }
    }

    private static func generateBaseVariables(for sector: String) -> BaseVariables {
        let isTech = sector == "IT/Software"
        let isFmcg = sector == "FMCG"
        let isBank = sector == "Banking/NBFC"
        let isPharma = sector == "Pharma"
        let isInfra = sector == "Infrastructure/Capital Goods"

        let rg = isTech ? Double.random(in: 10...25) :
                 isFmcg ? Double.random(in: 8...15) :
                 isBank ? Double.random(in: 12...20) :
                 isPharma ? Double.random(in: 8...18) :
                 Double.random(in: 5...15)

        let om = isTech ? Double.random(in: 18...30) :
                 isFmcg ? Double.random(in: 15...25) :
                 isBank ? Double.random(in: 10...20) :
                 isPharma ? Double.random(in: 20...35) :
                 Double.random(in: 8...14)

        let de = isBank ? Double.random(in: 4.0...8.0) :
                 isTech ? Double.random(in: 0.0...0.3) :
                 isInfra ? Double.random(in: 1.0...2.5) :
                 Double.random(in: 0.1...1.0)

        let at = isFmcg ? Double.random(in: 1.5...3.0) :
                 isTech ? Double.random(in: 0.8...1.5) :
                 isBank ? Double.random(in: 0.05...0.15) :
                 Double.random(in: 0.5...1.2)

        let ci = isInfra ? Double.random(in: 8...15) :
                 isTech ? Double.random(in: 1...5) :
                 isPharma ? Double.random(in: 5...10) :
                 Double.random(in: 2...8)

        let pe = isTech ? Double.random(in: 25...45) :
                 isFmcg ? Double.random(in: 35...55) :
                 isBank ? Double.random(in: 10...20) :
                 isPharma ? Double.random(in: 20...40) :
                 Double.random(in: 15...30)

        return BaseVariables(revenueGrowth: rg, opMargin: om, debtToEquity: de, assetTurnover: at, capexIntensity: ci, peMultiple: pe)
    }

    private static func deriveIndicators(from base: BaseVariables) -> [String: Double] {
        let opMargin = base.opMargin
        let revGrowth = base.revenueGrowth
        let ci = base.capexIntensity
        let de = base.debtToEquity
        let pe = base.peMultiple
        let at = base.assetTurnover

        let npm = opMargin * 0.72 * (1 - 0.25)
        let roe = npm * at * (1 + de)
        let roce = opMargin * at
        let intCov = opMargin / max(0.1, (de * 0.08 * 0.5 * 100)) // Scaled for realism
        let ebitda = opMargin + 2.0
        let debtToEbitda = de / max(0.01, (ebitda * at / 100.0))
        let currentRatio = max(0.6, 1.8 - de * 0.3)
        let fcfToDebt = de == 0 ? 999.0 : (opMargin - ci) / 100.0 / de

        let epsGrowth = revGrowth * (1 + (opMargin - 15) / 100.0)
        let salesCagr = revGrowth * 0.88
        let marginLift = 1 + (opMargin - 15) / 100.0
        let profitCagr = revGrowth * 0.88 * marginLift
        let opCfGrowth = max(0, revGrowth - ci * 0.5)

        let pb = pe * (npm / 100.0) * at
        let evEbitda = pe * 0.65
        let ps = pe * (npm / 100.0)
        let peg = pe / max(1.0, revGrowth)

        return [
            "Revenue Growth YoY": revGrowth,
            "EPS Growth (YoY)": epsGrowth,
            "5Y Sales CAGR": salesCagr,
            "5Y Profit CAGR": profitCagr,
            "Operating CF Growth": opCfGrowth,

            "Net Profit Margin": npm,
            "Return on Equity": roe,
            "Return on Capital Employed": roce,
            "Operating Margin": opMargin,
            "Asset Turnover": at,

            "Debt-to-Equity": de,
            "Interest Coverage": intCov,
            "Debt-to-EBITDA": debtToEbitda,
            "Current Ratio": currentRatio,
            "FCF-to-Debt": fcfToDebt,

            "P/E Ratio": pe,
            "Price-to-Book": pb,
            "EV/EBITDA": evEbitda,
            "Price-to-Sales": ps,
            "PEG Ratio": peg
        ]
    }

    private static func scoreCompanies(_ companies: [GeneratedCompanyData], in sector: String) -> [GeneratedCompanyData] {
        let weights = sectorWeights(for: sector)

        let allIndicators = companies.first?.indicators.keys.map { String($0) } ?? []
        let lowerIsBetter = lowerIsBetterSet()

        let sets = IndicatorSets(
            growth: Set(["Revenue Growth YoY", "EPS Growth (YoY)", "5Y Sales CAGR", "5Y Profit CAGR", "Operating CF Growth"]),
            financial: Set(["Net Profit Margin", "Return on Equity", "Return on Capital Employed", "Operating Margin", "Asset Turnover"]),
            debt: Set(["Debt-to-Equity", "Interest Coverage", "Debt-to-EBITDA", "Current Ratio", "FCF-to-Debt"]),
            valuation: Set(["P/E Ratio", "Price-to-Book", "EV/EBITDA", "Price-to-Sales", "PEG Ratio"])
        )

        let normalizedMatrix = normalizeMatrix(companies, allIndicators: allIndicators, lowerIsBetter: lowerIsBetter)
        var scoredCompanies = companies
        computeScores(&scoredCompanies, normalizedMatrix: normalizedMatrix, weights: weights, sets: sets)

        return scoredCompanies
    }

    private static func sectorWeights(for sector: String) -> SectorWeights {
        switch sector {
        case "IT/Software":                return SectorWeights(growth: 0.35, financial: 0.30, debt: 0.10, valuation: 0.25)
        case "FMCG":                       return SectorWeights(growth: 0.25, financial: 0.35, debt: 0.15, valuation: 0.25)
        case "Banking/NBFC":               return SectorWeights(growth: 0.20, financial: 0.25, debt: 0.40, valuation: 0.15)
        case "Pharma":                     return SectorWeights(growth: 0.30, financial: 0.35, debt: 0.15, valuation: 0.20)
        case "Infrastructure/Capital Goods": return SectorWeights(growth: 0.30, financial: 0.20, debt: 0.35, valuation: 0.15)
        default:                           return SectorWeights(growth: 0.25, financial: 0.25, debt: 0.25, valuation: 0.25)
        }
    }

    private static func lowerIsBetterSet() -> Set<String> {
        Set(["Debt-to-Equity", "Debt-to-EBITDA", "P/E Ratio",
             "Price-to-Book", "EV/EBITDA", "Price-to-Sales", "PEG Ratio"])
    }

    private static func normalizeMatrix(
        _ companies: [GeneratedCompanyData],
        allIndicators: [String],
        lowerIsBetter: Set<String>
    ) -> [[String: Double]] {
        var normalizedMatrix: [[String: Double]] = companies.map { _ in [:] }

        for key in allIndicators {
            let values = companies.map { $0.indicators[key] ?? 0.0 }
            let minVal = values.min() ?? 0.0
            let maxVal = values.max() ?? 1.0
            let range = max(0.0001, maxVal - minVal)

            for (index, val) in values.enumerated() {
                var norm = (val - minVal) / range
                if lowerIsBetter.contains(key) {
                    norm = 1.0 - norm
                }
                normalizedMatrix[index][key] = norm
            }
        }

        return normalizedMatrix
    }

    private static func computeScores(
        _ scoredCompanies: inout [GeneratedCompanyData],
        normalizedMatrix: [[String: Double]],
        weights: SectorWeights,
        sets: IndicatorSets
    ) {
        for index in 0..<scoredCompanies.count {
            var gScore = 0.0, fScore = 0.0, dScore = 0.0, vScore = 0.0
            for key in sets.growth { gScore += normalizedMatrix[index][key] ?? 0.0 }
            for key in sets.financial { fScore += normalizedMatrix[index][key] ?? 0.0 }
            for key in sets.debt { dScore += normalizedMatrix[index][key] ?? 0.0 }
            for key in sets.valuation { vScore += normalizedMatrix[index][key] ?? 0.0 }

            gScore /= 5.0
            fScore /= 5.0
            dScore /= 5.0
            vScore /= 5.0

            let composite = (gScore * weights.growth) + (fScore * weights.financial)
                + (dScore * weights.debt) + (vScore * weights.valuation)
            scoredCompanies[index].score = composite
        }
    }

    static func formatIndicatorValue(_ name: String, value: Double) -> String {
        let percentages = Set(["Revenue Growth YoY", "EPS Growth (YoY)", "5Y Sales CAGR",
                               "5Y Profit CAGR", "Operating CF Growth", "Net Profit Margin",
                               "Return on Equity", "Return on Capital Employed", "Operating Margin"])
        let ratios = Set(["Asset Turnover", "Debt-to-Equity", "Interest Coverage",
                          "Debt-to-EBITDA", "Current Ratio", "Price-to-Book",
                          "Price-to-Sales", "PEG Ratio", "FCF-to-Debt"])
        let multiples = Set(["P/E Ratio", "EV/EBITDA"])

        if percentages.contains(name) {
            return String(format: "%.1f%%", value)
        } else if multiples.contains(name) {
            return String(format: "%.1f", value)
        } else if ratios.contains(name) {
            return String(format: "%.2f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }

    static func getReturnPercent(forRank rank: Int) -> Int {
        switch rank {
        case 1: return Int.random(in: 28...42)
        case 2: return Int.random(in: 14...24)
        case 3: return Int.random(in: 5...13)
        case 4: return Int.random(in: -3...4)
        default: return 0
        }
    }
}
