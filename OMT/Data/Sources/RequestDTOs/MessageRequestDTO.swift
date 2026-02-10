//
//  MessageRequestDTO.swift
//  OMT
//
//  Created by 이인호 on 2/5/26.
//

import Foundation

struct MessageRequestDTO: Encodable {
    let actionType: String?
    let type: MessageType?
    let value: String?
    let optionValue: String?
    
    init(
        actionType: String? = nil,
        type: MessageType? = nil,
        value: String? = nil,
        optionValue: String? = nil
    ) {
        self.actionType = actionType
        self.type = type
        self.value = value
        self.optionValue = optionValue
    }
}
