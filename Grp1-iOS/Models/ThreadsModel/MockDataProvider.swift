//
//  MockDataProvider.swift
//  Grp1-iOS
//

import Foundation

struct MockDataProvider {

    // MARK: - Users

    static let anandita = AppUser(
        userName: "Anandita Babar",
        profileImage: "beach_1",
        bio: "Personal finance enthusiast. Long-term investor. iOS dev on the side.",
        followerNames: [
            "Rishabh Kothari", "Ishan Magarde", "Tanmay Verma", "Mitali Shah",
            "Priya Nair", "Arjun Mehta", "Sneha Rao", "Vikram Desai",
            "Neha Joshi", "Rahul Gupta", "Pooja Sharma", "Karan Malhotra",
            "Divya Pillai", "Siddharth Bose", "Meera Iyer", "Aakash Tiwari",
            "Riya Kapoor", "Nikhil Saxena", "Swati Patil", "Harsh Agarwal"
        ],
        followingNames: [
            "Rishabh Kothari", "Ishan Magarde", "Tanmay Verma", "Mitali Shah",
            "Priya Nair", "Arjun Mehta", "Sneha Rao", "Vikram Desai",
            "Neha Joshi", "Rahul Gupta", "Pooja Sharma", "Karan Malhotra",
            "Divya Pillai", "Siddharth Bose", "Meera Iyer", "Aakash Tiwari",
            "Riya Kapoor", "Nikhil Saxena", "Swati Patil", "Harsh Agarwal",
            "Zara Khan", "Rohan Verma"
        ]
    )

    static let rishabh = AppUser(
        userName: "Rishabh Kothari",
        profileImage: "person.fill",
        bio: "Macro economist. Writing about global markets and India's growth story.",
        followerNames: ["Anandita Babar", "Ishan Magarde", "Tanmay Verma", "Priya Nair", "Arjun Mehta"],
        followingNames: ["Anandita Babar", "Ishan Magarde"]
    )

    static let ishan = AppUser(
        userName: "Ishan Magarde",
        profileImage: "person.fill",
        bio: "Nifty watcher. Markets, momentum and money.",
        followerNames: ["Anandita Babar", "Rishabh Kothari", "Mitali Shah"],
        followingNames: ["Anandita Babar", "Rishabh Kothari", "Tanmay Verma"]
    )

    static let tanmay = AppUser(
        userName: "Tanmay Verma",
        profileImage: "person.fill",
        bio: "AI + investing. Tracking where capital meets technology.",
        followerNames: ["Anandita Babar", "Rishabh Kothari"],
        followingNames: ["Anandita Babar", "Ishan Magarde"]
    )

    static let mitali = AppUser(
        userName: "Mitali Shah",
        profileImage: "person.fill",
        bio: "Fundamental analysis. Balance sheets don't lie.",
        followerNames: ["Anandita Babar", "Ishan Magarde"],
        followingNames: ["Anandita Babar", "Rishabh Kothari"]
    )

    // MARK: - Comments

    static let commentsOnPost1: [Comment] = [
        Comment(
            id: UUID(),
            userName: "Anandita Babar",
            userProfileImage: "beach_1",
            text: "Really well put Rishabh. The Fed pivot timeline is what I'm watching most closely right now.",
            likes: 14,
            isLiked: true,
            replies: [
                Reply(
                    id: UUID(),
                    userName: "Rishabh Kothari",
                    userProfileImage: "person.fill",
                    text: "Agreed — Q3 is the key window. Any delay and EM currencies take a hit.",
                    likes: 6,
                    isLiked: false
                )
            ]
        ),
        Comment(
            id: UUID(),
            userName: "Ishan Magarde",
            userProfileImage: "person.fill",
            text: "China's property sector drag is the wildcard nobody's pricing in properly.",
            likes: 9,
            isLiked: false,
            replies: []
        ),
        Comment(
            id: UUID(),
            userName: "Tanmay Verma",
            userProfileImage: "person.fill",
            text: "If the US tips into recession, AI capex is the first thing that gets cut. Markets haven't figured that out yet.",
            likes: 22,
            isLiked: false,
            replies: []
        )
    ]

    static let commentsOnPost2: [Comment] = [
        Comment(
            id: UUID(),
            userName: "Anandita Babar",
            userProfileImage: "beach_1",
            text: "SIP investors shouldn't panic — valuations correct over time. Stay the course.",
            likes: 31,
            isLiked: true,
            replies: [
                Reply(
                    id: UUID(),
                    userName: "Ishan Magarde",
                    userProfileImage: "person.fill",
                    text: "100% Anandita. Volatility is the price of admission for equity returns.",
                    likes: 11,
                    isLiked: false
                )
            ]
        ),
        Comment(
            id: UUID(),
            userName: "Mitali Shah",
            userProfileImage: "person.fill",
            text: "Mid-caps look stretched. I'm rotating to large-cap quality names for now.",
            likes: 18,
            isLiked: false,
            replies: []
        )
    ]

    static let commentsOnPost102: [Comment] = [
        Comment(
            id: UUID(),
            userName: "Rishabh Kothari",
            userProfileImage: "person.fill",
            text: "Asset allocation is so underrated. Most retail investors skip it entirely.",
            likes: 27,
            isLiked: false,
            replies: [
                Reply(
                    id: UUID(),
                    userName: "Anandita Babar",
                    userProfileImage: "beach_1",
                    text: "Exactly why I start every year rebalancing before I do anything else.",
                    likes: 15,
                    isLiked: false
                )
            ]
        ),
        Comment(
            id: UUID(),
            userName: "Tanmay Verma",
            userProfileImage: "person.fill",
            text: "Time in the market > timing the market. Always.",
            likes: 44,
            isLiked: false,
            replies: []
        )
    ]

    static let commentsOnPost103: [Comment] = [
        Comment(
            id: UUID(),
            userName: "Ishan Magarde",
            userProfileImage: "person.fill",
            text: "Buffett has said this for decades and people still panic-sell every dip.",
            likes: 19,
            isLiked: false,
            replies: []
        )
    ]

}
