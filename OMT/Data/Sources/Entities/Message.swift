//
//  Message.swift
//  OMT
//
//  Created by 이인호 on 1/22/26.
//

import Foundation

struct Message: Identifiable, Equatable {
    let id: Int
    let content: String
    let isFromUser: Bool
    let createdAt: String
    let options: [MessageOption]?
    let terminal: Bool
    var selectedOption: String?

    static func from(_ dto: MessageDataDTO) -> Message {
        return Message(
            id: dto.messageId,
            content: dto.content,
            isFromUser: dto.role == .user,
            createdAt: dto.createdAt,
            options: dto.options.isEmpty ? nil : dto.options.map { MessageOption(label: $0.label, value: $0.value) },
            terminal: dto.terminal,
            selectedOption: nil
        )
    }
}

struct MessageOption: Equatable {
    let label: String
    let value: String
}
