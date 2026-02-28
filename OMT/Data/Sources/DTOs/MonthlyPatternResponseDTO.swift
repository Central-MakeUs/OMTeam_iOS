//
//  MonthlyPatternResponseDTO.swift
//  OMT
//
//  Created by 이인호 on 2/5/26.
//

import Foundation

typealias MonthlyPatternResponseDTO = APIResponse<MonthlyPatternDataDTO>

struct MonthlyPatternDataDTO: Decodable {
    let startDate: String
    let endDate: String
    let dayOfWeekStats: [DayOfWeekStatDTO]
    let aiFeedback: MonthlyAIFeedbackDTO
}

struct DayOfWeekStatDTO: Decodable {
    let dayOfWeek: DayOfWeek
    let dayName: String
    let totalCount: Int
    let successCount: Int
    let failureCount: Int
    let successRate: Double
}

struct MonthlyAIFeedbackDTO: Decodable {
    let dayOfWeekFeedbackTitle: String?
    let dayOfWeekFeedbackContent: String?
}
