//
//  OnboardingResponseDTO.swift
//  OMT
//
//  Created by 이인호 on 2/1/26.
//

import Foundation

typealias OnboardingResponseDTO = APIResponse<OnboardingDataDTO>

struct OnboardingDataDTO: Decodable {
    let nickname: String
    let appGoalText: String
    let workTimeType: String
    let availableStartTime: String
    let availableEndTime: String
    let minExerciseMinutes: Int
    let preferredExerciseText: String
    let lifestyleType: String
    let remindEnabled: Bool
    let checkinEnabled: Bool
    let reviewEnabled: Bool
}
