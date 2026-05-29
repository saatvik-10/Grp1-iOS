//
//  ArticleScorer.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 06/03/26.

import Foundation
import NaturalLanguage

enum FeedbackSignal {

    case recommendMore
    case recommendLess

    case readFull         // strongest implicit signal
    case scrolledToBottom // strong implicit signal
    case bookmarked       // stronger than selection
    case clicked          // weaker evidence
    case scrolledPast     // Weak negative
    case dismissed        // Strong negative

    var value: Double {
        switch self {

        case .recommendMore:    return +1.0
        case .recommendLess:    return -1.0

        case .readFull:         return +0.7   // strongest implicit
        case .bookmarked:       return +0.6   // retain > examine
        case .scrolledToBottom: return +0.5   // strong implicit
        case .clicked:          return +0.3   // weakest positive
        case .scrolledPast:     return -0.1   // weak negative
        case .dismissed:        return -0.4   // strong negative

        }
    }
}

struct UserProfile1 {

    static let tags: [String] = [
        "banking", "stock market", "hdfc bank", "interest rate", "rbi",
        "technology", "digital banking", "fintech", "inflation", "economy",
        "credit growth", "regulation", "monetary policy", "financial sector"
    ]

    private static let weightsKey = "userProfile1_weights"

    static var weights: [String: Double] {
        get {
            if let saved = UserDefaults.standard.dictionary(forKey: weightsKey) as? [String: Double] {
                return saved
            }
            var defaults: [String: Double] = [:]
            for tag in tags { defaults[tag] = 1.0 }
            return defaults
        }
        set {
            UserDefaults.standard.set(newValue, forKey: weightsKey)
        }
    }

    static let beta: Double = 0.8
    static let gamma: Double = 0.2
    static let minWeight: Double = 0.1
    static let maxWeight: Double = 5.0
}

// score = Σ confidence(tag) × weight(tag)
//              ↑                    ↑
//         how present          how important
//         in article           to this user

final class ArticleScorer {

    static let shared = ArticleScorer()
    private init() {}

    private let minConfidence: Double = 0.45
    private let semanticFloor: Double = 0.0

    private lazy var embedding: NLEmbedding? = NLEmbedding.wordEmbedding(for: .english)

    func score(title: String, body: String) -> Double {

        guard let embedding = embedding else {
            print("⚠️  ArticleScorer — embeddings unavailable, defaulting to 0")
            return 0.0
        }

        let articleText = cleanText(title + " " + body)
        let phrases     = extractPhrases(from: articleText)

        var totalScore: Double = 0.0

        for tag in UserProfile1.tags {

            let confidence = computeConfidence(
                tag: tag,
                phrases: phrases,
                embedding: embedding
            )

            if confidence >= minConfidence {
                let userWeight = UserProfile1.weights[tag] ?? 1.0
                totalScore += confidence * userWeight

                print("✅ Tag: '\(tag)' | Confidence: \(String(format: "%.2f", confidence)) "
                    + "| Contribution: \(String(format: "%.2f", confidence * userWeight))")
            }
        }

        print("📊 Final Score: \(String(format: "%.2f", totalScore)) | '\(title.prefix(50))'")
        return totalScore
    }

    func updateWeights(for title: String, body: String, signal: FeedbackSignal) {
        print("🎯 updateWeights called | signal: \(signal) | '\(title.prefix(40))'")

        guard let embedding = embedding else { return }

        let articleText = cleanText(title + " " + body)
        let phrases     = extractPhrases(from: articleText)

        for tag in UserProfile1.tags {

            let confidence = computeConfidence(
                tag: tag,
                phrases: phrases,
                embedding: embedding
            )
            print("   🔍 tag: '\(tag)' | confidence: \(String(format: "%.3f", confidence))")

            guard confidence >= minConfidence else { continue }

            let oldWeight    = UserProfile1.weights[tag] ?? 1.0
            let signalValue  = signal.value

            let newWeight: Double

            if signalValue > 0 {

                newWeight = oldWeight + UserProfile1.beta * signalValue

            } else {

                newWeight = oldWeight + UserProfile1.gamma * signalValue
            }

            UserProfile1.weights[tag] = min(
                max(newWeight, UserProfile1.minWeight),
                UserProfile1.maxWeight
            )

            if let newWeight = UserProfile1.weights[tag] {
                print("🔄 Updated '\(tag)': \(String(format: "%.2f", oldWeight)) → \(String(format: "%.2f", newWeight)) | Signal: \(signal)")
            }
        }
    }

    private func computeConfidence(
        tag: String,
        phrases: [String],
        embedding: NLEmbedding
    ) -> Double {

        let cleanedTag = cleanText(tag)
        let tagWords   = cleanedTag.split(separator: " ").map(String.init)

        var tagWordScores: [Double] = []

        for tagWord in tagWords {
            let tagRoot   = stem(tagWord)
            var bestScore = 0.0

            outer: for phrase in phrases {
                let phraseWords = phrase.split(separator: " ").map(String.init)

                if phrase.contains(tagWord) {
                    bestScore = 1.0
                    break outer
                }

                for phraseWord in phraseWords {
                    let phraseRoot = stem(phraseWord)

                    if tagWord == phraseWord || tagRoot == phraseRoot {
                        bestScore = 1.0
                        break outer
                    }

                    let distance   = embedding.distance(between: tagWord, and: phraseWord)
                    let similarity = max(semanticFloor, 1.0 - distance)
                    bestScore      = max(bestScore, similarity)
                }
            }

            tagWordScores.append(bestScore)
        }

        return tagWordScores.isEmpty
            ? 0.0
            : tagWordScores.reduce(0, +) / Double(tagWordScores.count)
    }

    private func cleanText(_ text: String) -> String {
        text.lowercased()
            .replacingOccurrences(of: "[^a-z0-9\\s]", with: "", options: .regularExpression)
    }

    private func extractPhrases(from text: String) -> [String] {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text

        var phrases: [String] = []
        var buffer: [String] = []

        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .lexicalClass,
            options: [.omitWhitespace, .omitPunctuation]
        ) { tag, range in
            let word = String(text[range])
            if tag == .noun || tag == .adjective {
                buffer.append(word)
            } else if !buffer.isEmpty {
                phrases.append(buffer.joined(separator: " "))
                buffer.removeAll()
            }
            return true
        }

        if !buffer.isEmpty { phrases.append(buffer.joined(separator: " ")) }
        return phrases
    }

    private func stem(_ word: String) -> String {
        let suffixes = ["ing", "ed", "s", "es", "ly"]
        for suffix in suffixes {
            if word.hasSuffix(suffix) && word.count > suffix.count + 2 {
                return String(word.dropLast(suffix.count))
            }
        }
        return word
    }
}
