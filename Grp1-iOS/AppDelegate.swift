import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        fetchAllFeedsOnce()
        return true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}

// MARK: - One-time Feed Fetch

extension AppDelegate {

    func fetchAllFeedsOnce() {
        guard NewsDataStore.shared.isCacheStale else {
            print("Cache is fresh, skipping fetch")
            return
        }
        fetchTOIFeed()
        fetchMintFeed()
        fetchETFeed()
    }

    private func fetchTOIFeed() {
        RSSService.shared.fetchTOINews { items in
            print("")
            print("╔══════════════════════════════════════════════════════════╗")
            print("║              TIMES OF INDIA — RSS FETCH                  ║")
            print("╚══════════════════════════════════════════════════════════╝")
            print("TOI RSS fetched, items count: \(items.count)")

            if let first = items.first {
                print("TOI First title : \(first.title)")
                print("TOI First image : \(first.imageURL)")
                print("TOI First date  : \(first.pubDate)")
            }

            let toiItems = Array(items.prefix(3))
            guard !toiItems.isEmpty else {
                print("⚠️  TOI — No RSS items found")
                return
            }

            for firstItem in toiItems {
                ArticleContentService.shared.fetchArticleHTML(from: firstItem.link) { html in
                    guard let html = html else {
                        print("❌ TOI — Failed to load article HTML for: \(firstItem.title)")
                        return
                    }

                    let fullText = html.extractTOIArticleBody()
                    print("\n── TOI ARTICLE ──────────────────────────────────────────")
                    print(fullText.prefix(50000))

                    let generator = ArticleSummaryGenerator()
                    let shortener = HeadlineShortener()

                    Task {
                        await generator.generateSummary(from: fullText)
                        let cleanTitle = await shortener.shortenIfNeeded(firstItem.title)

                        print("\nTOI CLEAN TITLE: \(cleanTitle)")
                        print("════════════════════════════════════════════════════════")

                        guard
                            let overview     = generator.summary?.overview,
                            let keyTakeaways = generator.summary?.keyTakeaways,
                            let jargons      = generator.summary?.jargons
                        else {
                            print("⚠️  TOI — Summary not ready for: \(cleanTitle)")
                            return
                        }

                        let summary = ArticleSummary(
                            overview: overview,
                            keyTakeaways: keyTakeaways,
                            jargons: jargons
                        )

                        let score = ArticleScorer.shared.score(
                            title: cleanTitle,
                            body: fullText
                        )

                        let scrapedArticle = ScrapedArticle(
                            title: cleanTitle,
                            bodyText: fullText,
                            imageName: firstItem.imageURL,
                            source: "Times of India",
                            publishedDate: firstItem.pubDate
                        )

                        NewsDataStore.shared.addArticle(
                            NewsArticleAssembler.makeArticle(
                                from: scrapedArticle,
                                summary: summary,
                                score: score
                            )
                        )

                        print("TOI OVERVIEW:")
                        summary.overview.forEach { print("• \($0)\n") }
                        print("TOI KEY TAKEAWAYS:")
                        summary.keyTakeaways.forEach { print("• \($0)\n") }
                        print("TOI JARGONS:")
                        summary.jargons.forEach { print("• \($0)") }
                    }
                }
            }
        }
    }

    private func fetchMintFeed() {
        MintRSSService.shared.fetchMintNews { items in
            print("")
            print("╔══════════════════════════════════════════════════════════╗")
            print("║                 LIVEMINT — RSS FETCH                     ║")
            print("╚══════════════════════════════════════════════════════════╝")
            print("Mint RSS fetched, items count: \(items.count)")

            if let first = items.first {
                print("Mint First title : \(first.title)")
                print("Mint First image : \(first.imageURL)")
                print("Mint First date  : \(first.pubDate)")
            }

            let mintItems = Array(items.prefix(3))
            guard !mintItems.isEmpty else {
                print("⚠️  Mint — No RSS items found")
                return
            }

            for firstItem in mintItems {
                ArticleContentService.shared.fetchArticleHTML(from: firstItem.link) { html in
                    guard let html = html else {
                        print("❌ Mint — Failed to load article HTML for: \(firstItem.title)")
                        return
                    }

                    let fullText = html.extractMintArticleBody()
                    print("\n── MINT ARTICLE ─────────────────────────────────────────")
                    print(fullText.prefix(50000))

                    let generator = ArticleSummaryGenerator()
                    let shortener = HeadlineShortener()

                    Task {
                        await generator.generateSummary(from: fullText)
                        let cleanTitle = await shortener.shortenIfNeeded(firstItem.title)

                        print("\nMint CLEAN TITLE: \(cleanTitle)")
                        print("════════════════════════════════════════════════════════")

                        guard
                            let overview     = generator.summary?.overview,
                            let keyTakeaways = generator.summary?.keyTakeaways,
                            let jargons      = generator.summary?.jargons
                        else {
                            print("⚠️  Mint — Summary not ready for: \(cleanTitle)")
                            return
                        }

                        let summary = ArticleSummary(
                            overview: overview,
                            keyTakeaways: keyTakeaways,
                            jargons: jargons
                        )

                        let score = ArticleScorer.shared.score(
                            title: cleanTitle,
                            body: fullText
                        )

                        let scrapedArticle = ScrapedArticle(
                            title: cleanTitle,
                            bodyText: fullText,
                            imageName: firstItem.imageURL,
                            source: "LiveMint",
                            publishedDate: firstItem.pubDate
                        )

                        NewsDataStore.shared.addArticle(
                            NewsArticleAssembler.makeArticle(
                                from: scrapedArticle,
                                summary: summary,
                                score: score
                            )
                        )

                        print("Mint OVERVIEW:")
                        summary.overview.forEach { print("• \($0)\n") }
                        print("Mint KEY TAKEAWAYS:")
                        summary.keyTakeaways.forEach { print("• \($0)\n") }
                        print("Mint JARGONS:")
                        summary.jargons.forEach { print("• \($0)") }
                    }
                }
            }
        }
    }

    private func fetchETFeed() {
        ETRSSService.shared.fetchETNews { items in
            print("")
            print("╔══════════════════════════════════════════════════════════╗")
            print("║              ECONOMIC TIMES — RSS FETCH                  ║")
            print("╚══════════════════════════════════════════════════════════╝")
            print("ET RSS fetched, items count: \(items.count)")

            if let first = items.first {
                print("ET First title : \(first.title)")
                print("ET First image : \(first.imageURL)")
                print("ET First date  : \(first.pubDate)")
            }

            let etItems = Array(items.prefix(3))
            guard !etItems.isEmpty else {
                print("⚠️  ET — No RSS items found")
                return
            }

            for firstItem in etItems {
                ArticleContentService.shared.fetchArticleHTML(from: firstItem.link) { html in
                    guard let html = html else {
                        print("❌ ET — Failed to load article HTML for: \(firstItem.title)")
                        return
                    }

                    let fullText = html.extractETArticleBody()
                    print("\n── ET ARTICLE ───────────────────────────────────────────")
                    print(fullText.prefix(50000))

                    let generator = ArticleSummaryGenerator()
                    let shortener = HeadlineShortener()

                    Task {
                        await generator.generateSummary(from: fullText)
                        let cleanTitle = await shortener.shortenIfNeeded(firstItem.title)

                        print("\nET CLEAN TITLE: \(cleanTitle)")
                        print("════════════════════════════════════════════════════════")

                        guard
                            let overview     = generator.summary?.overview,
                            let keyTakeaways = generator.summary?.keyTakeaways,
                            let jargons      = generator.summary?.jargons
                        else {
                            print("⚠️  ET — Summary not ready for: \(cleanTitle)")
                            return
                        }

                        let summary = ArticleSummary(
                            overview: overview,
                            keyTakeaways: keyTakeaways,
                            jargons: jargons
                        )

                        let score = ArticleScorer.shared.score(
                            title: cleanTitle,
                            body: fullText
                        )

                        let scrapedArticle = ScrapedArticle(
                            title: cleanTitle,
                            bodyText: fullText,
                            imageName: firstItem.imageURL,
                            source: "Economic Times",
                            publishedDate: firstItem.pubDate
                        )

                        NewsDataStore.shared.addArticle(
                            NewsArticleAssembler.makeArticle(
                                from: scrapedArticle,
                                summary: summary,
                                score: score
                            )
                        )

                        print("ET OVERVIEW:")
                        summary.overview.forEach { print("• \($0)\n") }
                        print("ET KEY TAKEAWAYS:")
                        summary.keyTakeaways.forEach { print("• \($0)\n") }
                        print("ET JARGONS:")
                        summary.jargons.forEach { print("• \($0)") }
                    }
                }
            }
        }
    }
}
