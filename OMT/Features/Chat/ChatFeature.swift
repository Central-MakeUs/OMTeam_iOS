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
    enum ChatMode: Equatable {
        case regular
        case missionComplete
    }

    @ObservableState
    struct State: Equatable {
        var messages: [Message] = []
        var inputText: String = ""
        var isLoading: Bool = false
        var hasActiveSession: Bool = false
        var hasFetched: Bool = false

        var mode: ChatMode = .regular
        var shouldFocusInput: Bool = false

        // Mission Complete Mode
        var currentMission: RecommendDTO? = nil
        var currentActionType: String? = nil  // Track current action type for requests
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
        case customInputOptionTapped

        // Mission Complete Mode Actions
        case sendCompleteMissionRequest(RecommendDTO)

        case delegate(Delegate)

        enum Delegate {
            case missionCompleted
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
                state.messages = data.messages
                    .sorted { $0.messageId < $1.messageId }
                    .enumerated()
                    .map { index, dto in
                        var message = Message.from(dto)
                        let isLastMessage = index == data.messages.count - 1
                        let isAssistantWithOptions = !message.isFromUser && message.options != nil
                        
                        // 마지막 메시지이면서 assistant가 보낸 옵션 메시지가 아니면 비활성화
                        if message.options != nil && !(isLastMessage && isAssistantWithOptions) {
                            message.selectedOption = "fetched"
                        }
                        return message
                    }

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

                let actionType = state.currentActionType

                // Clear actionType after text input for failure reason
                if state.currentActionType == "MISSION_FAILURE_REASON" {
                    state.currentActionType = nil
                }

                return .run { [networkManager] send in
                    let request = MessageRequestDTO(
                        actionType: actionType,
                        type: .text,
                        value: text
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

                // API응답에 따라 수정 필요
                if value == "GO_HOME" {
                    state.mode = .regular
                    state.currentMission = nil
                    state.currentActionType = nil
                    return .send(.delegate(.missionCompleted))
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

                let actionType = state.currentActionType

                // Update actionType based on selection
                if state.currentActionType == "COMPLETE_MISSION" && (value == "SUCCESS" || value == "FAILURE") {
                    if value == "FAILURE" {
                        state.currentActionType = "MISSION_FAILURE_REASON"
                    } else {
                        state.currentActionType = nil
                    }
                } else if state.currentActionType == "MISSION_FAILURE_REASON" {
                    state.currentActionType = nil
                }

                return .run { [networkManager] send in
                    let request = MessageRequestDTO(
                        actionType: actionType,
                        type: .option,
                        value: label,
                        optionValue: value
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

            case .customInputOptionTapped:
                // 옵션 버튼을 선택된 상태로 표시
                if let index = state.messages.lastIndex(where: { $0.options != nil && $0.selectedOption == nil }) {
                    state.messages[index].selectedOption = "custom_input"
                }
                state.shouldFocusInput = true
                return .none

            // MARK: - Mission Complete Mode
            case .sendCompleteMissionRequest(let mission):
                state.mode = .missionComplete
                state.currentMission = mission
                state.currentActionType = "COMPLETE_MISSION"
                state.isLoading = true
                let hasFetched = state.hasFetched
                return .run { [networkManager] send in
                    if !hasFetched {
                        let historyResponse = try await networkManager.requestNetwork(
                            dto: ChatResponseDTO.self,
                            router: ChatRouter.fetchChat()
                        )
                        if let data = historyResponse.data {
                            await send(.fetchChatResponse(data))
                        }
                    }

                    let request = MessageRequestDTO(actionType: "COMPLETE_MISSION")
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
