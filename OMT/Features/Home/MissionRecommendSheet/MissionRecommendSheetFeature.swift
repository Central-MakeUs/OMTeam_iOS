//
//  MissionRecommendSheetFeature.swift
//  OMT
//
//  Created by 이인호 on 2/9/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MissionRecommendSheetFeature {
    @ObservableState
    struct State: Equatable {
        var isLoading: Bool = false
        var recommendations: [RecommendDTO]
        var selectedRecommendation: RecommendDTO? = nil
        var errorMessage: String? = nil

        init(recommendations: [RecommendDTO]) {
            self.recommendations = recommendations
        }
    }

    enum Action {
        case recommendationSelected(RecommendDTO)
        case startMissionTapped
        case startMissionResponse(StartMissionDataDTO)
        case startMissionFailed(String)
        case refetchTapped
        case refetchResponse([RecommendDTO])
        case refetchFailed(String)
        case delegate(Delegate)

        enum Delegate {
            case missionStarted
        }
    }

    @Dependency(\.networkManager) var networkManager

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .recommendationSelected(let recommendation):
                state.selectedRecommendation = recommendation
                return .none

            case .startMissionTapped:
                guard let recommendation = state.selectedRecommendation else { return .none }
                state.isLoading = true
                let requestDTO = StartMissionRequestDTO(recommendedMissionId: recommendation.recommendedMissionId)
                return .run { send in
                    let response = try await networkManager.requestNetwork(
                        dto: StartMissionResponseDTO.self,
                        router: MissionRouter.startMission(requestDTO)
                    )
                    if let data = response.data {
                        await send(.startMissionResponse(data))
                    } else {
                        await send(.startMissionFailed("미션 시작에 실패했습니다."))
                    }
                } catch: { error, send in
                    await send(.startMissionFailed(error.localizedDescription))
                }

            case .startMissionResponse:
                state.isLoading = false
                return .send(.delegate(.missionStarted))

            case .startMissionFailed(let message):
                state.isLoading = false
                state.errorMessage = message
                return .none

            case .refetchTapped:
                state.isLoading = true
                state.selectedRecommendation = nil
                state.errorMessage = nil
                return .run { send in
                    let response = try await networkManager.requestNetwork(
                        dto: DailyRecommendResponseDTO.self,
                        router: MissionRouter.fetchDailyRecommend
                    )
                    if let data = response.data {
                        await send(.refetchResponse(data.recommendations))
                    } else {
                        await send(.refetchFailed("추천 미션을 불러오는데 실패했습니다."))
                    }
                } catch: { error, send in
                    await send(.refetchFailed(error.localizedDescription))
                }

            case .refetchResponse(let recommendations):
                state.isLoading = false
                state.recommendations = recommendations
                return .none

            case .refetchFailed(let message):
                state.isLoading = false
                state.errorMessage = message
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
