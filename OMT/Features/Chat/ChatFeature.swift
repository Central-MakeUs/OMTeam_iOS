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
        case missionRecommend
        case missionComplete
    }

    @ObservableState
    struct State: Equatable {
        var messages: [Message] = []
        var inputText: String = ""
        var isLoading: Bool = false
        var hasActiveSession: Bool = false
        var hasFetched: Bool = false

        // Mission Recommend Mode
        var mode: ChatMode = .regular
        var recommendations: [Recommendation] = []
        var selectedRecommendation: Recommendation? = nil
        var showStartMissionButton: Bool = false

        // Mission Complete Mode
        var currentMission: RecommendDTO? = nil
        var selectedResult: String? = nil  // "SUCCESS" or "FAIL"
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

        // Mission Recommend Mode Actions
        case enterMissionRecommendMode
        case exitMissionRecommendMode
        case fetchDailyRecommendResponse(DailyRecommendDataDTO)
        case recommendSelected(Recommendation)
        case startMissionTapped
        case startMissionResponse(StartMissionDataDTO)

        // Mission Complete Mode Actions
        case enterMissionCompleteMode(RecommendDTO)
        case resultSelected(String)  // "SUCCESS" or "FAIL"
        case backToHome
        case completeMissionResponse(CompleteMissionDataDTO)

        case delegate(Delegate)

        enum Delegate {
            case missionStarted
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

                return .run { send in
                    let request = MessageRequestDTO(
                        type: .text,
                        text: text,
                        value: "",
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
                        text: "",
                        value: label,
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

            // MARK: - Mission Recommend Mode

            case .enterMissionRecommendMode:
                state.mode = .missionRecommend
                state.recommendations = []
                state.selectedRecommendation = nil
                state.showStartMissionButton = false
                state.isLoading = true
                return .run { send in
                    let response = try await networkManager.requestNetwork(
                        dto: DailyRecommendResponseDTO.self,
                        router: MissionRouter.fetchDailyRecommend
                    )

                    if let data = response.data {
                        await send(.fetchDailyRecommendResponse(data))
                    }
                } catch: { error, send in
                    print(error)
                }

            case .exitMissionRecommendMode:
                state.mode = .regular
                state.recommendations = []
                state.selectedRecommendation = nil
                state.showStartMissionButton = false
                state.currentMission = nil
                state.selectedResult = nil

            case .fetchDailyRecommendResponse(let data):
                state.isLoading = false
                state.recommendations = data.recommendations.map { Recommendation.from($0) }

            case .recommendSelected(let recommendation):
                state.selectedRecommendation = recommendation
                state.showStartMissionButton = true

            case .startMissionTapped:
                guard let recommendation = state.selectedRecommendation else { return .none }
                state.isLoading = true
                let requestDTO = StartMissionRequestDTO(recommendedMissionId: recommendation.id)
                return .run { send in
                    let response = try await networkManager.requestNetwork(
                        dto: StartMissionResponseDTO.self,
                        router: MissionRouter.startMission(requestDTO)
                    )

                    if let data = response.data {
                        await send(.startMissionResponse(data))
                    }
                } catch: { error, send in
                    print(error)
                }

            case .startMissionResponse:
                state.isLoading = false
                state.mode = .regular
                state.recommendations = []
                state.selectedRecommendation = nil
                state.showStartMissionButton = false
                return .send(.delegate(.missionStarted))

            // MARK: - Mission Complete Mode

            case .enterMissionCompleteMode(let mission):
                state.mode = .missionComplete
                state.currentMission = mission
                state.selectedResult = nil

            case .resultSelected(let result):
                state.selectedResult = result
                
                state.isLoading = true
                let requestDTO = CompleteMissionRequestDTO(
                    result: result,
                    failureReason: result == "FAIL" ? "사용자 선택" : ""
                )
                return .run { send in
                    let response = try await networkManager.requestNetwork(
                        dto: CompleteMissionRepsonseDTO.self,
                        router: MissionRouter.completeMission(requestDTO)
                    )

                    if let data = response.data {
                        await send(.completeMissionResponse(data))
                    }
                } catch: { error, send in
                    print(error)
                }

            case .backToHome:
                return .send(.delegate(.missionCompleted))

            case .completeMissionResponse:
                state.isLoading = false
                state.mode = .regular
                state.currentMission = nil
                state.selectedResult = nil

            default:
                break
            }

            return .none
        }
    }
}
