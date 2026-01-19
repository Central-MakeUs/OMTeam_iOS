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
        VStack(spacing: 32) {
            progressView
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 16) {
                Text(store.currentStepData.title)
                
                stepContent
            }
            
            Spacer()
            
            navigationButtons
                .padding(.bottom)
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $store.customInputSheetPresented.sending(\.customInputSheetPresentedChanged)) {
            customInputSheet
                .presentationDetents([.height(260)])
        }
    }
    
    private var progressView: some View {
        VStack {
            HStack {
                ForEach(0..<store.totalSteps, id: \.self) { index in
                    Circle()
                        .fill(index == store.currentStep ? .blue : .gray)
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
    
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
        HStack(spacing: 16) {
            if store.currentStep > 0 {
                Button {
                    store.send(.previousTapped)
                } label: {
                    Text("이전")
                        .font(.body)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Button {
                    store.send(.nextTapped)
                } label: {
                    Text("다음")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(store.canProceed ? Color.blue : Color.gray.opacity(0.3))
                        .cornerRadius(12)
                }
                .disabled(!store.canProceed)
            } else {
                Button {
                    store.send(.nextTapped)
                } label: {
                    Text("다음")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(store.canProceed ? Color.blue : Color.gray.opacity(0.3))
                        .cornerRadius(12)
                }
                .disabled(!store.canProceed)
            }
        }
    }
}

// MARK: - 닉네임 Input
extension OnboardingView {
    private var textInputView: some View {
        VStack(alignment: .leading) {
            TextField("닉네임을 입력해주세요. (최대 8글자)", text: Binding(
                get: { store.answers[store.currentStep] ?? "" },
                set: { store.send(.textInputChanged($0)) }
            ))
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .autocorrectionDisabled()
            
            let text = store.answers[store.currentStep] ?? ""
            let hasSpecialChar = text.range(of: "[^가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]", options: .regularExpression) != nil
            
            if !text.isEmpty {
                if text.count > 8 {
                    Text("글자수를 초과했어요!")
                        .foregroundStyle(.red)
                } else if hasSpecialChar {
                    Text("특수문자는 입력할 수 없습니다.")
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

// MARK: - 선택지 Buttons
extension OnboardingView {
    private var optionButtons: some View {
        VStack {
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
                store.currentStepData.subtitle ?? "",
                text: $store.customInputText.sending(
                    \.customInputTextChanged
                )
            )
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .autocorrectionDisabled()
            .keyboardType(store.currentStepData.customInputKeyboardType)
            
            
            let text = store.customInputText
            let isNumberPad = store.currentStepData.customInputKeyboardType == .numberPad
            let inputTextToInt = Int(text) ?? 0
            
            let exceedLimit = isNumberPad && inputTextToInt > 30
            
            if exceedLimit {
                Text("30이하 숫자를 입력해주세요.")
                    .foregroundStyle(.red)
            }
            
            let isDisabled = text.isEmpty || exceedLimit
            
            Spacer()
            
            Button {
                store.send(.customInputConfirmed)
            } label: {
                Text("확인")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(isDisabled ? Color.gray : Color.blue)
                    .cornerRadius(12)
            }
            .disabled(isDisabled)
        }
        .padding(.horizontal, 16)
        .padding(.top, 30)
        .padding(.bottom, 20)
    }
}
