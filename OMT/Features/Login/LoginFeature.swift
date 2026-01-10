//
//  LoginFeature.swift
//  OMT
//
//  Created by 이인호 on 1/11/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct LoginFeature {
    @ObservableState
    struct State: Equatable { }
    enum Action {
        case appleLoginTapped
        case kakaoLoginTapped
        case loginResponse(Result<String, Error>)
    }
    
    @Dependency(\.authentication) var authentication
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .appleLoginTapped:
                return .run { send in
                    await send(.loginResponse(Result {
                        try await authentication.appleLogin()
                    }))
                }
                
            case .kakaoLoginTapped:
                return .run { send in
                    await send(.loginResponse(Result {
                        try await authentication.kakaoLogin()
                    }))
                }

            case let .loginResponse(.success(token)):
                print("토큰: \(token)")
                return .none
                
            case .loginResponse(.failure):
                return .none
            }
        }
    }
}
