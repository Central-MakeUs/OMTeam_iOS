//
//  AppFeature.swift
//  OMT
//
//  Created by 이인호 on 1/11/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    enum State: Equatable {
        case login(LoginFeature.State)
    }
    
    enum Action {
        case login(LoginFeature.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.login, action: \.login) {
            LoginFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .login(.loginResponse(.success)):
                return .none
            default:
                return .none
            }
        }
    }
}
