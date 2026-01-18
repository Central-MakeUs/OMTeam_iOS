//
//  AuthenticationClient.swift
//  OMT
//
//  Created by 이인호 on 1/11/26.
//

import Foundation
import ComposableArchitecture

struct AuthenticationClient {
    var appleLogin: @Sendable () async throws -> AppleLoginRequestDTO
    var kakaoLogin: @Sendable () async throws -> String
    var googleLogin: @Sendable () async throws -> String
}

extension AuthenticationClient: DependencyKey {
    static let liveValue = AuthenticationClient(
        appleLogin: {
            let controller = AppleSignInController()
            return try await controller.signIn()
        },
        kakaoLogin: {
            return try await LoginHelper.kakaoLogin()
        },
        googleLogin: {
            return try await LoginHelper.googleLogin()
        }
    )
}

extension DependencyValues {
    var authentication: AuthenticationClient {
        get { self[AuthenticationClient.self] }
        set { self[AuthenticationClient.self] = newValue }
    }
}
