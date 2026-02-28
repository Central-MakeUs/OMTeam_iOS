//
//  NotificationRouter.swift
//  OMT
//
//  Created by 이인호 on 2/26/26.
//

import Foundation
import Alamofire

enum NotificationRouter: TargetType {
    case saveFCMToken(FCMTokenRequestDTO)
    case deleteFCMToken
}

extension NotificationRouter {
    var method: Alamofire.HTTPMethod {
        switch self {
        case .saveFCMToken:
            return .put
        case .deleteFCMToken:
            return .delete
        }
    }
    
    var path: String {
        switch self {
        case .saveFCMToken, .deleteFCMToken:
            return "/api/notification/fcm-token"
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
        case .saveFCMToken(let request):
            return try? encoder.encode(request)
        case .deleteFCMToken:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .saveFCMToken, .deleteFCMToken:
            return .json
        }
    }
}
