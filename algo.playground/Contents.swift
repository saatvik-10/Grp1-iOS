import Foundation
import NaturalLanguage

struct MatchConfig {
    let minConfidence: Double = 0.45
    let exactMatchBoost: Double = 1.0
    let semanticFloor: Double = 0.0
}

let userTags = [
    "banking",
    "stock market",
    "hdfc bank",
    "interest rate",
    "rbi",
    "technology",
    "digital banking",
    "fintech",
    "inflation",
    "economy",
    "credit growth",
    "regulation",
    "monetary policy",
    "financial sector"
]

let tagWeights: [String: Double] = [
    "banking": 10,
    "stock market": 13,
    "hdfc bank": 8,
    "interest rate": 20,
    "rbi": 18,
    "technology": 7,
    "digital banking": 6,
    "fintech": 3,
    "inflation": 11,
    "economy": 4,
    "credit growth": 6,
    "regulation": 8,
    "monetary policy": 13,
    "financial sector": 9
]

let newsHeadline = "Retail inflation remains muted at 1.3% in December"

let newsBody = """
NEW DELHI: India's benchmark inflation rate stayed on the lower side of RBI's target band of 4% plus or minus 2% for the fourth consecutive month in December 2025. The 1.3% retail inflation value, as measured by the annual growth in Consumer Price Index (CPI), is mostly a result of easing but persisting deflation in food prices, which is more than compensating for inflationary tailwinds from sources such as precious metals.
The latest inflation reading also means that quarterly inflation in the period ending December 2025, was 0.76%, the lowest ever in the current series and the second consecutive quarter when it stayed below the lower end of RBI's target band. To be sure, the December quarter inflation print is slightly higher than the 0.6% projected by RBI in its December Monetary Policy Committee (MPC) resolution. Headline inflation has stayed below RBI's actual target of 4%  for four consecutive quarters now.
"""

func cleanText(_ text: String) -> String {
    let stopWords = Set(["the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for", "of", "with", "as", "by", "from", "is", "are", "was", "were", "be", "been", "being"])

    let cleaned = text.lowercased()
        .replacingOccurrences(of: "'s", with: "")
        .replacingOccurrences(of: "[^a-z0-9\\s]", with: " ", options: .regularExpression)
        .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        .trimmingCharacters(in: .whitespaces)

    let words = cleaned.split(separator: " ")
        .map(String.init)
        .filter { !stopWords.contains($0) && $0.count > 1 }

    return words.joined(separator: " ")
}

func lemmatize(_ word: String) -> String {
    let tagger = NLTagger(tagSchemes: [.lemma])
    tagger.string = word

    var lemma = word
    tagger.enumerateTags(in: word.startIndex..<word.endIndex, unit: .word, scheme: .lemma) { tag, _ in
        if let tag = tag {
            lemma = tag.rawValue
        }
        return true
    }

    return lemma.lowercased()
}

func lemmatizePhrase(_ phrase: String) -> String {
    let tagger = NLTagger(tagSchemes: [.lemma])
    tagger.string = phrase

    var lemmatizedWords: [String] = []

    tagger.enumerateTags(in: phrase.startIndex..<phrase.endIndex, unit: .word, scheme: .lemma, options: [.omitWhitespace, .omitPunctuation]) { tag, range in
        if let tag = tag {
            lemmatizedWords.append(tag.rawValue.lowercased())
        } else {
            lemmatizedWords.append(String(phrase[range]).lowercased())
        }
        return true
    }

    return lemmatizedWords.joined(separator: " ")
}

func extractPhrases(from text: String, maxPhraseLength: Int = 4) -> [String] {
    let tagger = NLTagger(tagSchemes: [.lexicalClass, .nameType, .lemma])
    tagger.string = text

    var phrases: Set<String> = []
    var nounPhraseBuffer: [String] = []
    var lemmaBuffer: [String] = []

    tagger.enumerateTags(
        in: text.startIndex..<text.endIndex,
        unit: .word,
        scheme: .nameType,
        options: [.omitWhitespace, .omitPunctuation, .joinNames]
    ) { tag, range in
        if tag != nil {
            let entity = String(text[range]).lowercased()
            phrases.insert(entity)
        }
        return true
    }

    tagger.enumerateTags(
        in: text.startIndex..<text.endIndex,
        unit: .word,
        scheme: .lexicalClass,
        options: [.omitWhitespace, .omitPunctuation]
    ) { tag, range in
        let word = String(text[range]).lowercased()

        let wordTagger = NLTagger(tagSchemes: [.lemma])
        wordTagger.string = word
        var lemma = word
        wordTagger.enumerateTags(in: word.startIndex..<word.endIndex, unit: .word, scheme: .lemma) { lemmaTag, _ in
            if let lemmaTag = lemmaTag {
                lemma = lemmaTag.rawValue.lowercased()
            }
            return true
        }

        if tag == .noun || tag == .adjective || tag == .verb {
            nounPhraseBuffer.append(word)
            lemmaBuffer.append(lemma)

            if nounPhraseBuffer.count > maxPhraseLength {
                nounPhraseBuffer.removeFirst()
                lemmaBuffer.removeFirst()
            }
        } else {
            if !nounPhraseBuffer.isEmpty {
                for length in 1...nounPhraseBuffer.count {
                    for start in 0...(nounPhraseBuffer.count - length) {
                        let originalNgram = nounPhraseBuffer[start..<(start + length)].joined(separator: " ")
                        let lemmatizedNgram = lemmaBuffer[start..<(start + length)].joined(separator: " ")

                        phrases.insert(originalNgram)
                        phrases.insert(lemmatizedNgram)
                    }
                }
                nounPhraseBuffer.removeAll()
                lemmaBuffer.removeAll()
            }
        }
        return true
    }

    if !nounPhraseBuffer.isEmpty {
        for length in 1...nounPhraseBuffer.count {
            for start in 0...(nounPhraseBuffer.count - length) {
                let originalNgram = nounPhraseBuffer[start..<(start + length)].joined(separator: " ")
                let lemmatizedNgram = lemmaBuffer[start..<(start + length)].joined(separator: " ")

                phrases.insert(originalNgram)
                phrases.insert(lemmatizedNgram)
            }
        }
    }

    let words = text.lowercased()
        .components(separatedBy: CharacterSet.alphanumerics.inverted)
        .filter { $0.count > 1 }

    for word in words {
        phrases.insert(word)
        phrases.insert(lemmatize(word))
    }

    return Array(phrases)
}

func matchUserTagsWithArticle(
    userTags: [String],
    headline: String,
    body: String,
    config: MatchConfig = MatchConfig()
) -> (matchedTags: [String], matchCount: Int) {

    guard let embedding = NLEmbedding.wordEmbedding(for: .english) else {
        print("Failed to load embeddings")
        return ([], 0)
    }

    let articleText = cleanText(headline + " " + body)
    let phrases = extractPhrases(from: articleText)

    print("\nExtracted Article Phrases (\(phrases.count) total):")
    Array(phrases).sorted().prefix(25).forEach { print("   • \($0)") }
    if phrases.count > 25 {
        print("   ... and \(phrases.count - 25) more")
    }
    print("")

    var matchedTags: [String] = []

    for tag in userTags {
        let cleanedTag = cleanText(tag)
        let lemmatizedTag = lemmatizePhrase(cleanedTag)
        let tagWords = cleanedTag.split(separator: " ").map(String.init)
        let lemmatizedTagWords = lemmatizedTag.split(separator: " ").map(String.init)

        if phrases.contains(cleanedTag) || phrases.contains(lemmatizedTag) {
            matchedTags.append(tag)
            print("Tag: '\(tag)' → EXACT PHRASE MATCH (confidence: 1.00)")
            continue
        }

        var foundPartialMatch = false
        for phrase in phrases {
            if phrase.contains(cleanedTag) || phrase.contains(lemmatizedTag) {
                matchedTags.append(tag)
                print("Tag: '\(tag)' → PARTIAL MATCH in '\(phrase)' (confidence: 0.95)")
                foundPartialMatch = true
                break
            }
        }
        if foundPartialMatch { continue }

        var tagWordScores: [Double] = []

        for (index, tagWord) in tagWords.enumerated() {
            let tagLemma = lemmatizedTagWords[index]
            var bestScore = 0.0
            var bestMatch = ""

            for phrase in phrases {
                let phraseWords = phrase.split(separator: " ").map(String.init)

                for phraseWord in phraseWords {
                    if tagWord == phraseWord || tagLemma == phraseWord {
                        bestScore = config.exactMatchBoost
                        bestMatch = phraseWord
                        break
                    }

                    let distance = embedding.distance(between: tagWord, and: phraseWord)
                    let similarity = max(config.semanticFloor, 1.0 - distance)

                    if similarity > bestScore {
                        bestScore = similarity
                        bestMatch = phraseWord
                    }
                }

                if bestScore == config.exactMatchBoost { break }
            }

            tagWordScores.append(bestScore)
            if bestScore > 0.5 {
                print("'\(tagWord)' → '\(bestMatch)' (score: \(String(format: "%.2f", bestScore)))")
            }
        }

        let confidence = tagWordScores.isEmpty ? 0.0 : tagWordScores.reduce(0, +) / Double(tagWordScores.count)
        let bestDistance = tagWordScores.isEmpty ? 2.0 : (1.0 - (tagWordScores.max() ?? 0.0))

        print(
            "Tag: '\(tag)' → distance: \(String(format: "%.2f", bestDistance)), " +
            "confidence: \(String(format: "%.2f", confidence))"
        )

        if confidence >= config.minConfidence {
            matchedTags.append(tag)
            print("   ✓ MATCHED")
        } else {
            print("   ✗ Below threshold")
        }
        print("")
    }

    return (matchedTags, matchedTags.count)
}

func calculateArticleScore(
    matchedTags: [String],
    tagWeights: [String: Double]
) -> Double {
    matchedTags.reduce(0.0) { score, tag in
        score + (tagWeights[tag] ?? 0.0)
    }
}

print("Starting Enhanced Tag Matching Algorithm\n")
print(String(repeating: "=", count: 60))

let result = matchUserTagsWithArticle(
    userTags: userTags,
    headline: newsHeadline,
    body: newsBody
)

print("\n" + String(repeating: "=", count: 60))
print("\nRESULTS:")
print("\nMatched Tags (\(result.matchCount) total):")
result.matchedTags.forEach { tag in
    let weight = tagWeights[tag] ?? 0.0
    print("   • \(tag) (weight: \(weight))")
}

let articleScore = calculateArticleScore(
    matchedTags: result.matchedTags,
    tagWeights: tagWeights
)

print("\nFinal Article Score: \(articleScore)")
print("\n" + String(repeating: "=", count: 60))

// Starting Enhanced Tag Matching Algorithm
//
// ============================================================
//
// Extracted Article Phrases (198 total):
//   • 2025
//   • 76
//   • actual
//   • actual target
//   • also
//   • annual
//   • band
//   • below
//   • benchmark
//   • benchmark inflation
//   • benchmark inflation rate
//   • benchmark inflation rate stay
//   • benchmark inflation rate stayed
//   • committee
//   • compensate
//   • compensate inflationary
//   • compensate inflationary tailwind
//   • compensate inflationary tailwind sources
//   • compensating
//   • compensating inflationary
//   • compensating inflationary tailwinds
//   • compensating inflationary tailwinds sources
//   • consecutive
//   • consecutive month
//   • consecutive month december
//   ... and 173 more
//
// Tag: 'banking' → distance: 1.00, confidence: 0.00
//   ✗ Below threshold
//
// Tag: 'stock market' → distance: 0.88, confidence: 0.10
//   ✗ Below threshold
//
// Tag: 'hdfc bank' → distance: 0.93, confidence: 0.04
//   ✗ Below threshold
//
// 'rate' → 'rate' (score: 1.00)
// Tag: 'interest rate' → distance: 0.00, confidence: 0.50
//   ✓ MATCHED
//
// Tag: 'rbi' → EXACT PHRASE MATCH (confidence: 1.00)
// Tag: 'technology' → distance: 1.00, confidence: 0.00
//   ✗ Below threshold
//
// Tag: 'digital banking' → distance: 1.00, confidence: 0.00
//   ✗ Below threshold
//
// Tag: 'fintech' → distance: 1.00, confidence: 0.00
//   ✗ Below threshold
//
// Tag: 'inflation' → EXACT PHRASE MATCH (confidence: 1.00)
// Tag: 'economy' → distance: 0.94, confidence: 0.06
//   ✗ Below threshold
//
// 'growth' → 'growth' (score: 1.00)
// Tag: 'credit growth' → distance: 0.00, confidence: 0.50
//   ✓ MATCHED
//
// Tag: 'regulation' → distance: 1.00, confidence: 0.00
//   ✗ Below threshold
//
// 'monetary' → 'monetary' (score: 1.00)
// 'policy' → 'policy' (score: 1.00)
// Tag: 'monetary policy' → distance: 0.00, confidence: 1.00
//   ✓ MATCHED
//
// Tag: 'financial sector' → distance: 1.00, confidence: 0.00
//   ✗ Below threshold
//
//
// ============================================================
//
// RESULTS:
//
// Matched Tags (5 total):
//   • interest rate (weight: 20.0)
//   • rbi (weight: 18.0)
//   • inflation (weight: 11.0)
//   • credit growth (weight: 6.0)
//   • monetary policy (weight: 13.0)
//
// Final Article Score: 68.0
//
// ============================================================
