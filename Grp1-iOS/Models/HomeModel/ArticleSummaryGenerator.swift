//
//  ArticleSummaryGenerator.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 21/01/26.
//

import Foundation
import FoundationModels
import Observation

@Observable
@MainActor
final class ArticleSummaryGenerator {

    private let session: LanguageModelSession

    private(set) var summary: ArticleSummary.PartiallyGenerated?
    private(set) var error: Error?

    init() {
        let instructions = Instructions {
            "You are a senior financial markets analyst."
            "Your task is to analyze financial and economic news articles."
            "Use only finance, banking, macroeconomics, or market terminology."
            "When extracting jargon, select only technical finance terms."
            "Do NOT include environmental, political, or general English words."
            "Avoid vague or generic terms."
        }

        self.session = LanguageModelSession(
            instructions: instructions
        )
    }

    func generateSummary(from articleText: String) async {

        do {
            let prompt = Prompt {
                """
                Summarize the following financial news article.

                • Generate a long overview.
                • Extract 7-8 key takeaways.
                • Identify 3-4 advanced financial or economic terms used in the article.
                • Only include jargon that appears in the text.
                • Avoid common or simple words.
                """

                articleText
            }

            let stream = session.streamResponse(
                to: prompt,
                generating: ArticleSummary.self,
                includeSchemaInPrompt: true
            )

            for try await partial in stream {
                self.summary = partial.content
            }

        } catch {
            self.error = error
        }
    }

    func prewarmModel() {
        session.prewarm()
    }
}
