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
    
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            itemValueView
            Spacer()
            editButton
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

    private var itemValueView: some View {
        VStack(alignment: .leading) {
            Text("운동 가능한 시간대를 선택해주세요.")

            Text("\(currentSelectedOption.displayText)")
                .typography(.sub_btn3_enabled)
                .foregroundStyle(.gray8)

            Divider()

            HStack {
                Image("icon_info")
                Text("몇 시 이후부터 운동할 수 있는지 아래에서 선택해주세요.")
            }

            Text("운동 가능 시간대 목록")

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(WorkTimeOption.allCases, id: \.self) { option in
                    Button {
                        store.send(.availableTimeSelected(option))
                    } label: {
                        let isSelected = option == currentSelectedOption
                        Text(option.displayText)
                            .typography(.sub_btn3_enabled)
                            .foregroundStyle(isSelected ? .white : .gray10)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(isSelected ? .primary7 : .greenGray3)
                            .clipShape(Capsule())
                    }
                }
            }
        }
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
        .disabled(!store.isAvailableTimeChanged)
    }
}
