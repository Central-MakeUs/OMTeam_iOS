//
//  MessageRequestDTO.swift
//  OMT
//
//  Created by 이인호 on 2/5/26.
//

import Foundation

struct MessageRequestDTO: Encodable {
    let type: MessageType
    let text: String
    let value: String
}
