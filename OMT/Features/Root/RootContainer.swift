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
        var currentView: ViewStatus
        var selectedTab: Tab = .home
        
        var login = LoginFeature.State()
        var onboarding: OnboardingFeature.State?
        var home = HomeFeature.State()
        var chat = ChatFeature.State()
        var report = ReportFeature.State()
        
        init() {
            if KeychainManager.shared.refreshToken != nil {
                self.currentView = .home
            } else {
                self.currentView = .login
            }
        }
    }
    
    enum Action {
        case login(LoginFeature.Action)
        case onboarding(OnboardingFeature.Action)
        case home(HomeFeature.Action)
        case chat(ChatFeature.Action)
        case report(ReportFeature.Action)
        case tabSelected(Tab)
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
        
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        
        Scope(state: \.chat, action: \.chat) {
            ChatFeature()
        }
        
        Scope(state: \.report, action: \.report) {
            ReportFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .login(.delegate(.moveToHome)):
                state.currentView = .home
                state.selectedTab = .home
                state.onboarding = nil
                
            case .login(.delegate(.moveToOnBoarding)):
                state.currentView = .onboarding
                state.onboarding = OnboardingFeature.State()
                
            case .onboarding(.delegate(.onboardingCompleted)):
                state.currentView = .home
                state.selectedTab = .home
                state.onboarding = nil
                
            case let .tabSelected(tab):
                state.selectedTab = tab
                
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
