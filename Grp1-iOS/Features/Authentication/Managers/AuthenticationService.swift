import Foundation

class AuthenticationService {
    static let shared = AuthenticationService()
    private let apiService = APIService.shared
    private let credentialStorage = CredentialStorageService.shared

    // MARK: - Sign Up

    struct SignUpParameters {
        let name: String
        let email: String
        let password: String
        let phone: String
        let level: String
        let dob: String
        let gender: String
        let hasOnboarding: Bool
        let profileImageData: Data?
        let profileImageFileName: String?
    }

    func signUp(
        params: SignUpParameters,
        completion: @escaping (Bool, String?) -> Void
    ) {
        let levelEnum: APILevel
        switch params.level.uppercased() {
        case "BEGINNER":              levelEnum = .beginner
        case "INTERMEDIATE":          levelEnum = .intermediate
        case "ADVANCE", "ADVANCED":   levelEnum = .advance
        default:                      levelEnum = .beginner
        }

        let genderEnum: APIGender
        switch params.gender.uppercased() {
        case "MALE":           genderEnum = .male
        case "FEMALE":         genderEnum = .female
        case "OTHER", "OTHERS": genderEnum = .others
        default:               genderEnum = .male
        }

        let payload = APISignUpRequest(
            name: params.name,
            email: params.email,
            password: params.password,
            phone: params.phone,
            level: levelEnum,
            dob: params.dob,
            gender: genderEnum,
            hasOnboarding: params.hasOnboarding,
            profileImageData: params.profileImageData,
            profileImageFileName: params.profileImageFileName ?? "avatar.jpg"
        )

        apiService.signUp(payload: payload) { result in
            switch result {
            case .success:
                let saved = self.credentialStorage.saveCredentials(email: params.email, password: params.password)
                DispatchQueue.main.async {
                    completion(saved, nil)
                }

            case .failure(let error):
                print("❌ Sign up error: \(error)")
                DispatchQueue.main.async {
                    completion(false, error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Sign In

    func signIn(
        email: String,
        password: String,
        completion: @escaping (Bool, String?, Bool, String?) -> Void
    ) {
        guard !email.isEmpty, !password.isEmpty else {
            completion(false, nil, false, "Email and password required")
            return
        }

        let payload = APISignInRequest(email: email, password: password)

        apiService.signIn(payload: payload) { result in
            switch result {
            case .success(let response):
                let saved = self.credentialStorage.saveCredentials(email: email, password: password)
                let token = response.token
                SessionManager.shared.authToken = token
                UserDefaults.standard.set(token, forKey: "authToken")
                UserDefaults.standard.set(response.userId, forKey: "userId")
                UserDefaults.standard.set(response.hasOnboarding ?? false, forKey: "hasOnboarding")

                DispatchQueue.main.async {
                    completion(saved, token, response.hasOnboarding ?? false, nil)
                }

            case .failure(let error):
                print("❌ Sign in error: \(error)")
                DispatchQueue.main.async {
                    completion(false, nil, false, error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Sign Out

    func signOut(completion: @escaping (Bool) -> Void) {
        SessionManager.shared.logout()
        credentialStorage.deleteCredentials()
        DispatchQueue.main.async {
            completion(true)
        }
    }
}
