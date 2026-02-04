//
//  ReportRouter.swift
//  OMT
//
//  Created by 이인호 on 2/4/26.
//

import Foundation
import Alamofire

enum ReportRouter: TargetType {
    
    case fetchWeeklyReports(year: Int, month: Int, weekOfMonth: Int)
}

extension ReportRouter {
    var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchWeeklyReports:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .fetchWeeklyReports:
            return "/api/reports/weekly"
        }
    }
    
    var optionalHeaders: Alamofire.HTTPHeaders? {
        return nil
    }
    
    var headers: HTTPHeaders {
        return .default
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchWeeklyReports(let year, let month, let weekOfMonth):
            return ["year": year, "month": month, "weekOfMonth": weekOfMonth]
        }
    }
    
    var body: Data? {
        var encoder = JSONEncoder()
        
        switch self {
        case .fetchWeeklyReports:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .fetchWeeklyReports:
            return .url
        }
    }
}

