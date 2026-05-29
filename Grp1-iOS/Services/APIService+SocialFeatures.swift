import Foundation

// MARK: - Comments & Likes

extension APIService {

    func createComment(
        payload: APICreateCommentRequest,
        token: String,
        completion: @escaping (Result<APIThreadComment, APIError>) -> Void
    ) {
        request(method: .post, path: "/api/comment", token: token, body: payload, completion: completion)
    }

    func fetchComments(
        threadId: String,
        token: String? = nil,
        completion: @escaping (Result<[APIThreadComment], APIError>) -> Void
    ) {
        request(
            method: .get,
            path: "/api/comments",
            token: token,
            queryItems: [URLQueryItem(name: "threadId", value: threadId)],
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    func toggleCommentLike(
        commentId: String,
        token: String,
        completion: @escaping (Result<APICommentLikeResponse, APIError>) -> Void
    ) {
        request(
            method: .post,
            path: "/api/comment/like",
            token: token,
            body: APICommentLikeRequest(commentId: commentId),
            completion: completion
        )
    }

    func toggleLike(
        threadId: String,
        token: String,
        completion: @escaping (Result<APIThreadLikeResponse, APIError>) -> Void
    ) {
        print("🔁 Toggling like for threadId: \(threadId)")
        request(
            method: .post,
            path: "/api/like",
            token: token,
            body: APIThreadLikeRequest(threadId: threadId),
            completion: completion
        )
    }
}

// MARK: - Follow

extension APIService {

    func updateFollow(
        followingId: String,
        token: String,
        completion: @escaping (Result<APIFollowResponse, APIError>) -> Void
    ) {
        request(
            method: .post,
            path: "/api/follow",
            token: token,
            body: APIFollowRequest(followingId: followingId),
            completion: completion
        )
    }

    func fetchAllFollowers(
        token: String,
        completion: @escaping (Result<[APIUserBasicInfo], APIError>) -> Void
    ) {
        request(
            method: .get,
            path: "/api/all-followers",
            token: token,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    func fetchAllFollowing(
        token: String,
        completion: @escaping (Result<[APIUserBasicInfo], APIError>) -> Void
    ) {
        request(
            method: .get,
            path: "/api/all-following",
            token: token,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }
}

// MARK: - User Profile

extension APIService {

    func fetchUserProfile(
        userId: String,
        token: String,
        completion: @escaping (Result<APIUserProfileResponse, APIError>) -> Void
    ) {
        request(
            method: .get,
            path: "/api/profile/users/\(userId)/profile",
            token: token,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    func fetchUserFollowers(
        userId: String,
        token: String,
        completion: @escaping (Result<[APIUserBasicInfo], APIError>) -> Void
    ) {
        request(
            method: .get,
            path: "/api/profile/users/\(userId)/followers",
            token: token,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    func fetchUserFollowing(
        userId: String,
        token: String,
        completion: @escaping (Result<[APIUserBasicInfo], APIError>) -> Void
    ) {
        request(
            method: .get,
            path: "/api/profile/users/\(userId)/following",
            token: token,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    func fetchUserInterests(
        token: String,
        type: APIInterestType? = nil,
        completion: @escaping (Result<[APIInterest], APIError>) -> Void
    ) {
        let queryItems: [URLQueryItem] = type.map {
            [URLQueryItem(name: "type", value: $0.rawValue)]
        } ?? []
        request(
            method: .get,
            path: "/api/interests",
            token: token,
            queryItems: queryItems,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }
}

// MARK: - Articles

extension APIService {

    func postArticleChatQuestion(
        question: String,
        answer: String,
        completion: @escaping (Result<String, APIError>) -> Void
    ) {
        let body = APIArticleChatQuestionRequest(question: question, answer: answer)
        request(method: .post, path: "/api/chat/question", body: body) { result in
            completion(result)
        }
    }

    func fetchArticleChatQuestions(
        completion: @escaping (Result<[APIArticleChatQuestion], APIError>) -> Void
    ) {
        request(
            method: .get,
            path: "/api/chat/questions",
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }
}

// MARK: - Bookmark Folders

extension APIService {

    func fetchBookmarkFolders(
        token: String,
        completion: @escaping (Result<[APIBookmarkFolder], APIError>) -> Void
    ) {
        request(
            method: .get,
            path: "/api/bookmarks/folders",
            token: token,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    func createBookmarkFolder(
        name: String,
        token: String,
        completion: @escaping (Result<APIBookmarkFolder, APIError>) -> Void
    ) {
        request(
            method: .post,
            path: "/api/bookmarks/folders",
            token: token,
            body: APICreateBookmarkFolderRequest(name: name),
            completion: completion
        )
    }

    func deleteBookmarkFolder(
        folderId: String,
        token: String,
        completion: @escaping (Result<Void, APIError>) -> Void
    ) {
        requestStatus(
            method: .delete,
            path: "/api/bookmarks/folders/\(folderId)",
            token: token,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }
}

// MARK: - Bookmarks

extension APIService {

    func fetchBookmarks(
        folderId: String,
        token: String,
        completion: @escaping (Result<[APIBookmark], APIError>) -> Void
    ) {
        request(
            method: .get,
            path: "/api/bookmarks",
            token: token,
            queryItems: [URLQueryItem(name: "folderId", value: folderId)],
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    func createBookmark(
        payload: APICreateBookmarkRequest,
        token: String,
        completion: @escaping (Result<APIBookmark, APIError>) -> Void
    ) {
        request(method: .post, path: "/api/bookmarks", token: token, body: payload, completion: completion)
    }

    func fetchBookmarkedArticles(
        token: String,
        folderId: String? = nil,
        completion: @escaping (Result<[APIBookmarkedArticle], APIError>) -> Void
    ) {
        let queryItems: [URLQueryItem] = folderId.map {
            [URLQueryItem(name: "folderId", value: $0)]
        } ?? []
        request(
            method: .get,
            path: "/api/bookmarks/articles",
            token: token,
            queryItems: queryItems,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    func createBookmarkedArticle(
        payload: APICreateBookmarkedArticleRequest,
        token: String,
        completion: @escaping (Result<APIBookmarkedArticle, APIError>) -> Void
    ) {
        request(
            method: .post,
            path: "/api/bookmarks/articles",
            token: token,
            body: payload,
            completion: completion
        )
    }

    func deleteBookmarkedArticle(
        articleId: String,
        token: String,
        completion: @escaping (Result<Void, APIError>) -> Void
    ) {
        requestStatus(
            method: .delete,
            path: "/api/bookmarks/articles/\(articleId)",
            token: token,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    func fetchBookmarkedThreads(
        token: String,
        folderId: String? = nil,
        completion: @escaping (Result<[APIBookmarkedThread], APIError>) -> Void
    ) {
        let queryItems: [URLQueryItem] = folderId.map {
            [URLQueryItem(name: "folderId", value: $0)]
        } ?? []
        request(
            method: .get,
            path: "/api/bookmarks/threads",
            token: token,
            queryItems: queryItems,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    func createBookmarkedThread(
        payload: APICreateBookmarkedThreadRequest,
        token: String,
        completion: @escaping (Result<APIBookmarkedThread, APIError>) -> Void
    ) {
        request(
            method: .post,
            path: "/api/bookmarks/threads",
            token: token,
            body: payload,
            completion: completion
        )
    }

    func deleteBookmarkedThread(
        threadId: String,
        token: String,
        completion: @escaping (Result<Void, APIError>) -> Void
    ) {
        requestStatus(
            method: .delete,
            path: "/api/bookmarks/threads/\(threadId)",
            token: token,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    func checkThreadBookmarkState(
        threadId: String,
        token: String,
        completion: @escaping (Result<APICheckBookmarkResponse, APIError>) -> Void
    ) {
        request(
            method: .get,
            path: "/api/bookmarks/threads/check",
            token: token,
            queryItems: [URLQueryItem(name: "threadId", value: threadId)],
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    func deleteBookmarkedThreadByThreadId(
        threadId: String,
        token: String,
        completion: @escaping (Result<Void, APIError>) -> Void
    ) {
        requestStatus(
            method: .delete,
            path: "/api/bookmarks/threads/by-thread/\(threadId)",
            token: token,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }
}

// MARK: - Progress

extension APIService {

    func fetchUserProgress(
        token: String,
        completion: @escaping (Result<APIUserProgress, APIError>) -> Void
    ) {
        request(
            method: .get,
            path: "/api/progress",
            token: token,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    func updateProgress(
        payload: APIUpdateProgressRequest,
        token: String,
        completion: @escaping (Result<APIUpdateProgressResponse, APIError>) -> Void
    ) {
        request(method: .post, path: "/api/progress", token: token, body: payload, completion: completion)
    }
}

// MARK: - Compatibility Helpers

extension APIService {

    func saveLevel(
        _ level: String,
        token: String,
        completion: @escaping (Bool) -> Void
    ) {
        let mapped: APILevel
        switch level.lowercased() {
        case "beginner": mapped = .beginner
        case "intermediate": mapped = .intermediate
        case "advanced": mapped = .advance
        default: mapped = .beginner
        }
        saveLevel(mapped, token: token) { result in
            completion((try? result.get()) != nil)
        }
    }

    func saveInterest(
        interestId: String,
        token: String,
        completion: @escaping (Bool) -> Void
    ) {
        addInterest(interestId: interestId, token: token) { result in
            completion((try? result.get()) != nil)
        }
    }
}
