//
//  EditLifestyleTypeView.swift
//  OMT
//
//  Created by 이인호 on 2/10/26.
//

import SwiftUI
import ComposableArchitecture

struct EditLifestyleTypeView: View {
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

extension EditLifestyleTypeView {
    private var currentSelectedType: LifestyleType {
        store.selectedLifestyleType ?? store.lifestyleType
    }

    @ViewBuilder
    private func lifestyleTypeButton(_ type: LifestyleType) -> some View {
        let isSelected = type == currentSelectedType
        Button {
            store.send(.lifestyleTypeSelected(type))
        } label: {
            Text(type.description)
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
    }

    private var itemValueView: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 20) {
                Text("평소 생활 패턴을 선택해주세요.")
                    .typography(.sub_b3_1)
                    .foregroundStyle(.gray7)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(currentSelectedType.description)")
                        .typography(.sub_btn2_enabled)
                        .foregroundStyle(.gray12)

                    Divider()

                    HStack(spacing: 2) {
                        Image("icon_info")
                        Text("아래의 4가지 선택지 중 하나를 선택해주세요.")
                            .typography(.sub_b4_2)
                            .foregroundStyle(.gray8)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("선택 가능한 생활 패턴 목록")
                    .typography(.sub_btn3_enabled)
                    .foregroundStyle(.gray10)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(LifestyleType.allCases, id: \.self) { type in
                        lifestyleTypeButton(type)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
    }
}


extension EditLifestyleTypeView {
    private var editButton: some View {
        Button {
            store.send(.lifestyleTypeEditConfirmed)
            dismiss()
        } label: {
            Text("생활 패턴 수정하기")
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .typography(store.isLifestyleTypeChanged ? .btn2_enabled : .btn2_disabled)
                .foregroundColor(store.isLifestyleTypeChanged ? .gray12 : .gray9)
                .background(store.isLifestyleTypeChanged ? .primary7 : .primary4)
                .cornerRadius(12)
        }
        .disabled(!store.isLifestyleTypeChanged)
        .padding(.bottom, 28)
    }
}
