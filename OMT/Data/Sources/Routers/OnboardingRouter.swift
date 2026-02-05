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
}

extension OnboardingRouter {
    var method: Alamofire.HTTPMethod {
        switch self {
        case .saveOnboarding:
            return .post
        case .fetchOnboarding:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .saveOnboarding, .fetchOnboarding:
            return "/api/onboarding"
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
        case .saveOnboarding(let onboardingRequestDTO):
            return try? encoder.encode(onboardingRequestDTO)
        case .fetchOnboarding:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .saveOnboarding:
            return .json
        case .fetchOnboarding:
            return .url
        }
    }
}
