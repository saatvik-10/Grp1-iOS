//
//  model.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 28/11/25.
//

import Foundation

final class ThreadsDataStore {

    static let shared = ThreadsDataStore()

    private let env = MockEnvironment.shared

    // MARK: - State

    private var threadPosts: [ThreadPost]
    private var drafts: [Draft]
    private var followedUsers: Set<String>

    // MARK: - Current user (single source of truth)

    var currentUserName: String { env.anandita.userName }
    var currentUserProfileImage: String { env.anandita.profileImage }

    // MARK: - Init

    private init() {
        // All posts come from MockEnvironment
        threadPosts = MockEnvironment.shared.allPosts

        // Anandita follows everyone in her followingNames list
        followedUsers = Set(MockEnvironment.shared.anandita.followingNames)

        // One pre-seeded draft
        drafts = [
            Draft(
                id: UUID(),
                title: "Saved draft",
                topic: "iOS",
                body: "This is a preloaded draft",
                imageName: "rbi-1722414243",
                lastUpdated: Date()
            )
        ]
    }

    // MARK: - Posts

    private func index(of id: Int) -> Int? {
        threadPosts.firstIndex { $0.id == id }
    }

    func getForYouThreads() -> [ThreadPost] {
        threadPosts.filter { $0.userName != currentUserName }
    }

    func getFollowingThreads() -> [ThreadPost] {
        threadPosts.filter { followedUsers.contains($0.userName) }
    }

    func getMyThreads() -> [ThreadPost] {
        threadPosts.filter { $0.userName == currentUserName }
    }

    func getAllPostsForSearch() -> [ThreadPost] {
        threadPosts
    }

    func addNewThread(_ thread: ThreadPost) {
        threadPosts.insert(thread, at: 0)
    }

    func postThreadFromCreate(
        title: String,
        body: String,
        imageName: String?,
        tags: [String]
    ) {
        let newThread = ThreadPost(
            id: Int(Date().timeIntervalSince1970),
            userName: currentUserName,
            userProfileImage: currentUserProfileImage,
            timeAgo: "Just now",
            title: title,
            tags: tags,
            imageName: imageName,
            description: body,
            likes: 0,
            comments: [],
            shares: 0,
            isLiked: false
        )
        addNewThread(newThread)
    }

    func deletePost(id: Int) {
        threadPosts.removeAll { $0.id == id }
    }

    func toggleLike(for threadID: Int) {
        guard let index = index(of: threadID) else { return }
        threadPosts[index].isLiked.toggle()
        threadPosts[index].likes += threadPosts[index].isLiked ? 1 : -1
    }

    // MARK: - Comments

    func getComments(for postID: Int) -> [Comment] {
        guard let index = index(of: postID) else { return [] }
        return threadPosts[index].comments
    }

    func addComment(to postID: Int, text: String) {
        guard let index = index(of: postID) else { return }
        let newComment = Comment(
            id: UUID(),
            userName: currentUserName,
            userProfileImage: currentUserProfileImage,
            text: text,
            likes: 0,
            isLiked: false,
            replies: []
        )
        threadPosts[index].comments.insert(newComment, at: 0)
    }

    func toggleLikeOnComment(postID: Int, commentID: UUID) {
        guard let pi = index(of: postID),
              let ci = threadPosts[pi].comments.firstIndex(where: { $0.id == commentID })
        else { return }
        threadPosts[pi].comments[ci].isLiked.toggle()
        threadPosts[pi].comments[ci].likes += threadPosts[pi].comments[ci].isLiked ? 1 : -1
    }

    func addReply(to postID: Int, commentID: UUID, text: String) {
        guard let pi = index(of: postID),
              let ci = threadPosts[pi].comments.firstIndex(where: { $0.id == commentID })
        else { return }
        let reply = Reply(
            id: UUID(),
            userName: currentUserName,
            userProfileImage: currentUserProfileImage,
            text: text,
            likes: 0,
            isLiked: false
        )
        threadPosts[pi].comments[ci].replies.append(reply)
    }

    // MARK: - Follow / Unfollow

    func isFollowing(_ userName: String) -> Bool {
        followedUsers.contains(userName)
    }

    func toggleFollow(_ userName: String) {
        if followedUsers.contains(userName) {
            followedUsers.remove(userName)
        } else {
            followedUsers.insert(userName)
        }
    }

    // MARK: - Drafts

    func getDrafts() -> [Draft] { drafts }

    func saveDraft(title: String?, topic: String?, body: String?, imageName: String?) {
        drafts.insert(
            Draft(id: UUID(), title: title, topic: topic, body: body, imageName: imageName, lastUpdated: Date()),
            at: 0
        )
    }

    func updateDraft(id: UUID, title: String?, topic: String?, body: String?, imageName: String?) {
        guard let index = drafts.firstIndex(where: { $0.id == id }) else { return }
        drafts[index].title       = title
        drafts[index].topic       = topic
        drafts[index].body        = body
        drafts[index].imageName   = imageName
        drafts[index].lastUpdated = Date()
    }

    func deleteDraft(id: UUID) {
        drafts.removeAll { $0.id == id }
    }

    // MARK: - Recommendation engine integration

    /// Returns ranked BlogArticles for Anandita's "For You" feed using the engine.
    /// Call this from your ForYou view controller instead of getForYouThreads()
    /// when you want personalised ordering.
    func getPersonalisedForYouFeed(profile: inout DynamicUserProfile) -> [ScoredArticle] {
        let candidates = getForYouThreads()
        let articles   = MockEnvironment.shared.blogArticles(from: candidates)
        return BlogRecommendationEngine.shared.recommend(
            articles: articles,
            profile: &profile,
            limit: 20
        )
    }
}
