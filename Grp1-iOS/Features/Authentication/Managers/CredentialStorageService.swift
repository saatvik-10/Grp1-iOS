import Foundation
import Security

class CredentialStorageService {
    static let shared = CredentialStorageService()
    private let service = "pho3nix.Grp1-iOS"

    func saveCredentials(email: String, password: String) -> Bool {
        let emailKey = "userEmail"
        let passwordKey = "userPassword"

        guard let emailData = email.data(using: .utf8),
              let passwordData = password.data(using: .utf8) else {
            return false
        }

        let emailQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: emailKey,
            kSecValueData as String: emailData
        ]

        SecItemDelete(emailQuery as CFDictionary)
        let emailStatus = SecItemAdd(emailQuery as CFDictionary, nil)

        let passwordQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: passwordKey,
            kSecValueData as String: passwordData
        ]

        SecItemDelete(passwordQuery as CFDictionary)
        let passwordStatus = SecItemAdd(passwordQuery as CFDictionary, nil)

        return emailStatus == errSecSuccess && passwordStatus == errSecSuccess
    }

    func getCredentials() -> (email: String, password: String)? {
        let emailKey = "userEmail"
        let passwordKey = "userPassword"

        guard let email = retrieveValue(for: emailKey),
              let password = retrieveValue(for: passwordKey) else {
            return nil
        }

        return (email, password)
    }

    // MARK: - Delete Credentials
    func deleteCredentials() -> Bool {
        let emailKey = "userEmail"
        let passwordKey = "userPassword"

        let emailQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: emailKey
        ]

        let passwordQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: passwordKey
        ]

        let emailStatus = SecItemDelete(emailQuery as CFDictionary)
        let passwordStatus = SecItemDelete(passwordQuery as CFDictionary)

        return emailStatus == errSecSuccess && passwordStatus == errSecSuccess
    }

    private func retrieveValue(for account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }
}
