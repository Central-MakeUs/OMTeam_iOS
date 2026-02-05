//
//  ChatResponseDTO.swift
//  OMT
//
//  Created by 이인호 on 2/5/26.
//

import Foundation

typealias ChatResponseDTO = APIResponse<ChatDataDTO>

struct ChatDataDTO: Decodable {
    let hasActiveSession: Bool
    let hasMore: Bool
    let nextCursor: Int?
    let messages: [MessageDataDTO]
}
