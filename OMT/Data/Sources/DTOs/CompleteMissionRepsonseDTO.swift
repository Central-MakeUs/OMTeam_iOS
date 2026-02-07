//
//  CompleteMissionRepsonseDTO.swift
//  OMT
//
//  Created by 이인호 on 2/7/26.
//

import Foundation

typealias CompleteMissionRepsonseDTO = APIResponse<CompleteMissionDataDTO>

struct CompleteMissionDataDTO: Decodable, Equatable {
    let id: Int
    let missionDate: String
    let result: String
    let failureReason: String?
    let mission: MissionDTO
}
