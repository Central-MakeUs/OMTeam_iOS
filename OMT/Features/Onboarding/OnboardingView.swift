//
//  OnboardingView.swift
//  OMT
//
//  Created by 이인호 on 1/19/26.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingView: View {
    @Bindable var store: StoreOf<OnboardingFeature>
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            VStack(alignment: .leading, spacing: 20) {
                Text(store.currentStepData.title)
                    .typography(.h2_1)
                    .foregroundStyle(.gray11)
                    .lineLimit(nil)
                
                stepContent
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            navigationButtons
        }
        .sheet(isPresented: $store.customInputSheetPresented.sending(\.customInputSheetPresentedChanged)) {
            customInputSheet
                .presentationDetents([.height(260)])
        }
    }
}

extension OnboardingView {
    private var headerView: some View {
        VStack(alignment: .trailing, spacing: 28) {
            skipButton
            progressView
        }
        .padding(.top, 12)
        .padding(.bottom, 36)
    }
    
    private var skipButton: some View {
        VStack {
            Button {
                
            } label: {
                Text("SKIP")
                    .typography(.sub_b3_1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .foregroundColor(.greenGray6)
                    .background(
                        Capsule()
                            .fill(.greenGray2)
                    )
                    .overlay(
                        Capsule()
                            .stroke(.greenGray5, lineWidth: 1)
                    )
            }
        }
        .padding(.trailing, 20)
    }
    
    private var progressView: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(.greenGray4)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
            
            ForEach(0..<store.totalSteps, id: \.self) { index in
                ZStack {
                    Circle()
                        .fill(index == store.currentStep ? .primary6 : .greenGray4)
                        .frame(width: 32, height: 32)
                    
                    Text("0\(index + 1)")
                        .typography(index == store.currentStep ? .sub_btn3_enabled : .sub_btn3_disabled)
                        .foregroundStyle(index == store.currentStep ? .gray0 : .greenGray1)
                }
                
                Rectangle()
                    .fill(.greenGray4)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

extension OnboardingView {
    @ViewBuilder
    private var stepContent: some View {
        switch store.currentStepData.type {
        case .textInput:
            textInputView
        case .choice:
            optionButtons
        }
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 9) {
            if store.currentStep > 0 {
                Button {
                    store.send(.previousTapped)
                } label: {
                    Text("이전")
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .typography( .btn2_disabled)
                        .foregroundColor(.gray7)
                        .background(.gray3)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .frame(width: 126)
                
                Button {
                    store.send(.nextTapped)
                } label: {
                    Text("다음")
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .typography(store.canProceed ? .btn2_enabled : .btn2_disabled)
                        .foregroundColor(store.canProceed ? .gray12 : .gray9)
                        .background(store.canProceed ? .primary7 : .primary4)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .frame(maxWidth: .infinity)
                .disabled(!store.canProceed)
            } else {
                Button {
                    store.send(.nextTapped)
                } label: {
                    Text("다음")
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .typography(store.canProceed ? .btn2_enabled : .btn2_disabled)
                        .foregroundColor(store.canProceed ? .gray12 : .gray9)
                        .background(store.canProceed ? .primary7 : .primary4)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(!store.canProceed)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

// MARK: - 닉네임 Input
extension OnboardingView {
    private var textInputView: some View {
        VStack(alignment: .leading) {
            TextField(
                "",
                text: Binding(
                    get: { store.answers[store.currentStep] ?? "" },
                    set: { store.send(.textInputChanged($0)) }
                ),
                prompt: Text("닉네임을 입력해주세요. (최대 8글자)")
                    .typography(.sub_btn3_disabled)
                    .foregroundStyle(.gray6)
            )
            .padding()
            .typography(.sub_btn2_enabled)
            .foregroundStyle(.gray10)
            .background(.greenGray2)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.greenGray4, lineWidth: 1)
            )
            .autocorrectionDisabled()
            
            let text = store.answers[store.currentStep] ?? ""
            let hasSpecialChar = text.range(of: "[^가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]", options: .regularExpression) != nil
            
            if !text.isEmpty {
                if text.count > 8 {
                    Text("글자수를 초과했어요!")
                        .typography(.sub_btn2_enabled)
                        .foregroundStyle(.error)
                } else if hasSpecialChar {
                    Text("특수문자는 입력할 수 없습니다.")
                        .typography(.sub_btn2_enabled)
                        .foregroundStyle(.error)
                }
            }
        }
    }
}

// MARK: - 선택지 Buttons
extension OnboardingView {
    private var optionButtons: some View {
        VStack(spacing: 12) {
            ForEach(store.currentStepData.options, id: \.self) { option in
                if option == "직접 입력하기" {
                    customInputButton
                } else {
                    OptionButton(
                        title: option,
                        selected: store.answers[store.currentStep] == option,
                        action: { store.send(.optionTapped(option)) }
                    )
                }
            }
        }
    }
    
    private var customInputButton: some View {
        let currentAnswer = store.answers[store.currentStep]
        let isCustomAnswer = currentAnswer != nil && !store.currentStepData.options.dropLast().contains(currentAnswer!)
        let displayText = isCustomAnswer ? currentAnswer! : "직접 입력하기"
        
        return OptionButton(
            title: displayText,
            selected: isCustomAnswer,
            action: {
                if isCustomAnswer {
                    store.send(.customInputButtonTapped)
                } else {
                    store.send(.optionTapped("직접 입력하기"))
                }
            }
        )
    }
}

// MARK: - 직접 입력 모달시트
extension OnboardingView {
    private var customInputSheet: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField(
                "",
                text: $store.customInputText.sending(
                    \.customInputTextChanged
                ),
                prompt: Text(store.currentStepData.subtitle ?? "")
                    .typography(.sub_btn3_disabled)
                    .foregroundStyle(.gray6)
            )
            .padding()
            .typography(.sub_btn2_enabled)
            .foregroundStyle(.gray10)
            .background(.greenGray2)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.greenGray4, lineWidth: 1)
            )
            .autocorrectionDisabled()
            .keyboardType(store.currentStepData.customInputKeyboardType)
            .onChange(of: store.customInputText) { oldValue, newValue in
                if store.currentStepData.customInputKeyboardType == .numberPad {
                    if let number = Int(newValue), number < 1 || number > 30 {
                        store.send(.customInputTextChanged(oldValue))
                    }
                }
            }
            
            let isDisabled = store.customInputText.isEmpty
            
            Spacer()
            
            Button {
                store.send(.customInputConfirmed)
            } label: {
                Text("확인")
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .typography(isDisabled ? .btn2_disabled : .btn2_enabled)
                    .foregroundColor(isDisabled ? .gray9 : .gray12)
                    .background(isDisabled ? .primary4 : .primary7)
                    .cornerRadius(12)
            }
            .disabled(isDisabled)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 20)
    }
}
