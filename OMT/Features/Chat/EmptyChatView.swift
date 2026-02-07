//
//  EmptyChatView.swift
//  OMT
//
//  Created by 이인호 on 2/3/26.
//

import SwiftUI
import ComposableArchitecture

struct EmptyChatView: View {
    @Bindable var store: StoreOf<ChatFeature>

    var body: some View {
        VStack {
            HStack {
                Image("logo")
                    .padding(.vertical, 12)
                Spacer()
            }
            
            Spacer()
            
            VStack(spacing: 32) {
                Image("emptyChat")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 190, height: 190)
                    .overlay(alignment: .topTrailing) {
                        Image("bubble_x")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 52, height: 52)
                            .offset(x: 5, y: -5)
                    }
                
                Text("아직 OMT와 나눈 대화가 없어요!")
                    .typography(.sub_btn2_disabled)
                    .foregroundStyle(.gray10)
            }
            
            Spacer()
            
            Button {
                store.send(.startChatTapped)
            } label: {
                Text("OMT와 채팅 시작하기")
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .typography(.btn2_enabled)
                    .foregroundColor(.gray12)
                    .background(.primary7)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 20)
    }
}
