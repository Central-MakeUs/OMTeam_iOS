//
//  Mission.swift
//  OMT
//
//  Created by 이인호 on 1/28/26.
//

import SwiftUI

struct WeeklyMission: Hashable {
    enum Status: Hashable {
        case success
        case fail
        case pending
        
        var imageName: String {
            switch self {
            case .success: return "apple_success"
            case .fail: return "apple_fail"
            case .pending: return "apple_pending"
            }
        }
        
        var font: Typography {
            switch self {
            case .success, .fail: return .sub_b4_1
            case .pending: return .sub_b4_2
            }
        }
        
        var textColor: Color {
            switch self {
            case .success: return .gray11
            case .fail: return .gray9
            case .pending: return .gray8
            }
        }
    }
    let status: Status
}
