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
        }
        .padding(.horizontal, 16)
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
}

