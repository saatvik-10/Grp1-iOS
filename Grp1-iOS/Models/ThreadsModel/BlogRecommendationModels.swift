//
//  BlogRecommendationModels.swift
//  Grp1-iOS
//

import Foundation

// MARK: - User profile (persisted)

struct DynamicUserProfile: Codable {

    var interests: [OnboardingInterest]
    var level: BlogUserLevel

    var tagWeights: [String: Double]

    var seenArticleIDs: Set<String>

    var likedArticleIDs: Set<String>

    init(interests: [OnboardingInterest], level: BlogUserLevel) {
        self.interests = interests
        self.level = level
        self.tagWeights = InterestTagMap.mergedWeights(for: interests)
        self.seenArticleIDs = []
        self.likedArticleIDs = []
    }

    // MARK: Engagement feedback

    mutating func recordLike(article: BlogArticle) {
        likedArticleIDs.insert(article.id)
        reinforceWeights(from: article, multiplier: 1.2)
    }

    mutating func recordBookmark(article: BlogArticle) {
        likedArticleIDs.insert(article.id)
        reinforceWeights(from: article, multiplier: 1.5)
    }

    mutating func recordShare(article: BlogArticle) {
        reinforceWeights(from: article, multiplier: 1.3)
    }

    mutating func recordSkip(article: BlogArticle) {
        reinforceWeights(from: article, multiplier: 0.85)
    }

    mutating func markSeen(articleID: String) {
        seenArticleIDs.insert(articleID)
    }

    // MARK: Weight decay

    mutating func applyWeeklyDecay(decayFactor: Double = 0.97) {
        let baseline = InterestTagMap.mergedWeights(for: interests)
        for key in tagWeights.keys {
            let base = baseline[key] ?? 0
            tagWeights[key] = base + ((tagWeights[key] ?? base) - base) * decayFactor
        }
    }

    private mutating func reinforceWeights(from article: BlogArticle, multiplier: Double) {
        for tag in article.inferredTags {
            guard let currentWeight = tagWeights[tag] else { continue }
            tagWeights[tag] = currentWeight * multiplier
        }
    }
}

// MARK: - Blog article model

struct BlogArticle {
    let id: String
    let title: String
    let body: String
    let category: String
    let publishedAt: Date
    let complexityTier: Int
    var inferredTags: [String]
}

// MARK: - Scoring config

struct ScoringConfig {
    let minConfidence: Double = 0.45
    let exactMatchBoost: Double = 1.0
    let semanticFloor: Double = 0.0
    let freshnessHalfLifeDays: Double = 7.0
    let diversityPenaltyAfter: Int = 2
    let diversityPenaltyFactor: Double = 0.6
}

// MARK: - Output model

struct ScoredArticle {
    let article: BlogArticle
    let baseScore: Double
    let levelMultiplier: Double
    let freshnessScore: Double
    let finalScore: Double
    let matchedTags: [String]

    func debugDescription() -> String {
        """
        [\(String(format: "%.1f", finalScore))] \(article.title.prefix(60))
          base=\(String(format: "%.1f", baseScore))  \
          level\u{00D7}\(String(format: "%.2f", levelMultiplier))  \
          fresh\u{00D7}\(String(format: "%.2f", freshnessScore))
          tags: \(matchedTags.joined(separator: ", "))
        """
    }
}
