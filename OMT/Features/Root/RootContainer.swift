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
        var alertType: AlertType?

        var login = LoginFeature.State()
        var onboarding: OnboardingFeature.State?
        var home = HomeFeature.State()
        var chat = ChatFeature.State()
        var report = ReportFeature.State()
        var my = MyFeature.State()

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
        case my(MyFeature.Action)
        case tabSelected(Tab)
        case showAlert(AlertType)
        case alertCanceled
        case alertConfirmed
        case withdrawCompleted
    }
    
    enum ViewStatus: Hashable {
        case login
        case loginSuccess
        case onboarding
        case home
    }
    
    enum Tab {
        case home, chat, analysis, myPage
    }

    @Dependency(\.networkManager) var networkManager

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
        
        Scope(state: \.my, action: \.my) {
            MyFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .login(.delegate(.moveToHome)):
                state.currentView = .home
                state.selectedTab = .home
                state.onboarding = nil

            case .login(.delegate(.moveToLoginSuccess)):
                state.currentView = .loginSuccess

            case .login(.delegate(.moveToOnBoarding)):
                state.currentView = .onboarding
                state.onboarding = OnboardingFeature.State()

            case .onboarding(.delegate(.onboardingCompleted)):
                state.currentView = .home
                state.selectedTab = .home
                state.onboarding = nil

            case let .tabSelected(tab):
                state.selectedTab = tab

//            case .home(.delegate(.switchToChatTab)):
//                state.selectedTab = .chat

            case .home(.delegate(.switchToAnalysisTab)):
                state.selectedTab = .analysis

            case .my(.delegate(.showLogoutAlert)):
                state.alertType = .logout

            case .my(.delegate(.showWithdrawAlert)):
                state.alertType = .withdraw

            case let .showAlert(alertType):
                state.alertType = alertType

            case .alertCanceled:
                state.alertType = nil

            case .alertConfirmed:
                guard let alertType = state.alertType else { return .none }
                state.alertType = nil

                switch alertType {
                case .logout:
                    KeychainManager.shared.deleteTokens()
                    state.currentView = .login
                    state.my = MyFeature.State()
                    state.home = HomeFeature.State()
                    state.chat = ChatFeature.State()
                    state.report = ReportFeature.State()
                    
                case .withdraw:
                    return .run { [networkManager] send in
                        _ = try await networkManager.requestNetwork(
                            dto: WithdrawResponseDTO.self,
                            router: AuthRouter.withdraw
                        )
                        await send(.withdrawCompleted)
                    } catch: { error, _ in
                        print(error)
                    }
                    
                case .withdrawComplete:
                    KeychainManager.shared.deleteTokens()
                    state.currentView = .login
                    state.my = MyFeature.State()
                    state.home = HomeFeature.State()
                    state.chat = ChatFeature.State()
                    state.report = ReportFeature.State()
                }

            case .withdrawCompleted:
                state.alertType = .withdrawComplete

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
