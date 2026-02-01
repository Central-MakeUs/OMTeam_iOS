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
}

extension OnboardingRouter {
    var method: Alamofire.HTTPMethod {
        switch self {
        case .saveOnboarding:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .saveOnboarding:
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
        case .saveOnboarding(let OnboardingRequestDTO):
            return try? encoder.encode(OnboardingRequestDTO)
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .saveOnboarding:
            return .json
        }
    }
}
