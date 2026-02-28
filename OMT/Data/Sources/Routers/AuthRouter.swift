//
//  AuthRouter.swift
//  OMT
//
//  Created by 이인호 on 1/18/26.
//

import Foundation
import Alamofire

enum AuthRouter: TargetType {

    /// Apple Login From -> Feature
    case appleLogin(LoginRequestDTO)
    case kakaoLogin(LoginRequestDTO)
    case googleLogin(LoginRequestDTO)
    case refreshToken(RefreshRequestDTO)
    case withdraw
}

extension AuthRouter {
    var method: Alamofire.HTTPMethod {
        switch self {
        case .appleLogin, .kakaoLogin, .googleLogin, .refreshToken, .withdraw:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .appleLogin:
            return "/auth/oauth/apple"
        case .kakaoLogin:
            return "/auth/oauth/kakao"
        case .googleLogin:
            return "/auth/oauth/google"
        case .refreshToken:
            return "/auth/refresh"
        case .withdraw:
            return "/auth/withdraw"
        }
    }
    
    var optionalHeaders: Alamofire.HTTPHeaders? {
        return nil
    }
    
    var headers: HTTPHeaders {
        return .default
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    var body: Data? {
        let encoder = JSONEncoder()

        switch self {
        case .appleLogin(let loginRequestDTO):
            return try? encoder.encode(loginRequestDTO)
        case .kakaoLogin(let loginRequestDTO):
            return try? encoder.encode(loginRequestDTO)
        case .googleLogin(let loginRequestDTO):
            return try? encoder.encode(loginRequestDTO)
        case .refreshToken(let refreshRequestDTO):
            return try? encoder.encode(refreshRequestDTO)
        case .withdraw:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .appleLogin, .kakaoLogin, .googleLogin, .refreshToken, .withdraw:
            return .json
        }
    }
}
