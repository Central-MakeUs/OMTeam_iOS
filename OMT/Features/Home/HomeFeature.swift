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
        
        var weeklyMissions: [WeeklyMission] = [
            WeeklyMission(status: .success),
            WeeklyMission(status: .success),
            WeeklyMission(status: .fail),
            WeeklyMission(status: .pending),
            WeeklyMission(status: .pending),
            WeeklyMission(status: .pending),
            WeeklyMission(status: .pending)
        ]
        
        var weekDates: [Date] {
            let calendar = Calendar.current
            let today = Date()
            
            // 이번 주 일요일
            guard let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
                return []
            }
            
            return (0..<7).compactMap { day in
                calendar.date(byAdding: .day, value: day, to: sunday)
            }
        }
    }
    
    enum Action {
        case onAppear
        case fetchCharacterResponse(CharacterDataDTO)
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
                return .run { send in
                    let response = try await networkManager.requestNetwork(
                        dto: CharacterResponseDTO.self,
                        router: CharacterRouter.fetchCharacter
                    )

                    if let data = response.data {
                        await send(.fetchCharacterResponse(data))
                    }
                } catch: { error, send in
                    print(error)
                }

            case .fetchCharacterResponse(let data):
                state.characterLevel = data.level
                state.experiencePercent = data.experiencePercent
                state.encouragementMessage = data.encouragementMessage

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

