//
//  MockEnvironment.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 18/03/26.
//

import Foundation

// MARK: - User model

struct AppUser {
    let userName: String
    let profileImage: String
    let bio: String
    let followerNames: [String]
    let followingNames: [String]

    var followerCount: Int { followerNames.count }
    var followingCount: Int { followingNames.count }
}

// MARK: - Mock environment

final class MockEnvironment {

    static let shared = MockEnvironment()
    private init() {}

    // MARK: - Users

    var anandita: AppUser { MockDataProvider.anandita }
    var rishabh: AppUser { MockDataProvider.rishabh }
    var ishan: AppUser { MockDataProvider.ishan }
    var tanmay: AppUser { MockDataProvider.tanmay }
    var mitali: AppUser { MockDataProvider.mitali }

    // MARK: - Comments

    var commentsOnPost1: [Comment] { MockDataProvider.commentsOnPost1 }
    var commentsOnPost2: [Comment] { MockDataProvider.commentsOnPost2 }
    var commentsOnPost102: [Comment] { MockDataProvider.commentsOnPost102 }
    var commentsOnPost103: [Comment] { MockDataProvider.commentsOnPost103 }

    // MARK: - Thread posts

    var allPosts: [ThreadPost] { MockPostDataProvider.allPosts }

    // MARK: - Pre-built profile

    lazy var ananditaProfile = DynamicUserProfile(
        interests: [.stockMarkets, .personalFinance, .indianEconomy, .bankingCredit],
        level: .intermediate
    )

    func blogArticles(from posts: [ThreadPost]) -> [BlogArticle] {
        posts.map { post in
            BlogArticle(
                id: String(post.id),
                title: post.title,
                body: post.description,
                category: post.tags.first ?? "General",
                publishedAt: approximateDate(from: post.timeAgo),
                complexityTier: complexityTier(for: post.tags),
                inferredTags: []
            )
        }
    }

    // MARK: - Helpers

    private func approximateDate(from timeAgo: String) -> Date {
        let calendar = Calendar.current
        let now = Date()
        if timeAgo.contains("h ago") {
            let hours = Int(timeAgo.components(separatedBy: "h").first ?? "1") ?? 1
            return calendar.date(byAdding: .hour, value: -hours, to: now) ?? now
        } else if timeAgo.contains("d ago") {
            let days = Int(timeAgo.components(separatedBy: "d").first ?? "1") ?? 1
            return calendar.date(byAdding: .day, value: -days, to: now) ?? now
        } else if timeAgo.contains("w ago") {
            let weeks = Int(timeAgo.components(separatedBy: "w").first ?? "1") ?? 1
            return calendar.date(byAdding: .weekOfYear, value: -weeks, to: now) ?? now
        }
        return now
    }

    private func complexityTier(for tags: [String]) -> Int {
        let advancedTags = Set([
            "Fundamentals", "Macro", "RBI", "Interest Rates",
            "Monetary Policy", "Inflation"
        ])
        let beginnerTags = Set(["Mindset", "Wealth", "Psychology", "Long Term"])
        let lowered = Set(tags.map { $0.lowercased() })
        let advancedLowered = Set(advancedTags.map { $0.lowercased() })
        let beginnerLowered = Set(beginnerTags.map { $0.lowercased() })
        if !lowered.isDisjoint(with: advancedLowered) { return 2 }
        if !lowered.isDisjoint(with: beginnerLowered) { return 0 }
        return 1
    }
}
