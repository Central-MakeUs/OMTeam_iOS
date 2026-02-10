//
//  WeeklyReportsResponseDTO.swift
//  OMT
//
//  Created by 이인호 on 2/4/26.
//

import Foundation

typealias WeeklyReportsResponseDTO = APIResponse<WeeklyReportsDataDTO>

struct WeeklyReportsDataDTO: Decodable {
    let weekStartDate: String
    let weekEndDate: String
    let thisWeekSuccessRate: Double
    let lastWeekSuccessRate: Double
    let thisWeekSuccessCount: Int
    let dailyResults: [DailyResultDTO]
    let typeSuccessCounts: [TypeSuccessCountDTO]
    let topFailureReasons: [FailureReasonDTO]
    let aiFeedback: AIFeedbackDTO
}

struct DailyResultDTO: Decodable {
    let date: String
    let dayOfWeek: DayOfWeek
    let status: MissionStatus
    let missionType: MissionType?
    let missionTitle: String?
}

struct TypeSuccessCountDTO: Decodable {
    let type: MissionType
    let typeName: String
    let successCount: Int
}

struct FailureReasonDTO: Decodable {
    let rank: Int
    let reason: String
    let count: Int
}

struct AIFeedbackDTO: Decodable {
    let failureReasonRanking: [FailureReasonRankingDTO]
    let weeklyFeedback: String?
}

struct FailureReasonRankingDTO: Decodable {
    let rank: Int
    let category: String
    let count: Int
}
