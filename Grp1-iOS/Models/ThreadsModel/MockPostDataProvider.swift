//
//  MockPostDataProvider.swift
//  Grp1-iOS
//

import Foundation

struct MockPostDataProvider {

    static let allPosts: [ThreadPost] = [
        ThreadPost(
            id: 1,
            userName: "Rishabh Kothari",
            userProfileImage: "person.fill",
            timeAgo: "15h ago",
            title: "Is the global economy heading for a slowdown?",
            tags: ["Economy", "Global Markets"],
            imageName: "urban_5",
            description: "Rising interest rates, slowing trade, and a weakening yuan "
                + "are converging in ways that make 2025 look increasingly fragile for global growth.",
            likes: 702,
            comments: MockDataProvider.commentsOnPost1,
            shares: 11,
            isLiked: true
        ),
        ThreadPost(
            id: 2,
            userName: "Ishan Magarde",
            userProfileImage: "person.fill",
            timeAgo: "19h ago",
            title: "Is the stock market rally sustainable?",
            tags: ["Markets", "Nifty"],
            imageName: "img(F5)",
            description: "Indian indices continue to hit record highs, but stretched "
                + "valuations and global cues raise questions about how long this rally can last.",
            likes: 518,
            comments: MockDataProvider.commentsOnPost2,
            shares: 6,
            isLiked: false
        ),
        ThreadPost(
            id: 3,
            userName: "Tanmay Verma",
            userProfileImage: "person.fill",
            timeAgo: "1d ago",
            title: "Why AI stocks are attracting massive capital",
            tags: ["AI", "Investing"],
            imageName: "beach_7",
            description: "From chips to software platforms, investors are betting big on "
                + "AI-led growth — but valuations are starting to price in perfection.",
            likes: 332,
            comments: [],
            shares: 4,
            isLiked: false
        ),
        ThreadPost(
            id: 4,
            userName: "Mitali Shah",
            userProfileImage: "person.fill",
            timeAgo: "3h ago",
            title: "How strong balance sheets protect investors",
            tags: ["Fundamentals", "Stocks"],
            imageName: "beach_13",
            description: "Companies with low debt and healthy cash flows tend to survive "
                + "market downturns better and reward long-term investors.",
            likes: 190,
            comments: [],
            shares: 2,
            isLiked: false
        ),
        ThreadPost(
            id: 5,
            userName: "Rishabh Kothari",
            userProfileImage: "person.fill",
            timeAgo: "2d ago",
            title: "RBI's rate decision: what it means for borrowers",
            tags: ["RBI", "Interest Rates", "Banking"],
            imageName: "rbi-1722414243",
            description: "The MPC held rates steady for the third consecutive meeting. "
                + "Here's what that means for home loan EMIs, corporate credit, and the rupee.",
            likes: 841,
            comments: [],
            shares: 34,
            isLiked: true
        ),
        ThreadPost(
            id: 6,
            userName: "Rishabh Kothari",
            userProfileImage: "person.fill",
            timeAgo: "4d ago",
            title: "India's inflation is finally under control — or is it?",
            tags: ["Inflation", "Economy", "RBI"],
            imageName: "urban_5",
            description: "CPI has dipped below 4% for two consecutive months, but food "
                + "price volatility and a weak monsoon forecast could reverse gains quickly.",
            likes: 390,
            comments: [],
            shares: 9,
            isLiked: false
        ),
        ThreadPost(
            id: 101,
            userName: "Anandita Babar",
            userProfileImage: "beach_1",
            timeAgo: "2d ago",
            title: "Building Threads UI in UIKit",
            tags: ["iOS", "UIKit"],
            imageName: "beach_9",
            description: "Lessons learnt while building a Threads-style feed — diffable "
                + "data sources, custom cells, and why Auto Layout still trips me up.",
            likes: 120,
            comments: [],
            shares: 3,
            isLiked: false
        ),
        ThreadPost(
            id: 102,
            userName: "Anandita Babar",
            userProfileImage: "beach_1",
            timeAgo: "3d ago",
            title: "How I plan my long-term investments",
            tags: ["Long Term", "Personal Finance"],
            imageName: "beach_9",
            description: "Consistency, asset allocation, and patience matter more than "
                + "chasing short-term returns. Here's my actual framework.",
            likes: 210,
            comments: MockDataProvider.commentsOnPost102,
            shares: 6,
            isLiked: false
        ),
        ThreadPost(
            id: 103,
            userName: "Anandita Babar",
            userProfileImage: "beach_1",
            timeAgo: "5d ago",
            title: "Why market volatility is not your enemy",
            tags: ["Markets", "Psychology"],
            imageName: "urban_2",
            description: "Volatility creates fear, but for disciplined investors it often "
                + "presents the best opportunities to buy quality businesses at fair prices.",
            likes: 98,
            comments: MockDataProvider.commentsOnPost103,
            shares: 1,
            isLiked: false
        ),
        ThreadPost(
            id: 104,
            userName: "Anandita Babar",
            userProfileImage: "beach_1",
            timeAgo: "1w ago",
            title: "Mutual funds vs direct stocks — what I chose",
            tags: ["Mutual Funds", "Stocks"],
            imageName: "images",
            description: "Both approaches have merits. The right choice depends on your "
                + "risk appetite, time availability, and how much you enjoy reading annual reports.",
            likes: 305,
            comments: [],
            shares: 10,
            isLiked: false
        ),
        ThreadPost(
            id: 105,
            userName: "Anandita Babar",
            userProfileImage: "beach_1",
            timeAgo: "2w ago",
            title: "The mindset needed to build wealth",
            tags: ["Mindset", "Wealth"],
            imageName: "beach_15",
            description: "Wealth creation is less about predicting markets and more about "
                + "discipline, patience, and keeping your emotions out of your portfolio.",
            likes: 445,
            comments: [],
            shares: 18,
            isLiked: false
        )
    ]
}
