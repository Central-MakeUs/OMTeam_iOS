//
//  AuthenticationClient.swift
//  OMT
//
//  Created by 이인호 on 1/11/26.
//

import Foundation
import ComposableArchitecture
import KakaoSDKUser
import KakaoSDKAuth

struct AuthenticationClient {
    var appleLogin: @Sendable () async throws -> String
    var kakaoLogin: @Sendable () async throws -> String
}

extension AuthenticationClient: DependencyKey {
    static let liveValue = AuthenticationClient(
        appleLogin: {
            let controller = AppleSignInController()
            return try await controller.signIn()
        },
        kakaoLogin: {
            return try await KakaoLoginHelper.login()
        }
    )
}

extension DependencyValues {
    var authentication: AuthenticationClient {
        get { self[AuthenticationClient.self] }
        set { self[AuthenticationClient.self] = newValue }
    }
}
