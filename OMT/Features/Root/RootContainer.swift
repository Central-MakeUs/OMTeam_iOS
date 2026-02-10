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
        var showSplash = true
        var currentView: ViewStatus
        var selectedTab: Tab = .home
        var alertType: AlertType?

        var login = LoginFeature.State()
        var onboarding: OnboardingFeature.State?
        var home = HomeFeature.State()
        var chat = ChatFeature.State()
        var report = ReportFeature.State()
        var my = MyFeature.State()

        var isLoggedIn: Bool {
            KeychainManager.shared.refreshToken != nil
        }

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
        case splashAppeared
        case splashCompleted
        case splashDataFetched(CharacterDataDTO?, WeeklyReportsDataDTO?, MissionStatusDataDTO?)
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

            case let .home(.delegate(.switchToCompleteMode(mission))):
                state.selectedTab = .chat
                state.chat.mode = .missionComplete
                state.chat.currentMission = mission
                state.chat.currentActionType = "COMPLETE_MISSION"
                return .send(.chat(.sendCompleteMissionRequest))

            case .chat(.delegate(.missionCompleted)):
                state.selectedTab = .home
                state.chat.mode = .regular
                return .send(.home(.refreshMissionStatus))

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

            case .splashAppeared:
                let isLoggedIn = state.isLoggedIn
                return .run { [networkManager] send in
                    let startTime = Date()

                    if isLoggedIn {
                        let calendar = Calendar.mondayFirst
                        let today = Date()
                        let (year, month, weekOfMonth) = calendar.weekInfoFromFirstMonday(for: today)

                        async let characterResponse = try? networkManager.requestNetwork(
                            dto: CharacterResponseDTO.self,
                            router: CharacterRouter.fetchCharacter
                        )
                        async let weeklyResponse = try? networkManager.requestNetwork(
                            dto: WeeklyReportsResponseDTO.self,
                            router: ReportRouter.fetchWeeklyReports(year: year, month: month, weekOfMonth: weekOfMonth)
                        )
                        async let missionResponse = try? networkManager.requestNetwork(
                            dto: MissionStatusResponseDTO.self,
                            router: MissionRouter.dailyMissionStatus
                        )

                        let (character, weekly, mission) = await (characterResponse, weeklyResponse, missionResponse)
                        await send(.splashDataFetched(character?.data, weekly?.data, mission?.data))
                    }

                    let elapsed = Date().timeIntervalSince(startTime)
                    let remaining = max(0, 1.5 - elapsed)

                    if remaining > 0 {
                        try? await Task.sleep(for: .seconds(remaining))
                    }

                    await send(.splashCompleted)
                }

            case .splashCompleted:
                state.showSplash = false

            case let .splashDataFetched(character, weekly, mission):
                if let character {
                    state.home.characterLevel = character.level
                    state.home.experiencePercent = character.experiencePercent
                    state.home.encouragementMessage = character.encouragementMessage
                }
                if let weekly {
                    state.home.thisWeekSuccessRate = weekly.thisWeekSuccessRate
                }
                if let mission {
                    state.home.hasActiveMission = mission.hasInProgressMission
                    state.home.hasCompletedMission = mission.hasCompletedMission
                    if mission.hasInProgressMission {
                        state.home.activeMission = mission.currentMission
                    }
                    if mission.hasCompletedMission {
                        state.home.completeMission = mission.missionResult
                    }
                }

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
