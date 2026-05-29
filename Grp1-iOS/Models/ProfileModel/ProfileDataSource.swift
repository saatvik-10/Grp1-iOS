import UIKit
// struct ProfileDataSource {
//    static let items: [ProfileOption] = [
//        ProfileOption(title: "Progress", isDestructive: false),
//        ProfileOption(title: "Interests", isDestructive: false),
//        ProfileOption(title: "Bookmarks", isDestructive: false),
//        ProfileOption(title: "About Us", isDestructive: false),
//        ProfileOption(title: "Logout", isDestructive: true)
//    ]
// }

struct ProfileDataSource {
    static let progressSection = ProgressSectionModel(
        progressPercentage: ProgressSectionMockData.mockProgress.progressPercentage,
        progressLevel: ProgressSectionMockData.mockProgress.progressLevel,
        requirementNextLevel: ProgressSectionMockData.mockProgress.requirementNextLevel
    )

    static let interestsSection = InterestsSectionModel(
        interests: Array(
            (UserInterests.domains.map { $0.title })
            //             + InterestsDataSource.companies.map { $0.title })
                .prefix(4)
        )
    )

    static let bookmarksSection = BookmarksSectionModel(
        totalBookmarks: Bookmarks.mockBookmarks.count,
        totalFolders: Bookmarks.mockBookmarks.count
    )

    static let sections: [ProfileSection] = [
        .progress(progressSection),
        .interests(interestsSection),
        .bookmarks(bookmarksSection),
        .about,
        .logout
    ]
}

struct InterestsDataSource {

    static let domains: [InterestModel] = [
        InterestModel(title: "Stocks", subtitle: nil, icon: "chart.line.uptrend.xyaxis"),
        InterestModel(title: "Crypto", subtitle: nil, icon: "bitcoinsign.circle"),
        InterestModel(title: "Macroeconomy", subtitle: nil, icon: "globe"),
        InterestModel(title: "Banking", subtitle: nil, icon: "building.columns"),
        InterestModel(title: "Commodities", subtitle: nil, icon: "shippingbox"),
        InterestModel(title: "Mutual Funds", subtitle: nil, icon: "banknote"),
        InterestModel(title: "Forex", subtitle: nil, icon: "dollarsign.arrow.circlepath"),
        InterestModel(title: "Bonds", subtitle: nil, icon: "doc.text"),
        InterestModel(title: "ETFs", subtitle: nil, icon: "chart.bar.doc.horizontal"),
        InterestModel(title: "Insurance", subtitle: nil, icon: "shield"),
        InterestModel(title: "FinTech", subtitle: nil, icon: "iphone"),
        InterestModel(title: "Startups", subtitle: nil, icon: "rocket"),
        InterestModel(title: "Venture Capital", subtitle: nil, icon: "briefcase"),
        InterestModel(title: "Private Equity", subtitle: nil, icon: "building.columns.fill"),
        InterestModel(title: "Taxation", subtitle: nil, icon: "percent"),
        InterestModel(title: "Personal Finance", subtitle: nil, icon: "wallet.pass"),
        InterestModel(title: "Real Estate", subtitle: nil, icon: "building.2"),
        InterestModel(title: "International Trade", subtitle: nil, icon: "shippingbox.fill"),
        InterestModel(title: "Business", subtitle: nil, icon: "bag"),
        InterestModel(title: "Economics", subtitle: nil, icon: "chart.pie"),
        InterestModel(title: "AI & Tech", subtitle: nil, icon: "cpu"),
        InterestModel(title: "Energy", subtitle: nil, icon: "bolt"),
        InterestModel(title: "Oil & Gas", subtitle: nil, icon: "flame"),
        InterestModel(title: "Gold & Silver", subtitle: nil, icon: "circle.hexagongrid"),
        InterestModel(title: "Agriculture", subtitle: nil, icon: "leaf"),
        InterestModel(title: "Manufacturing", subtitle: nil, icon: "gearshape.2"),
        InterestModel(title: "Supply Chain", subtitle: nil, icon: "arrow.triangle.branch"),
        InterestModel(title: "Retail", subtitle: nil, icon: "cart"),
        InterestModel(title: "E-Commerce", subtitle: nil, icon: "cart.fill"),
        InterestModel(title: "Automobile", subtitle: nil, icon: "car"),
        InterestModel(title: "Electric Vehicles", subtitle: nil, icon: "ev.charger"),
        InterestModel(title: "Aviation", subtitle: nil, icon: "airplane"),
        InterestModel(title: "Healthcare", subtitle: nil, icon: "cross.case"),
        InterestModel(title: "Pharma", subtitle: nil, icon: "pills"),
        InterestModel(title: "Biotech", subtitle: nil, icon: "testtube.2"),
        InterestModel(title: "Telecom", subtitle: nil, icon: "antenna.radiowaves.left.and.right"),
        InterestModel(title: "Media", subtitle: nil, icon: "tv"),
        InterestModel(title: "Entertainment", subtitle: nil, icon: "music.note.tv"),
        InterestModel(title: "Consumer Goods", subtitle: nil, icon: "bag.fill"),
        InterestModel(title: "Luxury Brands", subtitle: nil, icon: "crown"),
        InterestModel(title: "Climate Economy", subtitle: nil, icon: "globe.americas"),
        InterestModel(title: "ESG Investing", subtitle: nil, icon: "leaf.circle"),
        InterestModel(title: "Green Energy", subtitle: nil, icon: "sun.max"),
        InterestModel(title: "Space Economy", subtitle: nil, icon: "sparkles"),
        InterestModel(title: "Defense", subtitle: nil, icon: "shield.lefthalf.filled"),
        InterestModel(title: "Infrastructure", subtitle: nil, icon: "building.2.crop.circle"),
        InterestModel(title: "Logistics", subtitle: nil, icon: "truck.box"),
        InterestModel(title: "Hospitality", subtitle: nil, icon: "bed.double"),
        InterestModel(title: "Tourism", subtitle: nil, icon: "map"),
        InterestModel(title: "Education", subtitle: nil, icon: "book"),
        InterestModel(title: "EdTech", subtitle: nil, icon: "desktopcomputer"),
        InterestModel(title: "Gaming", subtitle: nil, icon: "gamecontroller"),
        InterestModel(title: "Sports Business", subtitle: nil, icon: "sportscourt"),
        InterestModel(title: "Digital Payments", subtitle: nil, icon: "creditcard"),
        InterestModel(title: "Blockchain", subtitle: nil, icon: "link"),
        InterestModel(title: "Web3", subtitle: nil, icon: "network"),
        InterestModel(title: "IPO Market", subtitle: nil, icon: "chart.bar.xaxis"),
        InterestModel(title: "Wealth Management", subtitle: nil, icon: "person.crop.circle.badge.dollar"),
        InterestModel(title: "Risk Management", subtitle: nil, icon: "exclamationmark.shield"),
        InterestModel(title: "Economic Policy", subtitle: nil, icon: "doc.plaintext")
    ]

    static let preferences: [InterestModel] = [
        InterestModel(title: "Indian Economy",
                      subtitle: "Inflation, GDP and growth trends",
                      icon: "indianrupeesign.gauge.chart.lefthalf.righthalf"),
        InterestModel(title: "Stock Markets", subtitle: "Shares, indices and market cycles", icon: "chart.line.uptrend.xyaxis"),
        InterestModel(title: "Personal Finance", subtitle: "Savings, budgeting and wealth building", icon: "wallet.pass"),
        InterestModel(title: "Government Policy", subtitle: "Reforms, taxation and public spending", icon: "newspaper"),
        InterestModel(title: "Banking & Credit", subtitle: "Loans, rates and money flow", icon: "building.columns"),
        InterestModel(title: "Crypto Trends", subtitle: "Bitcoin, Web3 and digital assets", icon: "bitcoinsign.circle"),
        InterestModel(title: "Global Economy", subtitle: "Trade, geopolitics and growth", icon: "globe.central.south.asia.fill"),
        InterestModel(title: "Real Estate Economics", subtitle: "Housing demand and interest rates", icon: "building.2"),
        InterestModel(title: "Startup Ecosystem", subtitle: "Funding, founders and innovation", icon: "rocket"),
        InterestModel(title: "FinTech Innovation", subtitle: "UPI, digital banking and payments", icon: "iphone"),
        InterestModel(title: "Retirement Planning", subtitle: "Long-term investing and pensions", icon: "calendar"),
        InterestModel(title: "Mutual Fund Investing", subtitle: "SIP, equity and debt funds", icon: "chart.pie"),
        InterestModel(title: "Commodity Markets", subtitle: "Gold, oil and agricultural goods", icon: "shippingbox"),
        InterestModel(title: "Forex Markets", subtitle: "Currencies and exchange rates", icon: "dollarsign.arrow.circlepath"),
        InterestModel(title: "AI Industry", subtitle: "Artificial intelligence and automation", icon: "cpu"),
        InterestModel(title: "Electric Vehicles", subtitle: "EV growth and battery markets", icon: "ev.charger"),
        InterestModel(title: "Green Energy", subtitle: "Solar, wind and sustainability", icon: "sun.max"),
        InterestModel(title: "ESG Investing", subtitle: "Ethical and sustainable investing", icon: "leaf.circle"),
        InterestModel(title: "IPO Analysis", subtitle: "Upcoming listings and valuations", icon: "chart.bar.xaxis"),
        InterestModel(title: "Business Strategy", subtitle: "Expansion, competition and scaling", icon: "briefcase"),
        InterestModel(title: "Consumer Trends", subtitle: "Spending habits and demand shifts", icon: "cart"),
        InterestModel(title: "Tax Planning", subtitle: "Deductions, compliance and savings", icon: "percent"),
        InterestModel(title: "Global Trade", subtitle: "Exports, imports and tariffs", icon: "shippingbox.fill"),
        InterestModel(title: "Supply Chain", subtitle: "Logistics and manufacturing flow", icon: "arrow.triangle.branch"),
        InterestModel(title: "Luxury Markets", subtitle: "Premium brands and demand", icon: "crown"),
        InterestModel(title: "Healthcare Industry", subtitle: "Hospitals, pharma and biotech", icon: "cross.case"),
        InterestModel(title: "Pharma Stocks", subtitle: "Drug companies and regulations", icon: "pills"),
        InterestModel(title: "Space Economy", subtitle: "Satellites and private space firms", icon: "sparkles"),
        InterestModel(title: "Defense Sector", subtitle: "Military tech and contracts", icon: "shield.lefthalf.filled"),
        InterestModel(title: "Infrastructure Growth", subtitle: "Roads, railways and urban projects", icon: "building.2.crop.circle"),
        InterestModel(title: "Digital Payments", subtitle: "UPI, wallets and fintech apps", icon: "creditcard"),
        InterestModel(title: "Blockchain Technology", subtitle: "Decentralized systems and smart contracts", icon: "link"),
        InterestModel(title: "E-Commerce", subtitle: "Online retail and marketplaces", icon: "cart.fill"),
        InterestModel(title: "Media & Entertainment", subtitle: "Streaming and digital content", icon: "tv"),
        InterestModel(title: "Sports Business", subtitle: "Leagues, sponsorships and media rights", icon: "sportscourt"),
        InterestModel(title: "Travel Economy", subtitle: "Tourism and hospitality growth", icon: "airplane"),
        InterestModel(title: "EdTech", subtitle: "Online learning and digital education", icon: "desktopcomputer"),
        InterestModel(title: "Gaming Industry", subtitle: "Esports and gaming companies", icon: "gamecontroller"),
        InterestModel(title: "Retail Industry", subtitle: "Consumer brands and shopping trends", icon: "bag"),
        InterestModel(title: "Climate Economics", subtitle: "Carbon markets and sustainability", icon: "globe.americas"),
        InterestModel(title: "Oil & Energy", subtitle: "Crude oil and power markets", icon: "flame"),
        InterestModel(title: "Agriculture Economy", subtitle: "Farming, exports and food supply", icon: "leaf"),
        InterestModel(title: "Economic History", subtitle: "Past crises and financial systems", icon: "clock.arrow.circlepath"),
        InterestModel(title: "Behavioral Finance", subtitle: "Psychology behind investing", icon: "brain.head.profile"),
        InterestModel(title: "Venture Capital", subtitle: "Startup funding and investors", icon: "briefcase.fill"),
        InterestModel(title: "Wealth Management", subtitle: "Portfolio and asset planning", icon: "person.crop.circle.badge.dollar"),
        InterestModel(title: "International Markets", subtitle: "US, Europe and Asian economies", icon: "network"),
        InterestModel(title: "Economic Indicators", subtitle: "CPI, PMI and employment data", icon: "waveform.path.ecg"),
        InterestModel(title: "Monetary Policy", subtitle: "Central banks and interest rates", icon: "banknote"),
        InterestModel(title: "Corporate Finance", subtitle: "Balance sheets and valuations", icon: "doc.text"),
        InterestModel(title: "Market Psychology", subtitle: "Fear, greed and investor sentiment", icon: "eye"),
        InterestModel(title: "Alternative Investments", subtitle: "Art, collectibles and private assets", icon: "diamond"),
        InterestModel(title: "Future Technologies", subtitle: "Innovation shaping economies", icon: "sparkles.tv")
    ]
}

// In-app (non-persisted) user selections used by the Profile Interests screens.
// The "Add" flow should still show the full master list from InterestsDataSource.
struct UserInterests {
    static var domains: [InterestModel] = []
    static var preferences: [InterestModel] = []
}

extension Notification.Name {
    static let userInterestsDidChange = Notification.Name("userInterestsDidChange")
}

struct User {
    static var current = UserProfile(
        image: "profile",
        name: "Anandita Babar",
        phone: "8446153201",
        email: "anandita0902@gmail.com",
        level: .beginner,
        dob: "09/02/2025",
        gender: .female
    )
}

struct ProgressSectionMockData {
    static let mockProgress = ProgressSectionModel(
        progressPercentage: 0.775,
        progressLevel: 5,
        requirementNextLevel: ""
    )
}

struct Bookmarks {
    static let mockBookmarks: [BookmarkItem] = [
        BookmarkItem(
            icon: UIImage(systemName: "folder") ?? UIImage(),
            id: "1",
            title: "Stocks"
        ),
        BookmarkItem(
            icon: UIImage(systemName: "folder") ?? UIImage(),
            id: "2",
            title: "Crypto"
        ),
        BookmarkItem(
            icon: UIImage(systemName: "folder") ?? UIImage(),
            id: "3",
            title: "Gold"
        )
    ]
}

struct ProgressMockData {
    static let overallProgress = OverallProgress(
        progressPercentage: 0.775,
        quizCompletionNumber: "2/3 Completed",
        levelNumber: 5
    )

    static let stats = ProgressStats(
        dayStreak: 12,
        totalXP: 2400,
        accuracyPercentage: 82
    )

    static let quizzes: [Quiz] = [
        Quiz(title: "Quiz 1", date: "17 Dec 2025", accuracy: 82),
        Quiz(title: "Quiz 2", date: "15 Dec 2025", accuracy: 76),
        Quiz(title: "Quiz 3", date: "13 Dec 2025", accuracy: 91),
        Quiz(title: "Quiz 4", date: "10 Dec 2025", accuracy: 68)
    ]
}
