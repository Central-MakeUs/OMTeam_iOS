//
//  RootContainer.swift
//  OMT
//
//  Created by 이인호 on 1/11/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct RootContainer {
    @ObservableState
    struct State: Equatable {
        var currentView: ViewStatus = .login
        var selectedTab: Tab = .home
        
        var login = LoginFeature.State()
        var onboarding: OnboardingFeature.State?
        var home = HomeFeature.State()
    }
    
    enum Action {
        case login(LoginFeature.Action)
        case onboarding(OnboardingFeature.Action)
        case home(HomeFeature.Action)
    }
    
    enum ViewStatus: Hashable {
        case login
        case onboarding
        case home
    }
    
    enum Tab {
        case home, chat, analysis, myPage
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.login, action: \.login) {
            LoginFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .login(.delegate(.moveToOnBoarding)):
                state.currentView = .onboarding
                state.onboarding = OnboardingFeature.State()
                
            case .onboarding(.delegate(.onboardingCompleted)):
                state.currentView = .home
                state.onboarding = nil
                
            case .home(.delegate(.switchToChatTab)):
                state.selectedTab = .chat
                
            case .home(.delegate(.switchToAnalysisTab)):
                state.selectedTab = .analysis
                
            default:
                break
            }
            
            return .none
        }
        .ifLet(\.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
    }
}
