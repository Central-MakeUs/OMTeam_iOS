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
//        var todayMission: Mission? = nil // 미션 생성 여부(채팅으로 생성 등)
        var analysisData: String? = nil

        var characterLevel: Int = 0
        var experiencePercent: Int = 0
        var encouragementMessage: String = ""
        
        var dailyResults: [DailyMission] = []
    }
    
    enum Action {
        case onAppear
        case fetchCharacterResponse(CharacterDataDTO)
        case fetchWeeklyReportsResponse(WeeklyReportsDataDTO)
        case missionChatTapped
        case analysisDetailTapped

        case delegate(Delegate)

        enum Delegate {
            case switchToChatTab
            case switchToAnalysisTab
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
                        let calendar = Calendar.current
                        let today = Date()
                        guard let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else { return }

                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let weekStartDate = formatter.string(from: sunday)

                        let response = try await networkManager.requestNetwork(
                            dto: WeeklyReportsResponseDTO.self,
                            router: ReportRouter.fetchWeeklyReports(weekStartDate: weekStartDate)
                        )

                        if let data = response.data {
                            await send(.fetchWeeklyReportsResponse(data))
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

            case .missionChatTapped:
                return .send(.delegate(.switchToChatTab))

            case .analysisDetailTapped:
                return .send(.delegate(.switchToAnalysisTab))

            default:
                 break
            }

            return .none
        }
    }
}

