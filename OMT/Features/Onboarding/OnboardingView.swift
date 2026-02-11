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
    @FocusState private var isFocused: Bool

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
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = false
        }
        .sheet(isPresented: $store.customInputSheetPresented.sending(\.customInputSheetPresentedChanged)) {
            customInputSheet
                .presentationDetents([.height(260)])
                .presentationCornerRadius(32)
        }
    }
}

extension OnboardingView {
    private var headerView: some View {
        VStack {
//            skipButton
            progressView
        }
        .padding(.top, 48)
        .padding(.bottom, 40)
    }
    
    private var skipButton: some View {
        VStack {
            Button {
                store.send(.skipTapped)
            } label: {
                Text("SKIP")
                    .typography(.sub_b3_1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .foregroundColor(.greenGray6)
                    .background(
                        Capsule()
                            .strokeBorder(.greenGray5, lineWidth: 1)
                            .background(Capsule().fill(.greenGray2))
                    )
            }
            .buttonStyle(.plain)
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
                        .frame(height: 60)
                        .typography( .btn2_disabled)
                        .foregroundColor(.gray7)
                        .background(.gray3)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .frame(width: 126)

                Button {
                    store.send(.nextTapped)
                } label: {
                    Text("다음")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .typography(store.canProceed ? .btn2_enabled : .btn2_disabled)
                        .foregroundColor(store.canProceed ? .gray12 : .gray9)
                        .background(store.canProceed ? .primary7 : .primary4)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .disabled(!store.canProceed)
            } else {
                Button {
                    store.send(.nextTapped)
                } label: {
                    Text("다음")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .typography(store.canProceed ? .btn2_enabled : .btn2_disabled)
                        .foregroundColor(store.canProceed ? .gray12 : .gray9)
                        .background(store.canProceed ? .primary7 : .primary4)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
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
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.greenGray2)
                    .strokeBorder(.greenGray4, lineWidth: 1)
            )
            .autocorrectionDisabled()
            .focused($isFocused)

            let text = store.answers[store.currentStep] ?? ""
            let hasSpecialChar = text.range(of: "[^가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]", options: .regularExpression) != nil
            var errorMessage: String? {
                guard !text.isEmpty else { return nil }
                if text.count > 8 { return "글자수를 초과했어요!" }
                if hasSpecialChar { return "특수문자는 입력할 수 없습니다." }
                return nil
            }
            
            if let errorMessage = errorMessage {
                HStack {
                    Image("error_icon")
                    Text(errorMessage)
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
                        selected: isOptionSelected(option),
                        action: { store.send(.optionTapped(option)) }
                    )
                }
            }
        }
    }

    private func isOptionSelected(_ option: String) -> Bool {
        guard let answer = store.answers[store.currentStep] else { return false }
        if store.currentStepData.maxSelections > 1 {
            return answer.components(separatedBy: ", ").contains(option)
        }
        return answer == option
    }
    
    private var customInputButton: some View {
        VStack {
            if store.currentStepData.maxSelections > 1 {
                let predefinedOptions = Set(store.currentStepData.options.filter { $0 != "직접 입력하기" })
                let selections = (store.answers[store.currentStep] ?? "")
                    .components(separatedBy: ", ")
                    .filter { !$0.isEmpty }
                let customValue = selections.first { !predefinedOptions.contains($0) }
                let isCustomAnswer = customValue != nil
                let displayText = customValue ?? "직접 입력하기"

                OptionButton(
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
            } else {
                let currentAnswer = store.answers[store.currentStep]
                let isCustomAnswer = currentAnswer != nil && !store.currentStepData.options.dropLast().contains(currentAnswer!)
                let displayText = isCustomAnswer ? currentAnswer! : "직접 입력하기"
                
                OptionButton(
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
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.greenGray2)
                    .strokeBorder(.greenGray4, lineWidth: 1)
            )
            .autocorrectionDisabled()
            .focused($isFocused)
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
            .buttonStyle(.plain)
            .disabled(isDisabled)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 20)
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = false
        }
    }
}
