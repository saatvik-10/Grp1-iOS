//
//  JargonContentGenerator.swift
//  Grp1-iOS
//

import Foundation
import FoundationModels
import Observation

// MARK: - Generable

@Generable
struct JargonContent: Equatable {

    @Guide(description: """
        A detailed definition of the financial or economic term, written in two paragraphs separated by \
        a blank line. Paragraph 1 (4-5 sentences): Define the term clearly, explain what it means, why \
        it exists, and how it works in financial markets. Paragraph 2 (4-5 sentences): Explain why it \
        matters to investors, how it affects the broader economy, and what happens when it changes. Use \
        professional financial language throughout. Total length should be 8-10 sentences.
        """)
    let definition: String

    @Guide(description: """
        A real-world example of this term in action, written in two paragraphs separated by a blank \
        line. Paragraph 1 (2-3 sentences): Describe a specific market event, scenario, or case where \
        this term was relevant. Use concrete numbers or named events where possible. Paragraph 2 (2-3 \
        sentences): Explain what happened as a result, how investors or institutions reacted, and what \
        the outcome was. Make it relatable to everyday investors or news readers.
        """)
    let realWorldExample: String

    @Guide(description: """
        A single clear quiz question testing deep understanding of this term.
        Start with Q) and be specific — test application of the concept, not just its definition.
        """)
    let quizQuestion: String

    @Guide(description: """
        Exactly 4 answer options for the quiz question.
        Make 3 plausible but incorrect, and 1 clearly correct.
        Keep each option very short (under 7 words).
        """)
    @Guide(.count(4...4))
    let quizOptions: [String]

    @Guide(description: """
        The index of the correct answer in quizOptions.
        Must be 0, 1, 2, or 3.
        """)
    let correctOptionIndex: Int
}

// MARK: - Generator

@Observable
@MainActor
final class JargonContentGenerator {

    private let session: LanguageModelSession

    private(set) var content: JargonContent.PartiallyGenerated?
    private(set) var isLoading: Bool = false
    private(set) var error: Error?

    init() {
        let instructions = Instructions {
            "You are a senior financial educator and markets analyst."
            "Explain financial and economic jargon in a clear, professional way."
            "Quiz questions must test genuine understanding — not just recall."
            "Never repeat the term definition verbatim in the quiz question."
            "Always return exactly 4 quiz options with one clearly correct answer."
        }
        self.session = LanguageModelSession(instructions: instructions)
    }

    func generate(for jargonWord: String, articleContext: String = "") async {
        isLoading = true
        error = nil
        content = nil

        do {
            let prompt = Prompt {
                """
                The user tapped on the financial term: "\(jargonWord)"

                This term appeared in the following article:
                \(articleContext.prefix(600))

                Generate the following with rich, detailed content:
                1. Definition of "\(jargonWord)" — two paragraphs, 8-10 sentences total. \
                First paragraph explains what it is and how it works. Second paragraph explains \
                why it matters and its economic impact.
                2. Real-world example — two paragraphs, 8-10 sentences total. First paragraph \
                describes a specific event or scenario. Second paragraph explains the outcome \
                and investor reaction.
                3. A multiple-choice quiz question with exactly 4 options testing application.
                4. The correct answer index (0, 1, 2, or 3).
                """
            }

            let stream = session.streamResponse(
                to: prompt,
                generating: JargonContent.self,
                includeSchemaInPrompt: true
            )

            for try await partial in stream {
                self.content = partial.content
            }

        } catch {
            self.error = error
            print("JargonContentGenerator error: \(error)")
        }

        isLoading = false
    }

    // MARK: - Convert to existing model structs

    func toJargonPages(for word: String) -> [JargonPage] {
        guard let contentData = content else { return [] }
        var pages: [JargonPage] = []

        if let def = contentData.definition, !def.isEmpty {
            pages.append(JargonPage(jargonWord: word, title: "Definition", content: formatParagraphs(def)))
        }
        if let ex = contentData.realWorldExample, !ex.isEmpty {
            pages.append(JargonPage(jargonWord: word, title: "Real World Example", content: formatParagraphs(ex)))
        }
        return pages
    }

    private func formatParagraphs(_ text: String) -> String {
        if text.contains("\n\n") {
            return text
                .components(separatedBy: "\n\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: "\n\n")
        }

        let sentences = text.components(separatedBy: ". ")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard sentences.count >= 4 else { return text }

        let mid = sentences.count / 2
        let para1 = sentences[..<mid].joined(separator: ". ") + "."
        let para2 = sentences[mid...].joined(separator: ". ")
        let para2Final = para2.hasSuffix(".") ? para2 : para2 + "."

        return para1 + "\n\n" + para2Final
    }

    func toJargonQuiz(for word: String) -> JargonQuiz? {
        guard
            let contentData = content,
            let question    = contentData.quizQuestion, !question.isEmpty,
            let opts        = contentData.quizOptions, opts.count == 4,
            let idx         = contentData.correctOptionIndex,
            (0...3).contains(idx)
        else { return nil }

        return JargonQuiz(
            jargonWord: word,
            question: question,
            options: opts,
            correctIndex: idx
        )
    }
}
