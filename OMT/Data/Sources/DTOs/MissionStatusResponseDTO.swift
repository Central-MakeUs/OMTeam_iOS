//
//  MissionStatusResponseDTO.swift
//  OMT
//
//  Created by 이인호 on 2/7/26.
//

import Foundation

typealias MissionStatusResponseDTO = APIResponse<MissionStatusDataDTO>

struct MissionStatusDataDTO: Decodable {
    let date: String
    let hasRecommendations: Bool
    let hasInProgressMission: Bool
    let hasCompletedMission: Bool
    let currentMission: RecommendDTO?
    let missionResult: CompleteMissionDataDTO?
}
