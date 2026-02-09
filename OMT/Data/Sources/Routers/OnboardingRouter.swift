//
//  OnboardingRouter.swift
//  OMT
//
//  Created by 이인호 on 2/1/26.
//

import Foundation
import Alamofire

enum OnboardingRouter: TargetType {
    case saveOnboarding(OnboardingRequestDTO)
    case fetchOnboarding
    case updateNickname(UpdateNicknameRequestDTO)
}

extension OnboardingRouter {
    var method: Alamofire.HTTPMethod {
        switch self {
        case .saveOnboarding:
            return .post
        case .fetchOnboarding:
            return .get
        case .updateNickname:
            return .patch
        }
    }
    
    var path: String {
        switch self {
        case .saveOnboarding, .fetchOnboarding:
            return "/api/onboarding"
        case .updateNickname:
            return "/api/onboarding/nickname"
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
        case .saveOnboarding(let onboardingRequestDTO):
            return try? encoder.encode(onboardingRequestDTO)
        case .fetchOnboarding:
            return nil
        case .updateNickname(let updateNicknameRequestDTO):
            return try? encoder.encode(updateNicknameRequestDTO)
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .saveOnboarding, .updateNickname:
            return .json
        case .fetchOnboarding:
            return .url
        }
    }
}
