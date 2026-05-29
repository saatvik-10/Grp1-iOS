//
//  dataStored.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 28/11/25.
import Foundation

struct ThreadPost {
    let id: Int
    let userName: String
    let userProfileImage: String
    let timeAgo: String
    let title: String
    let tags: [String]
    let imageName: String?
    let description: String
    var likes: Int
   var comments: [Comment]
    let shares: Int

    var isLiked: Bool
}

struct Draft {
    let id: UUID
    var title: String?
    var topic: String?
    var body: String?
    var imageName: String?
    var lastUpdated: Date
}
