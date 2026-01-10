//
//  KakaoLoginHelper.swift
//  OMT
//
//  Created by 이인호 on 1/11/26.
//

import Foundation
import KakaoSDKUser
import KakaoSDKAuth

@MainActor
class KakaoLoginHelper {
    
    static func login() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let completion: (OAuthToken?, Error?) -> Void = { oauthToken, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let idToken = oauthToken?.idToken {
                    continuation.resume(returning: idToken)
                } else {
                    continuation.resume(throwing: NSError(domain: "KakaoLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "토큰 없음"]))
                }
            }
            
            // 카카오톡 실행
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk(completion: completion)
            } else {
                UserApi.shared.loginWithKakaoAccount(completion: completion)
            }
        }
    }
}
