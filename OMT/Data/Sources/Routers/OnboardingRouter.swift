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
    case updateAppGoal(UpdateAppGoalRequestDTO)
    case updateAlert(UpdateAlertRequestDTO)
}

extension OnboardingRouter {
    var method: Alamofire.HTTPMethod {
        switch self {
        case .saveOnboarding:
            return .post
        case .fetchOnboarding:
            return .get
        case .updateNickname, .updateAppGoal, .updateAlert:
            return .patch
        }
    }
    
    var path: String {
        switch self {
        case .saveOnboarding, .fetchOnboarding:
            return "/api/onboarding"
        case .updateNickname:
            return "/api/onboarding/nickname"
        case .updateAppGoal:
            return "/api/onboarding/app-goal"
        case .updateAlert:
            return "/api/onboarding/notification"
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
        case .saveOnboarding(let request):
            return try? encoder.encode(request)
        case .fetchOnboarding:
            return nil
        case .updateNickname(let request):
            return try? encoder.encode(request)
        case .updateAppGoal(let request):
            return try? encoder.encode(request)
        case .updateAlert(let request):
            return try? encoder.encode(request)
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .saveOnboarding, .updateNickname, .updateAppGoal, .updateAlert:
            return .json
        case .fetchOnboarding:
            return .url
        }
    }
}
