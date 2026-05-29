//
//  AppleAuthManager.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 06/03/26.
//

import AuthenticationServices

class AppleAuthManager {

    static func createRequest() -> ASAuthorizationAppleIDRequest {

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()

        request.requestedScopes = [.fullName, .email]

        return request
    }

}
