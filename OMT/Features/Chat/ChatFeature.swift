//
//  ChatFeature.swift
//  OMT
//
//  Created by 이인호 on 1/22/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ChatFeature {
    @ObservableState
    struct State: Equatable {
        var messages: [Message] = []
        var inputText: String = ""
        var isLoading: Bool = false
        var hasActiveSession: Bool = false
        var hasFetched: Bool = false
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case fetchChatResponse(ChatDataDTO)
        case startChatTapped
        case sendEmptyChatResponse(MessageDataDTO)
        case sendButtonTapped
        case sendMessageResponse(MessageDataDTO)
        case optionSelected(label: String, value: String)

        case delegate(Delegate)

        enum Delegate {

        }
    }

    @Dependency(\.networkManager) var networkManager

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.hasFetched else { return .none }
                state.isLoading = true
                return .run { send in
                    let response = try await networkManager.requestNetwork(
                        dto: ChatResponseDTO.self,
                        router: ChatRouter.fetchChat()
                    )

                    if let data = response.data {
                        await send(.fetchChatResponse(data))
                    }
                } catch: { error, send in
                    print(error)
                }

            case .fetchChatResponse(let data):
                state.isLoading = false
                state.hasFetched = true
                state.hasActiveSession = data.hasActiveSession
                state.messages = data.messages.map { Message.from($0) }

            case .startChatTapped:
                state.isLoading = true
                return .run { send in
                    let response = try await networkManager.requestNetwork(
                        dto: MessageResponseDTO.self,
                        router: ChatRouter.sendEmptyChat
                    )

                    if let data = response.data {
                        await send(.sendEmptyChatResponse(data))
                    }
                } catch: { error, send in
                    print(error)
                }

            case .sendEmptyChatResponse(let data):
                state.isLoading = false
                let message = Message.from(data)
                state.messages.append(message)

            case .sendButtonTapped:
                guard !state.inputText.isEmpty else { return .none }
                let text = state.inputText
                state.inputText = ""
                state.isLoading = true

                let tempId = (state.messages.last?.id ?? 0) + 1
                let userMessage = Message(
                    id: tempId,
                    content: text,
                    isFromUser: true,
                    createdAt: ISO8601DateFormatter().string(from: Date()),
                    options: nil,
                    terminal: false,
                    selectedOption: nil
                )
                state.messages.append(userMessage)

                return .run { send in
                    let request = MessageRequestDTO(
                        type: .text,
                        text: text,
                        value: "",
                        startRequest: false
                    )

                    let response = try await networkManager.requestNetwork(
                        dto: MessageResponseDTO.self,
                        router: ChatRouter.sendChat(request)
                    )

                    if let data = response.data {
                        await send(.sendMessageResponse(data))
                    }
                } catch: { error, send in
                    print(error)
                }

            case .sendMessageResponse(let data):
                state.isLoading = false
                let message = Message.from(data)
                state.messages.append(message)

            case .optionSelected(let label, let value):
                if let index = state.messages.lastIndex(where: { $0.options != nil && $0.selectedOption == nil }) {
                    state.messages[index].selectedOption = value
                }
                state.isLoading = true

                let tempId = (state.messages.last?.id ?? 0) + 1
                let userMessage = Message(
                    id: tempId,
                    content: label,
                    isFromUser: true,
                    createdAt: ISO8601DateFormatter().string(from: Date()),
                    options: nil,
                    terminal: false,
                    selectedOption: nil
                )
                state.messages.append(userMessage)

                return .run { send in
                    let request = MessageRequestDTO(
                        type: .option,
                        text: label,
                        value: value,
                        startRequest: false
                    )

                    let response = try await networkManager.requestNetwork(
                        dto: MessageResponseDTO.self,
                        router: ChatRouter.sendChat(request)
                    )

                    if let data = response.data {
                        await send(.sendMessageResponse(data))
                    }
                } catch: { error, send in
                    print(error)
                }

            default:
                break
            }

            return .none
        }
    }
}
