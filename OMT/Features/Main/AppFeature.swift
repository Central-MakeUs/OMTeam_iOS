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
    struct State: Equatable {
        var currentView: ViewStatus = .login
        
        var login: LoginFeature.State
    }
    
    enum Action {
        case login(LoginFeature.Action)
    }
    
    enum ViewStatus: Hashable {
        case login
        case mainTab
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.login, action: \.login) {
            LoginFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .login(.delegate(.moveToOnBoarding)):
                return .none
                
            default:
                return .none
            }
        }
    }
}

extension AppFeature: Equatable {
    
}
