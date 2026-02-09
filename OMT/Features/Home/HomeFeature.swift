//
//  HomeFeature.swift
//  OMT
//
//  Created by 이인호 on 1/21/26.
//

import Foundation
import ComposableArchitecture

struct User: Equatable {
     let id: String
     let nickname: String
     let hasPersonalSetting: Bool
 }

@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable {
        var user: User? = nil
        var totalSuccessCount: Int = 0
        var thisWeekSuccessRate: Double = 0.0
        var overallFeedback: String = ""

        var characterLevel: Int = 0
        var experiencePercent: Int = 0
        var encouragementMessage: String = ""

        var dailyResults: [DailyMission] = []

        // Mission Status
        var hasActiveMission: Bool = false
        var hasCompletedMission: Bool = false
        var activeMission: RecommendDTO? = nil
        var completeMission: CompleteMissionDataDTO? = nil

        // Mission Recommend Sheet
        var isLoadingRecommendations: Bool = false
        @Presents var missionRecommendSheet: MissionRecommendSheetFeature.State?
    }

    enum Action {
        case onAppear
        case fetchCharacterResponse(CharacterDataDTO)
        case fetchWeeklyReportsResponse(WeeklyReportsDataDTO)
        case missionRecommendTapped
        case fetchRecommendationsResponse([RecommendDTO])
        case fetchRecommendationsFailed
        case missionCompleteTapped
        case analysisDetailTapped

        // Mission Status
        case refreshMissionStatus
        case fetchMissionStatusResponse(MissionStatusDataDTO)

        // Mission Recommend Sheet
        case missionRecommendSheet(PresentationAction<MissionRecommendSheetFeature.Action>)

        case delegate(Delegate)

        enum Delegate {
            case switchToAnalysisTab
            case switchToCompleteMode(RecommendDTO)
        }
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .run { send in
                        let response = try await networkManager.requestNetwork(
                            dto: CharacterResponseDTO.self,
                            router: CharacterRouter.fetchCharacter
                        )

                        if let data = response.data {
                            await send(.fetchCharacterResponse(data))
                        }
                    } catch: { error, send in
                        print(error)
                    },
                    .run { [networkManager] send in
                        let calendar = Calendar.mondayFirst
                        let today = Date()
                        let (year, month, weekOfMonth) = calendar.weekInfoFromFirstMonday(for: today)

                        let response = try await networkManager.requestNetwork(
                            dto: WeeklyReportsResponseDTO.self,
                            router: ReportRouter.fetchWeeklyReports(year: year, month: month, weekOfMonth: weekOfMonth)
                        )

                        if let data = response.data {
                            await send(.fetchWeeklyReportsResponse(data))
                        }
                    } catch: { error, send in
                        print(error)
                    },
                    .run { [networkManager] send in
                        let response = try await networkManager.requestNetwork(
                            dto: MissionStatusResponseDTO.self,
                            router: MissionRouter.dailyMissionStatus
                        )

                        if let data = response.data {
                            await send(.fetchMissionStatusResponse(data))
                        }
                    } catch: { error, send in
                        print(error)
                    }
                )

            case .fetchCharacterResponse(let data):
                state.characterLevel = data.level
                state.experiencePercent = data.experiencePercent
                state.encouragementMessage = data.encouragementMessage

            case .fetchWeeklyReportsResponse(let data):
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"

                guard let startDate = formatter.date(from: data.weekStartDate),
                      let endDate = formatter.date(from: data.weekEndDate) else { break }

                let resultsByDate = Dictionary(
                    uniqueKeysWithValues: data.dailyResults.map { ($0.date, $0) }
                )

                let calendar = Calendar.current
                var missions: [DailyMission] = []
                var current = startDate

                while current <= endDate {
                    let key = formatter.string(from: current)
                    if let dto = resultsByDate[key] {
                        missions.append(DailyMission.from(dto))
                    } else {
                        missions.append(DailyMission.notPerformed(date: current))
                    }
                    guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
                    current = next
                }

                state.dailyResults = missions
                state.totalSuccessCount = data.thisWeekSuccessCount
                state.thisWeekSuccessRate = data.thisWeekSuccessRate
                state.overallFeedback = data.aiFeedback.weeklyFeedback ?? ""

            case .missionRecommendTapped:
                state.isLoadingRecommendations = true
                return .run { [networkManager] send in
                    let response = try await networkManager.requestNetwork(
                        dto: DailyRecommendResponseDTO.self,
                        router: MissionRouter.fetchDailyRecommend
                    )
                    if let data = response.data {
                        await send(.fetchRecommendationsResponse(data.recommendations))
                    } else {
                        await send(.fetchRecommendationsFailed)
                    }
                } catch: { error, send in
                    print(error)
                    await send(.fetchRecommendationsFailed)
                }

            case .fetchRecommendationsResponse(let recommendations):
                state.isLoadingRecommendations = false
                state.missionRecommendSheet = MissionRecommendSheetFeature.State(recommendations: recommendations)
                return .none

            case .fetchRecommendationsFailed:
                state.isLoadingRecommendations = false
                return .none

            case .missionCompleteTapped:
                guard let mission = state.activeMission else { return .none }
                return .send(.delegate(.switchToCompleteMode(mission)))

            case .analysisDetailTapped:
                return .send(.delegate(.switchToAnalysisTab))

            case .refreshMissionStatus:
                return .run { [networkManager] send in
                    let response = try await networkManager.requestNetwork(
                        dto: MissionStatusResponseDTO.self,
                        router: MissionRouter.dailyMissionStatus
                    )

                    if let data = response.data {
                        await send(.fetchMissionStatusResponse(data))
                    }
                } catch: { error, send in
                    print(error)
                }

            case .fetchMissionStatusResponse(let data):
                state.hasActiveMission = data.hasInProgressMission
                state.hasCompletedMission = data.hasCompletedMission

                if data.hasInProgressMission {
                    state.activeMission = data.currentMission
                } else {
                    state.completeMission = data.missionResult
                }

            case .missionRecommendSheet(.presented(.delegate(.missionStarted))):
                state.missionRecommendSheet = nil
                return .send(.refreshMissionStatus)

            case .missionRecommendSheet:
                break

            case .delegate:
                break
            }

            return .none
        }
        .ifLet(\.$missionRecommendSheet, action: \.missionRecommendSheet) {
            MissionRecommendSheetFeature()
        }
    }
}

