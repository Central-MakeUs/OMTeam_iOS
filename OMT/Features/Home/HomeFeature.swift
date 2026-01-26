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
    }
    
    enum Action {
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

