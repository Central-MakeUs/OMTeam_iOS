//
//  MessageResponseDTO.swift
//  OMT
//
//  Created by 이인호 on 2/5/26.
//

import Foundation

typealias MessageResponseDTO = APIResponse<MessageDataDTO>

struct MessageDataDTO: Decodable {
    let messageId: Int
    let role: Role
    let content: String
    let options: [optionsDTO]
    let createdAt: String
    let terminal: Bool
}

struct optionsDTO: Decodable {
    let label: String
    let value: String
    let actionType: String?
}
