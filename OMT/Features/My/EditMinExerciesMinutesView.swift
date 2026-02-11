//
//  EditMinExerciesMinutesView.swift
//  OMT
//
//  Created by 이인호 on 2/10/26.
//

import SwiftUI
import ComposableArchitecture

struct EditMinExerciesMinutesView: View {
    @Bindable var store: StoreOf<MyFeature>
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            itemValueView
            Spacer()
            editButton
        }
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = false
        }
        .customNavigationBar(
            centerView: {
                Text("내 정보 수정하기")
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

extension EditMinExerciesMinutesView {
    private var hasError: Bool {
        store.minExerciseMinutesErrorMessage != nil
    }

    private var infoMessage: String {
        store.minExerciseMinutesErrorMessage ?? "최대 30분까지 입력 가능하며, 숫자로 입력해주세요."
    }

    private var itemValueView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("미션에 투자할 수 있는 시간을 입력해주세요.")
                .typography(.sub_b3_1)
                .foregroundStyle(.gray7)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    TextField(
                        "",
                        text: $store.minExerciseMinutesEditText
                    )
                    .keyboardType(.numberPad)
                    .typography(.sub_btn2_enabled)
                    .foregroundStyle(.gray12)
                    .focused($isFocused)
                }

                Divider()

                HStack(spacing: 2) {
                    Image(hasError ? "error_icon" : "icon_info")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    
                    Text(infoMessage)
                        .typography(.sub_b4_2)
                        .foregroundStyle(hasError ? .error : .gray8)
                }
            }
        }
        .padding(.horizontal, 12)
        .onAppear {
            store.minExerciseMinutesEditText = "\(store.minExerciseMinutes)"
        }
    }
}

extension EditMinExerciesMinutesView {
    private var editButton: some View {
        Button {
            store.send(.minExerciseMinutesEditConfirmed)
            dismiss()
        } label: {
            Text("미션 투자 시간 수정하기")
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .typography(store.isMinExerciseMinutesChanged ? .btn2_enabled : .btn2_disabled)
                .foregroundColor(store.isMinExerciseMinutesChanged ? .gray12 : .gray9)
                .background(store.isMinExerciseMinutesChanged ? .primary7 : .primary4)
                .cornerRadius(12)
        }
        .disabled(!store.isMinExerciseMinutesChanged)
        .padding(.bottom, 28)
    }
}
