//
//  CharacterResponseDTO.swift
//  OMT
//
//  Created by 이인호 on 2/4/26.
//

import Foundation

typealias CharacterResponseDTO = APIResponse<CharacterDataDTO>

struct CharacterDataDTO: Decodable {
    let level: Int
    let experiencePercent: Int
    let successCount: Int
    let successCountUntilNextLevel: Int
    let encouragementTitle: String
    let encouragementMessage: String
}
