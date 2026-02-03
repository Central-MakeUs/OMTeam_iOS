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

enum DayOfWeek: String, Decodable {
    case monday = "MONDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
    case thursday = "THURSDAY"
    case friday = "FRIDAY"
    case saturday = "SATURDAY"
    case sunday = "SUNDAY"
}

enum MissionType: String, Decodable {
    case exercise = "EXERCISE"
    case diet = "DIET"
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
    let mainFailureReason: String?
    let overallFeedback: String
}
