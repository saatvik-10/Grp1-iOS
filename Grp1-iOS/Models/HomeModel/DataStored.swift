import Foundation
import WidgetKit

class NewsDataStore {

    static let shared = NewsDataStore()

    private init() {
        loadFromCache()
    }

    // MARK: - Cache Keys & TTL
    private let cacheKey     = "cached_news_articles"
    private let cacheTimeKey = "cached_news_timestamp"
    private let cacheTTL: TimeInterval = 30 * 60

     var newsArticles: [NewsArticle] = []

    // MARK: - Seed Data

     var seedArticles: [NewsArticle] = []

    // MARK: - Cache Load/Save

    private func loadFromCache() {
        guard
            let data = UserDefaults.standard.data(forKey: cacheKey),
            let decoded = try? JSONDecoder().decode([NewsArticle].self, from: data),
            !decoded.isEmpty
        else {
            newsArticles = seedArticles
            return
        }
        newsArticles = decoded
        print("Loaded \(decoded.count) articles from cache")
    }

    private func saveToCache() {
        guard let data = try? JSONEncoder().encode(newsArticles) else { return }
        UserDefaults.standard.set(data, forKey: cacheKey)
        UserDefaults.standard.set(Date(), forKey: cacheTimeKey)
        print("Saved \(newsArticles.count) articles to cache")
    }
    private func saveToSharedCache() {
        let top3 = newsArticles.prefix(3).map {
            WidgetArticle(
                title: $0.title,
                source: $0.source,
                imageName: $0.imageName,
                relevanceScore: $0.relevanceScore
            )
        }
        guard let data = try? JSONEncoder().encode(top3) else { return }
        UserDefaults(suiteName: "group.com.yourcompany.newsapp")?
            .set(data, forKey: "widget_articles")
        WidgetCenter.shared.reloadAllTimelines()
    }

    var isCacheStale: Bool {
        guard let last = UserDefaults.standard.object(forKey: cacheTimeKey) as? Date else {
            return true
        }
        return Date().timeIntervalSince(last) > cacheTTL
    }

    func getAllNews() -> [NewsArticle] { newsArticles }

    func getTodaysPick() -> NewsArticle? { newsArticles.first }

    func getArticle(by id: Int) -> NewsArticle? {
        newsArticles.first { $0.id == id }
    }

    func addArticle(_ article: NewsArticle) {
        guard !newsArticles.contains(where: { $0.title == article.title }) else {
            print("Duplicate skipped: \(article.title)")
            return
        }

        newsArticles.append(article)

        // highest relevance score first
        newsArticles.sort { $0.relevanceScore > $1.relevanceScore }

        saveToCache()
        saveToSharedCache()

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .articlesUpdated, object: nil)
        }
    }

    func addQA(for articleID: Int, question: String, answer: String) {
        guard let index = newsArticles.firstIndex(where: { $0.id == articleID }) else { return }
        newsArticles[index].qaHistory.append(
            ArticleQA(question: question, answer: answer, createdAt: Date())
        )
        saveToCache()
    }

    func getQAHistory(for articleID: Int) -> [ArticleQA] {
        newsArticles.first { $0.id == articleID }?.qaHistory ?? []
    }

    func clearCache() {
        UserDefaults.standard.removeObject(forKey: cacheKey)
        UserDefaults.standard.removeObject(forKey: cacheTimeKey)
        newsArticles = seedArticles
        print("Cache cleared")
    }
}

struct JargonQuizStore {

    static let quizzes: [JargonQuiz] = [

        JargonQuiz(
            jargonWord: "Commodity Inflation",
            question: "Q) What best describes commodity inflation?",
            options: [
                "Increase in prices of raw materials",
                "Fall in stock market prices",
                "Rise in wages",
                "Increase in taxes"
            ],
            correctIndex: 0
        ),

        JargonQuiz(
            jargonWord: "Repo Rate",
            question: "Q) Repo rate is the rate at which:",
            options: [
                "Banks lend to customers",
                "RBI lends to commercial banks",
                "Government borrows money",
                "Banks lend to RBI"
            ],
            correctIndex: 1
        ),

        JargonQuiz(
            jargonWord: "Dollar Index",
            question: "Q) Dollar Index measures:",
            options: [
                "Value of the US dollar against major currencies",
                "US inflation rate",
                "Gold price movement",
                "US stock market performance"
            ],
            correctIndex: 0
        ),

        JargonQuiz(
            jargonWord: "Safe-Haven Asset",
            question: "Q) A safe-haven asset is one that:",
            options: [
                "Performs well during market uncertainty",
                "Always gives high returns",
                "Is issued only by governments",
                "Is used for short-term trading"
            ],
            correctIndex: 0
        ),

        JargonQuiz(
            jargonWord: "Strategic Consulting",
            question: "Q) Strategic consulting mainly focuses on:",
            options: [
                "Long-term business strategy and growth",
                "Daily operational tasks",
                "Employee payroll management",
                "IT infrastructure maintenance"
            ],
            correctIndex: 0
        ),

        JargonQuiz(
            jargonWord: "Market Diversification",
            question: "Q) Market diversification helps investors by:",
            options: [
                "Reducing overall risk",
                "Guaranteeing profits",
                "Avoiding taxes",
                "Increasing short-term volatility"
            ],
            correctIndex: 0
        ),

        JargonQuiz(
            jargonWord: "Operational Risk",
            question: "Q) Operational risk arises due to:",
            options: [
                "Failures in processes, people, or systems",
                "Changes in interest rates",
                "Stock market fluctuations",
                "Foreign exchange movements"
            ],
            correctIndex: 0
        ),

        JargonQuiz(
            jargonWord: "Monetary Policy",
            question: "Q) Monetary policy is controlled by:",
            options: [
                "Central bank",
                "Commercial banks",
                "Stock exchanges",
                "Private investors"
            ],
            correctIndex: 0
        ),

        JargonQuiz(
            jargonWord: "Inflation Targeting",
            question: "Q) Inflation targeting means:",
            options: [
                "Keeping inflation within a predefined range",
                "Eliminating inflation completely",
                "Controlling stock prices",
                "Fixing currency exchange rates"
            ],
            correctIndex: 0
        ),

        JargonQuiz(
            jargonWord: "Quarterly Earnings",
            question: "Q) Quarterly earnings represent:",
            options: [
                "Company’s financial performance every three months",
                "Annual revenue of a company",
                "Stock price movement",
                "Dividend payout frequency"
            ],
            correctIndex: 0
        ),

        JargonQuiz(
            jargonWord: "Tech Valuation",
            question: "Q) Tech valuation refers to:",
            options: [
                "Estimating the worth of technology companies",
                "Measuring internet speed",
                "Evaluating software bugs",
                "Calculating employee productivity"
            ],
            correctIndex: 0
        ),

        JargonQuiz(
            jargonWord: "Market Sentiment",
            question: "Q) Market sentiment reflects:",
            options: [
                "Overall investor attitude toward the market",
                "Company balance sheets",
                "Government fiscal policy",
                "Foreign trade balance"
            ],
            correctIndex: 0
        )
    ]

    static func quiz(for jargon: String) -> JargonQuiz? {
        quizzes.first { $0.jargonWord == jargon }
    }
}

class QuizStore {

    static let shared = QuizStore()
    private init() {}

    private let quizzes: [QuizQuestion] = [

        QuizQuestion(
            articleId: 1,
            question: "What was the main reason for the market rally?",
            options: [
                "Strong domestic investor participation",
                "Heavy foreign capital inflow",
                "Sudden fall in crude oil prices",
                "Major tax reforms announced"
            ],
            correctIndex: 0
        ),

        QuizQuestion(
            articleId: 1,
            question: "Which sector performed the best?",
            options: [
                "IT",
                "Banking and Financial Services",
                "Pharma",
                "Real Estate"
            ],
            correctIndex: 1
        ),

        QuizQuestion(
            articleId: 1,
            question: "Why were global markets uncertain?",
            options: [
                "Rising inflation",
                "Geopolitical tensions",
                "Natural disasters",
                "Trade surplus concerns"
            ],
            correctIndex: 1
        ),

        QuizQuestion(
            articleId: 1,
            question: "What did experts advise investors?",
            options: [
                "Exit equities",
                "Invest only in small caps",
                "Avoid long-term investments",
                "Stay invested long-term"
            ],
            correctIndex: 3
        ),

        QuizQuestion(
            articleId: 2,
            question: "Which technology is driving recent AI growth?",
            options: [
                "Blockchain",
                "Quantum Computing",
                "Generative AI",
                "5G Networks"
            ],
            correctIndex: 2
        ),
        QuizQuestion(
            articleId: 3,
            question: "Which technology is driving recent AI growth?",
            options: [
                "Blockchain",
                "Quantum Computing",
                "Generative AI",
                "5G Networks"
            ],
            correctIndex: 2
        ),
        QuizQuestion(
            articleId: 4,
            question: "Which technology is driving recent AI growth?",
            options: [
                "Blockchain",
                "Quantum Computing",
                "Generative AI",
                "5G Networks"
            ],
            correctIndex: 2
        ),
        QuizQuestion(
            articleId: 5,
            question: "Which technology is driving recent AI growth?",
            options: [
                "Blockchain",
                "Quantum Computing",
                "Generative AI",
                "5G Networks"
            ],
            correctIndex: 2
        )
    ]

    func quizForArticle(articleId: Int) -> [QuizQuestion] {
        return quizzes.filter { $0.articleId == articleId }
    }
}

extension Notification.Name {
    static let articlesUpdated = Notification.Name("articlesUpdated")
}
