//
//  OnboardingFeature.swift
//  OMT
//
//  Created by 이인호 on 1/19/26.
//

import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct OnboardingFeature {
    @ObservableState
    struct State: Equatable {
        var currentStep = 0
        var totalSteps = 7
        var answers: [Int: String] = [:]
        
        var customInputSheetPresented = false
        var customInputText = ""
        var customInputStepIndex: Int?
        
        var steps: [OnboardingStep] = OnboardingStep.steps
        var currentStepData: OnboardingStep {
            steps[currentStep]
        }
        
        var canProceed: Bool {
            switch currentStepData.type {
            case .textInput:
                let text = answers[currentStep] ?? ""
                let hasSpecialChar = text.range(of: "[^가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]", options: .regularExpression) != nil
                
                return text.count > 0 && text.count <= 8 && !hasSpecialChar
            case .choice:
                return answers[currentStep] != nil
            }
        }
        
        func toServerRequest() -> OnboardingRequestDTO {
            let nickname = answers[0] ?? ""
            let appGoalText = answers[1] ?? ""
            let preferredExerciseText = answers[4] ?? ""
            let remindEnabled = answers[6] == "받을래요."
            
            // 시간 변환
            let timeText = answers[2] ?? ""
            let (startTime, endTime): (String, String)
            if timeText == "18:00 이전" {
                (startTime, endTime) = ("00:00", "17:59")
            } else if timeText.contains("18:00") {
                (startTime, endTime) = ("18:00", "23:59")
            } else if timeText.contains("19:00") {
                (startTime, endTime) = ("19:00", "23:59")
            } else if timeText.contains("20:00") {
                (startTime, endTime) = ("20:00", "23:59")
            } else {
                (startTime, endTime) = ("00:00", "23:59")
            }
            
            // 운동 시간
            let exerciseText = answers[3] ?? "10"
            let minExerciseMinutes = Int(exerciseText.replacingOccurrences(of: "분", with: "")) ?? 10
            
            // 생활패턴 매핑
            let lifestyleText = answers[5] ?? ""
            let lifestyleType: String
            switch lifestyleText {
            case "비교적 규칙적인 평일 주간 근무에요.":
                lifestyleType = "REGULAR_DAYTIME"
            case "야근/불규칙한 일정이 자주 있어요.":
                lifestyleType = "IRREGULAR"
            case "주기적으로 교대/밤샘 근무가 있어요.":
                lifestyleType = "SHIFT_WORK"
            case "일정이 매일매일 달라요.":
                lifestyleType = "VARIABLE"
            default:
                lifestyleType = "REGULAR_DAYTIME"
            }
            
            return OnboardingRequestDTO(
                nickname: nickname,
                appGoalText: appGoalText,
                workTimeType: "FIXED",
                availableStartTime: startTime,
                availableEndTime: endTime,
                minExerciseMinutes: minExerciseMinutes,
                preferredExerciseText: preferredExerciseText,
                lifestyleType: lifestyleType,
                remindEnabled: remindEnabled,
                checkinEnabled: remindEnabled,
                reviewEnabled: remindEnabled
            )
        }
    }
    
    enum Action {
        case optionTapped(String)
        case textInputChanged(String)
        
        // 직접 입력
        case customInputButtonTapped
        case customInputSheetPresentedChanged(Bool)
        case customInputTextChanged(String)
        case customInputConfirmed
        case customInputCanceled
        
        // 버튼
        case nextTapped
        case previousTapped
        case completeTapped
        case skipTapped
        
        case submitToServer
        case submitResponse
        case delegate(Delegate)
        
        enum Delegate {
            case onboardingCompleted
        }
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .optionTapped(option):
                if option == "직접 입력하기" {
                    state.customInputStepIndex = state.currentStep
                    state.customInputText = ""
                    state.customInputSheetPresented = true
                } else {
                    state.answers[state.currentStep] = option
                }
            case let .textInputChanged(text):
                state.answers[state.currentStep] = text
                
            case .customInputButtonTapped:
                state.customInputStepIndex = state.currentStep
                
                let savedAnswer = state.answers[state.currentStep] ?? ""
                
                if state.currentStepData.customInputKeyboardType == .numberPad {
                    state.customInputText = savedAnswer.replacingOccurrences(of: "분", with: "")
                } else {
                    state.customInputText = savedAnswer
                }
                state.customInputSheetPresented = true
                
            case .customInputConfirmed:
                if let stepIndex = state.customInputStepIndex,
                   !state.customInputText.isEmpty {
                    var textToSave = state.customInputText
                    
                    if state.currentStepData.customInputKeyboardType == .numberPad {
                        if !textToSave.hasSuffix("분") {
                            textToSave += "분"
                        }
                    }
                    
                    state.answers[stepIndex] = textToSave
                }
                state.customInputSheetPresented = false
                state.customInputText = ""
                state.customInputStepIndex = nil
                
            case .customInputCanceled:
                state.customInputSheetPresented = false
                state.customInputText = ""
                state.customInputStepIndex = nil
                
            case let .customInputSheetPresentedChanged(isPresented):
                state.customInputSheetPresented = isPresented
                
            case let .customInputTextChanged(text):
                state.customInputText = text
                
            case .nextTapped:
                guard state.canProceed else { return .none }
                
                if state.currentStep < state.totalSteps - 1 {
                    state.currentStep += 1
                } else {
                    return .send(.completeTapped)
                }
                
            case .previousTapped:
                if state.currentStep > 0 {
                    state.currentStep -= 1
                }
                
            case .completeTapped:
                return .run { [state] send in
                    let requestDTO = state.toServerRequest()
                    let router: OnboardingRouter = .saveOnboarding(requestDTO)
                
                    let response = try await networkManager.requestNetwork(
                        dto: OnboardingResponseDTO.self,
                        router: router
                    )
                    
                    if response.success {
                        await send(.delegate(.onboardingCompleted))
                    }
                } catch: { error, send in
                    print(error, send)
                }
                
            case .skipTapped:
                return .run { send in
                    await send(.delegate(.onboardingCompleted))
                }
            
            default:
                break
            }
            
            return .none
                
        }
    }
}

