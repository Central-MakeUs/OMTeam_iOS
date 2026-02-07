//
//  DailyRecommendResponseDTO.swift
//  OMT
//
//  Created by 이인호 on 2/7/26.
//

import Foundation

typealias DailyRecommendResponseDTO = APIResponse<DailyRecommendDataDTO>

struct DailyRecommendDataDTO: Decodable {
    let missionDate: String
    let recommendations: [RecommendDTO]
    let hasInProgressMission: Bool
    let inProgressMission: RecommendDTO?
}

struct RecommendDTO: Decodable, Equatable {
    let recommendedMissionId: Int
    let missionDate: String
    let status: String
    let mission: MissionDTO
}

struct MissionDTO: Decodable, Equatable {
    let id: Int
    let name: String
    let type: MissionType
    let difficulty: Int
    let estimatedMinutes: Int
    let estimatedCalories: Int
}
