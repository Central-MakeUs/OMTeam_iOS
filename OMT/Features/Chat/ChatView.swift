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
        HStack(spacing: 12) {
            TextField("메시지를 입력하세요", text: $store.inputText)
                .textFieldStyle(.roundedBorder)
                .focused($isInputFocused)
                .submitLabel(.send)
                .onSubmit {
                    store.send(.sendButtonTapped)
                }
            
            Button {
                store.send(.sendButtonTapped)
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(store.inputText.isEmpty ? .gray : .blue)
            }
            .disabled(store.inputText.isEmpty)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
