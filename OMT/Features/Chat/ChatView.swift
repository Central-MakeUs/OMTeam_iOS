//
//  ChatView.swift
//  OMT
//
//  Created by 이인호 on 1/22/26.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct ChatView: View {
    @Bindable var store: StoreOf<ChatFeature>
    @FocusState private var isInputFocused: Bool
    @State private var isAtBottom: Bool = true
    @StateObject private var keyboard = KeyboardResponder()
    
    var body: some View {
        VStack(spacing: 0) {
            Text("채팅하기")
                .padding(.bottom, 10)
            
            ScrollViewReader { proxy in
                List {
                    ForEach(store.messages) { message in
                        MessageRow(message: message)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowBackground(Color.clear)
                            .id(message.id)
                            .onAppear {
                                if message.id == store.messages.last?.id {
                                    isAtBottom = true
                                }
                            }
                            .onDisappear {
                                if message.id == store.messages.last?.id {
                                    isAtBottom = false
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .onTapGesture {
                    isInputFocused = false
                }
                .onAppear {
                    if let lastMessage = store.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                    isAtBottom = true
                }
                .onChange(of: store.messages.count) { _, _ in
                    if let lastMessage = store.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                    isAtBottom = true
                }
                .onChange(of: keyboard.currentHeight) { oldHeight, newHeight in
                    if newHeight > oldHeight && isAtBottom {
                        proxy.scrollTo(store.messages.last?.id, anchor: .bottom)
                    }
                }
            }
            
            messageInput
        }
    }
}

extension ChatView {
    private var messageInput: some View {
        HStack(spacing: 8) {
            TextField(
                "",
                text: $store.inputText,
                prompt: Text("메시지를 입력해주세요.")
                    .typography(.sub_b3_1)
                    .foregroundStyle(.gray7)
            )
                .focused($isInputFocused)
                .submitLabel(.send)
                .onSubmit {
                    store.send(.sendButtonTapped)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 15)
                .typography(.sub_btn2_enabled)
                .foregroundStyle(.gray10)
                .background(.gray0)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.greenGray3, lineWidth: 1)
                )
                .autocorrectionDisabled()
            
            Button {
                store.send(.sendButtonTapped)
            } label: {
                Image("arrow_up")
            }
            .frame(width: 48, height: 48)
            .background(.primary7)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .disabled(store.inputText.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(.greenGray2)
    }
}
