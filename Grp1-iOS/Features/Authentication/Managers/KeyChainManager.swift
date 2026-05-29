//
//  KeyChainManager.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 06/03/26.
//
import Foundation
import Security

class KeyChainManager {

    static func saveUserId(_ userId: String) {
        guard let data = userId.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "appleUserID",
            kSecValueData as String: data
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    static func getUserID() -> String? {
        let query: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrAccount as String: "appleUserID",
                    kSecReturnData as String: true
                ]

                var result: AnyObject?

                SecItemCopyMatching(query as CFDictionary, &result)

                if let data = result as? Data {
                    return String(data: data, encoding: .utf8)
                }

                return nil
    }
}
