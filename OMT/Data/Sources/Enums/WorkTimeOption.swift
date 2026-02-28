//
//  WorkTimeOption.swift
//  OMT
//
//  Created by 이인호 on 2/10/26.
//

import Foundation

enum WorkTimeOption: CaseIterable {
    case before18 // 00:00 ~ 17:59
    case after18  // 18:00 ~
    case after19  // 19:00 ~
    case after20  // 20:00 ~
    
    init(serverStartTime: String) {
        let timeKey = String(serverStartTime.prefix(5)) // 19:00:00 -> 19:00
        switch timeKey {
        case "18:00": self = .after18
        case "19:00": self = .after19
        case "20:00": self = .after20
        default: self = .before18
        }
    }
    
    static func from(selectionText: String) -> WorkTimeOption {
        if selectionText.contains("19:00") { return .after19 }
        if selectionText.contains("20:00") { return .after20 }
        if selectionText.contains("18:00") && !selectionText.contains("이전") { return .after18 }
        
        return .before18
    }
    
    var displayText: String {
        switch self {
        case .before18: return "18:00 이전"
        case .after18: return "18:00 이후부터"
        case .after19: return "19:00 이후부터"
        case .after20: return "20:00 이후부터"
        }
    }
    
    var startTime: String {
        switch self {
        case .before18: return "00:00"
        case .after18: return "18:00"
        case .after19: return "19:00"
        case .after20: return "20:00"
        }
    }
    
    var endTime: String {
        switch self {
        case .before18: return "17:59"
        default: return "23:59"
        }
    }
}
