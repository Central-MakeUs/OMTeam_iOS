//
//  Mission.swift
//  OMT
//
//  Created by 이인호 on 1/28/26.
//

import SwiftUI

enum MissionStatus: String, Decodable {
    case success = "SUCCESS"
    case fail = "FAIL"
    case notPerformed = "NOT_PERFORMED"
    
    var imageName: String {
        switch self {
        case .success: return "apple_success"
        case .fail: return "apple_fail"
        case .notPerformed: return "apple_pending"
        }
    }

    var font: Typography {
        switch self {
        case .success, .fail: return .sub_b4_1
        case .notPerformed: return .sub_b4_2
        }
    }

    var textColor: Color {
        switch self {
        case .success: return .gray11
        case .fail: return .gray9
        case .notPerformed: return .gray8
        }
    }
}

struct DailyMission: Equatable {
    let date: Date
    let result: MissionStatus
}

extension DailyMission {
    static func from(_ dto: DailyResultDTO) -> DailyMission {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: dto.date) ?? Date()

        let result: MissionStatus = switch dto.status {
        case .success: .success
        case .fail: .fail
        case .notPerformed: .notPerformed
        }

        return DailyMission(date: date, result: result)
    }

    static func notPerformed(date: Date) -> DailyMission {
        DailyMission(date: date, result: .notPerformed)
    }
}
