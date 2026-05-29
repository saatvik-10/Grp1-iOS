//
//  BlogRecommendationEngine.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 18/03/26.
//

import Foundation
import NaturalLanguage

// MARK: - Recommendation engine

final class BlogRecommendationEngine {

    static let shared = BlogRecommendationEngine()
    private init() {}

    private let config = ScoringConfig()
    private lazy var embedding: NLEmbedding? = NLEmbedding.wordEmbedding(for: .english)

    // MARK: - Main API

    func recommend(
        articles: [BlogArticle],
        profile: inout DynamicUserProfile,
        limit: Int = 20,
        excludeSeen: Bool = true
    ) -> [ScoredArticle] {

        let pool = excludeSeen
            ? articles.filter { !profile.seenArticleIDs.contains($0.id) }
            : articles

        var scored: [ScoredArticle] = pool.map { article in
            let (baseScore, matchedTags) = computeBaseScore(article: article, profile: profile)
            let levelMult   = levelMultiplier(article: article, level: profile.level)
            let freshness   = freshnessScore(publishedAt: article.publishedAt)
            let final       = baseScore * levelMult * freshness

            var mutable = article
            mutable.inferredTags = matchedTags
            return ScoredArticle(
                article: mutable,
                baseScore: baseScore,
                levelMultiplier: levelMult,
                freshnessScore: freshness,
                finalScore: final,
                matchedTags: matchedTags
            )
        }

        scored.sort { $0.finalScore > $1.finalScore }
        let diversified = applyDiversityFilter(scored: scored)
        return Array(diversified.prefix(limit))
    }

    // MARK: - Base NLP score

    private func computeBaseScore(
        article: BlogArticle,
        profile: DynamicUserProfile
    ) -> (score: Double, matchedTags: [String]) {

        guard let embedding = embedding else { return (0.0, []) }

        let text    = cleanText(article.title + " " + article.body)
        let phrases = extractPhrases(from: text)
        var matchedTags: [String] = []

        for tag in profile.tagWeights.keys where matchTag(tag, phrases: phrases, embedding: embedding) {
            matchedTags.append(tag)
        }

        let score = matchedTags.reduce(0.0) { $0 + (profile.tagWeights[$1] ?? 0.0) }
        return (score, matchedTags)
    }

    private func matchTag(_ tag: String, phrases: [String], embedding: NLEmbedding) -> Bool {
        let cleanedTag = cleanText(tag)
        let lemmatizedTag = lemmatizePhrase(cleanedTag)
        let tagWords = cleanedTag.split(separator: " ").map(String.init)
        let lemmatizedTagWords = lemmatizedTag.split(separator: " ").map(String.init)

        if phrases.contains(cleanedTag) || phrases.contains(lemmatizedTag) {
            return true
        }

        for phrase in phrases {
            if phrase.contains(cleanedTag) || phrase.contains(lemmatizedTag) {
                return true
            }
        }

        var tagWordScores: [Double] = []
        for (index, tagWord) in tagWords.enumerated() {
            let tagLemma = index < lemmatizedTagWords.count ? lemmatizedTagWords[index] : tagWord
            var bestScore = 0.0
            outer: for phrase in phrases {
                for phraseWord in phrase.split(separator: " ").map(String.init) {
                    if tagWord == phraseWord || tagLemma == phraseWord {
                        bestScore = config.exactMatchBoost
                        break outer
                    }
                    let sim = max(
                        config.semanticFloor,
                        1.0 - embedding.distance(between: tagWord, and: phraseWord)
                    )
                    bestScore = max(bestScore, sim)
                }
            }
            tagWordScores.append(bestScore)
        }

        let confidence = tagWordScores.isEmpty
            ? 0.0
            : tagWordScores.reduce(0, +) / Double(tagWordScores.count)
        return confidence >= config.minConfidence
    }

    // MARK: - Level multiplier

    private func levelMultiplier(article: BlogArticle, level: BlogUserLevel) -> Double {
        let diff = abs(article.complexityTier - level.preferredComplexityTier)
        switch diff {
        case 0:  return level.complexityMultiplier
        case 1:  return 1.0
        default: return 0.75
        }
    }

    // MARK: - Freshness decay

    private func freshnessScore(publishedAt: Date) -> Double {
        let ageInDays = max(0, Date().timeIntervalSince(publishedAt) / 86_400)
        return pow(0.5, ageInDays / config.freshnessHalfLifeDays)
    }

    // MARK: - Diversity filter

    private func applyDiversityFilter(scored: [ScoredArticle]) -> [ScoredArticle] {
        var categoryCount: [String: Int] = [:]
        var result: [ScoredArticle] = []
        var deferred: [ScoredArticle] = []

        for item in scored {
            let cat   = item.article.category
            let count = categoryCount[cat, default: 0]
            if count < config.diversityPenaltyAfter {
                categoryCount[cat] = count + 1
                result.append(item)
            } else {
                deferred.append(ScoredArticle(
                    article: item.article,
                    baseScore: item.baseScore,
                    levelMultiplier: item.levelMultiplier,
                    freshnessScore: item.freshnessScore,
                    finalScore: item.finalScore * config.diversityPenaltyFactor,
                    matchedTags: item.matchedTags
                ))
            }
        }
        return (result + deferred).sorted { $0.finalScore > $1.finalScore }
    }

    // MARK: - NLP helpers

    private func cleanText(_ text: String) -> String {
        let stopWords = Set([
            "the", "a", "an", "and", "or", "but", "in", "on",
            "at", "to", "for", "of", "with", "as", "by", "from",
            "is", "are", "was", "were", "be", "been", "being"
        ])
        let cleaned = text.lowercased()
            .replacingOccurrences(of: "'s", with: "")
            .replacingOccurrences(of: "[^a-z0-9\\s]", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
        return cleaned.split(separator: " ").map(String.init)
            .filter { !stopWords.contains($0) && $0.count > 1 }
            .joined(separator: " ")
    }

    private func lemmatize(_ word: String) -> String {
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = word
        var lemma = word
        tagger.enumerateTags(in: word.startIndex..<word.endIndex, unit: .word, scheme: .lemma) { tag, _ in
            if let tag = tag { lemma = tag.rawValue }
            return true
        }
        return lemma.lowercased()
    }

    private func lemmatizePhrase(_ phrase: String) -> String {
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = phrase
        var words: [String] = []
        let range = phrase.startIndex..<phrase.endIndex
        let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation]
        tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: options) { tag, range in
            words.append(tag?.rawValue.lowercased() ?? String(phrase[range]).lowercased())
            return true
        }
        return words.joined(separator: " ")
    }

    private func extractPhrases(from text: String, maxPhraseLength: Int = 4) -> [String] {
        let tagger = NLTagger(tagSchemes: [.lexicalClass, .nameType, .lemma])
        tagger.string = text
        var phrases: Set<String> = []
        var nounBuffer: [String] = []
        var lemmaBuffer: [String] = []

        let nameOptions: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
        let textRange = text.startIndex..<text.endIndex
        tagger.enumerateTags(in: textRange, unit: .word, scheme: .nameType, options: nameOptions) { tag, range in
            if tag != nil { phrases.insert(String(text[range]).lowercased()) }
            return true
        }

        func flush() {
            guard !nounBuffer.isEmpty else { return }
            for length in 1...nounBuffer.count {
                for start in 0...(nounBuffer.count - length) {
                    phrases.insert(nounBuffer[start..<(start+length)].joined(separator: " "))
                    phrases.insert(lemmaBuffer[start..<(start+length)].joined(separator: " "))
                }
            }
            nounBuffer.removeAll()
            lemmaBuffer.removeAll()
        }

        let lexicalOptions: NLTagger.Options = [.omitWhitespace, .omitPunctuation]
        tagger.enumerateTags(in: textRange, unit: .word, scheme: .lexicalClass, options: lexicalOptions) { tag, range in
            let word = String(text[range]).lowercased()
            let wt = NLTagger(tagSchemes: [.lemma])
            wt.string = word
            var lemma = word
            let wordRange = word.startIndex..<word.endIndex
            wt.enumerateTags(in: wordRange, unit: .word, scheme: .lemma) { tag, _ in
                if let tag = tag { lemma = tag.rawValue.lowercased() }
                return true
            }
            if tag == .noun || tag == .adjective || tag == .verb {
                nounBuffer.append(word)
                lemmaBuffer.append(lemma)
                if nounBuffer.count > maxPhraseLength {
                    nounBuffer.removeFirst()
                    lemmaBuffer.removeFirst()
                }
            } else { flush() }
            return true
        }
        flush()

        let separators = CharacterSet.alphanumerics.inverted
        for word in text.lowercased().components(separatedBy: separators).filter({ $0.count > 1 }) {
            phrases.insert(word)
            phrases.insert(lemmatize(word))
        }
        return Array(phrases)
    }
}
