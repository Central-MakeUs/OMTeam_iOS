//
//  MessageRow.swift
//  OMT
//
//  Created by 이인호 on 1/22/26.
//

import SwiftUI
import ComposableArchitecture

struct MessageRow: View {
    @Bindable var store: StoreOf<ChatFeature>
    let message: Message

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isFromUser {
                Spacer()
                Text(message.content)
                    .typography(.sub_b2_4)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 11)
                    .foregroundColor(.gray12)
                    .background(.primary5)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 12,
                            bottomLeadingRadius: 12,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 12
                        )
                    )
                    .frame(maxWidth: 260, alignment: .trailing)
            } else {
                VStack(alignment: .leading) {
                    HStack(spacing: 8) {
                        Image("profile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)

                        Text("채팅봇") // 봇 이름
                            .typography(.sub_b2_1)
                            .foregroundColor(.gray11)
                    }

                    VStack(alignment: .leading, spacing: 20) {
                        Text(message.content)
                            .typography(.sub_b2_4)
                            .foregroundColor(.gray12)

                        if let options = message.options, !options.isEmpty {
                            VStack(spacing: 10) {
                                ForEach(options, id: \.value) { option in
                                    Button {
                                        if message.selectedOption == nil {
                                            // 미션인증에서는 value가 OTHER로 잘 오는데 일반 AI응답은 안올때가 있어 두가지 조건 모두 추가
                                            if option.value == "OTHER" || option.label.contains("직접 입력") {
                                                store.send(.customInputOptionTapped)
                                            } else {
                                                store.send(.optionSelected(label: option.label, value: option.value))
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 8) {
                                            if let iconName = option.iconName,
                                               (option.actionType == "COMPLETE_MISSION" || option.actionType == "MISSION_FAILURE_REASON") {
                                                Image(iconName)
                                            }
                                            Text(option.label)
                                                .typography(.btn2_enabled)
                                                .lineLimit(nil)
                                                .multilineTextAlignment(.center)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.gray12)
                                        .background(
                                            Capsule()
                                                .strokeBorder(.primary3, lineWidth: 1)
                                                .background(Capsule().fill(.primary2))
                                        )
                                    }
                                    .allowsHitTesting(message.selectedOption == nil)
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(.gray2)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: 12,
                            bottomTrailingRadius: 12,
                            topTrailingRadius: 12
                        )
                    )
                    .frame(maxWidth: 260, alignment: .leading)
                }
            }
        }
    }
}
