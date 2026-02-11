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

    private var itemValueView: some View {
        VStack(alignment: .leading) {
            Text("평소 생활 패턴을 선택해주세요.")

            Text("\(currentSelectedType.description)")
                .typography(.sub_btn3_enabled)
                .foregroundStyle(.gray8)

            Divider()

            HStack {
                Image("icon_info")
                Text("아래의 4가지 선택지 중 하나를 선택해주세요.")
            }

            Text("선택 가능한 생활 패턴 목록")

            VStack(spacing: 8) {
                ForEach(LifestyleType.allCases, id: \.self) { type in
                    Button {
                        store.send(.lifestyleTypeSelected(type))
                    } label: {
                        let isSelected = type == currentSelectedType
                        Text(type.description)
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
    }
}
