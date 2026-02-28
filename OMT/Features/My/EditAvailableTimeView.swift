//
//  EditAvailableTimeView.swift
//  OMT
//
//  Created by 이인호 on 2/10/26.
//

import SwiftUI
import ComposableArchitecture

struct EditAvailableTimeView: View {
    @Bindable var store: StoreOf<MyFeature>
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading) {
            itemValueView
            Spacer()
            editButton
        }
        .padding(.top, 16)
        .padding(.horizontal, 20)
        .onDisappear {
            store.send(.availableTimeEditDismissed)
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

extension EditAvailableTimeView {
    private var currentSelectedOption: WorkTimeOption {
        store.selectedAvailableTime ?? store.originalAvailableTime
    }

    @ViewBuilder
    private func timeOptionButton(_ option: WorkTimeOption) -> some View {
        let isSelected = option == currentSelectedOption
        Button {
            store.send(.availableTimeSelected(option))
        } label: {
            Text(option.displayText)
                .typography(.sub_btn2_enabled)
                .foregroundStyle(isSelected ? .gray12 : .gray9)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .strokeBorder(.gray3, lineWidth: 1)
                        .background(Capsule().fill(.gray1))
                )
        }
        .buttonStyle(.plain)
    }

    private var itemValueView: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 20) {
                Text("운동 가능한 시간대를 선택해주세요.")
                    .typography(.sub_b3_1)
                    .foregroundStyle(.gray7)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(currentSelectedOption.displayText)")
                        .typography(.sub_btn2_enabled)
                        .foregroundStyle(.gray12)
                    
                    Divider()
                    
                    HStack(spacing: 2) {
                        Image("icon_info")
                        Text("몇 시 이후부터 운동할 수 있는지 아래에서 선택해주세요.")
                            .typography(.sub_b4_2)
                            .foregroundStyle(.gray8)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("운동 가능 시간대 목록")
                    .typography(.sub_btn3_enabled)
                    .foregroundStyle(.gray10)

                let options = WorkTimeOption.allCases
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        ForEach(options.prefix(2), id: \.self) { option in
                            timeOptionButton(option)
                        }
                    }
                    HStack(spacing: 8) {
                        ForEach(options.suffix(2), id: \.self) { option in
                            timeOptionButton(option)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 12)
    }
}

extension EditAvailableTimeView {
    private var editButton: some View {
        Button {
            store.send(.availableTimeEditConfirmed)
            dismiss()
        } label: {
            Text("시간대 수정하기")
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .typography(store.isAvailableTimeChanged ? .btn2_enabled : .btn2_disabled)
                .foregroundColor(store.isAvailableTimeChanged ? .gray12 : .gray9)
                .background(store.isAvailableTimeChanged ? .primary7 : .primary4)
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .disabled(!store.isAvailableTimeChanged)
        .padding(.bottom, 28 )
    }
}
