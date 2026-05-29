import Foundation

// MARK: - Auth

extension APIService {

    func signUp(
        payload: APISignUpRequest,
        completion: @escaping (Result<String, APIError>) -> Void
    ) {
        let fields: [String: String] = [
            "name": payload.name,
            "email": payload.email,
            "password": payload.password,
            "phone": payload.phone,
            "level": payload.level.rawValue,
            "dob": payload.dob,
            "gender": payload.gender.rawValue,
            "hasOnboarding": payload.hasOnboarding ? "true" : "false"
        ]

        multipartRequest(
            method: .post,
            path: "/api/auth/signup",
            token: nil,
            fields: fields,
            tagsField: nil,
            imageData: payload.profileImageData,
            imageFileName: payload.profileImageFileName,
            imageFieldName: "profileImage",
            completion: completion
        )
    }

    func signIn(
        payload: APISignInRequest,
        completion: @escaping (Result<APISignInResponse, APIError>) -> Void
    ) {
        request(method: .post, path: "/api/auth/signin", body: payload, completion: completion)
    }

    func getMe(
        token: String,
        completion: @escaping (Result<APIGetMeResponse, APIError>) -> Void
    ) {
        request(
            method: .get,
            path: "/api/auth/me",
            token: token,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }
}

// MARK: - Profile / Onboarding

extension APIService {

    func fetchProfile(
        token: String,
        completion: @escaping (Result<APIProfileResponse, APIError>) -> Void
    ) {
        request(
            method: .get,
            path: "/api/profile/get",
            token: token,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    func editProfile(
        payload: APIEditProfileRequest,
        token: String,
        completion: @escaping (Result<APIProfileResponse, APIError>) -> Void
    ) {
        request(method: .patch, path: "/api/profile/edit", token: token, body: payload, completion: completion)
    }

    func fetchAvailableInterests(
        type: APIInterestType? = nil,
        completion: @escaping (Result<[APIInterest], APIError>) -> Void
    ) {
        let queryItems: [URLQueryItem] = type.map {
            [URLQueryItem(name: "type", value: $0.rawValue)]
        } ?? []
        request(
            method: .get,
            path: "/api/profile/interests/available",
            queryItems: queryItems,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    func addInterest(
        interestId: String,
        token: String,
        completion: @escaping (Result<APIInterest, APIError>) -> Void
    ) {
        request(
            method: .post,
            path: "/api/profile/interests",
            token: token,
            body: APIAddInterestRequest(interestId: interestId),
            completion: completion
        )
    }

    func deleteInterest(
        interestId: String,
        token: String,
        completion: @escaping (Result<Void, APIError>) -> Void
    ) {
        requestStatus(
            method: .delete,
            path: "/api/interests/\(interestId)",
            token: token,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    func saveLevel(
        _ level: APILevel,
        token: String,
        completion: @escaping (Result<Void, APIError>) -> Void
    ) {
        requestStatus(
            method: .patch,
            path: "/api/profile/level",
            token: token,
            body: APISetLevelRequest(level: level),
            completion: completion
        )
    }

    func finishOnboarding(
        token: String,
        completion: @escaping (Result<Void, APIError>) -> Void
    ) {
        requestStatus(
            method: .patch,
            path: "/api/profile/onboarding",
            token: token,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }
}

// MARK: - Threads

extension APIService {

    func fetchForYouThreads(
        token: String? = nil,
        completion: @escaping (Result<[APIThread], APIError>) -> Void
    ) {
        request(
            method: .get,
            path: "/api/for-you-threads",
            token: token,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    func fetchFollowingThreads(
        token: String,
        completion: @escaping (Result<[APIThread], APIError>) -> Void
    ) {
        request(
            method: .get,
            path: "/api/following-threads",
            token: token,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    func createThread(
        payload: APICreateThreadRequest,
        token: String,
        completion: @escaping (Result<APIThread, APIError>) -> Void
    ) {
        multipartRequest(
            method: .post,
            path: "/api/create-thread",
            token: token,
            fields: [
                "title": payload.title,
                "description": payload.description
            ],
            tagsField: payload.tags,
            imageData: payload.imageData,
            imageFileName: payload.imageFileName,
            imageFieldName: "threadImage",
            completion: completion
        )
    }

    func saveDraft(
        payload: APICreateDraftRequest,
        token: String,
        completion: @escaping (Result<APIThreadDraft, APIError>) -> Void
    ) {
        var fields: [String: String] = [
            "title": payload.title,
            "description": payload.description
        ]
        if let threadId = payload.threadId { fields["threadId"] = threadId }

        multipartRequest(
            method: .post,
            path: "/api/draft",
            token: token,
            fields: fields,
            tagsField: payload.tags,
            imageData: payload.imageData,
            imageFileName: payload.imageFileName,
            imageFieldName: "threadImage",
            completion: completion
        )
    }

    func fetchDrafts(
        token: String,
        completion: @escaping (Result<[APIThreadDraft], APIError>) -> Void
    ) {
        request(
            method: .get,
            path: "/api/drafts",
            token: token,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    func updateDraft(
        draftId: String,
        title: String? = nil,
        description: String? = nil,
        tags: [String]? = nil,
        imageData: Data? = nil,
        imageFileName: String? = nil,
        token: String,
        completion: @escaping (Result<APIThreadDraft, APIError>) -> Void
    ) {
        var fields: [String: String] = [:]
        if let title { fields["title"] = title }
        if let description { fields["description"] = description }

        multipartRequest(
            method: .put,
            path: "/api/draft/\(draftId)",
            token: token,
            fields: fields,
            tagsField: tags,
            imageData: imageData,
            imageFileName: imageFileName,
            imageFieldName: "threadImage",
            completion: completion
        )
    }

    func deleteDraft(
        draftId: String,
        token: String,
        completion: @escaping (Result<Void, APIError>) -> Void
    ) {
        requestStatus(
            method: .delete,
            path: "/api/draft?draftId=\(draftId)",
            token: token,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    func deleteThread(
        threadId: String,
        token: String,
        completion: @escaping (Result<Void, APIError>) -> Void
    ) {
        requestStatus(
            method: .delete,
            path: "/api/thread?threadId=\(threadId)",
            token: token,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }
}
