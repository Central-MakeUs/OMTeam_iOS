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
        Group {
            if store.isLoading && store.messages.isEmpty {
                ChatSkeletonView()
            } else if store.messages.isEmpty && store.mode != .missionComplete {
                EmptyChatView(store: store)
            } else {
                chatContent
            }
        }
        .onAppear {
            if store.mode == .regular {
                store.send(.onAppear)
            }
        }
        .onChange(of: store.shouldFocusInput) { _, newValue in
            if newValue {
                isInputFocused = true
                store.shouldFocusInput = false
            }
        }
    }

    private var chatContent: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                List {
                    ForEach(store.messages) { message in
                        MessageRow(store: store, message: message)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
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

                    if store.isLoading {
                        TypingIndicatorRow()
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                            .listRowBackground(Color.clear)
                            .id("typing-indicator")
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .safeAreaInset(edge: .top) {
                    Color.clear.frame(height: 2)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 2)
                }
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
                    if store.isLoading {
                        proxy.scrollTo("typing-indicator", anchor: .bottom)
                    } else if let lastMessage = store.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                    isAtBottom = true
                }
                .onChange(of: store.isLoading) { _, newValue in
                    if newValue {
                        proxy.scrollTo("typing-indicator", anchor: .bottom)
                    }
                }
                .onChange(of: keyboard.currentHeight) { oldHeight, newHeight in
                    if newHeight > oldHeight && isAtBottom {
                        proxy.scrollTo(store.messages.last?.id, anchor: .bottom)
                    }
                }
            }
            
            messageInput
        }
        .customNavigationBar(
            centerView: {
                HStack(spacing: 6) {
                    Text("채팅하기")
                        .typography(.h2_2)
                        .foregroundStyle(.gray11)
                }
            }
        )
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
