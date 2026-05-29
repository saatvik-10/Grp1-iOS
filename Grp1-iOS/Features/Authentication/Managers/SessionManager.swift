//
//  SessionManager.swift
//  Grp1-iOS
//

import Foundation

class SessionManager {

    static let shared = SessionManager()

    var currentUser: AuthenticateUser?
    var authToken: String?
    var userId: String?

    var isLoggedIn: Bool {
        return authToken != nil && !(authToken?.isEmpty ?? true)
    }

    /// Restore session from UserDefaults on app launch
    func restoreSession() {
        authToken = UserDefaults.standard.string(forKey: "authToken")
        userId = UserDefaults.standard.string(forKey: "userId")
    }

    /// Clear all session data
    func logout() {
        currentUser = nil
        authToken = nil
        userId = nil

        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "userId")

        _ = CredentialStorageService.shared.deleteCredentials()
    }
}
