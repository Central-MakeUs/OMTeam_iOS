//
//  MessageRow.swift
//  OMT
//
//  Created by 이인호 on 1/22/26.
//

import SwiftUI
import ComposableArchitecture

struct MessageRow: View {
    let store: StoreOf<ChatFeature>
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
                    .frame(maxWidth: 250, alignment: .trailing)
            } else {
                VStack(alignment: .leading) {
                    HStack {
                        Image("profile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)

                        Text("채팅봇") // 봇 이름
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
                                            store.send(.optionSelected(label: option.label, value: option.value))
                                        }
                                    } label: {
                                        Text(option.label)
                                            .typography(.btn2_enabled)
                                            .lineLimit(nil)
                                            .multilineTextAlignment(.center)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .frame(maxWidth: .infinity)
                                            .foregroundColor(.gray12)
                                            .background(
                                                Capsule()
                                                    .fill(.primary2)
                                            )
                                            .overlay(
                                                Capsule()
                                                    .stroke(.primary3, lineWidth: 1)
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
                    .frame(maxWidth: 250, alignment: .leading)
                }
            }
        }
    }
}
