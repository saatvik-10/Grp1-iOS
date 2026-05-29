//
//  DailyPuzzle+ResultData.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 27/02/26.
//

import Foundation
import UIKit

// MARK: - Data shapes the Result screen consumes

struct ResultScreenData {
    let isCorrect: Bool

    // Your pick
    let selectedCompany: Company
    let selectedRank: Int          // 1-based, among all companies

    // Twist indicator
    let twistIndicatorName: String
    let twistDefinition: String
    let twistFormula: String

    // Correlated indicators (only the linked ones — same Pillar as twist)
    let correlatedIndicators: [String]   // indicator names

    // Best company
    let bestCompany: Company
    let bestResult: Result1
    let bestReasons: [String]

    // Full ranking (sorted best → worst by returnPercent)
    let rankedResults: [RankedEntry]
}

struct RankedEntry {
    let rank: Int
    let company: Company
    let result: Result1
    let twistValue: String          // displayValue from twistIndicators
    let isUserPick: Bool
    let isBest: Bool
}

struct IndicatorDefinition {
    let definition: String
    let formula: String
    let icon: String
    let iconBg: UIColor
}

// MARK: - Extension

extension DailyPuzzle {

    func buildResultScreenData(selectedCompanyId: String) -> ResultScreenData? {

        // 1. Best company by returnPercent
        guard
            let bestResult  = results.max(by: { $0.returnPercent < $1.returnPercent }),
            let bestCompany = companies.first(where: { $0.id == bestResult.companyId }),
            let selectedCompany = companies.first(where: { $0.id == selectedCompanyId })
        else { return nil }

        let isCorrect = selectedCompanyId == bestResult.companyId

        // 2. Twist indicator name (first twistIndicator's name — same name for all companies)
        let twistName = twistIndicators.first?.indicatorName ?? "Twist Indicator"
        let twistPillar = twistIndicators.first?.pillar ?? .growthConsistency

        // 3. Correlated indicators = visibleIndicators that share the same Pillar as the twist
        let correlatedNames: [String] = Array(
            Set(
                visibleIndicators
                    .filter { $0.pillar == twistPillar }
                    .map { $0.indicatorName }
            )
        ).sorted()

        // 4. Full ranking sorted by returnPercent descending
        let sortedResults = results.sorted { $0.returnPercent > $1.returnPercent }
        let rankedEntries: [RankedEntry] = sortedResults.enumerated().compactMap { idx, res in
            guard let company = companies.first(where: { $0.id == res.companyId }) else { return nil }
            let twistVal = twistIndicators.first(where: { $0.companyId == res.companyId })?.displayValue ?? "-"
            return RankedEntry(
                rank: idx + 1,
                company: company,
                result: res,
                twistValue: twistVal,
                isUserPick: res.companyId == selectedCompanyId,
                isBest: res.companyId == bestResult.companyId
            )
        }

        // 5. Selected company rank
        let selectedRank = rankedEntries.first(where: { $0.company.id == selectedCompanyId })?.rank ?? rankedEntries.count

        let definitions = DailyPuzzle.getAllIndicatorDefinitions()

        let def = definitions[twistName] ?? IndicatorDefinition(
            definition: "\(twistName) is a key financial metric that reveals the underlying quality of a company's performance.",

            formula: "Refer to the financial glossary for the exact formula.",
            icon: "chart.bar",
            iconBg: .systemGray5
        )

        // 7. Best company reasons (driven by data)
        let bestTwistVal = twistIndicators.first(where: { $0.companyId == bestResult.companyId })?.displayValue ?? "-"
        let reasons: [String] = [
            "Highest return of \(bestResult.returnPercent)% among all companies in this sector.",
            "\(twistName) of \(bestTwistVal) — the twist indicator confirmed sustained performance, not a one-off.",
            bestResult.explanation,
            "Outperformed peers consistently across both visible and twist indicators."
        ]

        return ResultScreenData(
            isCorrect: isCorrect,
            selectedCompany: selectedCompany,
            selectedRank: selectedRank,
            twistIndicatorName: twistName,
            twistDefinition: def.definition,
            twistFormula: def.formula,
            correlatedIndicators: correlatedNames,
            bestCompany: bestCompany,
            bestResult: bestResult,
            bestReasons: reasons,
            rankedResults: rankedEntries
        )
    }

    static func getAllIndicatorDefinitions() -> [String: IndicatorDefinition] {
        growthDefinitions()
            .merging(financialStrengthDefinitions()) { $1 }
            .merging(debtLevelsDefinitions()) { $1 }
            .merging(valuationDefinitions()) { $1 }
    }

    private static func growthDefinitions() -> [String: IndicatorDefinition] {
        let bg = UIColor(red: 0.90, green: 0.95, blue: 0.98, alpha: 1)
        return [
            "Revenue Growth YoY": IndicatorDefinition(
                definition: "Measures the year-over-year percentage increase in total sales.",
                formula: "Revenue Growth = (Revenue This Year - Revenue Last Year) / Revenue Last Year",
                icon: "chart.line.uptrend.xyaxis", iconBg: bg
            ),
            "EPS Growth (YoY)": IndicatorDefinition(
                definition: "Earnings Per Share growth year-over-year measures how fast a company's profit per share is growing.",
                formula: "EPS Growth = ( EPS This Year − EPS Last Year ) ÷ EPS Last Year × 100",
                icon: "arrow.up.right.circle", iconBg: bg
            ),
            "5Y Sales CAGR": IndicatorDefinition(
                definition: "Compound Annual Growth Rate over 5 years smooths out yearly noise to show the real growth trajectory.",
                formula: "CAGR = ( End Value ÷ Start Value ) ^ (1 ÷ 5) − 1",
                icon: "chart.line.uptrend.xyaxis", iconBg: bg
            ),
            "5Y Profit CAGR": IndicatorDefinition(
                definition: "Compound Annual Growth Rate of profit over 5 years. Shows long term profitability trend.",
                formula: "CAGR = ( End Profit ÷ Start Profit ) ^ (1 ÷ 5) − 1",
                icon: "chart.line.uptrend.xyaxis", iconBg: bg
            ),
            "Operating CF Growth": IndicatorDefinition(
                definition: "Growth in cash generated from normal business operations.",
                formula: "OCF Growth = (OCF This Year - OCF Last Year) / OCF Last Year",
                icon: "dollarsign.circle", iconBg: bg
            )
        ]
    }

    private static func financialStrengthDefinitions() -> [String: IndicatorDefinition] {
        let bg = UIColor(red: 0.91, green: 0.96, blue: 0.87, alpha: 1)
        return [
            "Net Profit Margin": IndicatorDefinition(
                definition: "How much profit a company keeps from every ₹100 of revenue. Higher is generally better.",
                formula: "Net Profit Margin = Net Profit ÷ Revenue × 100",
                icon: "percent", iconBg: bg
            ),
            "Return on Equity": IndicatorDefinition(
                definition: "Measures how effectively management is using a company's assets to create profits.",
                formula: "ROE = Net Income / Shareholders' Equity",
                icon: "arrow.uturn.up", iconBg: bg
            ),
            "Return on Capital Employed": IndicatorDefinition(
                definition: "Measures a company's profitability and the efficiency with which its capital is used.",
                formula: "ROCE = EBIT / Capital Employed",
                icon: "arrow.uturn.up", iconBg: bg
            ),
            "Operating Margin": IndicatorDefinition(
                definition: "Measures how much profit a company makes on a dollar of sales after paying for variable costs.",
                formula: "Operating Margin = Operating Income / Revenue",
                icon: "percent", iconBg: bg
            ),
            "Asset Turnover": IndicatorDefinition(
                definition: "Measures the value of a company's sales or revenues relative to the value of its assets.",
                formula: "Asset Turnover = Total Sales / Average Assets",
                icon: "arrow.triangle.2.circlepath", iconBg: bg
            )
        ]
    }

    private static func debtLevelsDefinitions() -> [String: IndicatorDefinition] {
        let bg = UIColor(red: 0.98, green: 0.93, blue: 0.85, alpha: 1)
        return [
            "Debt-to-Equity": IndicatorDefinition(
                definition: "How much the company relies on debt vs its own funds. A lower ratio means less financial risk.",
                formula: "Debt-to-Equity = Total Debt / Total Equity",
                icon: "scalemass", iconBg: bg
            ),
            "Interest Coverage": IndicatorDefinition(
                definition: "Measures how easily a company can pay interest on its outstanding debt.",
                formula: "Interest Coverage = EBIT / Interest Expense",
                icon: "shield", iconBg: bg
            ),
            "Debt-to-EBITDA": IndicatorDefinition(
                definition: "Measures a company's ability to pay off its incurred debt.",
                formula: "Debt-to-EBITDA = Total Debt / EBITDA",
                icon: "banknote", iconBg: bg
            ),
            "Current Ratio": IndicatorDefinition(
                definition: "Measures a company's ability to pay short-term obligations or those due within one year.",
                formula: "Current Ratio = Current Assets / Current Liabilities",
                icon: "clock.arrow.circlepath", iconBg: bg
            ),
            "FCF-to-Debt": IndicatorDefinition(
                definition: "Measures how much free cash flow is available to cover debt.",
                formula: "FCF-to-Debt = Free Cash Flow / Total Debt",
                icon: "banknote.fill", iconBg: bg
            )
        ]
    }

    private static func valuationDefinitions() -> [String: IndicatorDefinition] {
        let bg = UIColor(red: 0.98, green: 0.91, blue: 0.94, alpha: 1)
        return [
            "P/E Ratio": IndicatorDefinition(
                definition: "Price investors pay for every ₹1 of earnings. High P/E can mean growth expectations are already priced in.",
                formula: "P/E Ratio = Share Price / Earnings Per Share",
                icon: "tag", iconBg: bg
            ),
            "Price-to-Book": IndicatorDefinition(
                definition: "Compares a company's market value to its book value.",
                formula: "P/B Ratio = Market Price per Share / Book Value per Share",
                icon: "book.closed", iconBg: bg
            ),
            "EV/EBITDA": IndicatorDefinition(
                definition: "Compares a company's Enterprise Value to its Earnings Before Interest, Taxes, Depreciation, and Amortization.",
                formula: "EV/EBITDA = Enterprise Value / EBITDA",
                icon: "building.columns", iconBg: bg
            ),
            "Price-to-Sales": IndicatorDefinition(
                definition: "Compares a company's stock price to its revenues.",
                formula: "P/S Ratio = Market Capitalization / Total Sales",
                icon: "cart", iconBg: bg
            ),
            "PEG Ratio": IndicatorDefinition(
                definition: "A stock's price-to-earnings ratio divided by the growth rate of its earnings.",
                formula: "PEG Ratio = (P/E Ratio) / Earnings Growth Rate",
                icon: "chart.bar.xaxis", iconBg: bg
            )
        ]
    }
}
