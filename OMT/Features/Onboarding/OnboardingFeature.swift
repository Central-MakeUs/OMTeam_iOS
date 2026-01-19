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
                let hasSpecialChar = text.range(of: "[^가-힣a-zA-Z0-9]", options: .regularExpression) != nil
                
                return text.count > 0 && text.count <= 8 && !hasSpecialChar
            case .choice:
                return answers[currentStep] != nil
            }
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
                print(state.answers) // 온보딩 선택 결과 확인
                return .send(.submitToServer)
                
            default:
                break
            }
            
            return .none
                
        }
    }
}

