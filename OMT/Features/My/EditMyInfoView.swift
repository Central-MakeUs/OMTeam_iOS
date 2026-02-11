//
//  EditMyInfoView.swift
//  OMT
//
//  Created by 이인호 on 2/10/26.
//

import SwiftUI
import ComposableArchitecture

struct EditMyInfoView: View {
    @Bindable var store: StoreOf<MyFeature>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading) {
            infoListView
            withdrawCell
            Spacer()
        }
        .padding(.top, 36)
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

extension EditMyInfoView {
    private var infoListView: some View {
        VStack(spacing: 28) {
            ForEach(MyFeature.ListItem.allCases, id: \.self) { item in
                VStack(spacing: 4) {
                    NavigationLink(destination: destinationView(for: item)) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(item.rawValue)
                                    .typography(.sub_b3_1)
                                    .foregroundStyle(.gray7)
                                Spacer()
                                Image("arrow_forth")
                            }
                            
                            itemValueView(for: item)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
        }
        .padding(.bottom, 54)
    }

    @ViewBuilder
    private func itemValueView(for item: MyFeature.ListItem) -> some View {
        switch item {
        case .avaliableTime:
            let timeOption = WorkTimeOption(serverStartTime: store.availableStartTime)
            
            Text("\(timeOption.displayText)")
                .typography(.sub_btn2_enabled)
                .foregroundStyle(.gray12)
        case .minExerciseMinutes:
            Text("\(store.minExerciseMinutes)분")
                .typography(.sub_btn2_enabled)
                .foregroundStyle(.gray12)
        case .preferredExercises:
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(store.preferredExercises, id: \.self) { exercise in
                        Text(exercise)
                            .typography(.sub_btn2_enabled)
                            .foregroundStyle(.gray12)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .strokeBorder(.gray3, lineWidth: 1)
                                    .background(Capsule().fill(.gray1))
                            )
                    }
                }
            }
        case .lifestyleType:
            Text(store.lifestyleType.description)
                .typography(.sub_btn2_enabled)
                .foregroundStyle(.gray12)
        }
    }
    
    @ViewBuilder
    private func destinationView(for item: MyFeature.ListItem) -> some View {
        switch item {
        case .avaliableTime:
            EditAvailableTimeView(store: store)
        case .minExerciseMinutes:
            EditMinExerciesMinutesView(store: store)
        case .preferredExercises:
            EditPreferredExercisesView(store: store)
        case .lifestyleType:
            EditLifestyleTypeView(store: store)
        }
    }
}


extension EditMyInfoView {
    private var withdrawCell: some View {
        HStack {
            Text("회원정보를 삭제하시겠어요?")
                .typography(.sub_b3_1)
                .foregroundStyle(.gray7)

            Spacer()

            Button {
                store.send(.withdrawButtonTapped)
            } label: {
                Text("회원탈퇴")
                    .typography(.sub_btn3_disabled)
                    .foregroundStyle(.gray7)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}
