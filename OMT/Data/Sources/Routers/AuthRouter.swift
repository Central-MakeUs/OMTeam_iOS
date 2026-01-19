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
}

extension AuthRouter {
    var method: Alamofire.HTTPMethod {
        switch self {
        case .appleLogin, .kakaoLogin, .googleLogin:
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
        case .appleLogin(let LoginRequestDTO):
            return try? encoder.encode(LoginRequestDTO)
        case .kakaoLogin(let loginRequestDTO):
            return try? encoder.encode(loginRequestDTO)
        case .googleLogin(let loginRequestDTO):
            return try? encoder.encode(loginRequestDTO)
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .appleLogin, .kakaoLogin, .googleLogin:
            return .json
        }
    }
}
