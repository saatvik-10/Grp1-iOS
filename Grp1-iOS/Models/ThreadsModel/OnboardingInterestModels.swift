//
//  OnboardingInterestModels.swift
//  Grp1-iOS
//

import Foundation

// MARK: - Onboarding models

/// Mirrors OnboardingInterestModel from your app
enum OnboardingInterest: String, CaseIterable, Codable {
    case indianEconomy      = "Indian Economy"
    case personalFinance    = "Personal Finance"
    case governmentPolicy   = "Government and Policy"
    case stockMarkets       = "Stock Markets"
    case realEstate         = "Real Estate Economics"
    case globalEconomy      = "Global Economy"
    case bankingCredit      = "Banking and credit"
    case crypto             = "Crypto"
}

enum BlogUserLevel: String, Codable {
    case beginner       = "Beginner"
    case intermediate   = "Intermediate"
    case advanced       = "Advanced"

    var complexityMultiplier: Double {
        switch self {
        case .beginner:     return 1.4
        case .intermediate: return 1.0
        case .advanced:     return 1.3
        }
    }

    var preferredComplexityTier: Int {
        switch self {
        case .beginner:     return 0
        case .intermediate: return 1
        case .advanced:     return 2
        }
    }
}

// MARK: - Tag taxonomy

struct InterestTagMap {

    static let map: [OnboardingInterest: [String: Double]] = [

        .indianEconomy: [
            "inflation": 15,
            "gdp": 14,
            "rbi": 13,
            "economy": 12,
            "monetary policy": 13,
            "interest rate": 11,
            "consumption": 10,
            "cpi": 9,
            "fiscal deficit": 9,
            "economic growth": 10,
            "india": 6,
            "budget": 8
        ],

        .personalFinance: [
            "personal finance": 16,
            "savings": 14,
            "investment": 13,
            "mutual fund": 12,
            "tax": 11,
            "insurance": 10,
            "retirement": 10,
            "sip": 9,
            "portfolio": 9,
            "wealth": 8,
            "loan": 7,
            "credit score": 8
        ],

        .governmentPolicy: [
            "government": 14,
            "policy": 14,
            "regulation": 13,
            "reform": 12,
            "budget": 11,
            "public spending": 11,
            "subsidy": 10,
            "tax policy": 10,
            "rbi": 9,
            "sebi": 9,
            "compliance": 8
        ],

        .stockMarkets: [
            "stock market": 16,
            "nifty": 14,
            "sensex": 14,
            "equity": 13,
            "ipo": 12,
            "shares": 12,
            "market cap": 11,
            "earnings": 11,
            "dividend": 10,
            "bull market": 10,
            "bear market": 10,
            "technical analysis": 9
        ],

        .realEstate: [
            "real estate": 16,
            "housing": 14,
            "property": 13,
            "mortgage": 12,
            "home loan": 12,
            "interest rate": 10,
            "construction": 9,
            "rent": 8,
            "realty": 9,
            "demand": 7,
            "supply": 7
        ],

        .globalEconomy: [
            "global economy": 15,
            "trade": 13,
            "exports": 12,
            "imports": 12,
            "tariff": 11,
            "fed": 11,
            "dollar": 10,
            "recession": 10,
            "geopolitics": 9,
            "oil price": 10,
            "currency": 9,
            "world bank": 8
        ],

        .bankingCredit: [
            "banking": 15,
            "credit": 14,
            "loan": 13,
            "npa": 12,
            "credit growth": 12,
            "hdfc bank": 10,
            "sbi": 10,
            "rbi": 11,
            "digital banking": 10,
            "fintech": 9,
            "financial sector": 9,
            "liquidity": 8
        ],

        .crypto: [
            "crypto": 16,
            "bitcoin": 15,
            "blockchain": 14,
            "web3": 13,
            "defi": 12,
            "nft": 11,
            "ethereum": 12,
            "digital assets": 11,
            "token": 10,
            "stablecoin": 10,
            "regulation": 8
        ]
    ]

    static func mergedWeights(for interests: [OnboardingInterest]) -> [String: Double] {
        var merged: [String: Double] = [:]
        for interest in interests {
            for (tag, weight) in map[interest] ?? [:] {
                merged[tag, default: 0] += weight
            }
        }
        return merged
    }

    static func allTags(for interests: [OnboardingInterest]) -> [String] {
        Array(mergedWeights(for: interests).keys)
    }
}
