//
//  OnboardingRequestDTO.swift
//  OMT
//
//  Created by 이인호 on 2/1/26.
//

import Foundation

struct OnboardingRequestDTO: Encodable {
    let nickname: String
    let appGoalText: String
    let workTimeType: String
    let availableStartTime: String
    let availableEndTime: String
    let minExerciseMinutes: Int
    let preferredExercises: [String]
    let lifestyleType: LifestyleType
    let remindEnabled: Bool
    let checkinEnabled: Bool
    let reviewEnabled: Bool
}
