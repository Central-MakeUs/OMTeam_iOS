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
}

extension AuthRouter {
    var method: Alamofire.HTTPMethod {
        switch self {
        case .appleLogin, .kakaoLogin, .googleLogin, .refreshToken:
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
        var encoder = JSONEncoder()
        
        switch self {
        case .appleLogin(let loginRequestDTO):
            return try? encoder.encode(loginRequestDTO)
        case .kakaoLogin(let loginRequestDTO):
            return try? encoder.encode(loginRequestDTO)
        case .googleLogin(let loginRequestDTO):
            return try? encoder.encode(loginRequestDTO)
        case .refreshToken(let refreshRequestDTO):
            return try? encoder.encode(refreshRequestDTO)
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .appleLogin, .kakaoLogin, .googleLogin, .refreshToken:
            return .json
        }
    }
}
