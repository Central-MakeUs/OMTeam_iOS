//
//  EditMyGoalView.swift
//  OMT
//
//  Created by 이인호 on 2/9/26.
//

import SwiftUI
import ComposableArchitecture

struct EditAppGoalView: View {
    @Bindable var store: StoreOf<MyFeature>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("나의 목표")
                .typography(.h4)
                .foregroundStyle(.gray11)
                .padding(.bottom, 12)
            
            HStack(spacing: 0) {
                Image("goal")
                
                TextField(
                    "",
                    text: $store.appGoalEditText,
                )
                .padding()
                .typography(.h3)
                .foregroundStyle(.gray11)
                .autocorrectionDisabled()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 27)
            .frame(height: 91)
            .frame(maxWidth: .infinity)
            .background(.gray2)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            HStack(spacing: 2) {
                if let appGoalErrorMessage = store.appGoalErrorMessage {
                    Image("error_icon")
                    Text(appGoalErrorMessage)
                        .typography(.sub_b4_2)
                        .foregroundStyle(.error)
                } else {
                    Image("icon_info")
                    Text("목표는 공백 포함 최대 15글자까지 입력할 수 있어요.")
                        .typography(.sub_b4_2)
                        .foregroundStyle(.gray8)
                }
            }
            .padding(.top, 8)

            Spacer()

            Button {
                store.send(.appGoalEditConfirmed)
                dismiss()
            } label: {
                Text("목표 수정하기")
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .typography(store.isAppGoalValid ? .btn2_enabled : .btn2_disabled)
                    .foregroundColor(store.isAppGoalValid ? .gray12 : .gray9)
                    .background(store.isAppGoalValid ? .primary7 : .primary4)
                    .cornerRadius(12)
            }
            .disabled(!store.isAppGoalValid)
        }
        .padding(.top, 8)
        .padding(.horizontal, 20)
        .padding(.bottom, 28)
        .customNavigationBar(
            centerView: {
                Text("나의 목표 수정하기")
                    .typography(.h2_2)
                    .foregroundStyle(.gray11)
            },
            leftView: {
                Button {
                    dismiss()
                } label: {
                    Image("arrow_back_01")
                }
            },
        )
    }
}
