//
//  OnboardingStep.swift
//  OMT
//
//  Created by 이인호 on 1/19/26.
//

import Foundation
import UIKit

struct OnboardingStep: Equatable {
    let title: String
    let subtitle: String?
    let type: StepType
    let options: [String]
    let customInputKeyboardType: UIKeyboardType
    
    init(
        title: String,
        subtitle: String? = nil,
        type: StepType,
        options: [String],
        customInputKeyboardType: UIKeyboardType = .default
    ) {
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.options = options
        self.customInputKeyboardType = customInputKeyboardType
    }
    
    enum StepType: Equatable {
        case textInput(placeholder: String)
        case choice
    }
}

extension OnboardingStep {
    static let steps: [OnboardingStep] = [
        OnboardingStep(
            title: "OMT에서 사용하실\n닉네임을 알려주세요!",
            type: .textInput(placeholder: "닉네임을 입력해주세요. (최대 8글자)"),
            options: []
        ),
        OnboardingStep(
            title: "OMT에서 함께 이루고 싶은 목표를 선택해주세요.",
            subtitle: "목표를 입력해주세요.",
            type: .choice,
            options: ["체중 감량하기", "운동 습관 형성하기", "직접 입력하기"]
        ),
        OnboardingStep(
            title: "하루 중 운동할 수 있는\n시간을 알려주세요.",
            type: .choice,
            options: ["18:00 이전", "18:00 이후 부터", "19:00 이후 부터", "20:00 이후 부터"]
        ),
        OnboardingStep(
            title: "OMT와 함께 미션 수행에 투자할 수 있는 시간을 알려주세요!",
            subtitle: "최대 30분까지 입력 가능해요.",
            type: .choice,
            options: ["05분", "10분", "15분", "직접 입력하기"],
            customInputKeyboardType: .numberPad
        ),
        OnboardingStep(
            title: "평소 선호하시는 운동을 선택해주세요.\n(중복 선택 가능)",
            subtitle: "선호하는 운동을 입력해주세요.",
            type: .choice,
            options: ["걷기", "스트레칭/요가", "홈 트레이닝(맨몸 운동)", "헬스", "생활 속 운동", "직접 입력하기"]
        ),
        OnboardingStep(
            title: "최근 한 달 간의 생활패턴과\n가장 유사한 것을 선택해주세요.",
            type: .choice,
            options: [
                "비교적 규칙적인 평일 주간 근무에요.",
                "야근/불규칙한 일정이 자주 있어요.",
                "주기적으로 교대/밤샘 근무가 있어요.",
                "일정이 매일매일 달라요."
            ]
        ),
        OnboardingStep(
            title: "푸시 알람을 켜두면 서비스를\n더 효과적으로 이용하실 수 있어요.",
            subtitle: "알람을 받아보시겠어요?",
            type: .choice,
            options: ["받을래요.", "안 받을래요."]
        ),
    ]
}
