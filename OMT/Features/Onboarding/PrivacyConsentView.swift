//
//  PrivacyConsentView.swift
//  OMT
//
//  Created by 이인호 on 2/17/26.
//

import SwiftUI
import ComposableArchitecture

struct PrivacyConsentView: View {
    let store: StoreOf<OnboardingFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("개인정보 제3자 제공 동의")
                .typography(.h2_1)
                .foregroundStyle(.gray12)
                .padding(.bottom, 12)

            Text("온보딩에서 입력하신 정보(닉네임, 목표, 운동 선호도, 가능한 시간, 생활패턴 등)와 미션 수행 데이터가 맞춤형 미션 추천과 AI 분석을 위해 Upstage AI로 전송됩니다.")
                .typography(.sub_b2_2)
                .foregroundStyle(.gray9)
                .padding(.bottom, 28)

            Text("수집된 정보는 서비스 제공 목적으로만 사용되며, 관련 법령에 따라 보관 후 파기됩니다.")
                .typography(.sub_b4_1)
                .foregroundStyle(.gray6)
            
            Spacer()

            VStack(spacing: 10) {
                Button {
                    store.send(.privacyConsentAgreed)
                } label: {
                    Text("동의하고 시작하기")
                        .typography(.btn2_enabled)
                        .foregroundStyle(.gray12)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(.primary7)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)

                Button {
                    store.send(.privacyConsentDeclined)
                } label: {
                    Text("동의 안 함")
                        .typography(.sub_b3_1)
                        .foregroundStyle(.gray9)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 48)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .background(.gray0)
        .overlay {
            if let alertType = store.privacyConsentAlertType {
                CustomAlertView(
                    alertType: alertType,
                    onCancel: {
                        store.send(.privacyConsentAlertCanceled)
                    },
                    onConfirm: {
                        store.send(.privacyConsentAlertConfirmed)
                    }
                )
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: store.privacyConsentAlertType)
            }
        }
    }
}
