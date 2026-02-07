//
//  Recommendation.swift
//  OMT
//
//  Created by 이인호 on 2/7/26.
//

import Foundation

struct Recommendation: Identifiable, Equatable {
    let id: Int
    let missionDate: String
    let status: String
    let mission: MissionInfo

    struct MissionInfo: Equatable {
        let id: Int
        let name: String
        let type: MissionType
        let difficulty: Int
        let estimatedMinutes: Int
        let estimatedCalories: Int
    }
}

extension Recommendation {
    static func from(_ dto: RecommendDTO) -> Recommendation {
        Recommendation(
            id: dto.recommendedMissionId,
            missionDate: dto.missionDate,
            status: dto.status,
            mission: MissionInfo(
                id: dto.mission.id,
                name: dto.mission.name,
                type: dto.mission.type,
                difficulty: dto.mission.difficulty,
                estimatedMinutes: dto.mission.estimatedMinutes,
                estimatedCalories: dto.mission.estimatedCalories
            )
        )
    }
}

