//
//  MissionRouter.swift
//  OMT
//
//  Created by 이인호 on 2/7/26.
//

import Foundation
import Alamofire

enum MissionRouter: TargetType {
    case fetchDailyRecommend
    case startMission(StartMissionRequestDTO)
    case completeMission(CompleteMissionRequestDTO)
    case dailyMissionStatus
}

extension MissionRouter {
    var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchDailyRecommend, .startMission, .completeMission:
            return .post
        case .dailyMissionStatus:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .fetchDailyRecommend:
            return "/api/missions/daily/recommend"
        case .startMission:
            return "/api/missions/daily/start"
        case .completeMission:
            return "/api/missions/daily/complete"
        case .dailyMissionStatus:
            return "/api/missions/daily/status"
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
        case .startMission(let request):
            return try? encoder.encode(request)
        case .completeMission(let request):
            return try? encoder.encode(request)
        default:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .fetchDailyRecommend, .startMission, .completeMission:
            return .json
        case .dailyMissionStatus:
            return .url
        }
    }
}

