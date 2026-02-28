//
//  LifestyleType.swift
//  OMT
//
//  Created by 이인호 on 2/10/26.
//

import Foundation

enum LifestyleType: String, Codable, CaseIterable {
    case regularDaytime = "REGULAR_DAYTIME"
    case irregularOvertime = "IRREGULAR_OVERTIME"
    case shiftNight = "SHIFT_NIGHT"
    case variableDaily = "VARIABLE_DAILY"
    
    var description: String {
        switch self {
        case .regularDaytime:
            return "비교적 규칙적인 평일 주간 근무에요."
        case .irregularOvertime:
            return "야근/불규칙한 일정이 자주 있어요."
        case .shiftNight:
            return "주기적으로 교대/밤샘 근무가 있어요."
        case .variableDaily:
            return "일정이 매일매일 달라요."
        }
    }
}
