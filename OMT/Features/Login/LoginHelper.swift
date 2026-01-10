//
//  KakaoLoginHelper.swift
//  OMT
//
//  Created by 이인호 on 1/11/26.
//

import Foundation
import KakaoSDKUser
import KakaoSDKAuth
import GoogleSignIn

@MainActor
class LoginHelper {
    
    static func kakaoLogin() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let completion: (OAuthToken?, Error?) -> Void = { oauthToken, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let idToken = oauthToken?.idToken {
                    continuation.resume(returning: idToken)
                } else {
                    continuation.resume(throwing: NSError(domain: "KakaoLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "카카오 로그인 idToken 없음"]))
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
    
    static func googleLogin() async throws -> String {
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController
        else {
            throw NSError(domain: "GoogleLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "화면을 찾을 수 없음"])
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
        
        guard let idToken = result.user.idToken?.tokenString else {
            throw NSError(domain: "GoogleLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "구글 로그인 idToken 없음"])
        }
        
        return idToken
    }
}
