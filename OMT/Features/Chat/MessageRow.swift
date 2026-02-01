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
                if message.type == .text {
                    Text(message.content)
                        .typography(.sub_b2_4)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 11)
                        .background(.gray2)
                        .foregroundColor(.gray12)
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: 12,
                                bottomTrailingRadius: 12,
                                topTrailingRadius: 12
                            )
                        )
                        .frame(maxWidth: 250, alignment: .leading)
                } else {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "heart") // 프로필
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                            
                            Text("채팅봇") // 봇 이름
                        }
                        
                        VStack(alignment: .leading, spacing: 20) {
                            Text(message.content)
                                .typography(.sub_b2_4)
                                .foregroundColor(.gray12)
                            
                            VStack(spacing: 10) {
                                if let options = message.options {
                                    ForEach(options, id: \.self) { option in
                                        Button {
                                            if message.selectedOption == nil {  // 선택 안 된 경우만 동작
                                                store.send(.optionSelected(option))
                                            }
                                        } label: {
                                            Text(option)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 10)
                                                .frame(maxWidth: .infinity)
                                                .foregroundColor(.blue)
                                                .background(
                                                    Capsule()
                                                        .fill(message.selectedOption == option ?
                                                            .greenGray5 : .greenGray2)
                                                )
                                                .overlay(
                                                    Capsule()
                                                        .stroke(.greenGray5, lineWidth: 1)
                                                )
                                        }
                                        .allowsHitTesting(message.selectedOption == nil)
                                    }
                                    .buttonStyle(PlainButtonStyle())
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
                
                Spacer()
            }
        }
    }
}
