//
//  DailyFeedbackResponseDTO.swift
//  OMT
//
//  Created by 이인호 on 2/4/26.
//

import Foundation

typealias DailyFeedbackResponseDTO = APIResponse<DailyFeedbackDataDTO>

struct DailyFeedbackDataDTO: Decodable {
    let targetDate: String
    let feedbackText: String
}
