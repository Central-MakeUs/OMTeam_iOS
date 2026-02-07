//
//  StartMissionResponseDTO.swift
//  OMT
//
//  Created by 이인호 on 2/7/26.
//

import Foundation

typealias StartMissionResponseDTO = APIResponse<StartMissionDataDTO>

struct StartMissionDataDTO: Decodable {
    let recommendedMissionId: Int
    let missionDate: String
    let status: String
    let mission: MissionDTO
}
