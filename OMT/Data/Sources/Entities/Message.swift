//
//  Message.swift
//  OMT
//
//  Created by 이인호 on 1/22/26.
//

import Foundation

// 임시 추후 API에 맞춰 변경 예정
struct Message: Identifiable, Equatable {
    let id: String
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    let type: MessageType
    let options: [String]? // 선택지 목록
    var selectedOption: String?
    
    // 텍스트 입력형, 선택지형
    enum MessageType {
        case text
        case selection
    }
    
    // Mockup
    static let messages: [Message] = [
        Message(
            id: "1",
            content: "안녕하세요!",
            isFromUser: true,
            timestamp: Date().addingTimeInterval(-3600),
            type: .text,
            options: nil
        ),
        Message(
            id: "2",
            content: "안녕하세요! 오늘 운동 계획을 세워볼까요?",
            isFromUser: false,
            timestamp: Date().addingTimeInterval(-3540),
            type: .text,
            options: nil
        ),
        Message(
            id: "3",
            content: "오늘은 어떤 운동을 하고 싶으신가요?",
            isFromUser: false,
            timestamp: Date().addingTimeInterval(-3480),
            type: .selection,
            options: ["유산소 운동", "근력 운동", "스트레칭"]
        ),
        Message(
            id: "4",
            content: "유산소 운동",
            isFromUser: true,
            timestamp: Date().addingTimeInterval(-3420),
            type: .text,
            options: nil
        ),
        Message(
            id: "5",
            content: "좋아요! 오늘 컨디션은 어떠세요?",
            isFromUser: false,
            timestamp: Date().addingTimeInterval(-3360),
            type: .selection,
            options: ["좋음", "보통", "피곤함"]
        ),
        Message(
            id: "6",
            content: "좋음",
            isFromUser: true,
            timestamp: Date().addingTimeInterval(-3300),
            type: .text,
            options: nil
        ),
        Message(
            id: "7",
            content: "그럼 30분 러닝을 추천드려요! 🏃‍♂️",
            isFromUser: false,
            timestamp: Date().addingTimeInterval(-3240),
            type: .text,
            options: nil
        ),
        Message(
            id: "8",
            content: "완벽해! 고마워",
            isFromUser: true,
            timestamp: Date().addingTimeInterval(-3180),
            type: .text,
            options: nil
        ),
        Message(
            id: "9",
            content: "좋은 운동 되세요! 💪",
            isFromUser: false,
            timestamp: Date().addingTimeInterval(-3120),
            type: .text,
            options: nil
        )
    ]
}
