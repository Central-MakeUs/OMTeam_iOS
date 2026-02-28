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

        var showPrivacyConsent = false
        var privacyConsentAlertType: AlertType?

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
            let preferredExercisesText = answers[4] ?? ""
            let preferredExercises = preferredExercisesText
                .components(separatedBy: ", ")
                .filter { !$0.isEmpty }
            let remindEnabled = answers[6] == "받을래요."
            
            // 시간 변환
            let timeText = answers[2] ?? ""
            let timeOption = WorkTimeOption.from(selectionText: timeText)
            
            // 운동 시간
            let exerciseText = answers[3] ?? "10"
            let minExerciseMinutes = Int(exerciseText.replacingOccurrences(of: "분", with: "")) ?? 10
            
            // 생활패턴 매핑
            let lifestyleText = answers[5] ?? ""
            let selectedLifeStyleType = LifestyleType.allCases.first { $0.description == lifestyleText } ?? .regularDaytime
            
            return OnboardingRequestDTO(
                nickname: nickname,
                appGoalText: appGoalText,
                workTimeType: "FIXED",
                availableStartTime: timeOption.startTime,
                availableEndTime: timeOption.endTime,
                minExerciseMinutes: minExerciseMinutes,
                preferredExercises: preferredExercises,
                lifestyleType: selectedLifeStyleType,
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

        case privacyConsentAgreed
        case privacyConsentDeclined
        case privacyConsentAlertCanceled
        case privacyConsentAlertConfirmed
        case privacyConsentWithdrawCompleted

        case delegate(Delegate)

        enum Delegate {
            case onboardingCompleted
            case privacyConsentWithdrawCompleted
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
                } else if state.currentStepData.maxSelections > 1 {
                    var selections = (state.answers[state.currentStep] ?? "")
                        .components(separatedBy: ", ")
                        .filter { !$0.isEmpty }

                    if let index = selections.firstIndex(of: option) {
                        selections.remove(at: index)
                    } else if selections.count < state.currentStepData.maxSelections {
                        selections.append(option)
                    }

                    if selections.isEmpty {
                        state.answers.removeValue(forKey: state.currentStep)
                    } else {
                        state.answers[state.currentStep] = selections.joined(separator: ", ")
                    }
                } else {
                    state.answers[state.currentStep] = option
                }
            case let .textInputChanged(text):
                state.answers[state.currentStep] = text
                
            case .customInputButtonTapped:
                state.customInputStepIndex = state.currentStep

                if state.currentStepData.maxSelections > 1 {
                    let predefinedOptions = Set(state.currentStepData.options.filter { $0 != "직접 입력하기" })
                    let selections = (state.answers[state.currentStep] ?? "")
                        .components(separatedBy: ", ")
                        .filter { !$0.isEmpty }
                    state.customInputText = selections.first { !predefinedOptions.contains($0) } ?? ""
                } else {
                    let savedAnswer = state.answers[state.currentStep] ?? ""
                    if state.currentStepData.customInputKeyboardType == .numberPad {
                        state.customInputText = savedAnswer.replacingOccurrences(of: "분", with: "")
                    } else {
                        state.customInputText = savedAnswer
                    }
                }
                state.customInputSheetPresented = true
                
            case .customInputConfirmed:
                if let stepIndex = state.customInputStepIndex {
                    let step = state.steps[stepIndex]

                    if step.maxSelections > 1 {
                        let predefinedOptions = Set(step.options.filter { $0 != "직접 입력하기" })
                        var selections = (state.answers[stepIndex] ?? "")
                            .components(separatedBy: ", ")
                            .filter { !$0.isEmpty }

                        // Remove previous custom input
                        selections = selections.filter { predefinedOptions.contains($0) }

                        // Add new custom input if not empty and within limit
                        if !state.customInputText.isEmpty, selections.count < step.maxSelections {
                            selections.append(state.customInputText)
                        }

                        if selections.isEmpty {
                            state.answers.removeValue(forKey: stepIndex)
                        } else {
                            state.answers[stepIndex] = selections.joined(separator: ", ")
                        }
                    } else if !state.customInputText.isEmpty {
                        var textToSave = state.customInputText

                        if step.customInputKeyboardType == .numberPad {
                            if !textToSave.hasSuffix("분") {
                                textToSave += "분"
                            }
                        }

                        state.answers[stepIndex] = textToSave
                    }
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
                state.showPrivacyConsent = true

            case .privacyConsentAgreed:
                return .run { [state] send in
                    let requestDTO = state.toServerRequest()
                    let router: OnboardingRouter = .saveOnboarding(requestDTO)

                    let response = try await networkManager.requestNetwork(
                        dto: OnboardingResponseDTO.self,
                        router: router
                    )
                    
                    if response.success {
                        UserDefaults.standard.set(requestDTO.remindEnabled, forKey: "isNotificationOn")
                        await send(.delegate(.onboardingCompleted))
                    }
                } catch: { error, send in
                    print(error, send)
                }

            case .privacyConsentDeclined:
                state.privacyConsentAlertType = .privacyConsentDeclined

            case .privacyConsentAlertCanceled:
                state.privacyConsentAlertType = nil

            case .privacyConsentAlertConfirmed:
                state.privacyConsentAlertType = nil
                return .run { [networkManager] send in
                    _ = try await networkManager.requestNetwork(
                        dto: WithdrawResponseDTO.self,
                        router: AuthRouter.withdraw
                    )
                    await send(.delegate(.privacyConsentWithdrawCompleted))
                } catch: { error, send in
                    print(error)
                    await send(.delegate(.privacyConsentWithdrawCompleted))
                }

            case .privacyConsentWithdrawCompleted:
                break

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

